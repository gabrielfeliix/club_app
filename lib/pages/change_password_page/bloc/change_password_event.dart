part of 'change_password_bloc.dart';

abstract class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();

  @override
  List<Object> get props => [];
}

class ChangePasswordChanged extends ChangePasswordEvent {
  const ChangePasswordChanged(this.password, this.confirmPassword);
  final String password;
  final String confirmPassword;

  @override
  List<Object> get props => [password, confirmPassword];
}

class ChangePasswordConfirmChanged extends ChangePasswordEvent {
  const ChangePasswordConfirmChanged(this.password, this.confirmPassword);
  final String password;
  final String confirmPassword;

  @override
  List<Object> get props => [password, confirmPassword];
}

class ChangePasswordObscureToggled extends ChangePasswordEvent {}

class ChangePasswordSecondObscureToggled extends ChangePasswordEvent {}

class ChangePasswordSubmitted extends ChangePasswordEvent {}
