import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'push_notification_service.dart';

class OneSignalPushService implements IPushNotificationService {
  final String appId;

  OneSignalPushService({required this.appId});

  @override
  Future<void> initialize() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(appId);
    OneSignal.Notifications.requestPermission(true);
  }

  @override
  Future<void> login(String userId) async {
    await OneSignal.login(userId);
  }

  @override
  Future<void> logout() async {
    await OneSignal.logout();
  }
}
