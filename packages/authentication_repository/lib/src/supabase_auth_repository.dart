import 'dart:developer';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:authentication_repository/src/utils/utils.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepository implements IAuthenticationRepository {
  final SupabaseClient _supabaseClient;
  final IPushNotificationService _pushService;

  SupabaseAuthRepository({
    SupabaseClient? supabaseClient,
    required IPushNotificationService pushService,
  })  : _supabaseClient = supabaseClient ?? Supabase.instance.client,
        _pushService = pushService;

  /// User cache key.
  final userCacheKey = '__user_cache_key__';

  @override
  Future<void> verifyPhone({required String phoneNumber}) async {
    // Implement phone verification via Supabase if needed
    // Supabase has signInWithOTP for phone. Left empty if not currently used.
    log('verifyPhone called: $phoneNumber');
  }

  @override
  Future<Result<String, Failure>> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      // Create user with Supabase Auth
      final AuthResponse response = await _supabaseClient.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {
          'name': name.trim(),
          'contact': phone.trim(),
          'role': 'teacher',
        },
      );

      final User? user = response.user;
      if (user == null) {
        return Error(Failure(message: 'Erro desconhecido ao criar usuário'));
      }

      // If session is present (auto-login enabled), map push service
      if (response.session != null) {
        try {
          await _pushService.login(user.id);
          await _pushService.requestPermission();
          _pushService.setInAppMessagesPaused(false);
        } catch (e) {
          log('Error mapping push service during signUp: $e');
        }
      }

      return const Success('Conta criada! Ative sua conta pelo Email');
    } on AuthException catch (e) {
      if (e.message.contains('already registered') || e.message.contains('already exists')) {
         return Error(CreateUserWithEmailAndPasswordFailure.fromCode('email-already-in-use'));
      }
      return Error(CreateUserWithEmailAndPasswordFailure(e.message));
    } catch (e) {
      return Error(Failure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Result<String, Failure>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabaseClient.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? user = response.user;
      if (user == null) {
        return Error(SignInWithEmailAndPasswordFailure());
      }
      
      final String userId = user.id;

      // Fetch user data from teachers table to get the role and linked clubs
      final Map<String, dynamic> doc = await _supabaseClient
          .from('teachers')
          .select('role, classIds')
          .eq('id', userId)
          .single();

      final String roleUser = doc['role'] as String;
      final List<String> classIds = List<String>.from(doc['classIds'] ?? []);

      CacheClient.write<AuthUserModel>(
        key: userCacheKey,
        value: AuthUserModel(
          userId: userId,
          userRole: Utils.userRoleToEnum(roleUser),
          classIds: classIds,
        ),
      );

      // Link user with OneSignal for targeted notifications
      try {
        await _pushService.login(userId);
        await _pushService.requestPermission();
        // Resume In-App Messages
        _pushService.setInAppMessagesPaused(false);
      } catch (e) {
        log('Error mapping push service during signIn: $e');
      }

      return const Success('Login realizado com sucesso');
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        return Error(SignInWithEmailAndPasswordFailure.fromCode('invalid-credential'));
      }
      return Error(SignInWithEmailAndPasswordFailure(e.message));
    } catch (e) {
      return Error(Failure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<void> logOut() async {
    try {
      _pushService.setInAppMessagesPaused(true);
      await _pushService.logout();
    } catch (e) {
      log('Error during push service logout: $e');
    }
    await _supabaseClient.auth.signOut();
    CacheClient.clear();
  }

  @override
  Future<Result<List<UsersModel>, Failure>> getAllUsers() async {
    try {
      final authUser = CacheClient.read<AuthUserModel>(key: userCacheKey);
      if (authUser == null) {
        return Error(Failure(message: "Usuário não autenticado no cache"));
      }
      final userId = authUser.userId;

      final List<dynamic> records = await _supabaseClient.from('teachers').select();

      final List<UsersModel> usersList = records
          .where((doc) => doc['id'] != userId)
          .map((doc) => UsersModel.fromJson(doc as Map<String, dynamic>).copyWith(id: doc['id'] as String))
          .toList();

      return Success(usersList);
    } on PostgrestException catch (e) {
      return Error(Failure(message: "Erro ao buscar Usuários: ${e.message}"));
    } catch (e) {
      return Error(Failure(message: "Erro inesperado ao buscar Usuários: $e"));
    }
  }

  @override
  Future<Result<String, Failure>> changeRoleUser({
    required String userId,
    required UserRole newRole,
  }) async {
    try {
      await _supabaseClient.from('teachers').update({
        'role': Utils.userRoleToString(newRole),
      }).eq('id', userId);

      return const Success("Role atualizado com sucesso");
    } on PostgrestException catch (e) {
      return Error(Failure(message: "Erro ao atualizar role: ${e.message}"));
    } catch (e) {
      return Error(Failure(message: "Erro inesperado: $e"));
    }
  }

  @override
  Future<Result<UsersModel, Failure>> getUserData({required String userId}) async {
    try {
      final doc = await _supabaseClient
          .from('teachers')
          .select()
          .eq('id', userId)
          .single();
      
      log('DEBUG: Raw teacher doc for $userId: $doc');
      
      return Success(UsersModel.fromJson(doc).copyWith(id: userId));
    } catch (e) {
      log('DEBUG: getUserData failed for $userId: $e');
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
      await _supabaseClient.from('teachers').update({
        'name': name.trim(),
        'contact': phone.trim(),
      }).eq('id', userId);
      return const Success("Perfil atualizado com sucesso");
    } catch (e) {
      return Error(Failure(message: "Erro ao atualizar perfil: $e"));
    }
  }

  @override
  Future<Result<String, Failure>> updateEmail({required String newEmail}) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(email: newEmail.trim()),
      );
      return const Success("E-mail alterado. Verifique a nova caixa de e-mail.");
    } on AuthException catch (e) {
      return Error(Failure(message: "Erro de autenticação: ${e.message}"));
    } catch (e) {
      return Error(Failure(message: "Erro inesperado ao alterar e-mail: $e"));
    }
  }

  @override
  Future<Result<String, Failure>> updatePassword({required String newPassword}) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword.trim()),
      );
      return const Success("Senha atualizada com sucesso");
    } on AuthException catch (e) {
      return Error(Failure(message: "Erro de autenticação: ${e.message}"));
    } catch (e) {
      return Error(Failure(message: "Erro inesperado ao alterar senha: $e"));
    }
  }

  @override
  Future<Result<String, Failure>> updateClassIds({
    required String userId,
    required List<String> classIds,
  }) async {
    try {
      await _supabaseClient
          .from('teachers')
          .update({'classIds': classIds})
          .eq('id', userId);
      return const Success("IDs de clubes atualizados com sucesso");
    } catch (e) {
      return Error(Failure(message: "Erro ao sincronizar clubinhos: $e"));
    }
  }
}
