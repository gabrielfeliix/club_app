import 'package:equatable/equatable.dart';

/// Models for Biometric Credentials
class BiometricCredentials extends Equatable {
  const BiometricCredentials({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Interface for Biometric Repository
abstract class IBiometricRepository {
  /// Check if the device has biometric hardware and it is enrolled.
  Future<bool> canAuthenticate();

  /// Trigger the biometric authentication prompt.
  Future<bool> authenticate({required String localizedReason});

  /// Securely save credentials for future biometric login.
  Future<void> saveCredentials(String email, String password);

  /// Retrieve securely stored credentials.
  Future<BiometricCredentials?> getCredentials();

  /// Clear securely stored credentials.
  Future<void> clearCredentials();

  /// Check if the user has enabled biometric login in settings.
  Future<bool> isBiometricEnabled();

  /// Enable or disable biometric login in settings.
  Future<void> setBiometricEnabled(bool enabled);
}
