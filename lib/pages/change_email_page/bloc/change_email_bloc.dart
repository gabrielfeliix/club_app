import 'package:app_ui/app_ui.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'change_email_event.dart';
part 'change_email_state.dart';

class ChangeEmailBloc extends Bloc<ChangeEmailEvent, ChangeEmailState> {
  ChangeEmailBloc({
    required IAuthenticationRepository authRepository,
  })  : _authRepository = authRepository,
        super(const ChangeEmailState()) {
    on<ChangeEmailChanged>(_onEmailChanged);
    on<ChangeEmailSubmitted>(_onSubmitted);
  }

  final IAuthenticationRepository _authRepository;

  void _onEmailChanged(
    ChangeEmailChanged event,
    Emitter<ChangeEmailState> emit,
  ) {
    final email = Email.dirty(event.email);
    emit(state.copyWith(
      email: email,
      status: FormzSubmissionStatus.initial,
    ));
  }

  Future<void> _onSubmitted(
    ChangeEmailSubmitted event,
    Emitter<ChangeEmailState> emit,
  ) async {
    if (state.email.isNotValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure, errorMessage: 'E-mail inválido'));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      final response = await _authRepository.updateEmail(
        newEmail: state.email.value,
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
