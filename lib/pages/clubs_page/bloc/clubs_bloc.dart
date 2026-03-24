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

  ClubsBloc({required IClubRepository clubRepository})
      : _clubRepository = clubRepository,
        super(const ClubsBlocState.initial()) {
    on<GetClubsRequired>(_onGetClubsRequired);
    on<AddClubRequired>(_onAddClubRequired);
  }

  Future<void> _onGetClubsRequired(
      GetClubsRequired event, Emitter<ClubsBlocState> emit) async {
    emit(const ClubsBlocState.loading());

    final userId =
        CacheClient.read<AuthUserModel>(key: AppConstants.userCacheKey)!.userId;
    final response = await _clubRepository.getAllClubs(uuid: userId);

    response.when(
      (success) => emit(
        success.isNotEmpty
            ? ClubsBlocState.loaded(clubs: success)
            : const ClubsBlocState.empty(),
      ),
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
