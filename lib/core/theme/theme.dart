import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static TextTheme _textTheme(Color p, Color s) {
    TextStyle f(double size, FontWeight w, Color c, {double h = 1.35, double ls = 0}) =>
        GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: w, color: c, height: h, letterSpacing: ls);
    return TextTheme(
      displayLarge: f(40, FontWeight.w600, p, h: 1.1, ls: -1),
      headlineLarge: f(26, FontWeight.w700, p, h: 1.2, ls: -0.4),
      titleLarge: f(18, FontWeight.w600, p, h: 1.25),
      titleMedium: f(16, FontWeight.w600, p),
      bodyLarge: f(15, FontWeight.w400, p, h: 1.45),
      bodyMedium: f(14, FontWeight.w400, s, h: 1.45),
      bodySmall: f(12, FontWeight.w400, s),
      labelLarge: f(15, FontWeight.w600, p),
      labelMedium: f(13, FontWeight.w500, s),
      labelSmall: f(11, FontWeight.w500, s, ls: 0.5),
    );
  }

  static ThemeData get lightTheme {
    final text = _textTheme(AppColors.textPrimaryLight, AppColors.textSecondaryLight);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        surfaceContainerHighest: AppColors.surfaceVariantLight,
        outline: AppColors.outlineLight,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: text,
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.outlineLight),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineLight),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final text = _textTheme(AppColors.textPrimaryDark, AppColors.textSecondaryDark);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        onPrimary: AppColors.primary,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        surfaceContainerHighest: AppColors.surfaceVariantDark,
        outline: AppColors.outlineDark,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: text,
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.outlineDark),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineDark),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}

