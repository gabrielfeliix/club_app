part of 'account_bloc.dart';

enum AccountStatus {
  initial,
  loading,
  loaded,
  failure,
}

class AccountState extends Equatable {
  final AccountStatus status;
  final String? message;
  final UsersModel? user;
  final List<ClubModel>? clubs;

  const AccountState._({
    this.status = AccountStatus.loading,
    this.message,
    this.user,
    this.clubs,
  });

  const AccountState.initial() : this._(status: AccountStatus.initial);

  const AccountState.failure({required String message})
      : this._(status: AccountStatus.failure, message: message);

  const AccountState.success({required UsersModel user, required List<ClubModel> clubs})
      : this._(status: AccountStatus.loaded, user: user, clubs: clubs);

  const AccountState.loading() : this._();

  @override
  List<Object?> get props => [status, message, user, clubs];
}

extension AccountStateExtensions on AccountState {
  bool get isInitial => status == AccountStatus.initial;
  bool get isLoading => status == AccountStatus.loading;
  bool get isLoaded => status == AccountStatus.loaded;
  bool get isFailure => status == AccountStatus.failure;
}
