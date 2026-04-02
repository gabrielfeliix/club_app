part of 'biometric_bloc.dart';

enum BiometricStatus { initial, loading, success, failure }

class BiometricState extends Equatable {
  const BiometricState({
    this.status = BiometricStatus.initial,
    this.isEnabled = false,
    this.isSupported = false,
    this.credentials,
    this.message,
    this.tempEmail,
    this.tempPassword,
  });

  final BiometricStatus status;
  final bool isEnabled;
  final bool isSupported;
  final BiometricCredentials? credentials;
  final String? message;
  final String? tempEmail;
  final String? tempPassword;

  BiometricState copyWith({
    BiometricStatus? status,
    bool? isEnabled,
    bool? isSupported,
    BiometricCredentials? credentials,
    String? message,
    String? tempEmail,
    String? tempPassword,
  }) {
    return BiometricState(
      status: status ?? this.status,
      isEnabled: isEnabled ?? this.isEnabled,
      isSupported: isSupported ?? this.isSupported,
      credentials: credentials ?? this.credentials,
      message: message ?? this.message,
      tempEmail: tempEmail ?? this.tempEmail,
      tempPassword: tempPassword ?? this.tempPassword,
    );
  }

  @override
  List<Object?> get props =>
      [status, isEnabled, isSupported, credentials, message, tempEmail, tempPassword];
}
