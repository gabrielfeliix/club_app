part of 'schedule_bloc.dart';

enum ScheduleStatus { initial, loading, success, failure }

class ScheduleState extends Equatable {
  final ScheduleStatus status;
  final List<ScheduleModel> schedules;
  final ScheduleModel? selectedSchedule;
  final String? errorMessage;

  const ScheduleState({
    this.status = ScheduleStatus.initial,
    this.schedules = const [],
    this.selectedSchedule,
    this.errorMessage,
  });

  ScheduleState copyWith({
    ScheduleStatus? status,
    List<ScheduleModel>? schedules,
    ScheduleModel? selectedSchedule,
    String? errorMessage,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      schedules: schedules ?? this.schedules,
      selectedSchedule: selectedSchedule ?? this.selectedSchedule,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, schedules, selectedSchedule, errorMessage];
}
