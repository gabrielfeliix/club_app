import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notification_repository/notification_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final INotificationRepository _notificationRepository;

  NotificationsBloc({required INotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository,
        super(const NotificationsState()) {
    on<GetNotifications>(_onGetNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
  }

  Future<void> _onGetNotifications(
      GetNotifications event, Emitter<NotificationsState> emit) async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    try {
      final notifications = await _notificationRepository.getNotifications();
      final unreadCount = await _notificationRepository.getUnreadCount();
      emit(state.copyWith(
        status: NotificationsStatus.success,
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(state.copyWith(status: NotificationsStatus.failure));
    }
  }

  Future<void> _onMarkAsRead(
      MarkAsRead event, Emitter<NotificationsState> emit) async {
    try {
      await _notificationRepository.markAsRead(notificationId: event.id);
      add(GetNotifications()); // Refresh
    } catch (_) {}
  }

  Future<void> _onMarkAllAsRead(
      MarkAllAsRead event, Emitter<NotificationsState> emit) async {
    try {
      await _notificationRepository.markAllAsRead();
      add(GetNotifications()); // Refresh
    } catch (_) {}
  }
}
