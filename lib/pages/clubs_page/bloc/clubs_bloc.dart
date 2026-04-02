import 'dart:developer';
import 'package:app_ui/app_ui.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:club_app/utils/constants.dart';
import 'package:club_repository/club_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'clubs_event.dart';
part 'clubs_state.dart';

class ClubsBloc extends Bloc<IClubsEvent, ClubsBlocState> {
  final IClubRepository _clubRepository;
  final IAuthenticationRepository _authRepository;

  ClubsBloc({
    required IClubRepository clubRepository,
    required IAuthenticationRepository authRepository,
  })  : _clubRepository = clubRepository,
        _authRepository = authRepository,
        super(const ClubsBlocState.initial()) {
    on<GetClubsRequired>(_onGetClubsRequired);
    on<AddClubRequired>(_onAddClubRequired);
  }

  Future<void> _onGetClubsRequired(
      GetClubsRequired event, Emitter<ClubsBlocState> emit) async {
    emit(const ClubsBlocState.loading());

    final cachedUser =
        CacheClient.read<AuthUserModel>(key: AppConstants.userCacheKey);

    if (cachedUser == null) {
      emit(const ClubsBlocState.failure(
          message: 'Usuário não autenticado no cache.'));
      return;
    }

    // BUSCA DADOS FRESCOS (Sincronização de permissões)
    final userResult =
        await _authRepository.getUserData(userId: cachedUser.userId);

    log('DEBUG: ClubsBloc fresh user fetch: $userResult');

    final List<String> allowedClubIds;
    final bool isAdmin;

    final freshUser = userResult.when((s) => s, (e) => null);

    if (freshUser != null) {
      allowedClubIds = freshUser.classIds;
      isAdmin = freshUser.userRole == UserRole.admin;
      
      log('DEBUG: ClubsBloc Fresh User: ${freshUser.userRole}, classIds: $allowedClubIds');

      // Atualiza o cache para outras partes do app
      CacheClient.write<AuthUserModel>(
        key: AppConstants.userCacheKey,
        value: cachedUser.copyWith(
          classIds: allowedClubIds,
          userRole: freshUser.userRole,
        ),
      );
    } else {
      log('DEBUG: ClubsBloc fresh fetch failed. Using Cache.');
      allowedClubIds = cachedUser.classIds;
      isAdmin = cachedUser.userRole == UserRole.admin;
    }

    log('DEBUG: ClubsBloc final filter: $allowedClubIds (isAdmin: $isAdmin)');

    final response = await _clubRepository.getAllClubs(
      uuid: cachedUser.userId,
      clubIds: isAdmin ? null : allowedClubIds,
    );

    log('DEBUG: ClubsBloc response: $response');

    response.when(
      (success) async {
        // --- SELF-HEALING SYNC LOGIC ---
        if (!isAdmin && success.isNotEmpty) {
          final fetchedIds = success.map((c) => c.id).toList();
          
          // Verifica se há algum ID no banco que não está no perfil do usuário
          final missingIds = fetchedIds.where((id) => !allowedClubIds.contains(id)).toList();
          
          if (missingIds.isNotEmpty) {
            log('DEBUG: Self-healing triggered. Missing IDs: $missingIds');
            final updatedIds = {...allowedClubIds, ...fetchedIds}.toList();
            
            // O próprio usuário atualiza seu perfil (Bypass RLS)
            await _authRepository.updateClassIds(
              userId: cachedUser.userId,
              classIds: updatedIds,
            );
            
            // Atualiza o cache local para refletir a mudança imediatamente
            CacheClient.write<AuthUserModel>(
              key: AppConstants.userCacheKey,
              value: cachedUser.copyWith(classIds: updatedIds),
            );
          }
        }
        // ------------------------------

        emit(
          success.isNotEmpty
              ? ClubsBlocState.loaded(clubs: success)
              : const ClubsBlocState.empty(),
        );
      },
      (failure) => emit(
        ClubsBlocState.failure(message: failure.message),
      ),
    );
  }

  Future<void> _onAddClubRequired(
      AddClubRequired event, Emitter<ClubsBlocState> emit) async {
    emit(const ClubsBlocState.loading());

    final response = await _clubRepository.createClub(
      name: event.name.trim(),
      address: event.address.trim(),
    );

    response.when(
      (success) => emit(ClubsBlocState.successCreate(message: success)),
      (failure) => emit(
        ClubsBlocState.failure(message: failure.message),
      ),
    );
  }


}
