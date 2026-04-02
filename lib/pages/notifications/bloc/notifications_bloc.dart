import 'dart:async';
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
    on<_NotificationsUpdated>(_onNotificationsUpdated);
  }

  StreamSubscription<List<NotificationModel>>? _subscription;

  Future<void> _onGetNotifications(
      GetNotifications event, Emitter<NotificationsState> emit) async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    
    await _subscription?.cancel();
    _subscription = _notificationRepository.watchNotifications().listen(
      (notifications) {
        add(_NotificationsUpdated(notifications));
      },
      onError: (e) {
        emit(state.copyWith(status: NotificationsStatus.failure));
      }
    );
  }

  void _onNotificationsUpdated(
      _NotificationsUpdated event, Emitter<NotificationsState> emit) {
    final unreadCount = event.notifications.where((n) => !n.isRead).length;
    emit(state.copyWith(
      status: NotificationsStatus.success,
      notifications: event.notifications,
      unreadCount: unreadCount,
    ));
  }

  Future<void> _onMarkAsRead(
      MarkAsRead event, Emitter<NotificationsState> emit) async {
    try {
      await _notificationRepository.markAsRead(notificationId: event.id);
      // O stream de tempo real cuidará da atualização automática
    } catch (_) {}
  }

  Future<void> _onMarkAllAsRead(
      MarkAllAsRead event, Emitter<NotificationsState> emit) async {
    try {
      await _notificationRepository.markAllAsRead();
      // O stream de tempo real cuidará da atualização automática
    } catch (_) {}
  }
  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

class _NotificationsUpdated extends NotificationsEvent {
  final List<NotificationModel> notifications;
  const _NotificationsUpdated(this.notifications);

  @override
  List<Object> get props => [notifications];
}
