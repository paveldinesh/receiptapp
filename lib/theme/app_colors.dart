import 'package:flutter/material.dart';

/// AppColors — Reference-matched palette: light gray bg, forest/emerald green primary.
/// Matches the dashboard reference: #F0F0F0 page, white cards, #1B6B47 green hero.
class AppColors {
  // ── Slipo Brand Guideline v1.0 Official Tokens ─────────────────────────────
  /// Core brand black (#121318) — primary logo color, primary buttons, high-contrast text
  static const Color obsidianBlack = Color(0xFF121318);
  /// Pressed/active button states (#0F1015), deepest dark surface
  static const Color pressBlack = Color(0xFF0F1015);
  /// Light-mode card fills & subtle light surfaces (#F4F5F7)
  static const Color softLightFill = Color(0xFFF4F5F7);
  /// Dashboard hero/summary card background (#1B1C23)
  static const Color heroBalanceCard = Color(0xFF1B1C23);
  /// Floating bottom navigation capsule background (#1B1C22)
  static const Color capsuleNavBar = Color(0xFF1B1C22);

  /// Primary accent (#00D2B8) — highlights, active states, key CTAs
  static const Color neonCyan = Color(0xFF00D2B8);
  /// Tertiary accent (#0066FF) — links, secondary CTAs, data viz
  static const Color electricBlue = Color(0xFF0066FF);

  /// Light mode app background (#FFFFFF)
  static const Color lightCanvas = Color(0xFFFFFFFF);
  /// Dark mode app background (#FFFFFF)
  static const Color darkCanvas = Color(0xFFFFFFFF);

  // ── Backgrounds ────────────────────────────────────────────────────────────
  static const Color bgLight = lightCanvas;
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF2F2F7);
  static const Color outlineLight = Color(0xFFE5E5EA);

  static const Color bgDark = darkCanvas;
  static const Color surfaceDark = heroBalanceCard;
  static const Color surfaceVariantDark = Color(0xFF22242C);
  static const Color outlineDark = Color(0xFF2C2D36);

  // ── Fintech Dark Hero & Floating Nav Palette ─────────────────────────────
  static const Color heroDark = pressBlack;
  static const Color heroCardDark = heroBalanceCard;
  static const Color heroCardGlass = Color(0x1FFFFFFF);
  static const Color navBarBackground = capsuleNavBar;
  static const Color navBarActivePill = Color(0xFFFFFFFF);
  static const Color navBarActiveIcon = obsidianBlack;
  static const Color navBarInactiveIcon = Color(0xFF8E929B);
  
  // Vibrant Dots & Stacked Card Graphic Accents
  static const Color dotCyan = neonCyan;
  static const Color dotYellow = Color(0xFFFFCC00);
  static const Color dotBlue = electricBlue;
  static const Color cardStackLime = neonCyan;
  static const Color cardStackCyan = neonCyan;
  static const Color cardStackBlue = electricBlue;

  // ── Primary Palette (Sleek Black) ──────────────────────────────────────────
  static const Color primary = obsidianBlack;
  static const Color primaryDark = pressBlack;
  static const Color primaryMid = capsuleNavBar;
  static const Color primaryLight = softLightFill;

  // ── Accents ────────────────────────────────────────────────────────────────
  static const Color accent = obsidianBlack;

  // ── Text Palette ───────────────────────────────────────────────────────────
  static const Color textPrimaryLight = obsidianBlack;
  static const Color textSecondaryLight = Color(0xFF6E6E73);
  static const Color textMutedLight = Color(0xFF8E8E93);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFA1A5B0);
  static const Color textMutedDark = Color(0xFF6E717C);

  // ── Semantic / Status Colors ───────────────────────────────────────────────
  static const Color success = obsidianBlack;
  static const Color successLight = softLightFill;

  // ── Warnings ───────────────────────────────────────────────────────────────
  static const Color warning = Color(0xFFFF9500);
  static const Color warningLight = Color(0xFFFFF8E6);
  static const Color warningBorder = Color(0xFFFF9500);

  static const Color error = Color(0xFFC83232);
  static const Color errorLight = Color(0xFFFDE6E6);

  // ── Warranty Badges ────────────────────────────────────────────────────────
  static const Color warrantyGreenBg = softLightFill;
  static const Color warrantyGreenFg = obsidianBlack;

  static const Color warrantyAmberBg = Color(0xFFFFF0DC);
  static const Color warrantyAmberFg = Color(0xFFE8920A);
  static const Color warrantyRedBg = Color(0xFFFDE6E6);
  static const Color warrantyRedFg = Color(0xFFC83232);

  // ── Category Chip Colors ───────────────────────────────────────────────────
  static const Color catElectrBg = Color(0xFFE8EEF8);
  static const Color catElectrFg = Color(0xFF3B537E);

  static const Color catFoodBg = Color(0xFFFCEFDF);
  static const Color catFoodFg = Color(0xFF8E562E);

  static const Color catGroceryBg = softLightFill;
  static const Color catGroceryFg = obsidianBlack;

  static const Color catFashionBg = Color(0xFFFBEAF0);
  static const Color catFashionFg = Color(0xFF8E3253);

  static const Color catTravelBg = Color(0xFFF0EDFA);
  static const Color catTravelFg = Color(0xFF6243A4);

  static const Color catHealthBg = Color(0xFFFCECED);
  static const Color catHealthFg = Color(0xFFAA2B3E);

  static const Color catOtherBg = Color(0xFFEBEBEB);
  static const Color catOtherFg = Color(0xFF6B6B6B);
}
