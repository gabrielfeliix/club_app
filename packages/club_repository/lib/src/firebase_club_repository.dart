import 'dart:developer';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club_repository/club_repository.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:uuid/uuid.dart';

class FirebaseClubRepository implements IClubRepository {
  final FirebaseFirestore _firebaseFirestore;

  FirebaseClubRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  /// User cache key.
  final userCacheKey = '__user_cache_key__';

  @override
  Future<Result<String, Failure>> createClub({
    required String name,
    required String address,
  }) async {
    const uuid = Uuid();
    final customId = 'club-${uuid.v4().substring(0, 5)}';

    try {
      final String userCache =
          CacheClient.read<AuthUserModel>(key: userCacheKey)!.userId;

      final QuerySnapshot adminsSnapshot = await _firebaseFirestore
          .collection('teachers')
          .where('role', isEqualTo: 'admin')
          .get();

      List<String> teacherIds = [userCache];

      for (var doc in adminsSnapshot.docs) {
        teacherIds.add(doc.id);
      }

      await _firebaseFirestore.collection('clubs').doc(customId).set({
        'name': name.trim(),
        'teachers': teacherIds,
        'kids': [],
        'address': address,
      });

      for (var teacherId in teacherIds) {
        await _firebaseFirestore.collection('teachers').doc(teacherId).update({
          'classIds': FieldValue.arrayUnion([customId]),
        });
      }
      return const Success('Clubinho criado com sucesso!');
      // ignore: unused_catch_clause
    } on FirebaseException catch (e) {
      return const Error(Failure(message: 'Erro ao criar clubinho!'));
    }
  }

  @override
  Future<Result<List<ClubModel>, FailureClub>> getAllClubs(
      {required String uuid, List<String>? clubIds}) async {
    try {
      final String userCache =
          CacheClient.read<AuthUserModel>(key: userCacheKey)!.userId;

      final teacherDoc =
          await _firebaseFirestore.collection('teachers').doc(userCache).get();

      if (!teacherDoc.exists) {
        throw Exception('Professor não encontrado');
      }

      final classIds = teacherDoc.data()?['classIds'] ?? [];

      if (classIds.isEmpty) {
        return const Success([]);
      }
      // isso vai ate 10
      final classesQuery = await _firebaseFirestore
          .collection('clubs')
          .where(FieldPath.documentId, whereIn: classIds)
          .get();

      log('log clubs query ==> ${classesQuery.docs}');

      final clubList = classesQuery.docs
          .map((doc) => ClubModel.fromJsonBasic(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      return Success(clubList);
    } on FirebaseException catch (e) {
      log('Firebase error: ${e.message}');
      return const Error(FailureClub(message: 'Nenhum Clubinho Vinculado!'));
    } catch (e) {
      log('General error: $e');
      return Error(FailureClub(message: e.toString()));
    }
  }

  @override
  Future<Result<String, Failure>> editAddress(
      {required String uuid, required String address}) async {
    try {
      await _firebaseFirestore.collection('clubs').doc(uuid).update({
        'address': address,
      });
      return const Success('Editado com sucesso!');
    } on FirebaseException catch (e) {
      return Error(FailureClub(message: e.message!));
    }
  }

  @override
  Future<Result<String, Failure>> editName(
      {required String uuid, required String name}) async {
    try {
      await _firebaseFirestore.collection('clubs').doc(uuid).update({
        'name': name,
      });
      return const Success('Editado com sucesso!');
    } on FirebaseException catch (e) {
      return Error(FailureClub(message: e.message!));
    }
  }

  @override
  Future<Result<ClubModel, Failure>> getClubInfo({required String id}) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firebaseFirestore.collection('clubs').doc(id).get();

      if (documentSnapshot.exists) {
        // final data =
        //     documentSnapshot.data() as DocumentSnapshot<Map<String, dynamic>>;
        final data = documentSnapshot.data();

        return Success(ClubModel.fromJson(data as Map<String, dynamic>));
      } else {
        return const Error(Failure(message: 'Clubinho não existe'));
      }
      // ignore: unused_catch_clause
    } on FirebaseException catch (e) {
      return const Error(Failure(message: "Erro ao buscar dados"));
    }
  }

  @override
  Future<Result<List<TeachersModel>, Failure>> getUsers(
      {required String id}) async {
    try {
      QuerySnapshot querySnapshot = await _firebaseFirestore
          .collection('teachers')
          .where('classIds', arrayContains: id)
          .get();

      List<TeachersModel> teachers = querySnapshot.docs.map((doc) {
        return TeachersModel.fromJson(doc.data() as Map<String, dynamic>)
            .copyWith(id: doc.id);
      }).toList();

      return Success(teachers);
    } on FirebaseException catch (e) {
      return Error(
          Failure(message: "Erro ao buscar professores: ${e.message}"));
    }
  }

  @override
  Future<Result<List<KidsModel>, Failure>> getChildren(
      {required String id}) async {
    try {
      final DocumentSnapshot docSnapshot =
          await _firebaseFirestore.collection('clubs').doc(id).get();

      if (!docSnapshot.exists) {
        return const Error(Failure(message: "Clube não encontrado"));
      }

      final data = docSnapshot.data() as Map<String, dynamic>;
      final List<dynamic> kidsData = data['kids'] ?? [];

      final List<KidsModel> kids = kidsData
          .map((kidData) => KidsModel.fromJson(kidData as Map<String, dynamic>))
          .toList();

      return Success(kids);
    } on FirebaseException catch (e) {
      return Error(
        Failure(message: "Erro ao buscar crianças: ${e.message}"),
      );
    } catch (e) {
      return Error(
        Failure(message: "Erro inesperado ao buscar crianças: $e"),
      );
    }
  }

  @override
  Future<Result<String, Failure>> addChild({
    required String id,
    required String address,
    required String age,
    required String birthDate,
    required String contactNumber,
    required String fatherName,
    required String fullName,
    required String motherName,
    required String notes,
  }) async {
    const uuid = Uuid();
    final customId = 'child-${uuid.v4().substring(0, 4)}';

    final Map<String, dynamic> newKid = {
      "address": address,
      "age": age,
      "birthDate": birthDate,
      "contactNumber": contactNumber,
      "fatherName": fatherName,
      "fullName": fullName,
      "motherName": motherName,
      "notes": notes,
      "id": customId,
    };

    try {
      await _firebaseFirestore.collection('clubs').doc(id).update({
        'kids': FieldValue.arrayUnion([newKid]),
      });

      return const Success('Criança adicionada com sucesso!');
    } on FirebaseException catch (e) {
      return Error(Failure(message: "Erro ao adicionar criança: ${e.message}"));
    } catch (e) {
      return Error(Failure(message: "Erro inesperado: $e"));
    }
  }

  @override
  Future<Result<String, Failure>> joinClub(
      {required String clubId, required String userId}) async {
    try {
      final clubDoc = await _firebaseFirestore
          .collection('clubs')
          .doc('club-${clubId.trim()}')
          .get();

      if (!clubDoc.exists) {
        return const Error(Failure(message: "Clubinho não encontrado"));
      }

      await _firebaseFirestore.collection('teachers').doc(userId).update({
        'classIds': FieldValue.arrayUnion(['club-${clubId.trim()}']),
      });

      await _firebaseFirestore
          .collection('clubs')
          .doc('club-${clubId.trim()}')
          .update({
        'teachers': FieldValue.arrayUnion([userId]),
      });

      return const Success("Solicitado com sucesso");
    } on FirebaseException catch (e) {
      return Error(Failure(message: "Erro ao solicitar entrada: ${e.message}"));
    } catch (e) {
      return Error(Failure(message: "Erro inesperado: $e"));
    }
  }

  @override
  Future<Result<String, Failure>> deleteClub({required String id}) async {
    try {
      final clubRef = _firebaseFirestore.collection('clubs').doc(id);
      final clubDoc = await clubRef.get();

      if (!clubDoc.exists) {
        return const Error(Failure(message: "Clube não encontrado."));
      }

      List<String> teacherIds = List<String>.from(clubDoc['teachers'] ?? []);

      for (String teacherId in teacherIds) {
        await _firebaseFirestore.collection('teachers').doc(teacherId).update({
          'classIds': FieldValue.arrayRemove([id])
        });
      }

      await clubRef.delete();

      return const Success('Clube deletado com sucesso.');
    } on FirebaseException catch (e) {
      return Error(Failure(message: "Erro ao deletar clube: ${e.message}"));
    } catch (e) {
      return Error(Failure(message: "Erro inesperado: $e"));
    }
  }

  @override
  Future<Result<String, Failure>> deleteTeacher(
      {required String idTeacher, required String idClub}) async {
    try {
      await _firebaseFirestore.collection('teachers').doc(idTeacher).update({
        'classIds': FieldValue.arrayRemove([idClub])
      });

      await _firebaseFirestore.collection('clubs').doc(idClub).update({
        'teachers': FieldValue.arrayRemove([idTeacher])
      });

      return const Success('Professor deletado com sucesso.');
    } on FirebaseException catch (e) {
      return Error(Failure(message: "Erro ao deletar clube: ${e.message}"));
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
      final clubDoc =
          await _firebaseFirestore.collection('clubs').doc(clubId).get();

      if (!clubDoc.exists) {
        return const Error(Failure(message: "Clube não encontrado."));
      }

      List<dynamic> kidsList = clubDoc.data()?['kids'] ?? [];

      kidsList.removeWhere((kid) => kid['id'] == idChild);

      await _firebaseFirestore.collection('clubs').doc(clubId).update({
        'kids': kidsList,
      });

      return const Success('Criança deletada com sucesso.');
    } on FirebaseException catch (e) {
      return Error(Failure(message: "Erro ao deletar criança: ${e.message}"));
    } catch (e) {
      return Error(Failure(message: "Erro inesperado: $e"));
    }
  }
}
