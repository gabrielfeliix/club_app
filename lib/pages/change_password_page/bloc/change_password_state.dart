part of 'change_password_bloc.dart';

class ChangePasswordState extends Equatable {
  const ChangePasswordState({
    this.password = const Password.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
    this.obscure = true,
    this.secondObscure = true,
    this.lowercase = false,
    this.uppercase = false,
    this.atLeast8 = false,
  });

  final Password password;
  final ConfirmedPassword confirmedPassword;
  final FormzSubmissionStatus status;
  final String? errorMessage;
  final bool obscure;
  final bool secondObscure;
  final bool lowercase;
  final bool uppercase;
  final bool atLeast8;

  ChangePasswordState copyWith({
    Password? password,
    ConfirmedPassword? confirmedPassword,
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool? obscure,
    bool? secondObscure,
    bool? lowercase,
    bool? uppercase,
    bool? atLeast8,
  }) {
    return ChangePasswordState(
      password: password ?? this.password,
      confirmedPassword: confirmedPassword ?? this.confirmedPassword,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      obscure: obscure ?? this.obscure,
      secondObscure: secondObscure ?? this.secondObscure,
      lowercase: lowercase ?? this.lowercase,
      uppercase: uppercase ?? this.uppercase,
      atLeast8: atLeast8 ?? this.atLeast8,
    );
  }

  @override
  List<Object?> get props => [
        password,
        confirmedPassword,
        status,
        errorMessage,
        obscure,
        secondObscure,
        lowercase,
        uppercase,
        atLeast8,
      ];
}
