import 'package:authentication_repository/authentication_repository.dart';
import 'package:club_repository/club_repository.dart';
import 'package:multiple_result/multiple_result.dart';

abstract class IClubRepository {
  Future<Result<String, Failure>> createClub(
      {required String name, required String address});

  Future<Result<List<ClubModel>, Failure>> getAllClubs({required String uuid, List<String>? clubIds});

  Future<Result<String, Failure>> editName({
    required String uuid,
    required String name,
  });

  Future<Result<String, Failure>> editAddress({
    required String uuid,
    required String address,
  });

  Future<Result<ClubModel, Failure>> getClubInfo({required String id});

  Future<Result<List<TeachersModel>, Failure>> getUsers({required String id});

  Future<Result<List<KidsModel>, Failure>> getChildren({required String id});

  Future<Result<String, Failure>> deleteClub({required String id});

  Future<Result<String, Failure>> deleteKid({
    required String idChild,
    required String clubId,
  });

  Future<Result<String, Failure>> deleteTeacher({
    required String idTeacher,
    required String idClub,
  });

  Future<Result<String, Failure>> joinClub({
    required String clubId,
    required String userId,
  });

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
  });
}
