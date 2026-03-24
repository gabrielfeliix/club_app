import 'package:attendance_repository/attendance_repository.dart';
import 'package:decision_repository/decision_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

part 'reports_event.dart';
part 'reports_state.dart';

class ReportsBloc extends Bloc<IReportsEvent, ReportsBlocState> {
  final IAttendanceRepository _attendanceRepository;
  final IDecisionRepository _decisionRepository;

  ReportsBloc({
    required IAttendanceRepository attendanceRepository,
    required IDecisionRepository decisionRepository,
  })  : _attendanceRepository = attendanceRepository,
        _decisionRepository = decisionRepository,
        super(const ReportsBlocState.initial()) {
    on<LoadReportsRequired>(_onLoadReportsRequired);
  }

  Future<void> _onLoadReportsRequired(
      LoadReportsRequired event, Emitter<ReportsBlocState> emit) async {
    emit(const ReportsBlocState.loading());

    final kidsResult = await _attendanceRepository.getChildrenBasic(clubId: event.clubId);
    final attendancesResult = await _attendanceRepository.getClubAttendancesBasic(clubId: event.clubId);
    final decisionsResult = await _decisionRepository.getDecisions(clubId: event.clubId);

    final kids = kidsResult.when((s) => s, (e) => <KidsModel>[]);
    final attendances = attendancesResult.when((s) => s, (e) => <AttendanceModel>[]);
    final decisions = decisionsResult.when((s) => s, (e) => <DecisionModel>[]);

    final int totalSessions = attendances.length;

    // Build chart data up to the last 7 sessions, reversed for chronological order (left to right)
    final chartData = attendances.take(7).toList().reversed.map((att) {
      final totalPresent = att.attendanceList.where((rec) => rec.present).length;
      return SessionChartData(date: att.date, totalPresent: totalPresent);
    }).toList();

    // Map the kids logic
    final kidsStats = kids.map((kid) {
      int presences = 0;
      for (var session in attendances) {
        final record = session.attendanceList.firstWhere(
            (rec) => rec.kidId == kid.id,
            orElse: () => AttendanceItem(kidId: kid.id, present: false),
        );
        if (record.present) presences++;
      }
      return KidAttendanceStats(
          kid: kid,
          totalPresences: presences,
          totalSessions: totalSessions,
      );
    }).toList();

    // Sort by presence from Highest to Lowest
    kidsStats.sort((a, b) => b.totalPresences.compareTo(a.totalPresences));

    // Decisions Chart Data: Group by month for the last 6 months
    final now = DateTime.now();
    final Map<String, int> monthlyDecisions = {};
    for (int i = 2; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final key = DateFormat('yyyy-MM').format(monthDate);
      monthlyDecisions[key] = 0;
    }

    for (var decision in decisions) {
      final key = DateFormat('yyyy-MM').format(decision.decisionDate);
      if (monthlyDecisions.containsKey(key)) {
        monthlyDecisions[key] = monthlyDecisions[key]! + 1;
      }
    }

    final decisionChartData = monthlyDecisions.entries.map((e) {
      return SessionChartData(date: e.key, totalPresent: e.value);
    }).toList();

    emit(ReportsBlocState.success(
      chartData: chartData,
      kidsStats: kidsStats,
      decisionChartData: decisionChartData,
      recentDecisions: decisions.take(5).toList(),
    ));
  }
}
