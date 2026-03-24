import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:schedule_repository/schedule_repository.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final IScheduleRepository _scheduleRepository;

  ScheduleBloc({required IScheduleRepository scheduleRepository})
      : _scheduleRepository = scheduleRepository,
        super(const ScheduleState()) {
    on<LoadSchedulesRequired>(_onLoadSchedulesRequired);
    on<LoadScheduleDetailsRequired>(_onLoadScheduleDetailsRequired);
    on<CreateScheduleRequired>(_onCreateScheduleRequired);
    on<UpdateScheduleRequired>(_onUpdateScheduleRequired);
    on<DeleteScheduleRequired>(_onDeleteScheduleRequired);
    on<PrepareNewScheduleTemplate>(_onPrepareNewScheduleTemplate);
  }

  Future<void> _onLoadSchedulesRequired(
      LoadSchedulesRequired event, Emitter<ScheduleState> emit) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      final schedules = await _scheduleRepository.getSchedules(clubId: event.clubId);
      emit(state.copyWith(status: ScheduleStatus.success, schedules: schedules));
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadScheduleDetailsRequired(
      LoadScheduleDetailsRequired event, Emitter<ScheduleState> emit) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      final schedule = await _scheduleRepository.getScheduleDetails(scheduleId: event.scheduleId);
      emit(state.copyWith(status: ScheduleStatus.success, selectedSchedule: schedule));
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateScheduleRequired(
      CreateScheduleRequired event, Emitter<ScheduleState> emit) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      await _scheduleRepository.createSchedule(schedule: event.schedule);
      emit(state.copyWith(status: ScheduleStatus.success));
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateScheduleRequired(
      UpdateScheduleRequired event, Emitter<ScheduleState> emit) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      await _scheduleRepository.updateSchedule(schedule: event.schedule);
      emit(state.copyWith(status: ScheduleStatus.success));
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteScheduleRequired(
      DeleteScheduleRequired event, Emitter<ScheduleState> emit) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      await _scheduleRepository.deleteSchedule(scheduleId: event.scheduleId);
      emit(state.copyWith(status: ScheduleStatus.success));
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onPrepareNewScheduleTemplate(
    PrepareNewScheduleTemplate event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      // Find nearest Saturday
      DateTime date = DateTime.now();
      while (date.weekday != DateTime.saturday) {
        date = date.add(const Duration(days: 1));
      }

      final template = ScheduleModel(
        id: '',
        clubId: event.clubId,
        date: date,
        blocks: [
          _createBlock(1, 'Recepção e crachá / portão', 7),
          _createBlock(2, 'Água e Banheiro', 8),
          _createBlock(3, 'Contagem Regressiva', 1),
          _createBlock(4, 'Bem-vindos / Oração', 4),
          _createBlock(5, 'Regras / Boas Maneiras', 3),
          _createBlock(6, 'Declaração da Criança', 2),
          _createBlock(7, 'Música 1', 4),
          _createBlock(8, 'Música 2', 4),
          _createBlock(9, 'Brincadeiras', 15),
          _createBlock(10, 'Música Lenta', 2),
          _createBlock(11, 'Versículo do Dia', 3),
          _createBlock(12, 'Fixação do Versículo', 3),
          _createBlock(13, 'Oração', 2),
          _createBlock(14, 'História bíblica', 12),
          _createBlock(15, 'Apelo', 6),
          _createBlock(16, 'Trabalho Manual', 10),
          _createBlock(17, 'Lanche / oração', 15),
          _createBlock(18, 'Aconselhamento', 8),
          _createBlock(19, 'Oração final', 1),
        ],
      );
      emit(state.copyWith(status: ScheduleStatus.success, selectedSchedule: template));
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: e.toString()));
    }
  }

  ScheduleBlockModel _createBlock(int order, String title, int duration) {
    return ScheduleBlockModel(
      id: '',
      scheduleId: '',
      order: order,
      title: title,
      durationMinutes: duration,
      responsibleNames: const [],
      description: '',
    );
  }
}
