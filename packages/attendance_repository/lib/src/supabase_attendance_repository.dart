import 'package:attendance_repository/attendance_repository.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAttendanceRepository implements IAttendanceRepository {
  final SupabaseClient _supabase;

  SupabaseAttendanceRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<Result<List<KidsModel>, Failure>> getChildrenBasic({required String clubId}) async {
    try {
      final response = await _supabase
          .from('kids')
          .select()
          .eq('club_id', clubId)
          .order('name');

      final kids = response.map((e) => KidsModel.fromJsonBasic(e).copyWith(clubId: clubId)).toList();
      return Success(kids);
    } catch (e) {
      return Error(Failure(message: 'Erro ao buscar crianças: $e'));
    }
  }

  @override
  Future<Result<List<AttendanceModel>, Failure>> getClubAttendancesBasic({required String clubId}) async {
    try {
      final response = await _supabase
          .from('attendances')
          .select('*, attendance_records(*)')
          .eq('club_id', clubId)
          .order('date', ascending: false);

      final list = response.map((e) {
        // Map Supabase nested result
        final recordsData = e['attendance_records'] as List<dynamic>? ?? [];
        final items = recordsData.map((r) => AttendanceItem(
              kidId: r['kid_id'] as String,
              present: r['present'] as bool,
            )).toList();

        return AttendanceModel(
          attendanceList: items,
          clubId: e['club_id'] as String,
          date: e['date'] as String,
        );
      }).toList();

      return Success(list);
    } catch (e) {
      return Error(Failure(message: 'Erro ao buscar chamadas do clube: $e'));
    }
  }

  @override
  Future<Result<String, Failure>> saveAttendanceSession({
    required String clubId,
    required List<KidsModel> kidsList,
    String? date,
  }) async {
    try {
      final sessionDate = date ?? DateTime.now().toIso8601String().split('T')[0];

      // Upsert the attendance session (creates if not exists, otherwise returns existing)
      final attendanceRes = await _supabase.from('attendances').upsert({
        'club_id': clubId,
        'date': sessionDate,
      }, onConflict: 'club_id, date').select('id').single();

      final attendanceId = attendanceRes['id'];

      // Prepare records array
      final records = kidsList.map((kid) {
        return {
          'attendance_id': attendanceId,
          'kid_id': kid.id,
          'present': kid.isPresent,
        };
      }).toList();

      if (records.isNotEmpty) {
        // Upsert all records in bulk
        await _supabase.from('attendance_records').upsert(
          records,
          onConflict: 'attendance_id, kid_id',
        );
      }

      return const Success('Chamada salva com sucesso!');
    } catch (e) {
      return Error(Failure(message: 'Erro ao salvar chamada: $e'));
    }
  }

  @override
  Future<Result<String, Failure>> takeAttendance({
    required String clubId,
    required String kidId,
    required bool present,
  }) async {
    // Deprecated for the new Supabase bulk method but kept to satisfy interface
    return const Error(Failure(message: 'Utilize saveAttendanceSession para Supabase.'));
  }

  @override
  Future<Result<List<AttendanceModel>, Failure>> getAllAttendancesGlobal(
      {List<String>? clubIds}) async {
    try {
      if (clubIds != null && clubIds.isEmpty) return const Success([]);

      var query = _supabase.from('attendances').select('*, attendance_records(*)');

      if (clubIds != null) {
        query = query.filter('club_id', 'in', clubIds);
      }

      final response = await query.order('date', ascending: false);

      final list = response.map((e) {
        final recordsData = e['attendance_records'] as List<dynamic>? ?? [];
        final items = recordsData
            .map((r) => AttendanceItem(
                  kidId: r['kid_id'] as String,
                  present: r['present'] as bool,
                ))
            .toList();

        return AttendanceModel(
          attendanceList: items,
          clubId: e['club_id'] as String,
          date: e['date'] as String,
        );
      }).toList();

      return Success(list);
    } catch (e) {
      return Error(Failure(message: 'Erro ao buscar chamadas globais: $e'));
    }
  }

  @override
  Future<Result<List<KidsModel>, Failure>> getAllChildrenGlobal(
      {List<String>? clubIds}) async {
    try {
      if (clubIds != null && clubIds.isEmpty) return const Success([]);

      var query = _supabase.from('kids').select();

      if (clubIds != null) {
        query = query.filter('club_id', 'in', clubIds);
      }

      final response = await query;
      final kids = response
          .map((e) => KidsModel.fromJsonBasic(e)
              .copyWith(clubId: e['club_id'] as String))
          .toList();
      return Success(kids);
    } catch (e) {
      return Error(Failure(message: 'Erro ao buscar todas as crianças: $e'));
    }
  }
}
