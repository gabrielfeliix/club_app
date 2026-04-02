import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'push_notification_service.dart';

class OneSignalPushService implements IPushNotificationService {
  final String appId;

  OneSignalPushService({required this.appId});

  @override
  Future<void> initialize() async {
    try {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      
      // Initialize FIRST
      OneSignal.initialize(appId);
      
      // Pause IAM IMMEDIATELY after init
      OneSignal.InAppMessages.paused(true);

      // Request permission WITHOUT await to prevent ANR during startup
      requestPermission();
    } catch (e) {
      // ignore: avoid_print
      print('Error initializing OneSignal: $e');
    }
  }

  @override
  Future<void> requestPermission() async {
    await OneSignal.Notifications.requestPermission(true);
  }

  @override
  Future<void> login(String userId) async {
    await OneSignal.login(userId);
  }

  @override
  Future<void> logout() async {
    await OneSignal.logout();
  }

  @override
  void setInAppMessagesPaused(bool paused) {
    OneSignal.InAppMessages.paused(paused);
  }
}
