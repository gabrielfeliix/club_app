import 'dart:developer';

import 'package:attendance_repository/attendance_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<IAttendanceEvent, AttendanceBlocState> {
  final IAttendanceRepository _attendanceRepository;

  AttendanceBloc({required IAttendanceRepository attendanceRepository})
      : _attendanceRepository = attendanceRepository,
        super(
          const AttendanceBlocState.initial(),
        ) {
    on<GetAllAttendanceRequired>(_onGetAllAttendanceRequired);
    on<GetAllKidsRequired>(_onGetGetAllKidsRequired);
    on<GetKidsForExistingAttendanceRequired>(_onGetKidsForExistingAttendance);
    on<ChangeRequired>(_onChangeRequired);
    on<TakeAttendanceRequired>(_onTakeAttendanceRequired);
  }

  Future<void> _onGetAllAttendanceRequired(
      GetAllAttendanceRequired event, Emitter<AttendanceBlocState> emit) async {
    emit(const AttendanceBlocState.loading());

    final response =
        await _attendanceRepository.getClubAttendancesBasic(clubId: event.id);

    response.when(
      (success) =>
          emit(AttendanceBlocState.successAttendance(listModel: success)),
      (failure) => emit(
        AttendanceBlocState.failure(message: failure.message),
      ),
    );
  }

  Future<void> _onTakeAttendanceRequired(
      TakeAttendanceRequired event, Emitter<AttendanceBlocState> emit) async {
    emit(const AttendanceBlocState.loading());

    try {
      final response = await _attendanceRepository.saveAttendanceSession(
        clubId: event.kidsList.first.clubId,
        kidsList: event.kidsList,
        date: event.date,
      );

      response.when(
        (success) {
          emit(AttendanceBlocState.successTakeAtt(
              message: 'Chamada salva com sucesso para ${event.kidsList.length} alunos'));
        },
        (failure) {
          emit(AttendanceBlocState.failure(message: failure.message));
        },
      );
    } catch (e) {
      final errorMessage = e is Failure ? e.message : 'Erro ao realizar chamada: $e';
      emit(AttendanceBlocState.failure(message: errorMessage));
    }
  }
  // Future<void> _onTakeAttendanceRequired(
  //     TakeAttendanceRequired event, Emitter<AttendanceBlocState> emit) async {
  //   emit(const AttendanceBlocState.loading());

  //   await Future.wait(
  //     event.kidsList.map(
  //       (kid) async {
  //         try {
  //           final response = await _attendanceRepository.takeAttendance(
  //             clubId: kid.clubId,
  //             kidId: kid.id,
  //             present: kid.isAbsent == true ||
  //                     (kid.isAbsent && kid.isPresent == false)
  //                 ? false
  //                 : true,
  //           );
  //           response.when(
  //             (success) {
  //               emit(AttendanceBlocState.successTakeAtt(message: success));
  //               return;
  //             },
  //             (failure) {
  //               emit(
  //                 AttendanceBlocState.failure(message: failure.message),
  //               );
  //               return;
  //             },
  //           );
  //         } catch (e) {
  //           emit(
  //             AttendanceBlocState.failure(
  //                 message: 'Erro ao realizar chamada! $e'),
  //           );
  //         }
  //       },
  //     ),
  //   );
  // }

  Future<void> _onGetGetAllKidsRequired(
      GetAllKidsRequired event, Emitter<AttendanceBlocState> emit) async {
    emit(const AttendanceBlocState.loading());

    final response =
        await _attendanceRepository.getChildrenBasic(clubId: event.id);

    response.when(
      (success) => emit(AttendanceBlocState.successKids(kidsList: success)),
      (failure) => emit(
        AttendanceBlocState.failure(message: failure.message),
      ),
    );
  }

  Future<void> _onGetKidsForExistingAttendance(
      GetKidsForExistingAttendanceRequired event, Emitter<AttendanceBlocState> emit) async {
    emit(const AttendanceBlocState.loading());

    final response = await _attendanceRepository.getChildrenBasic(clubId: event.id);

    response.when(
      (success) {
        final mappedKids = success.map((kid) {
          final recordPos = event.attendance.attendanceList.indexWhere((r) => r.kidId == kid.id);
          if (recordPos >= 0) {
            final isPresent = event.attendance.attendanceList[recordPos].present;
            return kid.copyWith(isPresent: isPresent, isAbsent: !isPresent);
          }
          return kid;
        }).toList();
        emit(AttendanceBlocState.successKids(kidsList: mappedKids));
      },
      (failure) => emit(AttendanceBlocState.failure(message: failure.message)),
    );
  }

  Future<void> _onChangeRequired(
      ChangeRequired event, Emitter<AttendanceBlocState> emit) async {
    if (state.kidsList == null) return;

    final updatedKidsList = state.kidsList!.map((kid) {
      if (kid.id == event.kidId) {
        return kid.copyWith(
          isPresent: event.isPresent,
          isAbsent: event.isAbsent,
        );
      } else {
        return kid;
      }
    }).toList();

    emit(AttendanceBlocState.change(kidsList: updatedKidsList));
    log('log==> ${state.kidsList}');
  }
}
