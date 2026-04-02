import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'biometric_repository.dart';

class LocalBiometricRepository implements IBiometricRepository {
  LocalBiometricRepository({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
    SharedPreferences? sharedPreferences,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _sharedPreferences = sharedPreferences;

  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;
  SharedPreferences? _sharedPreferences;

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _emailKey = 'biometric_email';
  static const String _passwordKey = 'biometric_password';

  Future<SharedPreferences> get _prefs async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    return _sharedPreferences!;
  }

  @override
  Future<bool> canAuthenticate() async {
    final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
    
    if (!canAuthenticate) return false;

    final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
    return availableBiometrics.isNotEmpty;
  }

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> saveCredentials(String email, String password) async {
    await _secureStorage.write(key: _emailKey, value: email);
    await _secureStorage.write(key: _passwordKey, value: password);
  }

  @override
  Future<BiometricCredentials?> getCredentials() async {
    final email = await _secureStorage.read(key: _emailKey);
    final password = await _secureStorage.read(key: _passwordKey);

    if (email != null && password != null) {
      return BiometricCredentials(email: email, password: password);
    }
    return null;
  }

  @override
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _emailKey);
    await _secureStorage.delete(key: _passwordKey);
  }

  @override
  Future<bool> isBiometricEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_biometricEnabledKey, enabled);
    if (!enabled) {
      await clearCredentials();
    }
  }
}
