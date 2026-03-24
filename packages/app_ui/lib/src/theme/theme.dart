// ignore_for_file: deprecated_member_use

import 'package:app_ui/src/theme/text_theme.dart';
import 'package:flutter/material.dart';

extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get text => theme.textTheme;
}

// extension CustomColors on ColorScheme {
//   Color get shadowGrey => const Color(0xFF9E9E9E).withOpacity(0.2);
// }

class GlobalThemeData {
  // static final Color _lightFocusColor = Colors.black.withOpacity(0.12);

  static ThemeData lightThemeData = themeData(lightColorScheme);

  //  static ThemeData lightThemeData =
  //     themeData(lightColorScheme, _lightFocusColor);

  static ThemeData themeData(ColorScheme colorScheme) {
    return ThemeData(
      textTheme: textTheme,
      colorScheme: colorScheme,
      canvasColor: colorScheme.background,
      scaffoldBackgroundColor: colorScheme.secondary,
      // highlightColor: Colors.transparent,
    );
  }

  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: Color(0xFF4D975B),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color.fromARGB(255, 217, 217, 217),
    onSecondary: Color(0xFF000000),
    tertiary: Color(0xFF0000FF),
    error: Colors.redAccent,
    onError: Color(0xFFFFFFFF),
    background: Color(0xFFFFFFFF),
    onBackground: Color(0xFFE6EBEB),

    // surface: Color(0xFF808080),
    surface: Color(0xFF9E9E9E),
    onSurface: Color(0xFF3A3D90),
    onSurfaceVariant: Color.fromARGB(255, 201, 201, 201),
    brightness: Brightness.light,
  );
}

// class IdpConnectTheme {
//   static ThemeData dark() => ThemeData.dark().applyTheme();
//   static ThemeData light() => ThemeData.light().applyTheme();
// }

// extension _ThemeDataExtensions on ThemeData {
//   ThemeData applyTheme() {
//     return copyWith(
//       brightness: Brightness.light,
//       colorScheme: ColorScheme.fromSeed(
//         seedColor: Color(0xff3822B6),
//         primary: Color(0xff3822B6),
//         secondary: Color(0xff8ED0C7),
//       ),
//       appBarTheme: AppBarTheme(
//         color: MyColors.grey,
//         foregroundColor: MyColors.dark,
//         titleTextStyle: GoogleFonts.montserrat(
//           fontWeight: FontWeight.bold,
//           fontSize: 28,
//         ),
//       ),
//       scaffoldBackgroundColor: MyColors.grey,
//       textTheme: GoogleFonts.montserratTextTheme(
//         textTheme.copyWith(
//           bodySmall: const TextStyle(fontSize: 18),
//           labelSmall: const TextStyle(fontSize: 18),
//           displaySmall: const TextStyle(fontSize: 18),
//           //   bodyLarge: const TextStyle(fontSize: 16),
//           //   labelLarge: const TextStyle(
//           //     letterSpacing: 1.5,
//           //     fontWeight: FontWeight.bold,
//           //   ),
//           //   headlineSmall: const TextStyle(fontWeight: FontWeight.bold),
//           //   //titleMedium: const TextStyle(color: Colors.grey),
//         ),
//       ),
//       // primaryTextTheme: GoogleFonts.nunitoTextTheme(primaryTextTheme),
//       // textButtonTheme: TextButtonThemeData(
//       //   style: TextButton.styleFrom(
//       //     minimumSize: const Size(double.infinity, double.minPositive),
//       //     padding: const EdgeInsets.all(30),
//       //     textStyle: const TextStyle(
//       //       letterSpacing: 1.5,
//       //       fontWeight: FontWeight.bold,
//       //     ),
//       //   ),
//       // ),
//       // snackBarTheme: SnackBarThemeData(
//       //   backgroundColor: Colors.black45,
//       //   contentTextStyle: GoogleFonts.nunito(),
//       //   behavior: SnackBarBehavior.floating,
//       // ),
//     );
//   }
// }
