part of 'change_email_bloc.dart';

class ChangeEmailState extends Equatable {
  const ChangeEmailState({
    this.email = const Email.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final Email email;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  ChangeEmailState copyWith({
    Email? email,
    FormzSubmissionStatus? status,
    String? errorMessage,
  }) {
    return ChangeEmailState(
      email: email ?? this.email,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, status, errorMessage];
}
