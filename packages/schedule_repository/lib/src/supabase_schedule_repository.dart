import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/schedule_block_model.dart';
import 'models/schedule_model.dart';
import 'schedule_repository.dart';

class SupabaseScheduleRepository implements IScheduleRepository {
  final SupabaseClient _supabase;

  SupabaseScheduleRepository({required SupabaseClient supabase})
      : _supabase = supabase;

  @override
  Future<List<ScheduleModel>> getSchedules({required String clubId}) async {
    try {
      final schedulesJson = await _supabase
          .from('schedules')
          .select('*, schedule_blocks(*)')
          .eq('club_id', clubId)
          .order('date', ascending: false);

      return (schedulesJson as List<dynamic>).map((json) {
        final blocks = (json['schedule_blocks'] as List<dynamic>?)
                ?.map((b) => ScheduleBlockModel.fromJson(b))
                .toList() ??
            [];
        // Sort blocks by order
        blocks.sort((a, b) => a.order.compareTo(b.order));
        return ScheduleModel.fromJson(json, blocks: blocks);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get schedules: $e');
    }
  }

  @override
  Future<ScheduleModel?> getScheduleDetails({required String scheduleId}) async {
    try {
      final json = await _supabase
          .from('schedules')
          .select('*, schedule_blocks(*)')
          .eq('id', scheduleId)
          .single();

      final blocks = (json['schedule_blocks'] as List<dynamic>?)
              ?.map((b) => ScheduleBlockModel.fromJson(b))
              .toList() ??
          [];
      blocks.sort((a, b) => a.order.compareTo(b.order));
      return ScheduleModel.fromJson(json, blocks: blocks);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createSchedule({required ScheduleModel schedule}) async {
    try {
      // 1. Check if a schedule already exists for this date and club
      final existing = await _supabase
          .from('schedules')
          .select('id')
          .eq('club_id', schedule.clubId)
          .eq('date', schedule.date.toIso8601String().split('T')[0])
          .maybeSingle();

      if (existing != null) {
        final existingId = existing['id'] as String;
        await deleteSchedule(scheduleId: existingId);
      }

      // 2. Insert the new schedule
      final scheduleJson = schedule.toJson();
      final response = await _supabase
          .from('schedules')
          .insert(scheduleJson)
          .select()
          .single();

      final scheduleId = response['id'] as String;

      if (schedule.blocks.isNotEmpty) {
        final blocksJson = schedule.blocks.map((b) {
          final json = b.toJson();
          json['schedule_id'] = scheduleId;
          return json;
        }).toList();

        await _supabase.from('schedule_blocks').insert(blocksJson);
      }
    } catch (e) {
      throw Exception('Failed to create schedule: $e');
    }
  }

  @override
  Future<void> updateSchedule({required ScheduleModel schedule}) async {
    try {
      await _supabase
          .from('schedules')
          .update(schedule.toJson())
          .eq('id', schedule.id);

      // Simple strategy: delete all blocks and re-insert
      await _supabase.from('schedule_blocks').delete().eq('schedule_id', schedule.id);

      if (schedule.blocks.isNotEmpty) {
        final blocksJson = schedule.blocks.map((b) {
          final json = b.toJson();
          json['schedule_id'] = schedule.id;
          return json;
        }).toList();

        await _supabase.from('schedule_blocks').insert(blocksJson);
      }
    } catch (e) {
      throw Exception('Failed to update schedule: $e');
    }
  }

  @override
  Future<void> deleteSchedule({required String scheduleId}) async {
    try {
      await _supabase.from('schedules').delete().eq('id', scheduleId);
    } catch (e) {
      throw Exception('Failed to delete schedule: $e');
    }
  }
}
