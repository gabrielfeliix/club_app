import 'models/schedule_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class IScheduleRepository {
  Future<List<ScheduleModel>> getSchedules({required String clubId});
  Future<ScheduleModel?> getScheduleDetails({required String scheduleId});
  Future<void> createSchedule({required ScheduleModel schedule});
  Future<void> updateSchedule({required ScheduleModel schedule});
  Future<void> deleteSchedule({required String scheduleId});
}
