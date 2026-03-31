import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {
  final String appId;

  OneSignalService({required this.appId});

  /// Initializes OneSignal with the given App ID.
  Future<void> initialize() async {
    // Set Log Level (Optional, but good for debugging)
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // OneSignal Initialization
    OneSignal.initialize(appId);

    // The promptForPushNotificationsWithUserResponse will show the native iOS or Android 13+ notification permission prompt.
    // We can call this here or after login. Calling it here for simplicity.
    OneSignal.Notifications.requestPermission(true);
  }

  /// Sets the external user ID so we can target this specific user from Supabase.
  /// This should be called after a successful login.
  Future<void> login(String userId) async {
    await OneSignal.login(userId);
  }

  /// Clears the external user ID on logout.
  Future<void> logout() async {
    await OneSignal.logout();
  }
}
