import 'package:attendance_repository/src/models/kids_model.dart';
import 'package:multiple_result/multiple_result.dart';

import 'failure/failure.dart';
import 'models/attendance_model.dart';

abstract class IAttendanceRepository {
  Future<Result<List<AttendanceModel>, Failure>> getClubAttendancesBasic({
    required String clubId,
  });
  Future<Result<List<KidsModel>, Failure>> getChildrenBasic({
    required String clubId,
  });
  Future<Result<String, Failure>> takeAttendance({
    required String clubId,
    required String kidId,
    required bool present,
  });

  Future<Result<String, Failure>> saveAttendanceSession({
    required String clubId,
    required List<KidsModel> kidsList,
    String? date,
  });

  Future<Result<List<AttendanceModel>, Failure>> getAllAttendancesGlobal();
  Future<Result<List<KidsModel>, Failure>> getAllChildrenGlobal();
}
