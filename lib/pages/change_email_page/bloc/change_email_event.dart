part of 'change_email_bloc.dart';

abstract class ChangeEmailEvent extends Equatable {
  const ChangeEmailEvent();

  @override
  List<Object> get props => [];
}

class ChangeEmailChanged extends ChangeEmailEvent {
  const ChangeEmailChanged(this.email);
  final String email;

  @override
  List<Object> get props => [email];
}

class ChangeEmailSubmitted extends ChangeEmailEvent {}
