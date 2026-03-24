import 'package:app_ui/app_ui.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'change_password_event.dart';
part 'change_password_state.dart';

class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordBloc({
    required IAuthenticationRepository authRepository,
  })  : _authRepository = authRepository,
        super(const ChangePasswordState()) {
    on<ChangePasswordChanged>(_onPasswordChanged);
    on<ChangePasswordConfirmChanged>(_onConfirmChanged);
    on<ChangePasswordObscureToggled>(_onObscureToggled);
    on<ChangePasswordSecondObscureToggled>(_onSecondObscureToggled);
    on<ChangePasswordSubmitted>(_onSubmitted);
  }

  final IAuthenticationRepository _authRepository;

  void _onPasswordChanged(
    ChangePasswordChanged event,
    Emitter<ChangePasswordState> emit,
  ) {
    final password = Password.dirty(event.password);
    final confirm = ConfirmedPassword.dirty(
      password: event.password,
      value: event.confirmPassword,
    );
    final val = event.password;
    emit(state.copyWith(
      password: password,
      confirmedPassword: confirm,
      status: FormzSubmissionStatus.initial,
      lowercase: val.contains(RegExp(r'[a-z]')),
      uppercase: val.contains(RegExp(r'[A-Z]')),
      atLeast8: val.length >= 8,
    ));
  }

  void _onConfirmChanged(
    ChangePasswordConfirmChanged event,
    Emitter<ChangePasswordState> emit,
  ) {
    final password = Password.dirty(event.password);
    final confirm = ConfirmedPassword.dirty(
      password: event.password,
      value: event.confirmPassword,
    );
    emit(state.copyWith(
      password: password,
      confirmedPassword: confirm,
      status: FormzSubmissionStatus.initial,
    ));
  }

  void _onObscureToggled(
    ChangePasswordObscureToggled event,
    Emitter<ChangePasswordState> emit,
  ) {
    emit(state.copyWith(obscure: !state.obscure));
  }

  void _onSecondObscureToggled(
    ChangePasswordSecondObscureToggled event,
    Emitter<ChangePasswordState> emit,
  ) {
    emit(state.copyWith(secondObscure: !state.secondObscure));
  }

  Future<void> _onSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    if (state.password.isNotValid || state.confirmedPassword.isNotValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure, errorMessage: 'Preencha os campos corretamente'));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      final response = await _authRepository.updatePassword(
        newPassword: state.password.value,
      );

      response.when(
        (success) => emit(state.copyWith(status: FormzSubmissionStatus.success)),
        (failure) => emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: failure.message,
        )),
      );
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure, errorMessage: 'Erro inesperado.'));
    }
  }
}
