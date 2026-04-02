abstract class IPushNotificationService {
  /// Initializes the notification service (e.g., configures App IDs).
  Future<void> initialize();

  /// Prompts the user for notification permissions.
  Future<void> requestPermission();

  /// Identifies the user within the notification provider (e.g., set external ID).
  Future<void> login(String userId);

  /// Removes the user identity from the notification provider.
  Future<void> logout();

  /// Pauses or resumes In-App Messages (modal popups) from the provider.
  void setInAppMessagesPaused(bool paused);
}
