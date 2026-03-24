// import 'package:attendance_repository/src/helpers/helpers.dart';
// import 'package:attendance_repository/src/models/kids_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:multiple_result/multiple_result.dart';

// import 'attendance_repo.dart';
// import 'failure/failure.dart';
// import 'models/attendance_model.dart';

// class FirebaseAttendanceRepository implements IAttendanceRepository {
//   final FirebaseFirestore _firebaseFirestore;

//   FirebaseAttendanceRepository({FirebaseFirestore? firebaseFirestore})
//       : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

//   // @overide
//   Future<Result<List<AttendanceModel>, Failure>> getClubAttendancesBasic({
//     required String clubId,
//   }) async {
//     try {
//       final subcollectionRef = _firebaseFirestore
//           .collection('clubs')
//           .doc(clubId)
//           .collection('attendance');

//       final querySnapshot = await subcollectionRef.get();

//       final attList = querySnapshot.docs
//           .map((doc) => AttendanceModel.fromJsonBasic(doc))
//           .toList();

//       return Success(attList);
//     } on FirebaseException catch (e) {
//       return Error(Failure(message: 'Erro ao encontrar chamadas $e'));
//     } catch (e) {
//       return Error(Failure(message: 'Erro ao encontrar chamadas $e'));
//     }
//   }

//   @override
//   Future<Result<List<KidsModel>, Failure>> getChildrenBasic(
//       {required String clubId}) async {
//     try {
//       final DocumentSnapshot docSnapshot =
//           await _firebaseFirestore.collection('clubs').doc(clubId).get();

//       if (!docSnapshot.exists) {
//         return const Error(Failure(message: "Clube não encontrado"));
//       }

//       final data = docSnapshot.data() as Map<String, dynamic>;
//       final List<dynamic> kidsData = data['kids'] ?? [];

//       final List<KidsModel> kids = kidsData
//           .map((kidData) =>
//               KidsModel.fromJsonBasic(kidData as Map<String, dynamic>)
//                   .copyWith(clubId: clubId))
//           .toList();

//       return Success(kids);
//     } on FirebaseException catch (e) {
//       return Error(
//         Failure(message: "Erro ao buscar crianças: ${e.message}"),
//       );
//     } catch (e) {
//       return Error(
//         Failure(message: "Erro inesperado ao buscar crianças: $e"),
//       );
//     }
//   }

//   Future<Result<String, Failure>> takeAttendance({
//     required String clubId,
//     required String kidId,
//     required bool present,
//   }) async {
//     try {
//       final now = Helpers.getCurrentDateWithoutIntl();

//       final Map<String, dynamic> kidPresent = {
//         'kidId': kidId,
//         'present': present,
//       };

//       final docRef = _firebaseFirestore
//           .collection('clubs')
//           .doc(clubId)
//           .collection('attendance')
//           .doc(now);

//       // Tenta buscar o documento primeiro
//       final docSnapshot = await docRef.get();

//       if (docSnapshot.exists) {
//         // Se o documento existir, primeiro precisamos verificar se o aluno já está na lista
//         final data = docSnapshot.data() as Map<String, dynamic>;
//         final attendanceList =
//             List<Map<String, dynamic>>.from(data['attendanceList'] ?? []);

//         // Procura o índice do aluno na lista
//         final kidIndex =
//             attendanceList.indexWhere((item) => item['kidId'] == kidId);

//         if (kidIndex >= 0) {
//           // Se o aluno existir, atualiza o registro existente
//           attendanceList[kidIndex] = kidPresent;

//           // Atualiza o documento com a lista atualizada
//           await docRef.update({
//             'attendanceList': attendanceList,
//           });
//         } else {
//           // Se o aluno não existir na lista, adiciona-o
//           await docRef.update({
//             'attendanceList': FieldValue.arrayUnion([kidPresent]),
//           });
//         }
//       } else {
//         // Se não existir, cria um novo com o primeiro dado
//         await docRef.set({
//           'attendanceList': [kidPresent],
//           'date': now,
//         });
//       }

//       return const Success('Chamada Realizada com Sucesso');
//     } on FirebaseException catch (e) {
//       return Error(Failure(message: 'Erro ao Realizar chamadas: ${e.message}'));
//     } catch (e) {
//       return Error(Failure(message: 'Erro ao Realizar chamadas: $e'));
//     }
//   }
//   // @override
//   // Future<Result<String, Failure>> takeAttendance({
//   //   required String clubId,
//   //   required String kidId,
//   //   required bool present,
//   // }) async {
//   //   try {
//   //     final now = Helpers.getCurrentDateWithoutIntl();

//   //     final Map<String, dynamic> kidPresent = {
//   //       'kidId': kidId,
//   //       'present': present,
//   //     };

//   //     final docRef = _firebaseFirestore
//   //         .collection('clubs')
//   //         .doc(clubId)
//   //         .collection('attendance')
//   //         .doc(now);

//   //     // Tenta buscar o documento primeiro
//   //     final docSnapshot = await docRef.get();

//   //     if (docSnapshot.exists) {
//   //       // Se o documento existir, apenas adiciona no array
//   //       await docRef.update({
//   //         'attendanceList': FieldValue.arrayUnion([kidPresent]),
//   //       });
//   //     } else {
//   //       // Se não existir, cria um novo com o primeiro dado
//   //       await docRef.set({
//   //         'attendanceList': [kidPresent],
//   //         'date': now,
//   //       });
//   //     }

//   //     return const Success('Chamada Realizada com Sucesso');
//   //   } on FirebaseException catch (e) {
//   //     return Error(Failure(message: 'Erro ao Realizar chamadas: ${e.message}'));
//   //   } catch (e) {
//   //     return Error(Failure(message: 'Erro ao Realizar chamadas: $e'));
//   //   }
//   // }
// }
