# ReceiptVault — Color Theme & Design System Reference

Source of Truth: [`lib/core/theme/colors.dart`](file:///c:/Antigravity/Projects/receiptvault_flutter/lib/core/theme/colors.dart)  
Theme Implementation: [`lib/theme/theme.dart`](file:///c:/Antigravity/Projects/receiptvault_flutter/lib/theme/theme.dart)

---

## 🎨 Overview & Design Aesthetic

ReceiptVault utilizes a modern fintech design system characterized by:
- High-contrast sleek black (`#121318`) primary accents.
- Deep obsidian dark hero cards and dark mode canvases (`#0F1015`, `#1B1C23`).
- Floating capsule navigation bar with crisp active/inactive state contrast.
- Vibrant neon accents (cyan `#00D2B8`, lime `#CCFF00`, blue `#00B2FF`) for interactive dots and graphic stacks.
- Soft pastel category pills with high-contrast text foregrounds.

---

## 🖤 Primary Brand Palette

| Token Name | Hex Code | Color Preview | Description / Usage |
|---|---|---|---|
| `AppColors.primary` | `#121318` | `rgb(18, 19, 24)` | Primary buttons, hero action cards, FAB |
| `AppColors.primaryDark` | `#0F1015` | `rgb(15, 16, 21)` | Pressed states & deep contrast backdrops |
| `AppColors.primaryMid` | `#1B1C22` | `rgb(27, 28, 34)` | Active dark mode icons, secondary buttons |
| `AppColors.primaryLight` | `#F4F5F7` | `rgb(244, 245, 247)` | Light pill fills, active badge backgrounds |
| `AppColors.accent` | `#121318` | `rgb(18, 19, 24)` | High-contrast links ("See All") |
| `AppColors.accentCoral` | `#E07856` | `rgb(224, 120, 86)` | Sparing highlight accent |

---

## 🌙 Fintech Dark Hero & Floating Navigation Palette

| Token Name | Hex Code | Usage |
|---|---|---|
| `AppColors.heroDark` | `#0F1015` | Hero header background canvas |
| `AppColors.heroCardDark` | `#1B1C23` | Dark balance card container background |
| `AppColors.heroCardGlass` | `0x1FFFFFFF` | Glassmorphic white overlay (12% opacity) |
| `AppColors.navBarBackground` | `#1B1C22` | Floating capsule navigation bar container |
| `AppColors.navBarActivePill` | `#FFFFFF` | Active item pill background |
| `AppColors.navBarActiveIcon` | `#121318` | Active navigation item icon tint |
| `AppColors.navBarInactiveIcon` | `#8E929B` | Inactive navigation item icon tint |

---

## ⚡ Vibrant Dot & Graphic Stack Accents

| Token Name | Hex Code | Usage |
|---|---|---|
| `AppColors.dotCyan` / `cardStackCyan` | `#00D2B8` | Cyan status dots & stacked card graphic layer |
| `AppColors.dotYellow` / `cardStackLime` | `#CCFF00` | Neon lime/yellow indicator dot & card stack layer |
| `AppColors.dotBlue` | `#00B2FF` | Neon cyan-blue status indicator dot |
| `AppColors.cardStackBlue` | `#0066FF` | Electric blue stacked card graphic accent |

---

## 🖼️ Backgrounds & Surfaces

### Light Mode Canvas
| Token Name | Hex Code | Usage |
|---|---|---|
| `AppColors.bgLight` | `#F4F4F4` | Soft light gray page/scaffold background |
| `AppColors.surfaceLight` | `#FFFFFF` | Pure white cards & bottom sheet containers |
| `AppColors.surfaceVariantLight` | `#F2F2F7` | Input field fills, icon container background |
| `AppColors.outlineLight` | `#E5E5EA` | Subtle card borders & horizontal dividers |

### Dark Mode Canvas
| Token Name | Hex Code | Usage |
|---|---|---|
| `AppColors.bgDark` | `#0F1015` | Deep obsidian dark scaffold background |
| `AppColors.surfaceDark` | `#18191E` | Dark mode surface & card background |
| `AppColors.surfaceVariantDark` | `#22242C` | Dark chip fills & dark input fields |
| `AppColors.outlineDark` | `#2C2D36` | Dark mode borders & dividers |

---

## 📝 Typography & Text Palette

### Light Mode Typography
| Token Name | Hex Code | Description |
|---|---|---|
| `AppColors.textPrimaryLight` | `#121318` | Solid crisp black for main headings & body |
| `AppColors.textSecondaryLight` | `#6E6E73` | Clean medium gray for dates, subheadings & labels |
| `AppColors.textMutedLight` | `#8E8E93` | Soft muted gray for placeholders & captions |

### Dark Mode Typography
| Token Name | Hex Code | Description |
|---|---|---|
| `AppColors.textPrimaryDark` | `#FFFFFF` | Pure crisp white for dark mode body text |
| `AppColors.textSecondaryDark` | `#A1A5B0` | Cool soft gray for dark mode subheadings |
| `AppColors.textMutedDark` | `#6E717C` | Muted slate gray for dark captions |

---

## 🚦 Semantic & Status System

| State | Hex Code | Background | Text / Foreground | Description |
|---|---|---|---|---|
| **Success / Active** | `#121318` | `AppColors.successLight` (`#F4F5F7`) | `AppColors.success` (`#121318`) | Healthy state / transaction amount |
| **Warning / Expiring** | `#FF9500` | `AppColors.warningLight` (`#FFF8E6`) | `AppColors.warning` (`#FF9500`) | Warranties expiring within 30 days |
| **Error / Expired** | `#C83232` | `AppColors.errorLight` (`#FDE6E6`) | `AppColors.error` (`#C83232`) | Expired warranties, destructive actions |

---

## 🛡️ Warranty Badge Color System

| Status State | Label Example | Background Color | Text / Foreground |
|---|---|---|---|
| **Healthy** | `"186D LEFT"` | `AppColors.warrantyGreenBg` (`#F4F5F7`) | `AppColors.warrantyGreenFg` (`#121318`) |
| **Expiring Soon** | `"12D LEFT"` | `AppColors.warrantyAmberBg` (`#FFF0DC`) | `AppColors.warrantyAmberFg` (`#E8920A`) |
| **Expired** | `"EXPIRED"` | `AppColors.warrantyRedBg` (`#FDE6E6`) | `AppColors.warrantyRedFg` (`#C83232`) |

---

## 🏷️ Category Chip Color Palette

| Category | Background Color | Text / Foreground | Color Visual |
|---|---|---|---|
| **Electronics** | `AppColors.catElectrBg` (`#E8EEF8`) | `AppColors.catElectrFg` (`#3B537E`) | Soft Blue / Slate Blue |
| **Food** | `AppColors.catFoodBg` (`#FCEFDF`) | `AppColors.catFoodFg` (`#8E562E`) | Soft Peach / Warm Brown |
| **Grocery** | `AppColors.catGroceryBg` (`#F4F5F7`) | `AppColors.catGroceryFg` (`#121318`) | Soft Gray / Sleek Black |
| **Fashion** | `AppColors.catFashionBg` (`#FBEAF0`) | `AppColors.catFashionFg` (`#8E3253`) | Soft Pink / Maroon |
| **Travel** | `AppColors.catTravelBg` (`#F0EDFA`) | `AppColors.catTravelFg` (`#6243A4`) | Lavender / Deep Violet |
| **Health** | `AppColors.catHealthBg` (`#FCECED`) | `AppColors.catHealthFg` (`#AA2B3E`) | Soft Rose / Dark Crimson |
| **Other** | `AppColors.catOtherBg` (`#EBEBEB`) | `AppColors.catOtherFg` (`#6B6B6B`) | Neutral Gray / Warm Gray |

---

## ⚙️ Flutter Usage Example

```dart
import 'package:flutter/material.dart';
import 'core/theme/colors.dart';

// Example: Styling a warranty chip
Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(
    color: AppColors.warrantyAmberBg,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    '15D LEFT',
    style: TextStyle(
      color: AppColors.warrantyAmberFg,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    ),
  ),
);
```
