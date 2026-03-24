import 'package:authentication_repository/authentication_repository.dart';
import 'package:club_repository/club_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<IAccountEvent, AccountState> {
  final IAuthenticationRepository _authRepository;
  final IClubRepository _clubRepository;

  AccountBloc({
    required IAuthenticationRepository authRepository,
    required IClubRepository clubRepository,
  })  : _authRepository = authRepository,
        _clubRepository = clubRepository,
        super(const AccountState.initial()) {
    on<GetAccountDataRequired>(_onGetAccountDataRequired);
  }

  Future<void> _onGetAccountDataRequired(
      GetAccountDataRequired event, Emitter<AccountState> emit) async {
    emit(const AccountState.loading());

    final userResponse = await _authRepository.getUserData(userId: event.userId);
    final clubsResponse = await _clubRepository.getAllClubs(uuid: event.userId);

    userResponse.when(
      (userSuccess) {
        clubsResponse.when(
          (clubsSuccess) => emit(AccountState.success(user: userSuccess, clubs: clubsSuccess)),
          (clubsFailure) => emit(AccountState.failure(message: clubsFailure.message)),
        );
      },
      (userFailure) => emit(AccountState.failure(message: userFailure.message)),
    );
  }
}
