import 'dart:developer';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:club_repository/club_repository.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClubRepository implements IClubRepository {
  final SupabaseClient _supabaseClient;
  
  SupabaseClubRepository({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  final userCacheKey = '__user_cache_key__';

  @override
  Future<Result<String, Failure>> createClub({
    required String name,
    required String address,
  }) async {
    try {
      final String userCache =
          CacheClient.read<AuthUserModel>(key: userCacheKey)!.userId;

      // Find all admins to also add them to the club
      final List<dynamic> adminsSnapshot = await _supabaseClient
          .from('teachers')
          .select('id')
          .eq('role', 'admin');

      Set<String> teacherIds = {userCache};
      for (var doc in adminsSnapshot) {
        teacherIds.add(doc['id'] as String);
      }

      // Insert the new club
      final clubData = await _supabaseClient.from('clubs').insert({
        'name': name.trim(),
        'address': address.trim(),
        'teachers': teacherIds.toList(),
      }).select('id').single();

      final String customId = clubData['id'] as String;

      // Add the club to each teacher's classIds list in the teachers table
      for (String teacherId in teacherIds) {
        final doc = await _supabaseClient.from('teachers').select('classIds').eq('id', teacherId).single();
        List<String> currentClasses = List<String>.from((doc['classIds'] as List<dynamic>?) ?? []);
        if (!currentClasses.contains(customId)) {
          currentClasses.add(customId);
          await _supabaseClient.from('teachers').update({'classIds': currentClasses}).eq('id', teacherId);
        }
      }

      return const Success('Clubinho criado com sucesso!');
    } catch (e) {
      log('Erro ao criar clubinho: $e');
      return const Error(Failure(message: 'Erro ao criar clubinho!'));
    }
  }

  @override
  Future<Result<List<ClubModel>, FailureClub>> getAllClubs(
      {required String uuid}) async {
    try {
      // Due to Row Level Security, calling select on clubs will only return 
      // the clubs the user is allowed to view!
      final response = await _supabaseClient.from('clubs').select();

      final clubList = response.map((data) {
        return ClubModel(
          id: data['id'] as String,
          name: data['name'] ?? '',
          address: data['address'] ?? '',
          kids: const [],
          teachers: const [],
        );
      }).toList();

      if (clubList.isEmpty) {
         return const Success([]);
      }

      return Success(clubList);
    } catch (e) {
      log('Nenhum Clubinho Vinculado ou Erro geral: $e');
      return Error(FailureClub(message: 'Nenhum Clubinho Vinculado! ($e)'));
    }
  }

  @override
  Future<Result<String, Failure>> editAddress(
      {required String uuid, required String address}) async {
    try {
      await _supabaseClient.from('clubs').update({
        'address': address,
      }).eq('id', uuid);
      return const Success('Editado com sucesso!');
    } catch (e) {
      return Error(FailureClub(message: e.toString()));
    }
  }

  @override
  Future<Result<String, Failure>> editName(
      {required String uuid, required String name}) async {
    try {
      await _supabaseClient.from('clubs').update({
        'name': name,
      }).eq('id', uuid);
      return const Success('Editado com sucesso!');
    } catch (e) {
      return Error(FailureClub(message: e.toString()));
    }
  }

  @override
  Future<Result<ClubModel, Failure>> getClubInfo({required String id}) async {
    try {
      final data = await _supabaseClient.from('clubs').select().eq('id', id).maybeSingle();

      if (data != null) {
        return Success(ClubModel(
          id: data['id'] as String,
          name: data['name'] ?? '',
          address: data['address'] ?? '',
          kids: const [],
          teachers: const [],
        ));
      } else {
        return const Error(Failure(message: 'Clubinho não existe'));
      }
    } catch (e) {
      return const Error(Failure(message: "Erro ao buscar dados"));
    }
  }

  @override
  Future<Result<List<TeachersModel>, Failure>> getUsers(
      {required String id}) async {
    try {
      // Find the club
      final clubData = await _supabaseClient.from('clubs').select('teachers').eq('id', id).single();
      List<String> teacherIds = List<String>.from((clubData['teachers'] as List<dynamic>?) ?? []);

      if (teacherIds.isEmpty) return const Success([]);

      // Fetch teachers by these IDs
      final response = await _supabaseClient.from('teachers').select().filter('id', 'in', teacherIds);

      List<TeachersModel> teachers = response.map((doc) {
         var model = TeachersModel.fromJson(doc);
         return model.copyWith(id: doc['id'] as String);
      }).toList();

      return Success(teachers);
    } catch (e) {
      return Error(Failure(message: "Erro ao buscar professores: $e"));
    }
  }

  @override
  Future<Result<List<KidsModel>, Failure>> getChildren(
      {required String id}) async {
    try {
      // Find the kids belonging to this club
      final kidsData = await _supabaseClient.from('kids').select().eq('club_id', id);

      final List<KidsModel> kids = kidsData
          .map((kidRow) {
             var model = KidsModel.fromJson(kidRow);
             return model.copyWith(id: kidRow['id'] as String);
          })
          .toList();

      return Success(kids);
    } catch (e) {
      return Error(Failure(message: "Erro inesperado ao buscar crianças: $e"));
    }
  }

  @override
  Future<Result<String, Failure>> addChild({
    required String id, // Club UUID
    required String address,
    required String age,
    required String birthDate,
    required String contactNumber,
    required String fatherName,
    required String fullName,
    required String motherName,
    required String notes,
  }) async {
    try {
      String? parsedDate;
      if (birthDate.isNotEmpty) {
        // Assume format is DD/MM/YYYY
        final parts = birthDate.split('/');
        if (parts.length == 3) {
           parsedDate = '${parts[2]}-${parts[1]}-${parts[0]}';
        } else {
           parsedDate = birthDate; // Fallback
        }
      }

      await _supabaseClient.from('kids').insert({
        "club_id": id,
        "address": address,
        "age": age,
        "birth_date": parsedDate,
        "contact_number": contactNumber,
        "father_name": fatherName,
        "full_name": fullName,
        "name": fullName,
        "mother_name": motherName,
        "notes": notes,
      });

      return const Success('Criança adicionada com sucesso!');
    } catch (e) {
      return Error(Failure(message: "Erro inesperado: $e"));
    }
  }

  @override
  Future<Result<String, Failure>> joinClub(
      {required String clubId, required String userId}) async {
    try {
      final clubDoc = await _supabaseClient.from('clubs').select('teachers').eq('id', clubId).maybeSingle();

      if (clubDoc == null) {
        return const Error(Failure(message: "Clubinho não encontrado"));
      }

      // Add user to club's teachers array
      List<String> teachers = List<String>.from((clubDoc['teachers'] as List<dynamic>?) ?? []);
      if (!teachers.contains(userId)) {
         teachers.add(userId);
         await _supabaseClient.from('clubs').update({'teachers': teachers}).eq('id', clubId);
      }

      // Add club to user's classIds array
      final teacherDoc = await _supabaseClient.from('teachers').select('classIds').eq('id', userId).maybeSingle();
      if (teacherDoc != null) {
         List<String> classIds = List<String>.from((teacherDoc['classIds'] as List<dynamic>?) ?? []);
         if (!classIds.contains(clubId)) {
            classIds.add(clubId);
            await _supabaseClient.from('teachers').update({'classIds': classIds}).eq('id', userId);
         }
      }

      return const Success("Solicitado com sucesso");
    } catch (e) {
      return Error(Failure(message: "Erro inesperado: $e"));
    }
  }

  @override
  Future<Result<String, Failure>> deleteClub({required String id}) async {
    try {
      final clubDoc = await _supabaseClient.from('clubs').select('teachers').eq('id', id).maybeSingle();

      if (clubDoc == null) {
        return const Error(Failure(message: "Clube não encontrado."));
      }

      List<String> teacherIds = List<String>.from((clubDoc['teachers'] as List<dynamic>?) ?? []);

      for (String teacherId in teacherIds) {
        final doc = await _supabaseClient.from('teachers').select('classIds').eq('id', teacherId).single();
         List<String> currentClasses = List<String>.from((doc['classIds'] as List<dynamic>?) ?? []);
         if (currentClasses.contains(id)) {
            currentClasses.remove(id);
            await _supabaseClient.from('teachers').update({'classIds': currentClasses}).eq('id', teacherId);
         }
      }

      await _supabaseClient.from('clubs').delete().eq('id', id);

      return const Success('Clube deletado com sucesso.');
    } catch (e) {
      return Error(Failure(message: "Erro inesperado: $e"));
    }
  }

  @override
  Future<Result<String, Failure>> deleteTeacher(
      {required String idTeacher, required String idClub}) async {
    try {
      // Delete from teacher's classIds
      final doc = await _supabaseClient.from('teachers').select('classIds').eq('id', idTeacher).single();
      List<String> currentClasses = List<String>.from((doc['classIds'] as List<dynamic>?) ?? []);
      if (currentClasses.contains(idClub)) {
          currentClasses.remove(idClub);
          await _supabaseClient.from('teachers').update({'classIds': currentClasses}).eq('id', idTeacher);
      }

      // Delete from club's teachers array
      final clubDoc = await _supabaseClient.from('clubs').select('teachers').eq('id', idClub).single();
      List<String> teachers = List<String>.from((clubDoc['teachers'] as List<dynamic>?) ?? []);
      if (teachers.contains(idTeacher)) {
         teachers.remove(idTeacher);
         await _supabaseClient.from('clubs').update({'teachers': teachers}).eq('id', idClub);
      }

      return const Success('Professor deletado com sucesso.');
    } catch (e) {
      return Error(Failure(message: "Erro inesperado: $e"));
    }
  }

  @override
  Future<Result<String, Failure>> deleteKid({
    required String idChild,
    required String clubId,
  }) async {
    try {
      // With our new SQL schema, Kids are just rows in "kids" table. We delete the row.
      await _supabaseClient.from('kids').delete().eq('id', idChild);

      return const Success('Criança deletada com sucesso.');
    } catch (e) {
      return Error(Failure(message: "Erro inesperado: $e"));
    }
  }
}
