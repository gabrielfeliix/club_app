import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

final textTheme = GoogleFonts.plusJakartaSansTextTheme(
  TextTheme(
    headlineMedium: TextStyle(
      // "Entrar"
      fontSize: 22.sp,
      fontWeight: FontWeight.w900,
    ),
    bodyMedium: TextStyle(
      // "Ganhe corações para Jesus..."
      fontWeight: FontWeight.w600,
      fontSize: 12.sp,
    ),
    bodySmall: TextStyle(
      // "Esqueceu a senha?"
      fontWeight: FontWeight.w600,
      fontSize: 13.sp,
    ),
    labelSmall: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12.sp,
    ),
    labelLarge: TextStyle(
      // "Clique aqui" e "Cadastre-se"
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      // Texto do botão "Entrar"
      fontSize: 13.sp,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      fontSize: 11.sp,
      fontWeight: FontWeight.w900,
      color: GlobalThemeData.lightColorScheme.onPrimary,
    ),
  ),
);
