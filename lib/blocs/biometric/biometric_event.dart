part of 'biometric_bloc.dart';

sealed class BiometricEvent extends Equatable {
  const BiometricEvent();

  @override
  List<Object?> get props => [];
}

class BiometricCheckStatusStarted extends BiometricEvent {}

class BiometricToggleToggled extends BiometricEvent {
  const BiometricToggleToggled(this.enabled);
  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

class BiometricAuthenticationRequested extends BiometricEvent {}

class BiometricCredentialsStored extends BiometricEvent {
  const BiometricCredentialsStored({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class BiometricTemporaryCredentialsCleared extends BiometricEvent {}
