abstract class IPushNotificationService {
  /// Initializes the notification service (e.g., configures App IDs, permissions).
  Future<void> initialize();

  /// Identifies the user within the notification provider (e.g., set external ID).
  Future<void> login(String userId);

  /// Removes the user identity from the notification provider.
  Future<void> logout();
}
