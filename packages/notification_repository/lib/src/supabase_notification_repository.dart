import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_model.dart';
import 'notification_repository.dart';

class SupabaseNotificationRepository implements INotificationRepository {
  final SupabaseClient _supabase;

  SupabaseNotificationRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      // Fetch user_notifications joined with notifications.
      // RLS ensures only the current user's rows are returned.
      final response = await _supabase
          .from('user_notifications')
          .select('id, notification_id, is_read, created_at, notifications(id, title, message)')
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Falha ao buscar notificações: $e');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _supabase
          .from('user_notifications')
          .select('id')
          .eq('is_read', false);

      return (response as List<dynamic>).length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<void> markAsRead({required String notificationId}) async {
    try {
      await _supabase
          .from('user_notifications')
          .update({'is_read': true})
          .eq('notification_id', notificationId);
    } catch (e) {
      throw Exception('Falha ao marcar notificação como lida: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _supabase
          .from('user_notifications')
          .update({'is_read': true})
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Falha ao marcar todas as notificações como lidas: $e');
    }
  }

  @override
  Stream<List<NotificationModel>> watchNotifications() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    final controller = StreamController<List<NotificationModel>>();

    // Initial fetch
    getNotifications().then((notifications) {
      if (!controller.isClosed) controller.add(notifications);
    }).catchError((e) {
      if (!controller.isClosed) controller.addError(e);
    });

    // Setup channel for real-time updates
    final channel = _supabase.channel('public:user_notifications:$userId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) async {
            try {
              final notifications = await getNotifications();
              if (!controller.isClosed) controller.add(notifications);
            } catch (e) {
              if (!controller.isClosed) controller.addError(e);
            }
          },
        )
        .subscribe();

    controller.onCancel = () {
      _supabase.removeChannel(channel);
      controller.close();
    };

    return controller.stream;
  }
}
