import 'package:app_ui/app_ui.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:club_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<IAuthenticationEvent, AuthenticationState> {
  final IAuthenticationRepository _authRepository;

  AuthenticationBloc({required IAuthenticationRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthenticationState.initial()) {
    on<SignInRequired>(_onSignInRequired);
    on<SignOutRequired>(_onSignOutRequired);
    on<ChangeObscureRequired>(_onChangeObscureRequired);
  }

  Future<void> _onSignOutRequired(
      SignOutRequired event, Emitter<AuthenticationState> emit) async {
    try {
      getIt<OneSignalService>().logout();
    } catch (_) {}
    _authRepository.logOut();
    emit(const AuthenticationState.logOUt());
  }

  Future<void> _onChangeObscureRequired(
      ChangeObscureRequired event, Emitter<AuthenticationState> emit) async {
    final currentState = state.state;
    emit(state.copyWith(
      obscure: !state.obscure!,
      state: state.isProgress ? currentState : FormzSubmissionStatus.initial,
    ));
  }

  Future<void> _onSignInRequired(
      SignInRequired event, Emitter<AuthenticationState> emit) async {
    final bool isObscure = state.obscure!;

    emit(const AuthenticationState.loading().copyWith(obscure: isObscure));

    final response = await _authRepository.signIn(
      email: event.email,
      password: event.password,
    );

    response.when(
      (success) {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          try {
            getIt<OneSignalService>().login(userId);
          } catch (_) {}
        }
        emit(
          AuthenticationState.success(message: success)
              .copyWith(obscure: isObscure),
        );
      },
      (failure) => emit(
        AuthenticationState.failure(message: failure.message)
            .copyWith(obscure: isObscure),
      ),
    );
  }
}
