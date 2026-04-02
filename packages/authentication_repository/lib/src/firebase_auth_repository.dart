import 'dart:developer';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:authentication_repository/src/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multiple_result/multiple_result.dart';

class FirebaseAuthRepository implements IAuthenticationRepository {
  final FirebaseAuth _firebaseAuth;

  final FirebaseFirestore _firebaseFirestore;

  FirebaseAuthRepository(
      {FirebaseAuth? firebaseAuth, FirebaseFirestore? firebaseFirestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  /// User cache key.
  final userCacheKey = '__user_cache_key__';

  @override
  Future<void> verifyPhone({required String phoneNumber}) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Se a verificação for automática, você pode assinar diretamente o usuário
        //  await _firebaseAuth.signInWithCredential(credential);
        log('token==> ${credential.smsCode}');
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle error
        log('Verification failed: ${e.message}');
      },
      codeSent: (String verId, int? resendToken) {
        // O código foi enviado com sucesso
        // setState(() {
        //   verificationId = verId;
        // });
        log('code Sent: $verId');
      },
      codeAutoRetrievalTimeout: (String verId) {
        // O tempo de espera para a verificação automática expirou
        // setState(() {
        //   verificationId = verId;
        // });
        log('retrieval timeout $verId');
      },
    );
  }

  @override
  Future<Result<String, Failure>> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    //
    try {
      // Create an account with Firebase Authentication
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      // Saves the userId as the document name in the "teachers" collection in Firestore
      final String userId = userCredential.user!.uid;

      await _firebaseFirestore.collection('teachers').doc(userId).set({
        'name': name.trim(),
        'email': email.trim(),
        'contact': phone.trim(),
        'classIds': [],
        'role': 'teacher'
      });

      return const Success('Conta criada! Ative sua conta pelo Email');
    } on FirebaseAuthException catch (e) {
      return Error(CreateUserWithEmailAndPasswordFailure.fromCode(e.code));
    }
  }

  @override
  Future<Result<String, Failure>> signIn(
      {required String email, required String password}) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Saves the userId for searching data user
      final String userId = userCredential.user!.uid;

      final DocumentSnapshot<Map<String, dynamic>> doc =
          await _firebaseFirestore
              .collection('teachers')
              .doc(userId)
              .get(const GetOptions(source: Source.server));

      final String roleUser = doc.get(FieldPath(const ['role']));

      CacheClient.write<AuthUserModel>(
        key: userCacheKey,
        value: AuthUserModel(
          userId: userId,
          userRole: Utils.userRoleToEnum(roleUser),
        ),
      );

      return const Success('Login realizado com sucesso');
    } on FirebaseAuthException catch (e) {
      return Error(SignInWithEmailAndPasswordFailure.fromCode(e.code));
    }
  }

  @override
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
    CacheClient.clear();
  }

  @override
  Future<Result<List<UsersModel>, Failure>> getAllUsers() async {
    try {
      final userId = CacheClient.read<AuthUserModel>(key: userCacheKey)!.userId;

      QuerySnapshot querySnapshot =
          await _firebaseFirestore.collection('teachers').get();

      final List<UsersModel> usersList = querySnapshot.docs
          .where((doc) => doc.id != userId)
          .map((doc) => UsersModel.fromJson(doc.data() as Map<String, dynamic>)
              .copyWith(id: doc.id))
          .toList();

      return Success(usersList);
    } on FirebaseException catch (e) {
      return Error(
        Failure(message: "Erro ao buscar Usuários: ${e.message}"),
      );
    } catch (e) {
      return Error(
        Failure(message: "Erro inesperado ao buscar Usuários: $e"),
      );
    }
  }

  @override
  Future<Result<String, Failure>> changeRoleUser({
    required String userId,
    required UserRole newRole,
  }) async {
    try {
      await _firebaseFirestore.collection('teachers').doc(userId).update({
        'role': Utils.userRoleToString(newRole),
      });

      return const Success("Role atualizado com sucesso");
    } on FirebaseException catch (e) {
      return Error(Failure(message: "Erro ao atualizar role: ${e.message}"));
    } catch (e) {
      return Error(Failure(message: "Erro inesperado: $e"));
    }
  }

  @override
  Future<Result<UsersModel, Failure>> getUserData({required String userId}) async {
    try {
      final doc = await _firebaseFirestore.collection('teachers').doc(userId).get();
      if (!doc.exists) return Error(Failure(message: 'Usuário não encontrado.'));
      return Success(UsersModel.fromJson(doc.data() as Map<String, dynamic>).copyWith(id: userId));
    } catch (e) {
      return Error(Failure(message: 'Erro ao buscar dados do usuário: $e'));
    }
  }

  @override
  Future<Result<String, Failure>> updateProfile({
    required String userId,
    required String name,
    required String phone,
  }) async {
    try {
      await _firebaseFirestore.collection('teachers').doc(userId).update({
        'name': name.trim(),
        'contact': phone.trim(),
      });
      return const Success("Perfil atualizado com sucesso");
    } on FirebaseException catch (e) {
      return Error(Failure(message: "Erro ao atualizar perfil: ${e.message}"));
    } catch (e) {
      return Error(Failure(message: "Erro inesperado: $e"));
    }
  }

  @override
  Future<Result<String, Failure>> updateEmail({required String newEmail}) async {
    try {
      if (_firebaseAuth.currentUser != null) {
        await _firebaseAuth.currentUser!.verifyBeforeUpdateEmail(newEmail.trim());
        return const Success("Solicitação enviada. Verifique seu novo e-mail.");
      }
      return const Error(Failure(message: "Usuário não logado."));
    } on FirebaseAuthException catch (e) {
      return Error(Failure(message: "Erro de autenticação: ${e.message}"));
    } catch (e) {
      return Error(Failure(message: "Erro inesperado: $e"));
    }
  }

  @override
  Future<Result<String, Failure>> updatePassword({required String newPassword}) async {
    try {
      if (_firebaseAuth.currentUser != null) {
        await _firebaseAuth.currentUser!.updatePassword(newPassword.trim());
        return const Success("Senha atualizada com sucesso");
      }
      return const Error(Failure(message: "Usuário não logado."));
    } on FirebaseAuthException catch (e) {
      return Error(Failure(message: "Erro de autenticação: ${e.message}"));
    } catch (e) {
      return Error(Failure(message: "Erro inesperado: $e"));
    }
  }

  @override
  Future<Result<String, Failure>> updateClassIds({
    required String userId,
    required List<String> classIds,
  }) async {
    try {
      await _firebaseFirestore.collection('teachers').doc(userId).update({
        'classIds': classIds,
      });
      return const Success("IDs de clubes atualizados com sucesso");
    } catch (e) {
      return Error(Failure(message: "Erro ao sincronizar clubinhos: $e"));
    }
  }
}
