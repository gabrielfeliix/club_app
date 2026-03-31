part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class GetNotifications extends NotificationsEvent {}

class MarkAsRead extends NotificationsEvent {
  final String id;

  const MarkAsRead({required this.id});

  @override
  List<Object?> get props => [id];
}

class MarkAllAsRead extends NotificationsEvent {}
