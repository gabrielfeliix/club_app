import 'package:biometric_repository/biometric_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'biometric_event.dart';
part 'biometric_state.dart';

class BiometricBloc extends Bloc<BiometricEvent, BiometricState> {
  BiometricBloc({
    required IBiometricRepository biometricRepository,
  })  : _biometricRepository = biometricRepository,
        super(const BiometricState()) {
    on<BiometricCheckStatusStarted>(_onCheckStatus);
    on<BiometricToggleToggled>(_onToggle);
    on<BiometricAuthenticationRequested>(_onAuthenticate);
    on<BiometricCredentialsStored>(_onStoreCredentials);
    on<BiometricTemporaryCredentialsCleared>(_onClearTemporaryCredentials);
  }

  final IBiometricRepository _biometricRepository;

  Future<void> _onCheckStatus(
    BiometricCheckStatusStarted event,
    Emitter<BiometricState> emit,
  ) async {
    final isSupported = await _biometricRepository.canAuthenticate();
    final isEnabled = await _biometricRepository.isBiometricEnabled();
    emit(state.copyWith(
      isSupported: isSupported,
      isEnabled: isEnabled,
    ));
  }

  Future<void> _onToggle(
    BiometricToggleToggled event,
    Emitter<BiometricState> emit,
  ) async {
    await _biometricRepository.setBiometricEnabled(event.enabled);
    emit(state.copyWith(isEnabled: event.enabled));
  }

  Future<void> _onAuthenticate(
    BiometricAuthenticationRequested event,
    Emitter<BiometricState> emit,
  ) async {
    emit(state.copyWith(status: BiometricStatus.loading));
    
    final authenticated = await _biometricRepository.authenticate(
      localizedReason: 'Acesse sua conta com biometria',
    );

    if (authenticated) {
      final credentials = await _biometricRepository.getCredentials();
      if (credentials != null) {
        emit(state.copyWith(
          status: BiometricStatus.success,
          credentials: credentials,
        ));
      } else {
        emit(state.copyWith(
          status: BiometricStatus.failure,
          message: 'Credenciais não encontradas. Por favor, faça login com e-mail e senha.',
        ));
      }
    } else {
      emit(state.copyWith(
        status: BiometricStatus.failure,
        message: 'Falha na autenticação biométrica.',
      ));
    }
  }

  Future<void> _onStoreCredentials(
    BiometricCredentialsStored event,
    Emitter<BiometricState> emit,
  ) async {
    // If biometric is enabled, we save to secure storage
    if (state.isEnabled) {
      await _biometricRepository.saveCredentials(event.email, event.password);
    }
    
    // Always keep temp credentials for activation flow after login
    emit(state.copyWith(
      tempEmail: event.email,
      tempPassword: event.password,
    ));
  }

  Future<void> _onClearTemporaryCredentials(
    BiometricTemporaryCredentialsCleared event,
    Emitter<BiometricState> emit,
  ) async {
    emit(state.copyWith(
      tempEmail: null,
      tempPassword: null,
    ));
  }
}
