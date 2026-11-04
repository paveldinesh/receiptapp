import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import '../core/constants/spacing.dart';

class AppTheme {
  static final ColorScheme kDarkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: Colors.white,
    secondary: AppColors.electricBlue,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.capsuleNavBar,
    onSecondaryContainer: Colors.white,
    tertiary: AppColors.neonCyan,
    onTertiary: AppColors.obsidianBlack,
    tertiaryContainer: AppColors.capsuleNavBar,
    onTertiaryContainer: AppColors.neonCyan,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: const Color(0xFF4A1010),
    onErrorContainer: const Color(0xFFFFCDD2),
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    onSurfaceVariant: AppColors.textPrimaryDark.withValues(alpha: 0.7),
    outline: AppColors.outlineDark,
    outlineVariant: AppColors.outlineDark.withValues(alpha: 0.5),
    shadow: Colors.black,
    scrim: Colors.black87,
    inverseSurface: AppColors.surfaceLight,
    onInverseSurface: AppColors.textPrimaryLight,
    inversePrimary: AppColors.primaryDark,
    surfaceTint: Colors.transparent,
  );

  static final ColorScheme kLightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.electricBlue,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.primaryLight,
    onSecondaryContainer: AppColors.primaryDark,
    tertiary: AppColors.neonCyan,
    onTertiary: AppColors.obsidianBlack,
    tertiaryContainer: AppColors.softLightFill,
    onTertiaryContainer: AppColors.obsidianBlack,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: const Color(0xFFFFEBEE),
    onErrorContainer: const Color(0xFFB71C1C),
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimaryLight,
    surfaceContainerHighest: AppColors.surfaceVariantLight,
    onSurfaceVariant: AppColors.textPrimaryLight.withValues(alpha: 0.7),
    outline: AppColors.outlineLight,
    outlineVariant: AppColors.outlineLight.withValues(alpha: 0.5),
    shadow: Colors.black26,
    scrim: Colors.black38,
    inverseSurface: AppColors.surfaceDark,
    onInverseSurface: AppColors.textPrimaryDark,
    inversePrimary: AppColors.primary,
    surfaceTint: Colors.transparent,
  );

  static const PageTransitionsTheme _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    },
  );

  static ThemeData buildDarkTheme() {
    final textTheme = buildSlipoTextTheme(Brightness.dark);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: kDarkColorScheme,
      scaffoldBackgroundColor: AppColors.bgDark,
      fontFamily: GoogleFonts.roboto().fontFamily,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: _pageTransitionsTheme,
      textTheme: textTheme,
      cardTheme: _buildCardTheme(AppColors.surfaceDark, AppColors.outlineDark),
      appBarTheme: _buildAppBarTheme(AppColors.bgDark, AppColors.textPrimaryDark, textTheme),
      bottomNavigationBarTheme: _buildBottomNavTheme(AppColors.surfaceDark, AppColors.textPrimaryDark, textTheme),
      bottomSheetTheme: _buildBottomSheetTheme(AppColors.surfaceDark),
      floatingActionButtonTheme: _buildFabTheme(),
      filledButtonTheme: _buildFilledButtonTheme(textTheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(AppColors.primaryMid, AppColors.outlineDark, textTheme),
      textButtonTheme: _buildTextButtonTheme(AppColors.primaryMid, textTheme),
      iconButtonTheme: _buildIconButtonTheme(AppColors.textPrimaryDark),
      inputDecorationTheme: _buildInputTheme(AppColors.surfaceVariantDark, AppColors.outlineDark, AppColors.textPrimaryDark.withValues(alpha: 0.5), textTheme),
      chipTheme: _buildChipTheme(AppColors.surfaceVariantDark, AppColors.textPrimaryDark, textTheme),
      dividerTheme: const DividerThemeData(color: AppColors.outlineDark, thickness: 1, space: 1),
      iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      switchTheme: _buildSwitchTheme(),
      progressIndicatorTheme: _buildProgressTheme(AppColors.surfaceVariantDark),
      snackBarTheme: _buildSnackBarTheme(AppColors.textPrimaryDark, AppColors.surfaceDark, textTheme, dark: true),
      dialogTheme: _buildDialogTheme(AppColors.surfaceDark),
      popupMenuTheme: _buildPopupMenuTheme(AppColors.surfaceDark, AppColors.outlineDark, textTheme),
      tabBarTheme: _buildTabBarTheme(AppColors.textPrimaryDark, textTheme),
      listTileTheme: _buildListTileTheme(AppColors.textPrimaryDark, textTheme),
      badgeTheme: _buildBadgeTheme(textTheme),
      tooltipTheme: _buildTooltipTheme(textTheme, dark: true),
      visualDensity: VisualDensity.standard,
    );
  }

  static ThemeData buildLightTheme() {
    final textTheme = buildSlipoTextTheme(Brightness.light);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: kLightColorScheme,
      scaffoldBackgroundColor: AppColors.bgLight,
      fontFamily: GoogleFonts.roboto().fontFamily,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: _pageTransitionsTheme,
      textTheme: textTheme,
      cardTheme: _buildCardTheme(AppColors.surfaceLight, AppColors.outlineLight),
      appBarTheme: _buildAppBarTheme(AppColors.bgLight, AppColors.textPrimaryLight, textTheme),
      bottomNavigationBarTheme: _buildBottomNavTheme(AppColors.surfaceLight, AppColors.textPrimaryLight, textTheme),
      bottomSheetTheme: _buildBottomSheetTheme(AppColors.surfaceLight),
      floatingActionButtonTheme: _buildFabTheme(),
      filledButtonTheme: _buildFilledButtonTheme(textTheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(AppColors.primary, AppColors.outlineLight, textTheme),
      textButtonTheme: _buildTextButtonTheme(AppColors.primary, textTheme),
      iconButtonTheme: _buildIconButtonTheme(AppColors.textPrimaryLight),
      inputDecorationTheme: _buildInputTheme(AppColors.surfaceVariantLight, AppColors.outlineLight, AppColors.textPrimaryLight.withValues(alpha: 0.4), textTheme),
      chipTheme: _buildChipTheme(AppColors.surfaceVariantLight, AppColors.textPrimaryLight, textTheme),
      dividerTheme: const DividerThemeData(color: AppColors.outlineLight, thickness: 1, space: 1),
      iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      switchTheme: _buildSwitchTheme(),
      progressIndicatorTheme: _buildProgressTheme(AppColors.surfaceVariantLight),
      snackBarTheme: _buildSnackBarTheme(AppColors.textPrimaryLight, AppColors.surfaceLight, textTheme, dark: false),
      dialogTheme: _buildDialogTheme(AppColors.surfaceLight),
      popupMenuTheme: _buildPopupMenuTheme(AppColors.surfaceLight, AppColors.outlineLight, textTheme),
      tabBarTheme: _buildTabBarTheme(AppColors.textPrimaryLight, textTheme),
      listTileTheme: _buildListTileTheme(AppColors.textPrimaryLight, textTheme),
      badgeTheme: _buildBadgeTheme(textTheme),
      tooltipTheme: _buildTooltipTheme(textTheme, dark: false),
      visualDensity: VisualDensity.standard,
    );
  }


  static CardThemeData _buildCardTheme(Color surface, Color outline) => CardThemeData(
    color: surface,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(color: outline.withValues(alpha: 0.4), width: 1),
    ),
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
  );

  static AppBarTheme _buildAppBarTheme(Color bg, Color text, TextTheme textTheme) => AppBarTheme(
    backgroundColor: bg,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 1,
    shadowColor: Colors.black.withValues(alpha: 0.06),
    centerTitle: true,
    iconTheme: IconThemeData(color: text),
    actionsIconTheme: IconThemeData(color: text),
    titleTextStyle: textTheme.titleLarge?.copyWith(color: text, letterSpacing: -0.2),
  );

  static BottomNavigationBarThemeData _buildBottomNavTheme(Color bg, Color onSurface, TextTheme textTheme) => BottomNavigationBarThemeData(
    backgroundColor: bg,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: onSurface.withValues(alpha: 0.45),
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    selectedLabelStyle: textTheme.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
    unselectedLabelStyle: textTheme.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w500),
  );

  static BottomSheetThemeData _buildBottomSheetTheme(Color surface) => BottomSheetThemeData(
    backgroundColor: surface,
    surfaceTintColor: Colors.transparent,
    modalBackgroundColor: surface,
    elevation: 0,
    modalElevation: 8,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
  );

  static FloatingActionButtonThemeData _buildFabTheme() => const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 3,
    focusElevation: 4,
    hoverElevation: 4,
    highlightElevation: 6,
    shape: CircleBorder(),
  );

  static FilledButtonThemeData _buildFilledButtonTheme(TextTheme textTheme) => FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.35),
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: textTheme.labelLarge?.copyWith(letterSpacing: 0.1),
      elevation: 0,
    ),
  );

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(Color color, Color outline, TextTheme textTheme) => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color.withValues(alpha: 0.5), width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      minimumSize: const Size.fromHeight(52),
      textStyle: textTheme.labelLarge,
    ),
  );

  static TextButtonThemeData _buildTextButtonTheme(Color color, TextTheme textTheme) => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: color,
      textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  static IconButtonThemeData _buildIconButtonTheme(Color color) => IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: color,
      highlightColor: AppColors.primary.withValues(alpha: 0.1),
    ),
  );

  static InputDecorationTheme _buildInputTheme(Color fill, Color outline, Color hint, TextTheme textTheme) => InputDecorationTheme(
    filled: true,
    fillColor: fill,
    hintStyle: textTheme.bodyLarge?.copyWith(color: hint, fontWeight: FontWeight.w400),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: outline.withValues(alpha: 0.5))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: outline.withValues(alpha: 0.5))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.error, width: 2)),
    contentPadding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceMd),
  );

  static ChipThemeData _buildChipTheme(Color surface, Color onSurface, TextTheme textTheme) => ChipThemeData(
    backgroundColor: surface,
    labelStyle: textTheme.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: onSurface),
    padding: const EdgeInsets.symmetric(horizontal: spaceSm, vertical: spaceXs),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    side: BorderSide.none,
  );

  static SwitchThemeData _buildSwitchTheme() => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      return Colors.white;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primary;
      return AppColors.outlineLight;
    }),
    trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
  );

  static ProgressIndicatorThemeData _buildProgressTheme(Color track) => ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: track,
    circularTrackColor: track,
  );

  static SnackBarThemeData _buildSnackBarTheme(Color onSurface, Color surface, TextTheme textTheme, {required bool dark}) => SnackBarThemeData(
    backgroundColor: dark ? const Color(0xFF2A2723) : const Color(0xFF1A1A1A),
    contentTextStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: Colors.white),
    actionTextColor: AppColors.primaryLight,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
  );

  static DialogThemeData _buildDialogTheme(Color surface) => DialogThemeData(
    backgroundColor: surface,
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  );

  static PopupMenuThemeData _buildPopupMenuTheme(Color surface, Color outline, TextTheme textTheme) => PopupMenuThemeData(
    color: surface,
    surfaceTintColor: Colors.transparent,
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: outline.withValues(alpha: 0.5)),
    ),
    textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
  );

  static TabBarThemeData _buildTabBarTheme(Color onSurface, TextTheme textTheme) => TabBarThemeData(
    labelColor: AppColors.primary,
    unselectedLabelColor: onSurface.withValues(alpha: 0.5),
    labelStyle: textTheme.bodySmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
    unselectedLabelStyle: textTheme.bodySmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
    indicatorColor: AppColors.primary,
    dividerColor: Colors.transparent,
  );

  static ListTileThemeData _buildListTileTheme(Color onSurface, TextTheme textTheme) => ListTileThemeData(
    iconColor: AppColors.primary,
    textColor: onSurface,
    titleTextStyle: textTheme.labelLarge?.copyWith(color: onSurface),
    subtitleTextStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w400, color: onSurface.withValues(alpha: 0.6)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  static BadgeThemeData _buildBadgeTheme(TextTheme textTheme) => BadgeThemeData(
    backgroundColor: AppColors.primary,
    textColor: Colors.white,
    textStyle: textTheme.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w700),
  );

  static TooltipThemeData _buildTooltipTheme(TextTheme textTheme, {required bool dark}) => TooltipThemeData(
    decoration: BoxDecoration(
      color: dark ? const Color(0xFF3A3630) : const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: textTheme.labelSmall?.copyWith(color: Colors.white),
  );

  static final ThemeData lightTheme = buildLightTheme();
  static final ThemeData darkTheme = buildDarkTheme();
}
