import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

TextTheme buildSlipoTextTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final baseTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  final mutedTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

  return TextTheme(
    displayLarge: GoogleFonts.roboto(fontSize: 32, fontWeight: FontWeight.w700, color: baseTextColor),
    headlineMedium: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.w600, color: baseTextColor),
    headlineSmall: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.w800, color: baseTextColor),
    titleLarge: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w600, color: baseTextColor),
    titleMedium: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600, color: baseTextColor),
    bodyLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500, color: baseTextColor),
    bodyMedium: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400, color: baseTextColor),
    bodySmall: GoogleFonts.roboto(fontSize: 13, fontWeight: FontWeight.w400, color: baseTextColor.withValues(alpha: 0.65)),
    labelSmall: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500, color: mutedTextColor, letterSpacing: 0.5),
    labelLarge: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w600, color: baseTextColor),
  );
}
