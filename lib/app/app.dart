import 'package:app_ui/app_ui.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:club_app/main.dart';
import 'package:club_app/pages/sign_in_page/bloc/authentication_bloc.dart';
import 'package:club_app/blocs/biometric/biometric_bloc.dart';
import 'package:biometric_repository/biometric_repository.dart';
import 'package:club_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) =>
//           AuthenticationBloc(authRepository: FirebaseAuthRepository()),
//       child: const MyApp(),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final AuthenticationBloc authBloc =
      AuthenticationBloc(authRepository: getIt<IAuthenticationRepository>());

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (context) => authBloc,
        ),
        BlocProvider<BiometricBloc>(
          create: (context) => BiometricBloc(
            biometricRepository: getIt<IBiometricRepository>(),
          )..add(BiometricCheckStatusStarted()),
        ),
      ],
      child: ScreenUtilInit(
          designSize: const Size(360, 640),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.light,
              theme: GlobalThemeData.lightThemeData,
              routerDelegate: AppRouter.router.routerDelegate,
              routeInformationParser: AppRouter.router.routeInformationParser,
              routeInformationProvider:
                  AppRouter.router.routeInformationProvider,
            );
          }),
    );
  }
}
