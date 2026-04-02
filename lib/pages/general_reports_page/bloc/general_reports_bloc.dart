import 'dart:developer';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:club_app/utils/constants.dart';
import 'package:attendance_repository/attendance_repository.dart' as att;
import 'package:club_repository/club_repository.dart';
import 'package:decision_repository/decision_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

part 'general_reports_event.dart';
part 'general_reports_state.dart';

class GeneralReportsBloc extends Bloc<GeneralReportsEvent, GeneralReportsState> {
  final IClubRepository _clubRepository;
  final att.IAttendanceRepository _attendanceRepository;
  final IDecisionRepository _decisionRepository;
  final IAuthenticationRepository _authRepository;

  GeneralReportsBloc({
    required IClubRepository clubRepository,
    required att.IAttendanceRepository attendanceRepository,
    required IDecisionRepository decisionRepository,
    required IAuthenticationRepository authRepository,
  })  : _clubRepository = clubRepository,
        _attendanceRepository = attendanceRepository,
        _decisionRepository = decisionRepository,
        _authRepository = authRepository,
        super(const GeneralReportsState.initial()) {
    on<LoadGeneralReportsRequired>(_onLoadGeneralReportsRequired);
  }

  Future<void> _onLoadGeneralReportsRequired(
    LoadGeneralReportsRequired event,
    Emitter<GeneralReportsState> emit,
  ) async {
    emit(const GeneralReportsState.loading());

    try {
      final cachedUser =
          CacheClient.read<AuthUserModel>(key: AppConstants.userCacheKey);
      
      if (cachedUser == null) {
        emit(const GeneralReportsState.failure('Usuário não autenticado.'));
        return;
      }

      // BUSCA DADOS FRESCOS DO BANCO (Sincronização de permissões)
      final userResult = await _authRepository.getUserData(userId: cachedUser.userId);
      
      final freshUser = userResult.when((s) => s, (e) => null);
      
      final bool isAdmin;
      final List<String> allowedClubIds;

      if (freshUser != null) {
        isAdmin = freshUser.userRole == UserRole.admin;
        allowedClubIds = freshUser.classIds;

        log('DEBUG: Fresh fetch success. Role: ${freshUser.userRole}, ClubIds: $allowedClubIds');

        // Atualiza o cache para outras partes do app
        CacheClient.write<AuthUserModel>(
          key: AppConstants.userCacheKey,
          value: cachedUser.copyWith(
            userRole: freshUser.userRole,
            classIds: freshUser.classIds,
          ),
        );
      } else {
        log('DEBUG: Fresh fetch failed or returned null. Using Cache.');
        // Fallback para o cache se a requisição de perfil falhar
        isAdmin = cachedUser.userRole == UserRole.admin;
        allowedClubIds = cachedUser.classIds;
      }

      final clubIdsFilter = isAdmin ? null : allowedClubIds;
      log('DEBUG: Final clubIdsFilter applied to repos: $clubIdsFilter');

      final clubsResult = await _clubRepository.getAllClubs(
        uuid: cachedUser.userId,
        clubIds: clubIdsFilter,
      );
      log('DEBUG: clubsResult: $clubsResult');

      // --- SELF-HEALING SYNC LOGIC ---
      List<String> finalClubIds = clubIdsFilter ?? [];
      
      if (!isAdmin) {
        final fetchedClubs = clubsResult.when((s) => s, (e) => <ClubModel>[]);
        if (fetchedClubs.isNotEmpty) {
          final fetchedIds = fetchedClubs.map((c) => c.id).toList();
          final missingIds = fetchedIds.where((id) => !allowedClubIds.contains(id)).toList();
          
          if (missingIds.isNotEmpty) {
            log('DEBUG: GeneralReports self-healing triggered. Missing IDs: $missingIds');
            final updatedIds = {...allowedClubIds, ...fetchedIds}.toList();
            
            // O próprio usuário atualiza seu perfil (Bypass RLS)
            await _authRepository.updateClassIds(
              userId: cachedUser.userId,
              classIds: updatedIds,
            );
            
            // Atualiza o cache local
            CacheClient.write<AuthUserModel>(
              key: AppConstants.userCacheKey,
              value: cachedUser.copyWith(classIds: updatedIds),
            );
            
            finalClubIds = updatedIds;
          }
        }
      }
      // ------------------------------

      final kidsResult = await _attendanceRepository.getAllChildrenGlobal(
        clubIds: isAdmin ? null : finalClubIds,
      );
      log('DEBUG: kidsResult: $kidsResult');

      final attendancesResult =
          await _attendanceRepository.getAllAttendancesGlobal(
        clubIds: isAdmin ? null : finalClubIds,
      );
      log('DEBUG: attendancesResult: $attendancesResult');

      final decisionsResult = await _decisionRepository.getAllDecisionsGlobal(
        clubIds: isAdmin ? null : finalClubIds,
      );
      log('DEBUG: decisionsResult: $decisionsResult');

      final clubs = clubsResult.when((s) => s, (e) => <ClubModel>[]);
      final allKids = kidsResult.when((s) => s, (e) => <att.KidsModel>[]);
      final allAttendances =
          attendancesResult.when((s) => s, (e) => <att.AttendanceModel>[]);
      final allDecisions =
          decisionsResult.when((s) => s, (e) => <DecisionModel>[]);

      if (clubs.isEmpty) {
        emit(const GeneralReportsState.success(
          totalKids: 0,
          totalDecisions: 0,
          globalRetentionRate: 0,
          kidsGrowth: [],
          decisionsGrowth: [],
          clubsSummaries: [],
        ));
        return;
      }

      final totalKids = allKids.length;
      final totalDecisions = allDecisions.length;

      double globalRetention = 0;
      if (allKids.isNotEmpty && allAttendances.isNotEmpty) {
        int totalPresences = 0;
        for (var session in allAttendances) {
          totalPresences += session.attendanceList.where((r) => r.present).length;
        }
        globalRetention = totalPresences / (allAttendances.length * allKids.length);
      }

      final kidsGrowth = _calculateGrowth(allKids.map((k) => k.createdAt ?? DateTime.now()).toList());
      final decisionsGrowth = _calculateGrowth(allDecisions.map((d) => d.decisionDate).toList());

      final List<ClubSummary> summaries = [];
      for (var club in clubs) {
        final clubKids = allKids.where((k) => k.clubId == club.id).toList();
        final clubDecisions = allDecisions.where((d) => d.clubId == club.id).toList();
        final clubAttendances = allAttendances.where((a) => a.clubId == club.id).toList();

        double clubRetention = 0;
        if (clubKids.isNotEmpty && clubAttendances.isNotEmpty) {
          int presences = 0;
          for (var session in clubAttendances) {
            presences += session.attendanceList.where((r) => r.present).length;
          }
          clubRetention = presences / (clubAttendances.length * clubKids.length);
        }

        Trend trend = Trend.stable;
        if (clubAttendances.length >= 4) {
          final recent = clubAttendances.take(2).toList();
          final previous = clubAttendances.skip(2).take(2).toList();
          
          final recentCount = recent.expand((a) => a.attendanceList).where((r) => r.present).length;
          final previousCount = previous.expand((a) => a.attendanceList).where((r) => r.present).length;

          if (recentCount > previousCount) trend = Trend.up;
          else if (recentCount < previousCount) trend = Trend.down;
        }

        summaries.add(ClubSummary(
          id: club.id,
          name: club.name,
          kidsCount: clubKids.length,
          decisionsCount: clubDecisions.length,
          retentionRate: clubRetention,
          trend: trend,
        ));
      }

      emit(GeneralReportsState.success(
        totalKids: totalKids,
        totalDecisions: totalDecisions,
        globalRetentionRate: globalRetention,
        kidsGrowth: kidsGrowth,
        decisionsGrowth: decisionsGrowth,
        clubsSummaries: summaries,
      ));
    } catch (e) {
      emit(GeneralReportsState.failure(e.toString()));
    }
  }

  List<GrowthData> _calculateGrowth(List<DateTime> dates) {
    if (dates.isEmpty) return [];
    final now = DateTime.now();
    final Map<String, int> monthly = {};
    for (int i = 2; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final key = DateFormat('yyyy-MM').format(monthDate);
      monthly[key] = 0;
    }

    for (var date in dates) {
      final key = DateFormat('yyyy-MM').format(date);
      if (monthly.containsKey(key)) {
        monthly[key] = monthly[key]! + 1;
      }
    }

    int total = 0;
    return monthly.entries.map((e) {
      total += e.value;
      return GrowthData(period: e.key, count: total);
    }).toList();
  }
}
