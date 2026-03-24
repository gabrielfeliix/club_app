part of 'schedule_bloc.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class LoadSchedulesRequired extends ScheduleEvent {
  final String clubId;
  const LoadSchedulesRequired({required this.clubId});

  @override
  List<Object?> get props => [clubId];
}

class LoadScheduleDetailsRequired extends ScheduleEvent {
  final String scheduleId;
  const LoadScheduleDetailsRequired({required this.scheduleId});

  @override
  List<Object?> get props => [scheduleId];
}

class CreateScheduleRequired extends ScheduleEvent {
  final ScheduleModel schedule;
  const CreateScheduleRequired({required this.schedule});

  @override
  List<Object?> get props => [schedule];
}

class UpdateScheduleRequired extends ScheduleEvent {
  final ScheduleModel schedule;
  const UpdateScheduleRequired({required this.schedule});

  @override
  List<Object?> get props => [schedule];
}

class DeleteScheduleRequired extends ScheduleEvent {
  final String scheduleId;
  final String clubId;
  const DeleteScheduleRequired({required this.scheduleId, required this.clubId});

  @override
  List<Object?> get props => [scheduleId, clubId];
}

class PrepareNewScheduleTemplate extends ScheduleEvent {
  final String clubId;
  const PrepareNewScheduleTemplate({required this.clubId});

  @override
  List<Object?> get props => [clubId];
}
