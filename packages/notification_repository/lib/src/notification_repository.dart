import 'notification_model.dart';

abstract class INotificationRepository {
  /// Fetch all notifications for the logged-in user (filtered by club via RLS).
  Future<List<NotificationModel>> getNotifications();

  /// Returns the total count of unread notifications for the current user.
  Future<int> getUnreadCount();

  /// Marks a single user_notification as read.
  Future<void> markAsRead({required String notificationId});

  /// Marks all notifications for the current user as read.
  Future<void> markAllAsRead();

  /// Returns a stream of notifications for the current user (real-time).
  Stream<List<NotificationModel>> watchNotifications();
}
