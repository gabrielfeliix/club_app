part of 'attendance_bloc.dart';

abstract class IAttendanceEvent extends Equatable {
  const IAttendanceEvent();

  @override
  List<Object> get props => [];
}

class GetAllAttendanceRequired extends IAttendanceEvent {
  final String id;

  const GetAllAttendanceRequired({required this.id});
  @override
  List<Object> get props => [id];
}

class GetAllKidsRequired extends IAttendanceEvent {
  final String id;

  const GetAllKidsRequired({required this.id});
  @override
  List<Object> get props => [id];
}

class GetKidsForExistingAttendanceRequired extends IAttendanceEvent {
  final String id;
  final AttendanceModel attendance;

  const GetKidsForExistingAttendanceRequired({required this.id, required this.attendance});
  
  @override
  List<Object> get props => [id, attendance];
}

class TakeAttendanceRequired extends IAttendanceEvent {
  final List<KidsModel> kidsList;
  final String? date;
  const TakeAttendanceRequired({required this.kidsList, this.date});
  @override
  List<Object> get props => [kidsList, date ?? ''];
}

class ChangeRequired extends IAttendanceEvent {
  final String kidId;
  final bool isPresent;
  final bool isAbsent;

  const ChangeRequired({
    required this.kidId,
    required this.isPresent,
    required this.isAbsent,
  });

  @override
  List<Object> get props => [kidId, isPresent, isAbsent];
}
