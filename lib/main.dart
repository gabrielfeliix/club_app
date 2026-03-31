import 'package:authentication_repository/authentication_repository.dart';
import 'package:attendance_repository/attendance_repository.dart';
import 'package:club_repository/club_repository.dart';
import 'package:decision_repository/decision_repository.dart';
import 'package:schedule_repository/schedule_repository.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:club_app/app/app.dart';
import 'package:club_app/app/simple_bloc_observer.dart';
import 'package:club_app/firebase_options.dart';

//! Red
//? Blue
////  riscado
//Todo laranja

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  Bloc.observer = SimpleBlocObserver();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Push Notifications Initialization
  final oneSignalAppId = dotenv.env['ONESIGNAL_APP_ID'] ?? '';
  if (oneSignalAppId.isNotEmpty && oneSignalAppId != 'SUBSTITUA_PELO_SEU_APP_ID') {
    final pushService = OneSignalPushService(appId: oneSignalAppId);
    await pushService.initialize();
    
    // If user is already logged in, map to provider
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      await pushService.login(userId);
    }
  }

  await setupDependences();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(),
    ),
  );
  //runApp(MyApp());
}

final getIt = GetIt.instance;

/// Create singletons (logic and services) that can be shared across the app.
Future<void> setupDependences() async {
  // Register service authentication
  getIt.registerLazySingleton<IAuthenticationRepository>(
    () => SupabaseAuthRepository(),
  );
  // Register service clubs
  getIt.registerLazySingleton<IClubRepository>(
    () => SupabaseClubRepository(),
  );
  // Register service attendances
  getIt.registerLazySingleton<IAttendanceRepository>(
    () => SupabaseAttendanceRepository(),
  );
  // Register service decisions
  getIt.registerLazySingleton<IDecisionRepository>(
    () => SupabaseDecisionRepository(),
  );
  // Register service schedules
  getIt.registerLazySingleton<IScheduleRepository>(
    () => SupabaseScheduleRepository(supabase: Supabase.instance.client),
  );

  // Register notification repository
  getIt.registerLazySingleton<INotificationRepository>(
    () => SupabaseNotificationRepository(),
  );

  // Register Push Notification Service
  final oneSignalAppId = dotenv.env['ONESIGNAL_APP_ID'] ?? '';
  getIt.registerLazySingleton<IPushNotificationService>(
    () => OneSignalPushService(appId: oneSignalAppId),
  );
}
