# ReceiptVault Flutter Codebase Context

This file contains the configuration, documentation, and source code of the ReceiptVault Flutter app to provide full context to an LLM.

# File: pubspec.yaml

```yaml
name: receiptvault_flutter
description: ReceiptVault - personal purchase and warranty manager.
version: 1.0.0+1
publish_to: none

environment:
  sdk: ">=3.4.0 <4.0.0"
  flutter: ">=3.22.0"

dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.0
  shared_preferences: ^2.3.3
  intl: ^0.19.0
  flutter_staggered_animations: ^1.1.1
  firebase_core: ^3.10.0
  cloud_firestore: ^5.6.1
  firebase_auth: ^5.4.1
  firebase_storage: ^12.3.6
  cloud_functions: ^5.2.0
  google_fonts: ^8.1.0
  google_mlkit_text_recognition: ^0.13.0
  image: ^4.3.0
  image_picker: ^1.1.2
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  http: ^1.6.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.9
  freezed: ^2.4.7
  json_serializable: ^6.8.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/logo.png
    - assets/images/safe_scanner.png

```

---

# Documentation File: docs/category-icon-map.md

# ReceiptVault — Category Icon Map

**Single source of truth** for category → icon + color pairs.  
All screens that render a category chip or icon must read from this table.

---

## Category Definitions

| Category (string) | Icon (`Icons.*`) | Chip BG | Chip Text |
|---|---|---|---|
| `Electronics` | `devices` | `#E8EEF8` | `#3B537E` |
| `Food` | `restaurant` | `#FCEFDF` | `#8E562E` |
| `Grocery` | `local_grocery_store` | `#E6F4EE` | `#1B6B47` |
| `Fashion` | `checkroom` | `#FBEAF0` | `#8E3253` |
| `Travel` | `flight` | `#F0EDFA` | `#6243A4` |
| `Health` | `favorite` | `#FCECED` | `#AA2B3E` |
| `Other` (fallback) | `receipt_long` | `#EBEBEB` | `#6B6B6B` |

---

## Dart Helper Pattern

Whenever a widget needs a category color pair or icon, use a switch expression rather than duplicating `if/else` chains inline:

```dart
(Color bg, Color fg) categoryColors(String category) => switch (category) {
  'Electronics' => (const Color(0xFFE8EEF8), const Color(0xFF3B537E)),
  'Food'        => (const Color(0xFFFCEFDF), const Color(0xFF8E562E)),
  'Grocery'     => (const Color(0xFFE6F4EE), const Color(0xFF1B6B47)),
  'Fashion'     => (const Color(0xFFFBEAF0), const Color(0xFF8E3253)),
  'Travel'      => (const Color(0xFFF0EDFA), const Color(0xFF6243A4)),
  'Health'      => (const Color(0xFFFCECED), const Color(0xFFAA2B3E)),
  _             => (const Color(0xFFEBEBEB), const Color(0xFF6B6B6B)),
};

IconData categoryIcon(String category) => switch (category) {
  'Electronics' => Icons.devices,
  'Food'        => Icons.restaurant,
  'Grocery'     => Icons.local_grocery_store,
  'Fashion'     => Icons.checkroom,
  'Travel'      => Icons.flight,
  'Health'      => Icons.favorite,
  _             => Icons.receipt_long,
};
```

---

## Rules

- **String matching is case-sensitive** — categories are stored title-case (e.g. `"Electronics"`, not `"electronics"`).
- **Always provide a fallback** — unrecognised categories fall through to `Other`.
- **Do not add one-off colors** — if a new category is added to the data model, add a row to this table first, then update `AppColors` in `lib/core/theme/colors.dart`.


---

# Documentation File: docs/color-theme.md

# ReceiptVault — Color Theme Reference

**Locked palette. Do not change without updating this file.**  
Source of truth: `lib/core/theme/colors.dart` → aliased in `lib/theme/colors.dart`.

---

## Primary Brand Colors

| Token | Hex | Usage |
|---|---|---|
| `AppColors.primary` / `kPrimary` | `#1B6B47` | FAB, active nav, filled buttons, hero accent |
| `AppColors.primaryDark` / `kPrimaryDark` | `#156039` | Pressed/contrast states, light-mode ColorScheme primary |
| `AppColors.primaryMid` / `kSecondary` | `#1E7A52` | Active icons dark mode, text links |
| `AppColors.primaryLight` / `kPrimaryLight` | `#E6F4EE` | Active badges, light pill backgrounds |
| `AppColors.accent` | `#22A06B` | "See All" links, underlines |
| `AppColors.accentCoral` | `#E07856` | Sparing highlight only — do not overuse |

---

## Backgrounds & Surfaces

### Light Mode
| Token | Hex | Usage |
|---|---|---|
| `kLightBackground` | `#F0F0F0` | Page/scaffold background |
| `kLightSurface` | `#FFFFFF` | Cards, bottom sheets |
| `kLightSurfaceVariant` | `#E8E8E8` | Chip fills, input backgrounds |
| `kLightOutline` | `#DCDCDC` | Dividers, borders |

### Dark Mode
| Token | Hex | Usage |
|---|---|---|
| `kDarkBackground` | `#141311` | Page/scaffold background |
| `kDarkSurface` | `#1F1D1A` | Cards, bottom sheets |
| `kDarkSurfaceVariant` | `#2A2723` | Chip fills, input backgrounds |
| `kDarkOutline` | `#38342E` | Dividers, borders |

---

## Text Colors

### Light Mode
| Token | Hex | Usage |
|---|---|---|
| `AppColors.textPrimaryLight` | `#1A1A1A` | Primary body text |
| `AppColors.textSecondaryLight` | `#6B6B6B` | Dates, labels, subtext |
| `AppColors.textMutedLight` | `#9E9E9E` | Placeholders, captions |

### Dark Mode
| Token | Hex | Usage |
|---|---|---|
| `AppColors.textPrimaryDark` | `#F2EFE9` | Primary body text (warm sand white) |
| `AppColors.textSecondaryDark` | `#A39F97` | Dates, labels, subtext |
| `AppColors.textMutedDark` | `#6E6A63` | Placeholders, captions |

---

## Semantic / Status Colors

| Token | Hex | Usage |
|---|---|---|
| `kSuccess` | `#1B6B47` | Active warranty, success states |
| `kSuccessLight` | `#E6F4EE` | Success background pill |
| `kWarning` | `#E8920A` | Expiring soon, amber alert |
| `kWarningLight` | `#FFF8E6` | Warning banner background |
| `AppColors.warningBorder` | `#E8920A` | Warning banner border |
| `kError` | `#C83232` | Expired, destructive action |
| `AppColors.errorLight` | `#FDE6E6` | Error/expired background |

---

## Warranty Badge Colors

| State | Background | Foreground |
|---|---|---|
| Healthy (e.g. "186D LEFT") | `#E6F4EE` | `#1B6B47` |
| Amber (e.g. "12D LEFT") | `#FFF0DC` | `#E8920A` |
| Expired | `#FDE6E6` | `#C83232` |

---

## Category Chip Colors

| Category | Background | Text |
|---|---|---|
| Electronics | `#E8EEF8` | `#3B537E` |
| Food | `#FCEFDF` | `#8E562E` |
| Grocery | `#E6F4EE` | `#1B6B47` |
| Fashion | `#FBEAF0` | `#8E3253` |
| Travel | `#F0EDFA` | `#6243A4` |
| Health | `#FCECED` | `#AA2B3E` |
| Other | `#EBEBEB` | `#6B6B6B` |

> See `docs/category-icon-map.md` for the full category → icon mapping.


---

# Documentation File: docs/design-principles.md

# ReceiptVault — Design Principles

**10 core UX rules. Treat these as constraints, not suggestions.**  
When in doubt, default to whichever option is most consistent with these principles.

---

## 1. One Primary Action Per Screen

Every screen has exactly one primary CTA (FilledButton or FAB). Secondary actions use OutlinedButton or text links. Never show two filled buttons side by side.

## 2. Progressive Disclosure

Show summary first, details on demand. Receipt list → receipt detail → full OCR text. Don't surface raw data before the user has opted into seeing it.

## 3. Thumb-Friendly Layout

Interactive elements (buttons, list items, chips) have a minimum tap target of 48×48dp. Bottom nav, FAB, and primary actions sit in the lower third of the screen. Destructive actions are never in thumb-reach by default.

## 4. Consistent Hierarchy with Plus Jakarta Sans

- **Screen titles**: `headlineLarge` (26sp, w700)
- **Card/section titles**: `titleMedium` (16sp, w600)
- **Body / form labels**: `bodyMedium` (14sp, w400)
- **Muted metadata**: `bodySmall` (12sp, w400, 65% opacity)
- **Buttons**: `labelLarge` (15sp, w600)
- **Overline/labels**: `labelSmall` (11sp, w500, 0.5px letter-spacing)

Never use raw `TextStyle` inline when a theme text style maps to the intent.

## 5. Color Carries Meaning — Use Tokens, Not Raw Hex

Always use `AppColors.*` / `k*` tokens. Raw hex values are banned except in `lib/core/theme/colors.dart`. Semantic colors (success/warning/error) are strictly reserved for their semantic purpose.

## 6. Cards Have Zero Elevation by Default

`CardThemeData` uses `elevation: 0` with `borderRadius: 16`. Depth comes from background contrast (`#FFFFFF` card on `#F0F0F0` bg in light mode), not shadow. Only use elevation for modals/bottom sheets.

## 7. Empty States Are Friendly, Not Empty

Every list/collection screen must have an illustrated (or icon-based) empty state with a short human message and a primary action to add content. No naked "No items found" text.

## 8. Category and Status Chips Are Pill-Shaped

Chips use `borderRadius: 8` from the chip theme. Category chips always show bg + fg pair from `docs/color-theme.md`. Status badges (warranty) always use the three-state palette (green/amber/red). Never improvise a one-off chip color.

## 9. Navigation Uses the Bottom NavigationBar

The app uses `NavigationBar` (Material 3). Tab indices are stable — do not reorder tabs without updating all deep links and filter logic. Active indicator uses `kPrimary` at 20% opacity.

## 10. Forms Validate Inline, Not on Submit

Show validation errors beneath the relevant field as soon as the field loses focus (not on submit). Use `kError` (#C83232) for error text, `errorBorder` in `InputDecorationTheme`. Never surface a generic "Form has errors" toast.


---

# Documentation File: docs/known-fixes.md

# ReceiptVault — Known Fixes Log

Running log of bugs identified and resolved. Check here before re-diagnosing any issue.  
Format: `[YYYY-MM-DD] Screen/component — what was wrong → what was fixed`

---

## Open / Pending

*(none logged yet)*

---

## Resolved

*(Add entries below as fixes are applied — newest first)*

---

## Rules for This File

- One line per fix; link the screen/widget if helpful.
- If the same bug reappears, add a note rather than a new entry.
- When a fix introduces a new **design rule**, also append it to `docs/design-principles.md`.
- Do not remove resolved entries — they serve as a record against regression.


---

# File: lib/main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'features/auth/data/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool isFirebaseAvailable = false;
  try {
    await Firebase.initializeApp();
    isFirebaseAvailable = true;
    debugPrint('Firebase connected successfully.');
  } catch (e) {
    debugPrint('Firebase not configured. Using local fallback store. ($e)');
  }

  runApp(
    ProviderScope(
      overrides: [
        firebaseAvailableProvider.overrideWith((ref) => isFirebaseAvailable),
      ],
      child: const ReceiptVaultApp(),
    ),
  );
}

class ReceiptVaultApp extends ConsumerWidget {
  const ReceiptVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ReceiptVault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

```

---

# File: lib/core/constants/app_constants.dart

```dart
class AppConstants {
  static const String appName = 'ReceiptVault';
  static const String currencyRupee = '₹';
  static const String currencyUsd = '\$';
  
  static const String mockUserId = 'sarah_kapur_mock_id';
  static const String defaultProfileImage = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80';
}

```

---

# File: lib/core/router/app_router.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../screens/splash/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/dashboard_screen.dart';
import '../../features/receipt/presentation/scan_receipt_screen.dart';
import '../../features/receipt/presentation/receipt_preview_screen.dart';
import '../../features/receipt/presentation/receipt_details_screen.dart';
import '../../features/warranty/presentation/warranty_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../widgets/bottom_nav_bar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => const NoTransitionPage(child: SearchScreen()),
          ),
          GoRoute(
            path: '/warranty',
            pageBuilder: (context, state) => const NoTransitionPage(child: WarrantyScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (context, state) => const NoTransitionPage(child: AnalyticsScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/scan',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ScanReceiptScreen(),
      ),
      GoRoute(
        path: '/preview',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ReceiptPreviewScreen(
            imagePath: extra?['imagePath'] as String?,
            ocrText: extra?['ocrText'] as String?,
            imagePaths: (extra?['imagePaths'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
            initialPaymentMethod: extra?['paymentMethod'] as String?,
            parsedData: extra?['parsedData'] as Map<String, dynamic>?,
          );
        },
      ),
      GoRoute(
        path: '/receipt/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ReceiptDetailsScreen(receiptId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),

    ],
  );
});

```

---

# File: lib/core/services/cloud_functions_service.dart

```dart
import 'dart:async';
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class CloudFunctionsService {
  static const _geminiCallTimeout = Duration(seconds: 25);

  /// Calls Gemini 2.5 Flash via Firebase Cloud Functions
  /// or falls back to local regex extraction if Firebase is offline,
  /// errors out, OR takes too long.
  Future<Map<String, dynamic>> parseReceiptText(String ocrText, {bool isFirebaseAvailable = false}) async {
    if (isFirebaseAvailable) {
      try {
        final result = await FirebaseFunctions.instance
            .httpsCallable('parseReceiptWithGemini')
            .call({'text': ocrText})
            .timeout(
              _geminiCallTimeout,
              onTimeout: () => throw TimeoutException(
                'Gemini Cloud Function exceeded ${_geminiCallTimeout.inSeconds}s',
              ),
            );
        
        final dynamic rawData = result.data;
        if (rawData is Map) {
          return Map<String, dynamic>.from(rawData);
        } else if (rawData is String) {
          return Map<String, dynamic>.from(jsonDecode(rawData));
        }
      } catch (e) {
        debugPrint('Cloud Function call failed or timed out: $e. Falling back to local parser.');
      }
    }
    
    return _parseOcrTextLocally(ocrText);
  }

  /// Backup parser executing locally via regex parsing models
  Map<String, dynamic> _parseOcrTextLocally(String text) {
    final lowerText = text.toLowerCase();
    
    // 1. Guess Merchant
    String merchant = 'Store | General Merchant';
    if (lowerText.contains('croma')) {
      merchant = 'Coffee Maker | Croma';
    } else if (lowerText.contains('starbucks')) {
      merchant = 'Starbucks Coffee';
    } else if (lowerText.contains('zara')) {
      merchant = 'Zara Fashion';
    } else if (lowerText.contains('grocer') || lowerText.contains('zepto')) {
      merchant = 'Zepto';
    } else if (lowerText.contains('reliance')) {
      merchant = 'Reliance Digital';
    }

    // 2. Guess Category
    String category = 'Other';
    if (lowerText.contains('food') || lowerText.contains('cafe') || lowerText.contains('starbucks') || lowerText.contains('coffee') || lowerText.contains('restaurant')) {
      category = 'Food';
    } else if (lowerText.contains('croma') || lowerText.contains('digital') || lowerText.contains('reliance') || lowerText.contains('electronics') || lowerText.contains('computer') || lowerText.contains('phone')) {
      category = 'Electronics';
    } else if (lowerText.contains('zara') || lowerText.contains('apparel') || lowerText.contains('clothes') || lowerText.contains('shirt') || lowerText.contains('fashion')) {
      category = 'Fashion';
    } else if (lowerText.contains('grocer') || lowerText.contains('zepto') || lowerText.contains('basket') || lowerText.contains('milk') || lowerText.contains('supermarket')) {
      category = 'Grocery';
    } else if (lowerText.contains('uber') || lowerText.contains('flight') || lowerText.contains('travel') || lowerText.contains('cab') || lowerText.contains('metro') || lowerText.contains('ticket')) {
      category = 'Travel';
    } else if (lowerText.contains('pharmacy') || lowerText.contains('health') || lowerText.contains('medical') || lowerText.contains('doctor') || lowerText.contains('hospital') || lowerText.contains('clinic')) {
      category = 'Health';
    }

    // 3. Guess Currency
    String currency = '₹';
    if (lowerText.contains('\$') || lowerText.contains('usd') || lowerText.contains('dollars')) {
      currency = '\$';
    }

    // 4. Extract Total Amount
    double totalAmount = 0.0;
    final amountRegex = RegExp(r'(?:₹|Rs\.?|INR|\$)?\s*(\d{1,6}(?:\.\d{2})?)');
    final matches = amountRegex.allMatches(text);
    
    final lines = text.split('\n');
    for (final line in lines) {
      final l = line.toLowerCase();
      if (l.contains('total') || l.contains('net') || l.contains('amount') || l.contains('due')) {
        final match = amountRegex.firstMatch(line);
        if (match != null) {
          totalAmount = double.tryParse(match.group(1) ?? '0.0') ?? 0.0;
          break;
        }
      }
    }

    if (totalAmount == 0.0 && matches.isNotEmpty) {
      // Find the largest amount if no keyword match
      double maxAmt = 0.0;
      for (final m in matches) {
        final val = double.tryParse(m.group(1) ?? '0.0') ?? 0.0;
        if (val > maxAmt) maxAmt = val;
      }
      totalAmount = maxAmt;
    }

    if (totalAmount == 0.0) {
      totalAmount = 299.00; // standard mock default
    }

    double tax = (totalAmount * 0.05); // 5% guess

    // 5. Extract Invoice Number
    String invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    final invRegex = RegExp(r'(?:inv|invoice|bill|receipt)\s*(?:no|num|#)?\s*([a-zA-Z0-9\-]{4,15})', caseSensitive: false);
    final invMatch = invRegex.firstMatch(text);
    if (invMatch != null) {
      invoiceNumber = invMatch.group(1) ?? invoiceNumber;
    }

    // 6. Guess Warranty Months
    int? warrantyMonths;
    if (lowerText.contains('warranty') || lowerText.contains('guarantee') || category == 'Electronics') {
      warrantyMonths = 12; // default 1 year on electronics
      if (lowerText.contains('2 year') || lowerText.contains('24 month')) {
        warrantyMonths = 24;
      } else if (lowerText.contains('3 year') || lowerText.contains('36 month')) {
        warrantyMonths = 36;
      }
    }

    return {
      'merchant': merchant,
      'category': category,
      'purchaseDate': DateTime.now().toIso8601String(),
      'currency': currency,
      'subtotal': totalAmount - tax,
      'tax': tax,
      'totalAmount': totalAmount,
      'paymentMethod': lowerText.contains('card') ? 'Credit Card' : 'UPI',
      'invoiceNumber': invoiceNumber,
      'warrantyMonths': warrantyMonths,
      'products': [
        {'name': 'General Item', 'quantity': 1, 'price': totalAmount - tax}
      ]
    };
  }
}

```

---

# File: lib/core/services/ocr_service.dart

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class OcrService {
  /// Runs Google ML Kit local OCR pipeline after pre-processing low contrast images
  static Future<RecognizedText> recognizeReceiptText(File imageFile) async {
    // 1. Image preprocessing (Sharpen / Convert grayscale to improve ML Kit recognition accuracy)
    final File processedFile = await _preprocessImage(imageFile);

    // 2. Instantiate local ML Kit text recognizer
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final InputImage inputImage = InputImage.fromFile(processedFile);
    
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText;
    } finally {
      await textRecognizer.close();
    }
  }

  static Future<File> _preprocessImage(File originalFile) async {
    try {
      final bytes = await originalFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return originalFile;

      // Apply Grayscale and Contrast enhancement filter
      img.grayscale(image);
      img.adjustColor(image, contrast: 1.2);

      final processedBytes = img.encodeJpg(image, quality: 85);
      final String tempPath = originalFile.path.replaceAll('.jpg', '_processed.jpg');
      final File tempFile = File(tempPath);
      await tempFile.writeAsBytes(processedBytes);
      return tempFile;
    } catch (_) {
      return originalFile;
    }
  }
}

class ReceiptProcessingError implements Exception {
  final String code;
  final String message;
  final bool isTransient;

  ReceiptProcessingError({
    required this.code,
    required this.message,
    this.isTransient = false,
  });

  @override
  String toString() => 'ReceiptProcessingError[$code]: $message';
}

enum ReceiptProcessingState {
  idle,
  capturing,
  preparingImage,
  readingText,
  analysingReceipt,
  validating,
  completed,
  failed,
  cancelled,
}

class ReceiptItem {
  final String name;
  final int quantity;
  final double price;

  ReceiptItem({required this.name, this.quantity = 1, required this.price});

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      name: json['name'] as String? ?? 'Unknown Item',
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ReceiptData {
  final String? merchantName;
  final String? purchaseDate;
  final double? total;
  final double? tax;
  final List<ReceiptItem> items;

  ReceiptData({
    this.merchantName,
    this.purchaseDate,
    this.total,
    this.tax,
    this.items = const [],
  });

  factory ReceiptData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return ReceiptData(
      merchantName: json['merchantName'] as String?,
      purchaseDate: json['purchaseDate'] as String?,
      total: (json['total'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      items: rawItems.map((e) => ReceiptItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  ReceiptData copyWith({
    String? merchantName,
    String? purchaseDate,
    double? total,
    double? tax,
    List<ReceiptItem>? items,
  }) {
    return ReceiptData(
      merchantName: merchantName ?? this.merchantName,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      total: total ?? this.total,
      tax: tax ?? this.tax,
      items: items ?? this.items,
    );
  }
}

class LocalReceiptParser {
  static bool isUsableReceiptText(String text) {
    final normalized = text.trim();
    if (normalized.length < 20) return false;
    
    final containsAmount = RegExp(r'\d+[.,]\d{2}').hasMatch(normalized);
    final containsKeyword = RegExp(
      r'(total|subtotal|tax|amount|invoice|receipt|bill|gst|vat)', 
      caseSensitive: false
    ).hasMatch(normalized);

    return containsAmount || containsKeyword;
  }

  static ReceiptData parseReceiptLocally(String rawText) {
    final lines = rawText.split('\n');
    double? detectedTotal;
    String? detectedDate;

    final dateRegex = RegExp(r'(\d{2}[-/.]\d{2}[-/.]\d{2,4})');
    final totalRegex = RegExp(r'(?:total|grand\s+total|amt\s+due)[:\s$]+(\d+[.,]\d{2})', caseSensitive: false);

    for (final line in lines) {
      if (detectedDate == null) {
        final dateMatch = dateRegex.firstMatch(line);
        if (dateMatch != null) detectedDate = dateMatch.group(1);
      }
      if (detectedTotal == null) {
        final totalMatch = totalRegex.firstMatch(line);
        if (totalMatch != null) {
          final matchedStr = totalMatch.group(1)!.replaceAll(',', '.');
          detectedTotal = double.tryParse(matchedStr);
        }
      }
    }

    return ReceiptData(
      total: detectedTotal,
      purchaseDate: detectedDate,
      merchantName: lines.isNotEmpty ? lines.first.trim() : null,
      items: const [],
    );
  }
}

class ReceiptProcessingManager {
  ReceiptProcessingState _state = ReceiptProcessingState.idle;
  String? _errorMessage;
  String? _warningMessage;
  bool _isProcessingLock = false;
  String? _currentScanId;

  // Configuration parameters
  final Duration ocrTimeout = const Duration(seconds: 15);
  final Duration geminiTimeout = const Duration(seconds: 30);
  
  // Callbacks hooked to your Flutter State management notifier
  void Function(ReceiptProcessingState state)? onStateChanged;
  void Function(String? error, String? warning)? onMessagesChanged;
  void Function(ReceiptData data)? onScanSuccess;

  ReceiptProcessingState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get warningMessage => _warningMessage;

  void _updateState(ReceiptProcessingState newState) {
    _state = newState;
    onStateChanged?.call(_state);
  }

  void _updateMessages({String? error, String? warning}) {
    _errorMessage = error;
    _warningMessage = warning;
    onMessagesChanged?.call(_errorMessage, _warningMessage);
  }

  Future<void> processReceipt({
    required String? imageUri,
    required Future<String> Function(String) ocrEngine,
    required bool Function() isMountedCheck,
  }) async {
    // 1. Strict concurrency block check
    if (_isProcessingLock) return;

    final scanId = Random().nextInt(1000000).toString();
    _currentScanId = scanId;
    _isProcessingLock = true;

    _updateState(ReceiptProcessingState.preparingImage);
    _updateMessages(error: null, warning: null);

    ReceiptData localFallback = ReceiptData();

    try {
      // 2. Preprocessing verification stage
      if (imageUri == null || imageUri.isEmpty) {
        throw ReceiptProcessingError(code: 'MISSING_URI', message: 'Target image locator reference is invalid');
      }

      if (!isMountedCheck()) return;

      // 3. Document text extraction stage
      _updateState(ReceiptProcessingState.readingText);
      final String ocrText = await ocrEngine(imageUri).timeout(
        ocrTimeout,
        onTimeout: () => throw ReceiptProcessingError(
          code: 'MLKIT_TIMEOUT', 
          message: 'Local machine character scanning exceeded performance threshold',
          isTransient: true,
        ),
      );

      if (_currentScanId != scanId || !isMountedCheck()) return;

      if (!LocalReceiptParser.isUsableReceiptText(ocrText)) {
        throw ReceiptProcessingError(
          code: 'INSUFFICIENT_OCR_TEXT', 
          message: 'Insufficient transaction validation parameters found within raw document data',
        );
      }

      localFallback = LocalReceiptParser.parseReceiptLocally(ocrText);

      // 4. Cloud Enrichment Layer
      _updateState(ReceiptProcessingState.analysingReceipt);
      ReceiptData? enhancedResult;

      try {
        final response = await http.post(
          Uri.parse('https://your-backend.api/api/receipts/extract'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'scanId': scanId,
            'ocrText': ocrText,
            'currencyHint': 'INR',
          }),
        ).timeout(geminiTimeout);

        if (response.statusCode == 200) {
          final decodedBody = jsonDecode(response.body) as Map<String, dynamic>;
          if (decodedBody['receipt'] != null) {
            enhancedResult = ReceiptData.fromJson(decodedBody['receipt'] as Map<String, dynamic>);
          }
        } else {
          throw Exception('Http Server Error Status: ${response.statusCode}');
        }
      } catch (geminiException) {
        // Safe contextual recovery fallthrough handling
        if (isMountedCheck() && _currentScanId == scanId) {
          _updateMessages(warning: 'Advanced structural inference was unavailable. Populating standard data matrices.');
        }
      }

      if (_currentScanId != scanId || !isMountedCheck()) return;

      // 5. Context Merging & Finalization State
      _updateState(ReceiptProcessingState.validating);
      
      final finalData = localFallback.copyWith(
        merchantName: enhancedResult?.merchantName ?? localFallback.merchantName,
        purchaseDate: enhancedResult?.purchaseDate ?? localFallback.purchaseDate,
        total: enhancedResult?.total ?? localFallback.total,
        tax: enhancedResult?.tax ?? localFallback.tax,
        items: enhancedResult?.items != null && enhancedResult!.items.isNotEmpty 
            ? enhancedResult.items 
            : localFallback.items,
      );

      _updateState(ReceiptProcessingState.completed);
      onScanSuccess?.call(finalData);

    } on ReceiptProcessingError catch (customError) {
      if (_currentScanId == scanId && isMountedCheck()) {
        _updateState(ReceiptProcessingState.failed);
        _updateMessages(error: customError.message);
      }
    } catch (genericException) {
      if (_currentScanId == scanId && isMountedCheck()) {
        _updateState(ReceiptProcessingState.failed);
        _updateMessages(error: 'System core execution faulted during asset conversion pipelines');
      }
    } finally {
      // 6. Mandatory processing safety release ring
      if (_currentScanId == scanId) {
        _isProcessingLock = false;
      }
    }
  }

  void cancelProcessing() {
    _currentScanId = null;
    _isProcessingLock = false;
    _updateState(ReceiptProcessingState.cancelled);
  }
}

```

---

# File: lib/core/services/storage_service.dart

```dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

class StorageService {
  /// Compresses image locally before uploading to storage / local file storage reference
  Future<String> uploadReceiptImage(File imageFile, String userId, {bool isFirebaseAvailable = false}) async {
    // 1. Compress image to reduce storage usage and network latency
    final File compressedFile = await _compressImage(imageFile);

    if (isFirebaseAvailable) {
      final fileName = 'receipts/${userId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await ref.putFile(compressedFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } else {
      // Local fallback: returns local path location
      return compressedFile.path;
    }
  }

  static Future<File> _compressImage(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return file;

    // Resize image to width 1080 (maintaining aspect ratio) to compress size
    final resized = img.copyResize(image, width: 1080);
    final compressedBytes = img.encodeJpg(resized, quality: 75);
    
    final tempPath = file.path.replaceAll('.jpg', '_compressed.jpg');
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(compressedBytes);
    return tempFile;
  }
}

```

---

# File: lib/core/theme/colors.dart

```dart
import 'package:flutter/material.dart';

/// AppColors — Reference-matched palette: light gray bg, forest/emerald green primary.
/// Matches the dashboard reference: #F0F0F0 page, white cards, #1B6B47 green hero.
class AppColors {
  // ── Backgrounds ────────────────────────────────────────────────────────────
  /// Light gray page background (#F0F0F0) — matches reference screenshot exactly
  static const Color bgLight = Color(0xFFF0F0F0);
  /// Pure white (#FFFFFF) for receipt cards — creates depth against gray bg
  static const Color surfaceLight = Color(0xFFFFFFFF);
  /// Slightly deeper gray (#E8E8E8) for chip fills, input backgrounds
  static const Color surfaceVariantLight = Color(0xFFE8E8E8);
  /// Subtle gray outline/divider (#DCDCDC)
  static const Color outlineLight = Color(0xFFDCDCDC);

  /// Warm dark charcoal for dark mode background
  static const Color bgDark = Color(0xFF141311);
  /// Warm dark surface for cards in dark mode
  static const Color surfaceDark = Color(0xFF1F1D1A);
  /// Dark variant surface for chips/inputs
  static const Color surfaceVariantDark = Color(0xFF2A2723);
  /// Dark outline/divider
  static const Color outlineDark = Color(0xFF38342E);

  // ── Primary Palette (Forest/Emerald Green) ─────────────────────────────────
  /// Forest/Emerald green (#1B6B47) — hero card, FAB, active nav, primary buttons
  static const Color primary = Color(0xFF1B6B47);
  /// Darker forest green (#156039) for pressed/contrast states
  static const Color primaryDark = Color(0xFF156039);
  /// Mid-tone emerald (#1E7A52) for active icons in dark mode / text links
  static const Color primaryMid = Color(0xFF1E7A52);
  /// Soft mint tint (#E6F4EE) for active badges and light pill backgrounds
  static const Color primaryLight = Color(0xFFE6F4EE);

  // ── Accents ────────────────────────────────────────────────────────────────
  /// Lighter emerald (#22A06B) for text links like "See All" and underlines
  static const Color accent = Color(0xFF22A06B);
  /// Muted coral (#E07856) for sparing highlights
  static const Color accentCoral = Color(0xFFE07856);

  // ── Text Palette ───────────────────────────────────────────────────────────
  /// Primary text (#1A1A1A) — near-black, slightly soft
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  /// Secondary text (#6B6B6B) — gray for dates, labels, subtext
  static const Color textSecondaryLight = Color(0xFF6B6B6B);
  /// Muted text (#9E9E9E) for subtle placeholders/captions
  static const Color textMutedLight = Color(0xFF9E9E9E);

  /// Primary text for dark mode (#F2EFE9) — warm sand white
  static const Color textPrimaryDark = Color(0xFFF2EFE9);
  /// Secondary text for dark mode (#A39F97) — warm dark gray
  static const Color textSecondaryDark = Color(0xFFA39F97);
  /// Muted text for dark mode (#6E6A63)
  static const Color textMutedDark = Color(0xFF6E6A63);

  // ── Semantic / Status Colors ───────────────────────────────────────────────
  /// Success / Active Warranty — forest green
  static const Color success = Color(0xFF1B6B47);
  static const Color successLight = Color(0xFFE6F4EE);

  /// Warning / Expiring soon (#E8920A — amber/orange matching reference)
  static const Color warning = Color(0xFFE8920A);
  /// Warning background (#FFF8E6 — pale amber cream matching reference alert banner)
  static const Color warningLight = Color(0xFFFFF8E6);
  /// Warning border (#E8920A — same amber for banner border)
  static const Color warningBorder = Color(0xFFE8920A);

  /// Destructive / Expired (#C83232 — rust red)
  static const Color error = Color(0xFFC83232);
  /// Destructive/Expired background (#FDE6E6)
  static const Color errorLight = Color(0xFFFDE6E6);

  // ── Warranty Badges ────────────────────────────────────────────────────────
  /// Healthy ("186D LEFT") — soft mint background (#E6F4EE)
  static const Color warrantyGreenBg = Color(0xFFE6F4EE);
  /// Healthy text — forest green (#1B6B47)
  static const Color warrantyGreenFg = Color(0xFF1B6B47);
  /// Amber ("12D LEFT") — pale orange background (#FFF0DC)
  static const Color warrantyAmberBg = Color(0xFFFFF0DC);
  /// Amber text — dark amber (#E8920A)
  static const Color warrantyAmberFg = Color(0xFFE8920A);
  /// Red ("EXPIRED") — soft red background (#FDE6E6)
  static const Color warrantyRedBg = Color(0xFFFDE6E6);
  /// Red text — rust red (#C83232)
  static const Color warrantyRedFg = Color(0xFFC83232);

  // ── Category Chip Colors ───────────────────────────────────────────────────
  // Electronics: soft blue-gray (#E8EEF8), dark blue-gray text (#3B537E)
  static const Color catElectrBg = Color(0xFFE8EEF8);
  static const Color catElectrFg = Color(0xFF3B537E);

  // Food: soft peach (#FCEFDF), warm brown text (#8E562E)
  static const Color catFoodBg = Color(0xFFFCEFDF);
  static const Color catFoodFg = Color(0xFF8E562E);

  // Grocery: soft mint (#E6F4EE), dark green text (#1B6B47)
  static const Color catGroceryBg = Color(0xFFE6F4EE);
  static const Color catGroceryFg = Color(0xFF1B6B47);

  // Fashion: soft pink (#FBEAF0), dark pink/maroon text (#8E3253)
  static const Color catFashionBg = Color(0xFFFBEAF0);
  static const Color catFashionFg = Color(0xFF8E3253);

  // Travel: soft lavender (#F0EDFA), dark violet text (#6243A4)
  static const Color catTravelBg = Color(0xFFF0EDFA);
  static const Color catTravelFg = Color(0xFF6243A4);

  // Health: soft rose (#FCECED), dark rose text (#AA2B3E)
  static const Color catHealthBg = Color(0xFFFCECED);
  static const Color catHealthFg = Color(0xFFAA2B3E);

  // Other: neutral light gray (#EBEBEB), warm gray text (#6B6B6B)
  static const Color catOtherBg = Color(0xFFEBEBEB);
  static const Color catOtherFg = Color(0xFF6B6B6B);
}

```

---

# File: lib/core/theme/theme.dart

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  // ────────────────────────────────────────────────────────── Light ──────────
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.primaryMid,
      onSecondary: Colors.white,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      error: AppColors.error,
      outline: AppColors.outlineLight,
      surfaceContainerHighest: AppColors.surfaceVariantLight,
    ),
    scaffoldBackgroundColor: AppColors.bgLight,
    fontFamily: GoogleFonts.roboto().fontFamily,
    textTheme: _textTheme(AppColors.textPrimaryLight, AppColors.textSecondaryLight),
    // ── AppBar ──────────────────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bgLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryLight,
        letterSpacing: -0.3,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
    ),
    // ── Card ────────────────────────────────────────────────────────────────
    cardTheme: const CardThemeData(
      color: AppColors.surfaceLight,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: AppColors.outlineLight, width: 0.5),
      ),
    ),
    // ── Input ───────────────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      hintStyle: GoogleFonts.roboto(
        fontSize: 15,
        color: AppColors.textMutedLight,
      ),
    ),
    // ── Elevated Button ─────────────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(double.infinity, 52),
      ),
    ),
    // ── Outlined Button ─────────────────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimaryLight,
        side: const BorderSide(color: AppColors.outlineLight, width: 1.5),
        elevation: 0,
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(double.infinity, 52),
      ),
    ),
    // ── Bottom Nav ──────────────────────────────────────────────────────────
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMutedLight,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      unselectedLabelStyle: GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.outlineLight,
      thickness: 1,
      space: 1,
    ),
  );

  // ────────────────────────────────────────────────────────── Dark ───────────
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryMid,
      onPrimary: Colors.white,
      secondary: AppColors.primaryMid,
      onSecondary: Colors.white,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      error: AppColors.error,
      outline: AppColors.outlineDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
    ),
    scaffoldBackgroundColor: AppColors.bgDark,
    fontFamily: GoogleFonts.roboto().fontFamily,
    textTheme: _textTheme(AppColors.textPrimaryDark, AppColors.textSecondaryDark),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bgDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryDark,
        letterSpacing: -0.3,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: AppColors.outlineDark, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariantDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryMid, width: 1.5),
      ),
      hintStyle: GoogleFonts.roboto(fontSize: 15, color: AppColors.textMutedDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryMid,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(double.infinity, 52),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimaryDark,
        side: const BorderSide(color: AppColors.outlineDark, width: 1.5),
        elevation: 0,
        textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(double.infinity, 52),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.primaryMid,
      unselectedItemColor: AppColors.textMutedDark,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.outlineDark, thickness: 1, space: 1),
  );

  // ── Shared text theme factory ──────────────────────────────────────────────
  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: GoogleFonts.roboto(fontSize: 32, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.5),
      displayMedium: GoogleFonts.roboto(fontSize: 26, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.3),
      displaySmall: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.2),
      headlineLarge: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w700, color: primary),
      headlineMedium: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
      headlineSmall: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      titleLarge: GoogleFonts.roboto(fontSize: 17, fontWeight: FontWeight.w700, color: primary),
      titleMedium: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w600, color: primary),
      titleSmall: GoogleFonts.roboto(fontSize: 13, fontWeight: FontWeight.w600, color: secondary),
      bodyLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400, color: primary),
      bodyMedium: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400, color: secondary),
      bodySmall: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w400, color: secondary),
      labelLarge: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600, color: primary, letterSpacing: 0.1),
      labelMedium: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w600, color: secondary, letterSpacing: 0.2),
      labelSmall: GoogleFonts.roboto(fontSize: 11, fontWeight: FontWeight.w600, color: secondary, letterSpacing: 0.4),
    );
  }
}

```

---

# File: lib/features/analytics/presentation/analytics_controller.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/presentation/dashboard_controller.dart';

class AnalyticsData {
  final double totalSpendYear;
  final double averageMonthlySpend;
  final Map<String, double> categoryDistribution;
  final Map<String, double> merchantDistribution;
  final List<MonthlySpendPoint> monthlyTrend;

  AnalyticsData({
    required this.totalSpendYear,
    required this.averageMonthlySpend,
    required this.categoryDistribution,
    required this.merchantDistribution,
    required this.monthlyTrend,
  });
}

class MonthlySpendPoint {
  final String label;
  final double amount;
  MonthlySpendPoint(this.label, this.amount);
}

final analyticsDataProvider = Provider<AnalyticsData>((ref) {
  final receipts = ref.watch(dashboardReceiptsProvider).value ?? [];
  final now = DateTime.now();
  final currentYear = now.year;

  double totalSpend = 0.0;
  Map<String, double> categoryDistribution = {};
  Map<String, double> merchantDistribution = {};
  
  final Map<int, double> monthAmountMap = {
    1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0, 5: 0.0, 6: 0.0,
    7: 0.0, 8: 0.0, 9: 0.0, 10: 0.0, 11: 0.0, 12: 0.0
  };

  for (final r in receipts) {
    if (r.purchaseDate.year == currentYear) {
      totalSpend += r.totalAmount;
      categoryDistribution[r.category] = (categoryDistribution[r.category] ?? 0.0) + r.totalAmount;
      merchantDistribution[r.merchant.split(' | ').last] = (merchantDistribution[r.merchant.split(' | ').last] ?? 0.0) + r.totalAmount;
      
      final month = r.purchaseDate.month;
      monthAmountMap[month] = (monthAmountMap[month] ?? 0.0) + r.totalAmount;
    }
  }

  final List<String> monthLabels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  final List<MonthlySpendPoint> trend = [];
  
  int monthsWithSpend = 0;
  monthAmountMap.forEach((month, amount) {
    trend.add(MonthlySpendPoint(monthLabels[month - 1], amount));
    if (amount > 0.0) {
      monthsWithSpend++;
    }
  });

  final averageMonthlySpend = monthsWithSpend > 0 ? totalSpend / monthsWithSpend : 0.0;

  return AnalyticsData(
    totalSpendYear: totalSpend,
    averageMonthlySpend: averageMonthlySpend,
    categoryDistribution: categoryDistribution,
    merchantDistribution: merchantDistribution,
    monthlyTrend: trend,
  );
});

```

---

# File: lib/features/analytics/presentation/analytics_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'analytics_controller.dart';
import '../../../core/theme/colors.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(analyticsDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSec = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final rupee = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    double maxBar = 1.0;
    for (final p in data.monthlyTrend) {
      if (p.amount > maxBar) maxBar = p.amount;
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Analytics',
          style: TextStyle(fontFamily: 'Roboto', fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Summary cards ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Yearly Spend',
                    value: rupee.format(data.totalSpendYear),
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppColors.primary,
                    iconBg: AppColors.primaryLight,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSec: textSec,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Monthly Avg',
                    value: rupee.format(data.averageMonthlySpend),
                    icon: Icons.trending_up_rounded,
                    iconColor: AppColors.catGroceryFg,
                    iconBg: AppColors.catGroceryBg,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSec: textSec,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Monthly bar chart ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monthly Spending', style: TextStyle(fontFamily: 'Roboto', fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 140,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(data.monthlyTrend.length, (i) {
                        final p = data.monthlyTrend[i];
                        final ratio = (p.amount / maxBar).clamp(0.04, 1.0);
                        final now = DateTime.now();
                        final isCurrentMonth = i == now.month - 1;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  height: 110 * ratio,
                                  decoration: BoxDecoration(
                                    color: isCurrentMonth
                                        ? AppColors.primary
                                        : (isDark ? AppColors.outlineDark : const Color(0xFFD1E9DC)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  p.label,
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 10,
                                    fontWeight: isCurrentMonth ? FontWeight.w700 : FontWeight.w400,
                                    color: isCurrentMonth ? AppColors.primary : textSec,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Category breakdown ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category Breakdown', style: TextStyle(fontFamily: 'Roboto', fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
                  const SizedBox(height: 18),
                  if (data.categoryDistribution.isEmpty)
                    Center(child: Text('No data yet', style: TextStyle(color: textSec)))
                  else
                    ...(() {
                      final sorted = data.categoryDistribution.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));
                      return sorted.map((entry) {
                        final pct = data.totalSpendYear > 0 ? entry.value / data.totalSpendYear : 0.0;
                        final barColor = _catProgressColor(entry.key);
                        final catBg = _catBg(entry.key);
                        final catIcon = _categoryIcon(entry.key);
                        final catFg = _catFg(entry.key);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(color: catBg, borderRadius: BorderRadius.circular(7)),
                                    child: Icon(catIcon, color: catFg, size: 14),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(entry.key,
                                        style: TextStyle(fontFamily: 'Roboto', fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary)),
                                  ),
                                  Text(
                                    '${rupee.format(entry.value)}  ${(pct * 100).round()}%',
                                    style: TextStyle(fontFamily: 'Roboto', fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 7,
                                  backgroundColor: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    })(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Top merchants ──────────────────────────────────────────────
            if (data.merchantDistribution.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Top Merchants', style: TextStyle(fontFamily: 'Roboto', fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
                    const SizedBox(height: 16),
                    ...((() {
                      final sorted = data.merchantDistribution.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));
                      return sorted.take(5).toList().asMap().entries.map((e) {
                        final rank = e.key + 1;
                        final entry = e.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: rank == 1 ? AppColors.primaryLight : (isDark ? AppColors.outlineDark : AppColors.surfaceVariantLight),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  '$rank',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: rank == 1 ? AppColors.primary : textSec,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(entry.key,
                                    style: TextStyle(fontFamily: 'Roboto', fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary)),
                              ),
                              Text(rupee.format(entry.value),
                                  style: TextStyle(fontFamily: 'Roboto', fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary)),
                            ],
                          ),
                        );
                      }).toList();
                    })()),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color cardBg;
  final Color textPrimary;
  final Color textSec;
  final bool isDark;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.cardBg,
    required this.textPrimary,
    required this.textSec,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(fontFamily: 'Roboto', fontSize: 12, fontWeight: FontWeight.w500, color: textSec)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontFamily: 'Roboto', fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Color _catProgressColor(String cat) {
  switch (cat.toLowerCase()) {
    case 'electronics': return AppColors.catElectrFg;
    case 'food': return AppColors.catFoodFg;
    case 'fashion': return AppColors.catFashionFg;
    case 'grocery': return AppColors.catGroceryFg;
    case 'travel': return AppColors.catTravelFg;
    case 'health': return AppColors.catHealthFg;
    default: return AppColors.catOtherFg;
  }
}

Color _catBg(String cat) {
  switch (cat.toLowerCase()) {
    case 'electronics': return AppColors.catElectrBg;
    case 'food': return AppColors.catFoodBg;
    case 'fashion': return AppColors.catFashionBg;
    case 'grocery': return AppColors.catGroceryBg;
    case 'travel': return AppColors.catTravelBg;
    case 'health': return AppColors.catHealthBg;
    default: return AppColors.catOtherBg;
  }
}

Color _catFg(String cat) => _catProgressColor(cat);

IconData _categoryIcon(String cat) {
  switch (cat.toLowerCase()) {
    case 'electronics': return Icons.electrical_services_rounded;
    case 'food': return Icons.restaurant_rounded;
    case 'fashion': return Icons.shopping_bag_rounded;
    case 'grocery': return Icons.shopping_cart_rounded;
    case 'travel': return Icons.flight_takeoff_rounded;
    case 'health': return Icons.local_hospital_rounded;
    default: return Icons.receipt_long_rounded;
  }
}

```

---

# File: lib/features/auth/data/auth_repository.dart

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/user_model.dart';

abstract class AuthRepository {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel?> signIn(String email, String password);
  Future<UserModel?> signUp(String email, String password, String name);
  Future<void> signOut();
  UserModel? get currentUser;
}

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth? _firebaseAuth;
  final bool _isFirebaseAvailable;
  
  // Local fallback mock state
  UserModel? _mockUser;
  
  FirebaseAuthRepository(this._firebaseAuth, this._isFirebaseAvailable) {
    if (_isFirebaseAvailable && _firebaseAuth == null) {
      throw Exception("FirebaseAuth is required when Firebase is available.");
    }
    if (!_isFirebaseAvailable) {
      _loadMockSession();
    }
  }

  Future<void> _loadMockSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('mock_user_email');
    final name = prefs.getString('mock_user_name');
    if (email != null) {
      _mockUser = UserModel(
        uid: 'sarah_kapur_mock_id',
        email: email,
        displayName: name ?? 'Sarah Kapur',
      );
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    if (_isFirebaseAvailable) {
      return _firebaseAuth!.authStateChanges().map((user) {
        if (user == null) return null;
        return UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          photoUrl: user.photoURL,
        );
      });
    } else {
      // Local fallback stream
      return Stream.value(_mockUser);
    }
  }

  @override
  Future<UserModel?> signIn(String email, String password) async {
    if (_isFirebaseAvailable) {
      final credential = await _firebaseAuth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        return UserModel(
          uid: credential.user!.uid,
          email: credential.user!.email ?? '',
          displayName: credential.user!.displayName,
          photoUrl: credential.user!.photoURL,
        );
      }
      return null;
    } else {
      // Local mock sign in
      _mockUser = UserModel(
        uid: 'sarah_kapur_mock_id',
        email: email,
        displayName: 'Sarah Kapur',
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mock_user_email', email);
      await prefs.setString('mock_user_name', 'Sarah Kapur');
      return _mockUser;
    }
  }

  @override
  Future<UserModel?> signUp(String email, String password, String name) async {
    if (_isFirebaseAvailable) {
      final credential = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        return UserModel(
          uid: credential.user!.uid,
          email: credential.user!.email ?? '',
          displayName: name,
        );
      }
      return null;
    } else {
      // Local mock sign up
      _mockUser = UserModel(
        uid: 'sarah_kapur_mock_id',
        email: email,
        displayName: name,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mock_user_email', email);
      await prefs.setString('mock_user_name', name);
      return _mockUser;
    }
  }

  @override
  Future<void> signOut() async {
    if (_isFirebaseAvailable) {
      await _firebaseAuth!.signOut();
    } else {
      _mockUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('mock_user_email');
      await prefs.remove('mock_user_name');
    }
  }

  @override
  UserModel? get currentUser {
    if (_isFirebaseAvailable) {
      final user = _firebaseAuth!.currentUser;
      if (user == null) return null;
      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
    } else {
      return _mockUser;
    }
  }
}

// Providers
final firebaseAuthProvider = Provider<FirebaseAuth?>((ref) {
  final isAvailable = ref.watch(firebaseAvailableProvider);
  if (isAvailable) {
    return FirebaseAuth.instance;
  }
  return null;
});

final firebaseAvailableProvider = StateProvider<bool>((ref) {
  return false; 
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final isAvailable = ref.watch(firebaseAvailableProvider);
  return FirebaseAuthRepository(auth, isAvailable);
});

final authStateChangesProvider = StreamProvider<UserModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

```

---

# File: lib/features/auth/domain/user_model.dart

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

```

---

# File: lib/features/auth/presentation/auth_controller.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/user_model.dart';

class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncValue.data(null)) {
    _init();
  }

  void _init() {
    _authRepository.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signIn(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signUp(email, password, name);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});

```

---

# File: lib/features/auth/presentation/login_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_controller.dart';
import '../../../core/theme/colors.dart';

/// Login screen matching the reference — app icon, "Welcome back",
/// Google + Sign in with Email buttons, legal footer.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _showEmailForm = false;
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submitEmail() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).signIn(
            _emailCtrl.text.trim(),
            _passCtrl.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue>(authControllerProvider, (_, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null && mounted) context.go('/home');
        },
        error: (err, _) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$err'), backgroundColor: AppColors.error),
            );
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 64),

              // ── App icon ────────────────────────────────────────────────────
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                  size: 38,
                ),
              ),
              const SizedBox(height: 36),

              // ── Headline ─────────────────────────────────────────────────────
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to access your vault',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 15,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 40),

              // ── Buttons / Email form ──────────────────────────────────────────
              if (!_showEmailForm) ...[ 
                // Google
                _AuthButton(
                  onTap: () {
                    ref.read(authControllerProvider.notifier).signIn(
                          'sarah.kapur@gmail.com',
                          'password123',
                        );
                  },
                  outlined: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GoogleIcon(),
                      const SizedBox(width: 10),
                      const Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Sign in with Email
                _AuthButton(
                  onTap: () => setState(() => _showEmailForm = true),
                  outlined: false,
                  child: const Text(
                    'Sign in with Email',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ] else ...[
                // ── Email + Password form ───────────────────────────────────────
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email Address',
                        style: TextStyle(fontFamily: 'Roboto', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(fontFamily: 'Roboto', fontSize: 15, color: AppColors.textPrimaryLight),
                        decoration: const InputDecoration(hintText: 'name@example.com'),
                        validator: (v) {
                          if (v == null || v.isEmpty || !v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Password',
                        style: TextStyle(fontFamily: 'Roboto', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submitEmail(),
                        style: const TextStyle(fontFamily: 'Roboto', fontSize: 15, color: AppColors.textPrimaryLight),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textMutedLight,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.length < 6) return 'At least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: authState.isLoading ? null : _submitEmail,
                          child: authState.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Sign In', style: TextStyle(fontFamily: 'Roboto', fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: TextButton(
                          onPressed: () => setState(() => _showEmailForm = false),
                          child: const Text(
                            '← Back to options',
                            style: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ── Register link ─────────────────────────────────────────────────
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: AppColors.textSecondaryLight),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/register'),
                    child: const Text(
                      'Register',
                      style: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),

              // ── Push legal to bottom ──────────────────────────────────────────
              const Spacer(),

              // ── Legal footer ──────────────────────────────────────────────────
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'By continuing, you agree to our ',
                  style: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: AppColors.textSecondaryLight),
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: AppColors.textPrimaryLight,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(text: ' and\n'),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppColors.textPrimaryLight,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _AuthButton extends StatelessWidget {
  final Widget child;
  final bool outlined;
  final VoidCallback onTap;

  const _AuthButton({
    required this.child,
    required this.outlined,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: outlined
          ? OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.outlineLight, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: EdgeInsets.zero,
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: EdgeInsets.zero,
              ),
              child: child,
            ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Matches the ⊗ circle icon in the reference
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outlineLight, width: 1.5),
      ),
      child: const Center(
        child: Icon(Icons.close_rounded, size: 13, color: AppColors.textPrimaryLight),
      ),
    );
  }
}

```

---

# File: lib/features/auth/presentation/register_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_controller.dart';
import '../../../core/theme/colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _nameController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<AsyncValue>(authControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (err, st) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: $err'), backgroundColor: AppColors.error),
          );
        },
        data: (user) {
          if (user != null) {
            context.go('/home');
          }
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 36),
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontSize: 34,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start managing your receipts and warranties',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                ),
                const SizedBox(height: 36),

                Text(
                  'Full Name',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Sarah Kapur',
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Text(
                  'Email Address',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'name@example.com',
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty || !val.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Text(
                  'Password',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    hintText: '••••••••',
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty || val.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: authState.isLoading ? null : _submit,
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Register',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

```

---

# File: lib/features/home/presentation/dashboard_controller.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../../receipt/data/receipt_repository.dart';
import '../../receipt/domain/receipt_model.dart';
import '../../../core/constants/app_constants.dart';

final dashboardReceiptsProvider = StreamProvider<List<ReceiptModel>>((ref) {
  final userState = ref.watch(authStateChangesProvider).value;
  final userId = userState?.uid ?? AppConstants.mockUserId;
  final repository = ref.watch(receiptRepositoryProvider);
  
  repository.seedInitialData(userId);
  return repository.streamReceipts(userId);
});

class DashboardStats {
  final double totalSpendMonth;
  final int totalCount;
  final int activeWarranties;
  final List<ReceiptModel> recentReceipts;
  final List<ReceiptModel> expiringWarranties;
  final Map<String, double> categoryDistribution;

  DashboardStats({
    required this.totalSpendMonth,
    required this.totalCount,
    required this.activeWarranties,
    required this.recentReceipts,
    required this.expiringWarranties,
    required this.categoryDistribution,
  });
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final receipts = ref.watch(dashboardReceiptsProvider).value ?? [];
  final now = DateTime.now();
  final currentMonth = now.month;
  final currentYear = now.year;

  double totalSpend = 0.0;
  int activeWarranties = 0;
  List<ReceiptModel> expiringWarranties = [];
  Map<String, double> categoryMap = {};

  for (final r in receipts) {
    if (r.purchaseDate.month == currentMonth && r.purchaseDate.year == currentYear) {
      totalSpend += r.totalAmount;
      categoryMap[r.category] = (categoryMap[r.category] ?? 0.0) + r.totalAmount;
    }

    if (r.warrantyMonths != null && r.warrantyMonths! > 0) {
      final expiryDate = r.purchaseDate.add(Duration(days: r.warrantyMonths! * 30));
      if (expiryDate.isAfter(now)) {
        activeWarranties++;
        final diffDays = expiryDate.difference(now).inDays;
        if (diffDays <= 30) {
          expiringWarranties.add(r);
        }
      }
    }
  }

  final recent = receipts.take(5).toList();

  return DashboardStats(
    totalSpendMonth: totalSpend,
    totalCount: receipts.length,
    activeWarranties: activeWarranties,
    recentReceipts: recent,
    expiringWarranties: expiringWarranties,
    categoryDistribution: categoryMap,
  );
});

```

---

# File: lib/features/home/presentation/dashboard_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dashboard_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../receipt/domain/receipt_model.dart';
import '../../../core/theme/colors.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final receiptsAsync = ref.watch(dashboardReceiptsProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSec = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final rupeeFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final rupeeCompact = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: bgColor,
      body: receiptsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (_) => SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(dashboardReceiptsProvider),
            child: CustomScrollView(
              slivers: [
                // ── Top Bar ──────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello,',
                              style: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: textSec),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.displayName ?? 'Sarah Kapur',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.go('/profile'),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundImage: NetworkImage(
                              user?.photoUrl ??
                                  'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=150&q=80',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Spend Card ───────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Spend This Month',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '+12.5%',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            rupeeFormat.format(stats.totalSpendMonth),
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _StatLabel(
                                label: 'Receipts',
                                value: '${stats.totalCount}',
                                color: AppColors.primaryLight,
                              ),
                              const SizedBox(width: 32),
                              _StatLabel(
                                label: 'Active Warranties',
                                value: '${stats.activeWarranties}',
                                color: AppColors.primaryLight,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Expiry Warning ───────────────────────────────────────────
                if (stats.expiringWarranties.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: GestureDetector(
                        onTap: () => context.go('/warranty'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2D2010) : AppColors.warningLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.warningBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.notifications_outlined, color: AppColors.warning, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${stats.expiringWarranties.length} warranties expiring soon',
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_rounded, color: AppColors.warning, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── Recent Receipts header ───────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Receipts',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/search'),
                          child: const Text(
                            'See All',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Receipt list ─────────────────────────────────────────────
                if (stats.recentReceipts.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_rounded, size: 48, color: textSec.withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text('No receipts yet', style: TextStyle(color: textSec, fontSize: 15)),
                          const SizedBox(height: 8),
                          Text('Tap + to scan your first receipt', style: TextStyle(color: textSec, fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == stats.recentReceipts.length) return null;
                          final r = stats.recentReceipts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ReceiptListTile(
                              receipt: r,
                              cardBg: cardBg,
                              isDark: isDark,
                              rupeeCompact: rupeeCompact,
                              onTap: () => context.push('/receipt/${r.id}'),
                            ),
                          );
                        },
                        childCount: stats.recentReceipts.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Receipt list tile — matches reference exactly
// ─────────────────────────────────────────────────────────────────────────────
class _ReceiptListTile extends StatelessWidget {
  final ReceiptModel receipt;
  final Color cardBg;
  final bool isDark;
  final NumberFormat rupeeCompact;
  final VoidCallback onTap;

  const _ReceiptListTile({
    required this.receipt,
    required this.cardBg,
    required this.isDark,
    required this.rupeeCompact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final parts = receipt.merchant.split(' | ');
    final storeName = parts.length > 1 ? parts.last : parts.first;

    // Warranty badge
    String? warrantyLabel;
    Color? warrantyBg;
    Color? warrantyFg;
    if (receipt.warrantyMonths != null && receipt.warrantyMonths! > 0) {
      final expiry = receipt.purchaseDate.add(Duration(days: receipt.warrantyMonths! * 30));
      final diff = expiry.difference(DateTime.now()).inDays;
      if (diff > 0) {
        warrantyLabel = '${diff}D LEFT';
        if (diff <= 30) {
          warrantyBg = AppColors.warrantyAmberBg;
          warrantyFg = AppColors.warrantyAmberFg;
        } else {
          warrantyBg = AppColors.warrantyGreenBg;
          warrantyFg = AppColors.warrantyGreenFg;
        }
      }
    }

    // Category badge colors
    final catColors = _categoryColors(receipt.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
          border: Border.all(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight.withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // ── Logo ─────────────────────────────────────────────────────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: catColors.$3,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_categoryIcon(receipt.category), color: catColors.$2, size: 24),
            ),
            const SizedBox(width: 14),

            // ── Name + date + category ────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        DateFormat('d MMMM').format(receipt.purchaseDate),
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _CategoryChip(label: receipt.category.toUpperCase(), bg: catColors.$3, fg: catColors.$2),
                    ],
                  ),
                ],
              ),
            ),

            // ── Amount + warranty ─────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rupeeCompact.format(receipt.totalAmount),
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 22,
                  child: warrantyLabel != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: warrantyBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            warrantyLabel,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: warrantyFg,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _StatLabel extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatLabel({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Roboto', color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontFamily: 'Roboto', color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _CategoryChip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: TextStyle(fontFamily: 'Roboto', fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

IconData _categoryIcon(String cat) {
  switch (cat.toLowerCase()) {
    case 'electronics': return Icons.laptop_mac_rounded;
    case 'food': return Icons.restaurant_rounded;
    case 'fashion': return Icons.shopping_bag_rounded;
    case 'grocery': return Icons.shopping_cart_rounded;
    case 'travel': return Icons.flight_takeoff_rounded;
    case 'health': return Icons.local_hospital_rounded;
    default: return Icons.receipt_long_rounded;
  }
}

/// Returns (iconColor, badgeFg, badgeBg)
(Color, Color, Color) _categoryColors(String cat) {
  switch (cat.toLowerCase()) {
    case 'electronics': return (AppColors.catElectrFg, AppColors.catElectrFg, AppColors.catElectrBg);
    case 'food': return (AppColors.catFoodFg, AppColors.catFoodFg, AppColors.catFoodBg);
    case 'fashion': return (AppColors.catFashionFg, AppColors.catFashionFg, AppColors.catFashionBg);
    case 'grocery': return (AppColors.catGroceryFg, AppColors.catGroceryFg, AppColors.catGroceryBg);
    case 'travel': return (AppColors.catTravelFg, AppColors.catTravelFg, AppColors.catTravelBg);
    case 'health': return (AppColors.catHealthFg, AppColors.catHealthFg, AppColors.catHealthBg);
    default: return (AppColors.catOtherFg, AppColors.catOtherFg, AppColors.catOtherBg);
  }
}

```

---

# File: lib/features/profile/presentation/profile_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_repository.dart';
import '../../home/presentation/dashboard_controller.dart';
import '../../../core/theme/colors.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final stats = ref.watch(dashboardStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSec = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final rupee = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Text('Profile', style: TextStyle(fontFamily: 'Roboto', fontSize: 26, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.3)),
              const SizedBox(height: 24),

              // ── Avatar + info ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: NetworkImage(
                        user?.photoUrl ??
                            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=150&q=80',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.displayName ?? 'Sarah Kapur',
                              style: TextStyle(fontFamily: 'Roboto', fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary)),
                          const SizedBox(height: 4),
                          Text(user?.email ?? 'sarah.kapur@gmail.com',
                              style: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: textSec)),
                        ],
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Stats row ─────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _ProfileStat(
                        label: 'Receipts',
                        value: '${stats.totalCount}',
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.25)),
                    Expanded(
                      child: _ProfileStat(
                        label: 'Warranties',
                        value: '${stats.activeWarranties}',
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.25)),
                    Expanded(
                      child: _ProfileStat(
                        label: 'Total Spend',
                        value: rupee.format(stats.totalSpendMonth),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Menu sections ─────────────────────────────────────────────
              _Section(
                title: 'Account',
                children: [
                  _MenuItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Personal Information',
                    isDark: isDark,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSec: textSec,
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notifications',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                      child: const Text('3', style: TextStyle(fontFamily: 'Roboto', color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                    isDark: isDark,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSec: textSec,
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.cloud_outlined,
                    label: 'Backup & Sync',
                    isDark: isDark,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSec: textSec,
                    onTap: () {},
                  ),
                ],
                textSec: textSec,
              ),
              const SizedBox(height: 20),

              _Section(
                title: 'Preferences',
                children: [
                  _MenuItem(
                    icon: Icons.dark_mode_outlined,
                    label: 'Appearance',
                    isDark: isDark,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSec: textSec,
                    onTap: () => context.push('/settings'),
                  ),
                  _MenuItem(
                    icon: Icons.security_outlined,
                    label: 'Privacy & Security',
                    isDark: isDark,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSec: textSec,
                    onTap: () {},
                  ),
                ],
                textSec: textSec,
              ),
              const SizedBox(height: 20),

              _Section(
                title: 'Support',
                children: [
                  _MenuItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help Center',
                    isDark: isDark,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSec: textSec,
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.info_outline_rounded,
                    label: 'About ReceiptVault',
                    isDark: isDark,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSec: textSec,
                    onTap: () {},
                  ),
                ],
                textSec: textSec,
              ),
              const SizedBox(height: 20),

              // ── Sign out ──────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
                ),
                child: _MenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Sign Out',
                  isDark: isDark,
                  cardBg: Colors.transparent,
                  textPrimary: AppColors.error,
                  textSec: AppColors.error,
                  iconColor: AppColors.error,
                  isLast: true,
                  onTap: () {
                    ref.read(authRepositoryProvider).signOut();
                    context.go('/login');
                  },
                ),
              ),
              const SizedBox(height: 32),

              // ── Version ───────────────────────────────────────────────────
              Center(
                child: Text('ReceiptVault v1.0.0', style: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: textSec)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontFamily: 'Roboto', color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontFamily: 'Roboto', color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color textSec;

  const _Section({required this.title, required this.children, required this.textSec});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: TextStyle(fontFamily: 'Roboto', fontSize: 13, fontWeight: FontWeight.w700, color: textSec, letterSpacing: 0.3)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSec;
  final Color? iconColor;
  final bool isLast;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSec,
    required this.onTap,
    this.trailing,
    this.iconColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor ?? AppColors.primary, size: 19),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label, style: TextStyle(fontFamily: 'Roboto', fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary)),
              ),
              trailing ?? Icon(Icons.chevron_right_rounded, color: textSec, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

```

---

# File: lib/features/profile/presentation/settings_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';

final darkModeProvider = StateProvider<bool>((ref) => false);
final notificationsProvider = StateProvider<bool>((ref) => true);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);
    final notifications = ref.watch(notificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSec = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Settings', style: TextStyle(fontFamily: 'Roboto', fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // ── Appearance ────────────────────────────────────────────────────
          _SettingsSection(title: 'Appearance', textSec: textSec, children: [
            _ToggleTile(
              icon: Icons.dark_mode_outlined,
              label: 'Dark Mode',
              sub: 'Switch to dark theme',
              value: darkMode,
              onChanged: (v) => ref.read(darkModeProvider.notifier).state = v,
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSec: textSec,
            ),
          ]),
          const SizedBox(height: 20),

          // ── Notifications ─────────────────────────────────────────────────
          _SettingsSection(title: 'Notifications', textSec: textSec, children: [
            _ToggleTile(
              icon: Icons.notifications_outlined,
              label: 'Push Notifications',
              sub: 'Warranty expiry alerts',
              value: notifications,
              onChanged: (v) => ref.read(notificationsProvider.notifier).state = v,
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSec: textSec,
            ),
          ]),
          const SizedBox(height: 20),

          // ── Storage ───────────────────────────────────────────────────────
          _SettingsSection(title: 'Storage & Sync', textSec: textSec, children: [
            _NavTile(
              icon: Icons.folder_outlined,
              label: 'Storage Provider',
              sub: 'Manage where receipts are stored',
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSec: textSec,
              onTap: () {},
            ),
            _NavTile(
              icon: Icons.cloud_sync_outlined,
              label: 'Sync Settings',
              sub: 'Auto-sync to Google Drive',
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSec: textSec,
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 20),

          // ── About ─────────────────────────────────────────────────────────
          _SettingsSection(title: 'About', textSec: textSec, children: [
            _NavTile(
              icon: Icons.info_outline_rounded,
              label: 'App Version',
              sub: 'v1.0.0',
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSec: textSec,
              onTap: () {},
            ),
            _NavTile(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Policy',
              sub: 'How we handle your data',
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSec: textSec,
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color textSec;

  const _SettingsSection({required this.title, required this.children, required this.textSec});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: TextStyle(fontFamily: 'Roboto', fontSize: 13, fontWeight: FontWeight.w700, color: textSec, letterSpacing: 0.3)),
        ),
        ...children,
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSec;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.value,
    required this.onChanged,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontFamily: 'Roboto', fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary)),
                Text(sub, style: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: textSec)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSec;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSec,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontFamily: 'Roboto', fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary)),
                  Text(sub, style: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: textSec)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: textSec, size: 20),
          ],
        ),
      ),
    );
  }
}

```

---

# File: lib/features/receipt/data/receipt_repository.dart

```dart
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/product_model.dart';
import '../domain/receipt_model.dart';

abstract class ReceiptRepository {
  Stream<List<ReceiptModel>> streamReceipts(String userId);
  Future<void> addReceipt(ReceiptModel receipt);
  Future<void> updateReceipt(ReceiptModel receipt);
  Future<void> deleteReceipt(String receiptId);
  Future<void> seedInitialData(String userId);
}

class FirestoreReceiptRepository implements ReceiptRepository {
  final FirebaseFirestore? _firestore;
  final bool _isFirebaseAvailable;
  
  // Local cache/fallback
  final List<ReceiptModel> _localCache = [];
  final StreamController<List<ReceiptModel>> _localStreamController =
      StreamController<List<ReceiptModel>>.broadcast();

  FirestoreReceiptRepository(this._firestore, this._isFirebaseAvailable) {
    if (_isFirebaseAvailable && _firestore == null) {
      throw Exception("FirebaseFirestore is required when Firebase is available.");
    }
    if (!_isFirebaseAvailable) {
      _loadLocalCache();
    }
  }

  Future<void> _loadLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString('cached_receipts');
      if (dataStr != null) {
        final List<dynamic> decoded = jsonDecode(dataStr);
        _localCache.clear();
        _localCache.addAll(decoded.map((item) => ReceiptModel.fromJson(item)));
      } else {
        // Seed initial mock list if empty
        _seedMockData();
      }
      _localStreamController.add(List.unmodifiable(_localCache));
    } catch (e) {
      debugPrint('Error loading receipt cache: $e');
    }
  }

  Future<void> _saveLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = jsonEncode(_localCache.map((r) => r.toJson()).toList());
      await prefs.setString('cached_receipts', dataStr);
      _localStreamController.add(List.unmodifiable(_localCache));
    } catch (e) {
      debugPrint('Error saving receipt cache: $e');
    }
  }

  void _seedMockData() {
    final now = DateTime.now();
    final sampleReceipts = [
      ReceiptModel(
        id: 'mock_1',
        merchant: 'Coffee Maker | Croma',
        category: 'Electronics',
        purchaseDate: DateTime(2026, 7, 12),
        currency: '₹',
        subtotal: 8193.33,
        tax: 409.67,
        totalAmount: 8603.00,
        paymentMethod: 'Credit Card',
        invoiceNumber: 'INV-738210',
        products: [const ProductModel(name: 'Coffee Maker', quantity: 1, price: 8603.00)],
        imageUrl: null,
        ocrText: 'CROMA STORE\nCOFFEE MAKER\nTOTAL ₹8,603\nDATE 12 JUL 2026',
        warrantyMonths: 12,
        createdAt: now,
        updatedAt: now,
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_2',
        merchant: 'Zepto',
        category: 'Grocery',
        purchaseDate: DateTime(2026, 7, 10),
        currency: '₹',
        subtotal: 3333.33,
        tax: 166.67,
        totalAmount: 3500.00,
        paymentMethod: 'UPI',
        invoiceNumber: 'ZPT-93821',
        products: [const ProductModel(name: 'Organic Grocery Items', quantity: 1, price: 3500.0)],
        createdAt: now,
        updatedAt: now,
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_3',
        merchant: 'BigBasket',
        category: 'Grocery',
        purchaseDate: DateTime(2026, 7, 13),
        currency: '₹',
        subtotal: 3221.33,
        tax: 161.07,
        totalAmount: 3382.40,
        paymentMethod: 'UPI',
        invoiceNumber: 'BB-9871A',
        products: [const ProductModel(name: 'Fruits & Veggies', quantity: 1, price: 3382.4)],
        createdAt: now,
        updatedAt: now,
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_4',
        merchant: 'Zomato',
        category: 'Food',
        purchaseDate: DateTime(2026, 7, 14),
        currency: '₹',
        subtotal: 2308.95,
        tax: 115.45,
        totalAmount: 2424.40,
        paymentMethod: 'UPI',
        invoiceNumber: 'ZMT-92731',
        products: [const ProductModel(name: 'Meal Delivery', quantity: 1, price: 2424.40)],
        createdAt: now,
        updatedAt: now,
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_5',
        merchant: 'Starbucks Coffee',
        category: 'Food',
        purchaseDate: DateTime(2026, 7, 15),
        currency: '₹',
        subtotal: 1904.76,
        tax: 95.24,
        totalAmount: 2000.00,
        paymentMethod: 'Credit Card',
        invoiceNumber: 'SBC-9817',
        products: [const ProductModel(name: 'Java Chip Frappuccino', quantity: 2, price: 1000.0)],
        createdAt: now,
        updatedAt: now,
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_6',
        merchant: 'Amazon Fashion',
        category: 'Fashion',
        purchaseDate: DateTime(2026, 7, 8),
        currency: '₹',
        subtotal: 2809.14,
        tax: 140.46,
        totalAmount: 2949.60,
        paymentMethod: 'Credit Card',
        invoiceNumber: 'AMZ-FASH-92',
        products: [const ProductModel(name: 'Designer Shirt', quantity: 1, price: 2949.6)],
        createdAt: now,
        updatedAt: now,
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_7',
        merchant: 'Uber',
        category: 'Other',
        purchaseDate: DateTime(2026, 7, 5),
        currency: '₹',
        subtotal: 1638.67,
        tax: 81.93,
        totalAmount: 1720.60,
        paymentMethod: 'UPI',
        invoiceNumber: 'UBR-9382',
        products: [const ProductModel(name: 'Ride fare', quantity: 1, price: 1720.6)],
        createdAt: now,
        updatedAt: now,
        userId: 'sarah_kapur_mock_id',
      ),
      
      // Expiring active warranties (14 days left from July 16, 2026 -> expiry July 30, 2026)
      ReceiptModel(
        id: 'mock_w1',
        merchant: 'iPhone 15 Pro | Reliance Digital',
        category: 'Electronics',
        purchaseDate: DateTime(2025, 7, 14),
        currency: '₹',
        subtotal: 136180.95,
        tax: 6809.05,
        totalAmount: 142990.00,
        paymentMethod: 'Credit Card',
        invoiceNumber: 'RD-9283-11',
        products: [const ProductModel(name: 'iPhone 15 Pro Max', quantity: 1, price: 142990.0)],
        warrantyMonths: 12,
        imageUrl: null,
        createdAt: now.subtract(const Duration(days: 365)),
        updatedAt: now.subtract(const Duration(days: 365)),
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_w2',
        merchant: 'AirPods Pro | Apple Store',
        category: 'Electronics',
        purchaseDate: DateTime(2025, 8, 10),
        currency: '₹',
        subtotal: 23714.28,
        tax: 1185.72,
        totalAmount: 24900.00,
        paymentMethod: 'Credit Card',
        invoiceNumber: 'APL-83921',
        products: [const ProductModel(name: 'AirPods Pro 2', quantity: 1, price: 24900.0)],
        warrantyMonths: 12,
        createdAt: now.subtract(const Duration(days: 340)),
        updatedAt: now.subtract(const Duration(days: 340)),
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_w3',
        merchant: 'MacBook Air | Apple Store',
        category: 'Electronics',
        purchaseDate: DateTime(2025, 12, 15),
        currency: '₹',
        subtotal: 95142.86,
        tax: 4757.14,
        totalAmount: 99900.00,
        paymentMethod: 'Credit Card',
        invoiceNumber: 'APL-92731',
        products: [const ProductModel(name: 'MacBook Air M2', quantity: 1, price: 99900.0)],
        warrantyMonths: 24, // 2 years warranty
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now.subtract(const Duration(days: 200)),
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_w4',
        merchant: 'Leather Jacket | Zara',
        category: 'Fashion',
        purchaseDate: DateTime(2026, 5, 5),
        currency: '₹',
        subtotal: 9522.86,
        tax: 476.14,
        totalAmount: 9999.00,
        paymentMethod: 'Credit Card',
        invoiceNumber: 'ZR-938210',
        products: [const ProductModel(name: 'Leather Jacket', quantity: 1, price: 9999.0)],
        warrantyMonths: 12,
        createdAt: now.subtract(const Duration(days: 70)),
        updatedAt: now.subtract(const Duration(days: 70)),
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_w5',
        merchant: 'Microwave | LG Store',
        category: 'Electronics',
        purchaseDate: DateTime(2026, 2, 20),
        currency: '₹',
        subtotal: 11904.76,
        tax: 595.24,
        totalAmount: 12500.00,
        paymentMethod: 'UPI',
        invoiceNumber: 'LG-839210',
        products: [const ProductModel(name: 'LG Smart Microwave', quantity: 1, price: 12500.0)],
        warrantyMonths: 24,
        createdAt: now.subtract(const Duration(days: 145)),
        updatedAt: now.subtract(const Duration(days: 145)),
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_w6',
        merchant: 'Office Chair | IKEA',
        category: 'Other',
        purchaseDate: DateTime(2026, 3, 10),
        currency: '₹',
        subtotal: 14285.71,
        tax: 714.29,
        totalAmount: 15000.00,
        paymentMethod: 'Credit Card',
        invoiceNumber: 'IK-928311',
        products: [const ProductModel(name: 'Ergonomic Office Chair', quantity: 1, price: 15000.0)],
        warrantyMonths: 36, // 3 years warranty
        createdAt: now.subtract(const Duration(days: 128)),
        updatedAt: now.subtract(const Duration(days: 128)),
        userId: 'sarah_kapur_mock_id',
      ),
    ];
    _localCache.addAll(sampleReceipts);
    _saveLocalCache();
  }

  @override
  Stream<List<ReceiptModel>> streamReceipts(String userId) {
    if (_isFirebaseAvailable) {
      return _firestore!
          .collection('receipts')
          .where('userId', isEqualTo: userId)
          .orderBy('purchaseDate', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return ReceiptModel.fromJson(data);
        }).toList();
      });
    } else {
      Future.microtask(() => _localStreamController.add(List.unmodifiable(_localCache)));
      return _localStreamController.stream.map((list) {
        return list.where((r) => r.userId == userId).toList()
          ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
      });
    }
  }

  @override
  Future<void> addReceipt(ReceiptModel receipt) async {
    if (_isFirebaseAvailable) {
      await _firestore!.collection('receipts').add(receipt.toJson());
    } else {
      _localCache.insert(0, receipt);
      await _saveLocalCache();
    }
  }

  @override
  Future<void> updateReceipt(ReceiptModel receipt) async {
    if (_isFirebaseAvailable) {
      await _firestore!.collection('receipts').doc(receipt.id).update(receipt.toJson());
    } else {
      final index = _localCache.indexWhere((r) => r.id == receipt.id);
      if (index != -1) {
        _localCache[index] = receipt;
        await _saveLocalCache();
      }
    }
  }

  @override
  Future<void> deleteReceipt(String receiptId) async {
    if (_isFirebaseAvailable) {
      await _firestore!.collection('receipts').doc(receiptId).delete();
    } else {
      _localCache.removeWhere((r) => r.id == receiptId);
      await _saveLocalCache();
    }
  }

  @override
  Future<void> seedInitialData(String userId) async {
    if (_isFirebaseAvailable) {
      final snapshot = await _firestore!
          .collection('receipts')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
          
      if (snapshot.docs.isEmpty) {
        // Seed mock data to Firestore
        final tempRepo = FirestoreReceiptRepository(_firestore, false);
        tempRepo._seedMockData();
        for (final r in tempRepo._localCache) {
          final mapped = r.copyWith(userId: userId);
          await _firestore.collection('receipts').add(mapped.toJson());
        }
      }
    }
  }
}

// Providers
final firestoreProvider = Provider<FirebaseFirestore?>((ref) {
  final isAvailable = ref.watch(firebaseAvailableProvider);
  if (isAvailable) {
    return FirebaseFirestore.instance;
  }
  return null;
});

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final isAvailable = ref.watch(firebaseAvailableProvider);
  return FirestoreReceiptRepository(firestore, isAvailable);
});

```

---

# File: lib/features/receipt/domain/product_model.dart

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String name,
    required int quantity,
    required double price,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

```

---

# File: lib/features/receipt/domain/receipt_model.dart

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'product_model.dart';

part 'receipt_model.freezed.dart';
part 'receipt_model.g.dart';

@freezed
class ReceiptModel with _$ReceiptModel {
  const factory ReceiptModel({
    required String id,
    required String merchant,
    required String category,
    required DateTime purchaseDate,
    required String currency,
    required double subtotal,
    required double tax,
    required double totalAmount,
    required String paymentMethod,
    required String invoiceNumber,
    required List<ProductModel> products,
    String? imageUrl,
    String? ocrText,
    int? warrantyMonths,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String userId,
  }) = _ReceiptModel;

  factory ReceiptModel.fromJson(Map<String, dynamic> json) =>
      _$ReceiptModelFromJson(json);
}

```

---

# File: lib/features/receipt/presentation/receipt_controller.dart

```dart
import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../data/receipt_repository.dart';
import '../domain/receipt_model.dart';
import '../domain/product_model.dart';
import '../../../core/services/ocr_service.dart';
import '../../../core/services/cloud_functions_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/constants/app_constants.dart';

class ReceiptProcessingException implements Exception {
  final String code;
  final String message;
  ReceiptProcessingException(this.code, this.message);
  @override
  String toString() => message;
}

class ReceiptController extends StateNotifier<AsyncValue<ReceiptModel?>> {
  final ReceiptRepository _receiptRepository;
  final AuthRepository _authRepository;

  bool _isProcessingLock = false;
  int _scanCounter = 0;

  static const _mlKitTimeout = Duration(seconds: 15);

  ReceiptController(this._receiptRepository, this._authRepository)
      : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>> processReceiptImage(File file, bool isFirebaseAvailable) async {
    if (_isProcessingLock) {
      throw ReceiptProcessingException(
        'ALREADY_PROCESSING',
        'A scan is already in progress. Please wait.',
      );
    }

    final myScanId = ++_scanCounter;
    _isProcessingLock = true;
    state = const AsyncValue.loading();

    try {
      final recognizedText = await OcrService.recognizeReceiptText(file).timeout(
        _mlKitTimeout,
        onTimeout: () => throw ReceiptProcessingException(
          'MLKIT_TIMEOUT',
          'Text recognition took too long. Retake the photo with better lighting, or enter details manually.',
        ),
      );

      final rawText = recognizedText.text;

      if (rawText.trim().isEmpty) {
        throw ReceiptProcessingException(
          'EMPTY_OCR_TEXT',
          'We could not read any text from this image. Enter the details manually instead.',
        );
      }

      // CloudFunctionsService already has its own internal timeout +
      // local-parser fallback (see Section 1) — it will not hang or throw
      // for a slow/failed Gemini call, so no extra timeout needed here.
      final parsedData = await CloudFunctionsService().parseReceiptText(
        rawText,
        isFirebaseAvailable: isFirebaseAvailable,
      );

      parsedData['ocrText'] = rawText;

      if (myScanId == _scanCounter) {
        state = const AsyncValue.data(null);
      }
      return parsedData;
    } catch (e, st) {
      if (myScanId == _scanCounter) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    } finally {
      if (myScanId == _scanCounter) {
        _isProcessingLock = false;
      }
    }
  }

  Future<void> saveReceipt({
    required String merchant,
    required String category,
    required DateTime purchaseDate,
    required String currency,
    required double subtotal,
    required double tax,
    required double totalAmount,
    required String paymentMethod,
    required String invoiceNumber,
    required List<Map<String, dynamic>> products,
    required String ocrText,
    int? warrantyMonths,
    File? imageFile,
    bool isFirebaseAvailable = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _authRepository.currentUser;
      final userId = user?.uid ?? AppConstants.mockUserId;

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await StorageService().uploadReceiptImage(
          imageFile,
          userId,
          isFirebaseAvailable: isFirebaseAvailable,
        );
      }

      final productModels = products.map((p) {
        return ProductModel.fromJson(p);
      }).toList();

      final now = DateTime.now();
      final newReceipt = ReceiptModel(
        id: now.millisecondsSinceEpoch.toString(),
        merchant: merchant,
        category: category,
        purchaseDate: purchaseDate,
        currency: currency,
        subtotal: subtotal,
        tax: tax,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        invoiceNumber: invoiceNumber,
        products: productModels,
        imageUrl: imageUrl,
        ocrText: ocrText,
        warrantyMonths: warrantyMonths,
        createdAt: now,
        updatedAt: now,
        userId: userId,
      );

      await _receiptRepository.addReceipt(newReceipt);
      state = AsyncValue.data(newReceipt);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final receiptControllerProvider =
    StateNotifierProvider<ReceiptController, AsyncValue<ReceiptModel?>>((ref) {
  final receiptRepo = ref.watch(receiptRepositoryProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return ReceiptController(receiptRepo, authRepo);
});

```

---

# File: lib/features/receipt/presentation/receipt_details_screen.dart

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/receipt_repository.dart';
import '../domain/receipt_model.dart';
import '../../home/presentation/dashboard_controller.dart';
import '../../../core/theme/colors.dart';


class ReceiptDetailsScreen extends ConsumerStatefulWidget {
  final String receiptId;

  const ReceiptDetailsScreen({super.key, required this.receiptId});

  @override
  ConsumerState<ReceiptDetailsScreen> createState() => _ReceiptDetailsScreenState();
}

class _ReceiptDetailsScreenState extends ConsumerState<ReceiptDetailsScreen> {
  bool _isFavorited = false;

  @override
  Widget build(BuildContext context) {
    final receiptId = widget.receiptId;
    final receipts = ref.watch(dashboardReceiptsProvider).value ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSec = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final outline = isDark ? AppColors.outlineDark : AppColors.outlineLight;

    final receiptOrNull = receipts.cast<ReceiptModel?>().firstWhere(
      (r) => r?.id == receiptId,
      orElse: () => null,
    );

    if (receiptOrNull == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text('Receipt Details', style: TextStyle(fontFamily: 'Roboto', fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
        ),
        body: Center(child: Text('Receipt not found', style: TextStyle(color: textSec))),
      );
    }

    // After null guard, receipt is promoted to non-nullable ReceiptModel
    final receipt = receiptOrNull;
    final parts = receipt.merchant.split(' | ');
    final displayMerchant = parts.last;
    final displayItem = parts.length > 1 ? parts.first : null;

    final rupeeFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final now = DateTime.now();
    int daysRemaining = 0;
    bool isExpired = true;
    DateTime? expiryDate;

    if (receipt.warrantyMonths != null && receipt.warrantyMonths! > 0) {
      expiryDate = receipt.purchaseDate.add(Duration(days: receipt.warrantyMonths! * 30));
      daysRemaining = expiryDate.difference(now).inDays;
      isExpired = expiryDate.isBefore(now);
    }

    Future<void> onDelete() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Delete Receipt', style: TextStyle(fontFamily: 'Roboto', fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary)),
          content: Text('Are you sure you want to permanently delete this receipt?',
              style: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: textSec)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: TextStyle(fontFamily: 'Roboto', color: textSec, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      if (confirm == true && context.mounted) {
        await ref.read(receiptRepositoryProvider).deleteReceipt(receiptId);
        ref.invalidate(dashboardReceiptsProvider);
        if (context.mounted) context.pop();
      }
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Receipt Details',
            style: TextStyle(fontFamily: 'Roboto', fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
      ),
      // ── Pinned bottom action row ──────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(top: BorderSide(color: outline)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.07), blurRadius: 16, offset: const Offset(0, -4)),
          ],
        ),
        padding: EdgeInsets.only(
          left: 8,
          right: 8,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        child: Row(
          children: [
            // Share as PDF
            Expanded(
              child: _ActionButton(
                icon: Icons.picture_as_pdf_outlined,
                label: 'Share PDF',
                color: AppColors.primary,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF export coming soon'), duration: Duration(seconds: 2)),
                  );
                },
              ),
            ),
            // Edit
            Expanded(
              child: _ActionButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                color: textPrimary,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/preview', extra: {
                    'imagePath': receipt.imageUrl,
                    'ocrText': receipt.ocrText,
                  });
                },
              ),
            ),
            // Favorite
            Expanded(
              child: _ActionButton(
                icon: _isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                label: 'Favorite',
                color: _isFavorited ? AppColors.error : textPrimary,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isFavorited = !_isFavorited);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isFavorited ? 'Added to favorites' : 'Removed from favorites'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
            // Delete
            Expanded(
              child: _ActionButton(
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                color: AppColors.error,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onDelete();
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header card ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store name + category chip
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayMerchant,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (displayItem != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                displayItem,
                                style: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: textSec),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          receipt.category.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Amount ─────────────────────────────────────────────────
                  Text(
                    rupeeFormat.format(receipt.totalAmount),
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Meta row ───────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _MetaItem(label: 'Invoice', value: receipt.invoiceNumber, textPrimary: textPrimary, textSec: textSec)),
                        Container(width: 1, height: 32, color: outline),
                        Expanded(child: _MetaItem(label: 'Date', value: DateFormat('d MMM yyyy').format(receipt.purchaseDate), textPrimary: textPrimary, textSec: textSec)),
                        Container(width: 1, height: 32, color: outline),
                        Expanded(child: _MetaItem(label: 'Payment', value: receipt.paymentMethod, textPrimary: textPrimary, textSec: textSec)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Items ────────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Items', style: TextStyle(fontFamily: 'Roboto', fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
                  const SizedBox(height: 14),
                  // Column headers
                  Row(
                    children: [
                      Expanded(child: Text('ITEM', style: TextStyle(fontFamily: 'Roboto', fontSize: 11, fontWeight: FontWeight.w700, color: textSec, letterSpacing: 0.5))),
                      Text('TOTAL', style: TextStyle(fontFamily: 'Roboto', fontSize: 11, fontWeight: FontWeight.w700, color: textSec, letterSpacing: 0.5)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(color: outline, thickness: 1, height: 1),
                  const SizedBox(height: 12),

                  // Items
                  ...receipt.products.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: TextStyle(fontFamily: 'Roboto', fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary)),
                              Text('Qty: ${item.quantity}', style: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: textSec)),
                            ],
                          ),
                        ),
                        Text(
                          rupeeFormat.format(item.price * item.quantity),
                          style: TextStyle(fontFamily: 'Roboto', fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary),
                        ),
                      ],
                    ),
                  )),

                  Divider(color: outline, thickness: 1, height: 1),
                  const SizedBox(height: 14),

                  // Subtotal / Tax / Total
                  _InvoiceRow(label: 'Subtotal', value: rupeeFormat.format(receipt.subtotal), textPrimary: textPrimary, textSec: textSec),
                  const SizedBox(height: 8),
                  _InvoiceRow(label: 'Tax', value: rupeeFormat.format(receipt.tax), textPrimary: textPrimary, textSec: textSec),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: TextStyle(fontFamily: 'Roboto', fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
                      Text(
                        rupeeFormat.format(receipt.totalAmount),
                        style: const TextStyle(fontFamily: 'Roboto', fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Warranty card ────────────────────────────────────────────────
            if (receipt.warrantyMonths != null && receipt.warrantyMonths! > 0) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // High-contrast opaque fills — no more translucent blending into page bg
                  color: isExpired
                      ? (isDark ? const Color(0xFF3B1515) : const Color(0xFFFFEBEB))
                      : (isDark ? const Color(0xFF0E3024) : const Color(0xFFD6F0E8)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isExpired ? AppColors.error.withValues(alpha: 0.55) : AppColors.primary.withValues(alpha: 0.55),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isExpired ? AppColors.error : AppColors.primary).withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isExpired ? AppColors.error.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isExpired ? Icons.cancel_outlined : Icons.verified_user_rounded,
                        color: isExpired ? AppColors.error : AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isExpired ? 'Warranty Expired' : 'Active Warranty',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isExpired ? AppColors.error : AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isExpired
                                ? 'Cover expired on ${DateFormat('d MMM yyyy').format(expiryDate!)}'
                                : 'Expires ${DateFormat('d MMM yyyy').format(expiryDate!)} • $daysRemaining days left',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 13,
                              color: isExpired
                                  ? AppColors.error
                                  : AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Receipt image ────────────────────────────────────────────────
            if (receipt.imageUrl != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Receipt Image', style: TextStyle(fontFamily: 'Roboto', fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () {
                        final url = receipt.imageUrl!;
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(8),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: InteractiveViewer(
                                    child: url.startsWith('http')
                                        ? Image.network(url)
                                        : Image.file(File(url)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Builder(
                        builder: (context) {
                          final imgUrl = receipt.imageUrl!;
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: imgUrl.startsWith('http')
                                ? Image.network(imgUrl, width: double.infinity, height: 300, fit: BoxFit.cover)
                                : Image.file(File(imgUrl), width: double.infinity, height: 300, fit: BoxFit.cover),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _MetaItem extends StatelessWidget {
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSec;

  const _MetaItem({required this.label, required this.value, required this.textPrimary, required this.textSec});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label.toUpperCase(), style: TextStyle(fontFamily: 'Roboto', fontSize: 10, fontWeight: FontWeight.w700, color: textSec, letterSpacing: 0.4)),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(fontFamily: 'Roboto', fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary), textAlign: TextAlign.center),
      ],
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSec;

  const _InvoiceRow({required this.label, required this.value, required this.textPrimary, required this.textSec});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: textSec)),
        Text(value, style: TextStyle(fontFamily: 'Roboto', fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(fontFamily: 'Roboto', fontSize: 11, fontWeight: FontWeight.w600, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

```

---

# File: lib/features/receipt/presentation/receipt_preview_screen.dart

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'receipt_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../../core/theme/colors.dart';

class ReceiptPreviewScreen extends ConsumerStatefulWidget {
  final String? imagePath;
  final String? ocrText;
  final List<String>? imagePaths;
  final String? initialPaymentMethod;
  final Map<String, dynamic>? parsedData; // NEW

  const ReceiptPreviewScreen({
    super.key,
    this.imagePath,
    this.ocrText,
    this.imagePaths,
    this.initialPaymentMethod,
    this.parsedData,
  });

  @override
  ConsumerState<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends ConsumerState<ReceiptPreviewScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _merchantController;
  late final TextEditingController _amountController;
  late final TextEditingController _dateController;
  late final TextEditingController _taxController;
  late final TextEditingController _invoiceController;
  
  DateTime _purchaseDate = DateTime.now();
  String _selectedCategory = 'Other';
  String _paymentMethod = 'UPI';
  bool _hasWarranty = false;
  int _warrantyMonths = 12;
  bool _hasAppliedParsedData = false;

  final List<Map<String, dynamic>> _products = [];

  final List<String> _categories = ['Food', 'Electronics', 'Fashion', 'Grocery', 'Travel', 'Health', 'Other'];
  final List<String> _paymentMethods = ['UPI', 'Credit Card', 'Cash', 'Debit Card'];

  String? get _effectiveImagePath => widget.imagePath ?? (widget.imagePaths != null && widget.imagePaths!.isNotEmpty ? widget.imagePaths!.first : null);
  List<String> get _allImagePaths => widget.imagePaths != null && widget.imagePaths!.isNotEmpty ? widget.imagePaths! : (widget.imagePath != null ? [widget.imagePath!] : []);

  @override
  void initState() {
    super.initState();

    if (widget.initialPaymentMethod != null && _paymentMethods.contains(widget.initialPaymentMethod!)) {
      _paymentMethod = widget.initialPaymentMethod!;
    }

    _merchantController = TextEditingController();
    _amountController = TextEditingController();
    _dateController = TextEditingController(text: DateFormat('d MMMM yyyy').format(_purchaseDate));
    _taxController = TextEditingController(text: '0.00');
    _invoiceController = TextEditingController();

    if (widget.parsedData != null) {
      // Already parsed upstream in scan_receipt_screen.dart — apply
      // directly. This is the normal path now; no second OCR/Gemini call.
      _applyParsedData(widget.parsedData!);
    } else if (widget.ocrText != null && _effectiveImagePath != null) {
      // Defensive fallback only — shouldn't normally trigger once every
      // capture path forwards parsedData.
      _runParserSimulation();
    }
  }

  void _applyParsedData(Map<String, dynamic> data) {
    setState(() {
      _hasAppliedParsedData = true;
      _merchantController.text = data['merchant'] ?? '';

      final double total = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
      _amountController.text = total > 0 ? total.toStringAsFixed(2) : '';

      final double taxVal = (data['tax'] as num?)?.toDouble() ?? 0.0;
      _taxController.text = taxVal.toStringAsFixed(2);

      _invoiceController.text = data['invoiceNumber'] ?? '';
      _selectedCategory = data['category'] ?? 'Other';
      _paymentMethod = data['paymentMethod'] ?? _paymentMethod;

      final dateStr = data['purchaseDate'] as String?;
      if (dateStr != null) {
        _purchaseDate = DateTime.tryParse(dateStr) ?? DateTime.now();
        _dateController.text = DateFormat('d MMMM yyyy').format(_purchaseDate);
      }

      final wMonths = data['warrantyMonths'] as int?;
      if (wMonths != null && wMonths > 0) {
        _hasWarranty = true;
        _warrantyMonths = wMonths;
      }

      final itemsList = data['products'] as List<dynamic>?;
      if (itemsList != null) {
        _products.clear();
        for (final item in itemsList) {
          _products.add({
            'name': item['name'] ?? '',
            'quantity': item['quantity'] ?? 1,
            'price': (item['price'] as num?)?.toDouble() ?? 0.0,
          });
        }
      }
    });
  }

  void _runParserSimulation() {
    if (_effectiveImagePath == null) return;
    final parsed = ref.read(receiptControllerProvider.notifier).processReceiptImage(
      File(_effectiveImagePath!),
      ref.read(firebaseAvailableProvider),
    );

    parsed.then((data) {
      if (!mounted) return;
      _applyParsedData(data);
    }).catchError((err) {
      debugPrint('Parsing error in preview initialization: $err');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not auto-fill details. Please enter them manually.'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 4),
        ),
      );
    });
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _taxController.dispose();
    _invoiceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _purchaseDate) {
      setState(() {
        _purchaseDate = picked;
        _dateController.text = DateFormat('d MMMM yyyy').format(_purchaseDate);
      });
    }
  }

  void _addProduct() {
    setState(() {
      _products.add({
        'name': '',
        'quantity': 1,
        'price': 0.0,
      });
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      final total = double.parse(_amountController.text.trim());
      final tax = double.parse(_taxController.text.trim());
      final subtotal = total - tax;
      final isFirebase = ref.read(firebaseAvailableProvider);

      try {
        await ref.read(receiptControllerProvider.notifier).saveReceipt(
          merchant: _merchantController.text.trim(),
          category: _selectedCategory,
          purchaseDate: _purchaseDate,
          currency: '₹',
          subtotal: subtotal,
          tax: tax,
          totalAmount: total,
          paymentMethod: _paymentMethod,
          invoiceNumber: _invoiceController.text.trim().isNotEmpty
              ? _invoiceController.text.trim()
              : 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
          products: _products.isNotEmpty
              ? _products
              : [
                  {'name': 'General Purchase', 'quantity': 1, 'price': subtotal}
                ],
          ocrText: widget.ocrText ?? 'Manual entry',
          warrantyMonths: _hasWarranty ? _warrantyMonths : null,
          imageFile: _effectiveImagePath != null ? File(_effectiveImagePath!) : null,
          isFirebaseAvailable: isFirebase,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt saved successfully!'), backgroundColor: AppColors.success),
        );
        context.go('/home');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save receipt: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(receiptControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Details', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_allImagePaths.isNotEmpty) ...[
                    if (_allImagePaths.length == 1)
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: FileImage(File(_allImagePaths.first)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_allImagePaths.length} Pages Captured (Long Bill)',
                                style: const TextStyle(fontFamily: 'Roboto', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                              const Icon(Icons.collections_bookmark_rounded, color: AppColors.primary, size: 16),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 180,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _allImagePaths.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, idx) {
                                return Stack(
                                  children: [
                                    Container(
                                      width: 130,
                                      height: 180,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: AppColors.outlineLight),
                                        image: DecorationImage(
                                          image: FileImage(File(_allImagePaths[idx])),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(6)),
                                        child: Text('P${idx + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                  ],

                  if (_hasAppliedParsedData) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Parsed with Gemini AI — please verify values.',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  Text('Merchant Name', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _merchantController,
                    decoration: const InputDecoration(hintText: 'e.g. Apple Store'),
                    validator: (val) => val == null || val.isEmpty ? 'Merchant name is required' : null,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Amount (₹)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(hintText: '0.00'),
                              validator: (val) {
                                if (val == null || val.isEmpty || double.tryParse(val) == null) {
                                  return 'Invalid amount';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tax Included (₹)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _taxController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(hintText: '0.00'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Purchase Date', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              onTap: _selectDate,
                              decoration: const InputDecoration(
                                suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Invoice Number', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _invoiceController,
                              decoration: const InputDecoration(hintText: 'INV-XXXX'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text('Category', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  Text('Payment Method', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _paymentMethods.map((pm) {
                      final isSelected = _paymentMethod == pm;
                      return ChoiceChip(
                        label: Text(pm),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        onSelected: (_) => setState(() => _paymentMethod = pm),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Includes Warranty', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Track warranty remaining duration'),
                          value: _hasWarranty,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => _hasWarranty = val),
                        ),
                        if (_hasWarranty) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Warranty Duration:', style: TextStyle(fontWeight: FontWeight.bold)),
                              DropdownButton<int>(
                                value: _warrantyMonths,
                                underline: const SizedBox(),
                                items: const [
                                  DropdownMenuItem(value: 6, child: Text('6 Months')),
                                  DropdownMenuItem(value: 12, child: Text('1 Year (12m)')),
                                  DropdownMenuItem(value: 24, child: Text('2 Years (24m)')),
                                  DropdownMenuItem(value: 36, child: Text('3 Years (36m)')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _warrantyMonths = val);
                                },
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Line Items List', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: _addProduct,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Item'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_products.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('No line items. General purchase model will be created.'),
                    )
                  else
                    ..._products.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final prod = entry.value;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  initialValue: prod['name'],
                                  onChanged: (val) => prod['name'] = val,
                                  decoration: const InputDecoration(hintText: 'Item Name', contentPadding: EdgeInsets.all(8)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  initialValue: prod['quantity'].toString(),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) => prod['quantity'] = int.tryParse(val) ?? 1,
                                  decoration: const InputDecoration(hintText: 'Qty', contentPadding: EdgeInsets.all(8)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: prod['price'] > 0 ? prod['price'].toString() : '',
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) => prod['price'] = double.tryParse(val) ?? 0.0,
                                  decoration: const InputDecoration(hintText: 'Price (₹)', contentPadding: EdgeInsets.all(8)),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                onPressed: () => _removeProduct(idx),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: authState.isLoading ? null : _save,
                      child: const Text('Save Receipt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          if (authState.isLoading)
            Container(
              color: Colors.black54,
              width: double.infinity,
              height: double.infinity,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

```

---

# File: lib/features/receipt/presentation/scan_receipt_screen.dart

```dart
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'receipt_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../../core/theme/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Full Scan Screen (Camera Viewfinder & Immediate Entry Point)
// ─────────────────────────────────────────────────────────────────────────────
class ScanReceiptScreen extends ConsumerStatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  ConsumerState<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends ConsumerState<ScanReceiptScreen> {
  final ImagePicker _picker = ImagePicker();
  
  bool _isProcessing = false;
  bool _isFlashOn = false;
  bool _isAligning = true;
  bool _isPulsing = false;
  bool _isAutoCaptureTriggered = false;

  final List<String> _capturedPages = [];
  final List<String> _ocrResults = [];
  String? _selectedPaymentMethod;
  Map<String, dynamic>? _lastParsedData;

  Timer? _alignmentTimer;

  @override
  void initState() {
    super.initState();
    _startAutoCaptureAssist();
  }

  void _startAutoCaptureAssist() {
    // Simulate detecting a steady, well-aligned rectangle
    Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _isAligning = false);
    });

    _alignmentTimer = Timer(const Duration(milliseconds: 1700), () {
      if (mounted && _capturedPages.isEmpty && !_isProcessing && !_isAutoCaptureTriggered) {
        _triggerAutoCapture();
      }
    });
  }

  Future<void> _triggerAutoCapture() async {
    _isAutoCaptureTriggered = true;
    setState(() => _isPulsing = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _isPulsing = false);
    
    // Auto trigger capture
    await _capturePage(source: ImageSource.camera);
  }

  Future<void> _capturePage({required ImageSource source, String? paymentMethod}) async {
    if (_isProcessing) return;
    File? file;
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      setState(() => _isProcessing = true);
      file = File(pickedFile.path);
      final isFirebase = ref.read(firebaseAvailableProvider);
      final parsedData = await ref.read(receiptControllerProvider.notifier).processReceiptImage(file, isFirebase);

      if (!mounted) return;
      
      setState(() {
        _capturedPages.add(file!.path);
        _ocrResults.add(parsedData['ocrText'] ?? 'Page ${_capturedPages.length} OCR');
        _lastParsedData = parsedData; // NEW — carry forward, don't re-parse later
        if (paymentMethod != null) _selectedPaymentMethod = paymentMethod;
      });

      // If imported via UPI or if user wants immediate preview on single page (when no multi-page action taken yet)
      if (paymentMethod == 'UPI') {
        _finishAndGoToPreview();
      }
    } catch (e) {
      if (mounted) {
        if (file != null) {
          setState(() {
            _capturedPages.add(file!.path);
            _ocrResults.add('Page ${_capturedPages.length} OCR (Failed)');
            _lastParsedData = null;
            if (paymentMethod != null) _selectedPaymentMethod = paymentMethod;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auto-fill timed out/failed ($e). Please enter details manually.'),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 4),
          ),
        );
        if (_capturedPages.isNotEmpty) {
          _finishAndGoToPreview();
        }
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _importUpi() async {
    await _capturePage(source: ImageSource.gallery, paymentMethod: 'UPI');
  }

  void _finishAndGoToPreview() {
    if (_capturedPages.isEmpty) return;
    context.pushReplacement(
      '/preview',
      extra: {
        'imagePath': _capturedPages.first,
        'imagePaths': _capturedPages,
        'ocrText': _ocrResults.join('\n\n--- Next Page ---\n\n'),
        if (_selectedPaymentMethod != null) 'paymentMethod': _selectedPaymentMethod,
        if (_lastParsedData != null) 'parsedData': _lastParsedData,
      },
    );
  }

  @override
  void dispose() {
    _alignmentTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Camera Viewfinder / Frame ──────────────────────────────────────
          Column(
            children: [
              Expanded(
                flex: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(color: _isFlashOn ? const Color(0xFF22221A) : const Color(0xFF111111)),
                    
                    // Corner guides & alignment frame
                    Positioned(
                      top: topPadding + 72,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: MediaQuery.of(context).size.width * 0.82,
                        height: MediaQuery.of(context).size.width * 1.08,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isPulsing ? Colors.white : Colors.white.withValues(alpha: _isFlashOn ? 0.35 : 0.15),
                            width: _isPulsing ? 2.5 : 1,
                          ),
                          boxShadow: _isPulsing
                              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.8), blurRadius: 32)]
                              : [],
                        ),
                        child: Stack(
                          children: [
                            if (_isPulsing)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            _corner(top: 0, left: 0, topBorder: true, leftBorder: true),
                            _corner(top: 0, right: 0, topBorder: true, rightBorder: true),
                            _corner(bottom: 0, left: 0, bottomBorder: true, leftBorder: true),
                            _corner(bottom: 0, right: 0, bottomBorder: true, rightBorder: true),
                          ],
                        ),
                      ),
                    ),

                    // ── Top Bar Controls ─────────────────────────────────────
                    // Back button (top left)
                    Positioned(
                      top: topPadding + 16,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                        ),
                      ),
                    ),

                    // Import UPI button (overflow-friendly next to close X)
                    Positioned(
                      top: topPadding + 16,
                      left: 66,
                      child: GestureDetector(
                        onTap: _isProcessing ? null : _importUpi,
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primaryMid.withValues(alpha: 0.6)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.qr_code_scanner_rounded, color: AppColors.primaryLight, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Import UPI',
                                style: TextStyle(fontFamily: 'Roboto', color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Flash Toggle (top right)
                    Positioned(
                      top: topPadding + 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => setState(() => _isFlashOn = !_isFlashOn),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _isFlashOn ? AppColors.warningBorder.withValues(alpha: 0.3) : Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                            border: _isFlashOn ? Border.all(color: AppColors.warningBorder, width: 1.5) : Border.all(color: Colors.white24),
                          ),
                          child: Icon(
                            _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                            color: _isFlashOn ? AppColors.warningBorder : Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),

                    // Center Guidance Badge
                    Positioned(
                      top: topPadding + 22,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _isAligning ? Colors.white24 : AppColors.primary),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isAligning ? Icons.crop_free_rounded : Icons.check_circle_rounded,
                              color: _isAligning ? Colors.white70 : AppColors.primaryLight,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isAligning ? 'Align receipt inside frame' : 'Steady — Auto capturing!',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: _isAligning ? Colors.white70 : AppColors.primaryLight,
                                fontSize: 13,
                                fontWeight: _isAligning ? FontWeight.w500 : FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Multi-Page "Roll of Film" Thumbnail Chip (Bottom Left) ──
                    if (_capturedPages.isNotEmpty)
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B1B18).withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primaryMid, width: 1.5),
                            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 16, offset: Offset(0, 6))],
                          ),
                          child: Row(
                            children: [
                              // Roll of film thumbnail indicator
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_capturedPages.last),
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${_capturedPages.length} ${_capturedPages.length == 1 ? 'Page' : 'Pages'} Captured',
                                      style: const TextStyle(fontFamily: 'Roboto', color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                                    ),
                                    const Text(
                                      'Tap + for next page of long bill',
                                      style: TextStyle(fontFamily: 'Roboto', color: Colors.white70, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              // "+" add next page button
                              GestureDetector(
                                onTap: _isProcessing ? null : () => _capturePage(source: ImageSource.camera),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Review & Save arrow
                              GestureDetector(
                                onTap: _finishAndGoToPreview,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Review →',
                                    style: TextStyle(fontFamily: 'Roboto', color: Colors.black, fontSize: 12, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Bottom Controls ─────────────────────────────────────────────
              Container(
                color: const Color(0xFF1A1A1A),
                padding: EdgeInsets.only(
                  left: 32,
                  right: 32,
                  top: 24,
                  bottom: bottomPadding + 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Gallery
                    GestureDetector(
                      onTap: _isProcessing ? null : () => _capturePage(source: ImageSource.gallery),
                      child: const _ControlBtn(icon: Icons.photo_library_outlined, label: 'Gallery'),
                    ),
                    // Shutter (Manual Override / Take Photo)
                    GestureDetector(
                      onTap: _isProcessing ? null : () => _capturePage(source: ImageSource.camera),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                    // Manual
                    GestureDetector(
                      onTap: () {
                        if (_capturedPages.isNotEmpty) {
                          _finishAndGoToPreview();
                        } else {
                          context.pushReplacement('/preview');
                        }
                      },
                      child: const _ControlBtn(icon: Icons.edit_note_rounded, label: 'Manual'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Processing overlay
          if (_isProcessing)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                    SizedBox(height: 18),
                    Text(
                      'Analyzing with AI…',
                      style: TextStyle(fontFamily: 'Roboto', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'ML Kit OCR → Gemini 2.5 Flash',
                      style: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _corner({double? top, double? bottom, double? left, double? right,
      bool topBorder = false, bool bottomBorder = false, bool leftBorder = false, bool rightBorder = false}) {
    final color = _isPulsing ? Colors.white : AppColors.primary;
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: 26, height: 26,
        decoration: BoxDecoration(
          border: Border(
            top: topBorder ? BorderSide(color: color, width: 3) : BorderSide.none,
            bottom: bottomBorder ? BorderSide(color: color, width: 3) : BorderSide.none,
            left: leftBorder ? BorderSide(color: color, width: 3) : BorderSide.none,
            right: rightBorder ? BorderSide(color: color, width: 3) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ControlBtn({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 28),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontFamily: 'Roboto', color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

```

---

# File: lib/features/search/presentation/search_controller.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/presentation/dashboard_controller.dart';
import '../../receipt/domain/receipt_model.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final searchFilterProvider = StateProvider<String>((ref) => 'All');

final searchResultsProvider = Provider<List<ReceiptModel>>((ref) {
  final receipts = ref.watch(dashboardReceiptsProvider).value ?? [];
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(searchFilterProvider);

  if (query.isEmpty) {
    return receipts.where((r) {
      if (filter == 'Warranty') return r.warrantyMonths != null && r.warrantyMonths! > 0;
      return true;
    }).toList();
  }

  return receipts.where((r) {
    final matchesMerchant = r.merchant.toLowerCase().contains(query);
    final matchesCategory = r.category.toLowerCase().contains(query);
    final matchesInvoice = r.invoiceNumber.toLowerCase().contains(query);
    final matchesProducts = r.products.any((p) => p.name.toLowerCase().contains(query));

    bool matchesAmount = false;
    final parsedQueryVal = double.tryParse(query);
    if (parsedQueryVal != null) {
      matchesAmount = (r.totalAmount - parsedQueryVal).abs() < 10.0;
    }

    final isMatched = matchesMerchant || matchesCategory || matchesInvoice || matchesProducts || matchesAmount;

    if (filter == 'Warranty') {
      return isMatched && r.warrantyMonths != null && r.warrantyMonths! > 0;
    }
    if (filter == 'Amount') {
      return matchesAmount;
    }
    if (filter == 'Category') {
      return matchesCategory;
    }

    return isMatched;
  }).toList();
});

```

---

# File: lib/features/search/presentation/search_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'search_controller.dart';
import '../../../core/theme/colors.dart';


class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    final filter = ref.watch(searchFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSec = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final inputBg = isDark ? AppColors.surfaceVariantDark : Colors.white;

    final rupee = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'Search',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Search bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
                ),
                child: TextField(
                  controller: _textCtrl,
                  onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                  style: TextStyle(fontFamily: 'Roboto', fontSize: 15, color: textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search merchant, category, amount…',
                    hintStyle: TextStyle(fontFamily: 'Roboto', fontSize: 15, color: textSec),
                    prefixIcon: Icon(Icons.search_rounded, color: textSec, size: 22),
                    suffixIcon: _textCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: textSec, size: 20),
                            onPressed: () {
                              _textCtrl.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Filter chips ───────────────────────────────────────────────
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: ['All', 'Warranty', 'Electronics', 'Food', 'Fashion', 'Grocery', 'Travel'].map((f) {
                  final sel = filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => ref.read(searchFilterProvider.notifier).state = f,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primary : (isDark ? AppColors.surfaceVariantDark : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel ? Colors.transparent : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
                          ),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : textSec,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // ── Result count ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${results.length} results',
                style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: textSec, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 10),

            // ── Result list ────────────────────────────────────────────────
            Expanded(
              child: results.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 52, color: textSec.withValues(alpha: 0.3)),
                        const SizedBox(height: 14),
                        Text('No receipts found', style: TextStyle(fontFamily: 'Roboto', fontSize: 15, color: textSec)),
                        const SizedBox(height: 6),
                        Text('Try a different search term', style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: textSec.withValues(alpha: 0.6))),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final r = results[index];
                        final parts = r.merchant.split(' | ');
                        final storeName = parts.last;
                        final catColors = _categoryColors(r.category);

                        String? warrantyLabel;
                        Color? wBg, wFg;
                        if (r.warrantyMonths != null && r.warrantyMonths! > 0) {
                          final exp = r.purchaseDate.add(Duration(days: r.warrantyMonths! * 30));
                          final diff = exp.difference(DateTime.now()).inDays;
                          if (diff > 0) {
                            warrantyLabel = '${diff}D LEFT';
                            wBg = diff <= 30 ? AppColors.warningLight : AppColors.warrantyGreenBg;
                            wFg = diff <= 30 ? AppColors.warning : AppColors.warrantyGreenFg;
                          }
                        }

                        return GestureDetector(
                          onTap: () => context.push('/receipt/${r.id}'),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: catColors.$3,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(_categoryIcon(r.category), color: catColors.$2, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        storeName,
                                        style: TextStyle(fontFamily: 'Roboto', fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            DateFormat('d MMM yyyy').format(r.purchaseDate),
                                            style: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: textSec),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(color: catColors.$3, borderRadius: BorderRadius.circular(5)),
                                            child: Text(
                                              r.category.toUpperCase(),
                                              style: TextStyle(fontFamily: 'Roboto', fontSize: 10, fontWeight: FontWeight.w700, color: catColors.$2),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      rupee.format(r.totalAmount),
                                      style: TextStyle(fontFamily: 'Roboto', fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary),
                                    ),
                                    if (warrantyLabel != null) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: wBg, borderRadius: BorderRadius.circular(5)),
                                        child: Text(warrantyLabel, style: TextStyle(fontFamily: 'Roboto', fontSize: 10, fontWeight: FontWeight.w700, color: wFg)),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category helpers ──────────────────────────────────────────────────────────

IconData _categoryIcon(String cat) {
  switch (cat.toLowerCase()) {
    case 'electronics': return Icons.electrical_services_rounded;
    case 'food': return Icons.restaurant_rounded;
    case 'fashion': return Icons.shopping_bag_rounded;
    case 'grocery': return Icons.shopping_cart_rounded;
    case 'travel': return Icons.flight_takeoff_rounded;
    case 'health': return Icons.local_hospital_rounded;
    default: return Icons.receipt_long_rounded;
  }
}

(Color, Color, Color) _categoryColors(String cat) {
  switch (cat.toLowerCase()) {
    case 'electronics': return (AppColors.catElectrFg, AppColors.catElectrFg, AppColors.catElectrBg);
    case 'food': return (AppColors.catFoodFg, AppColors.catFoodFg, AppColors.catFoodBg);
    case 'fashion': return (AppColors.catFashionFg, AppColors.catFashionFg, AppColors.catFashionBg);
    case 'grocery': return (AppColors.catGroceryFg, AppColors.catGroceryFg, AppColors.catGroceryBg);
    case 'travel': return (AppColors.catTravelFg, AppColors.catTravelFg, AppColors.catTravelBg);
    case 'health': return (AppColors.catHealthFg, AppColors.catHealthFg, AppColors.catHealthBg);
    default: return (AppColors.catOtherFg, AppColors.catOtherFg, AppColors.catOtherBg);
  }
}

```

---

# File: lib/features/warranty/presentation/warranty_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../home/presentation/dashboard_controller.dart';
import '../../../core/theme/colors.dart';



final warrantyFilterProvider = StateProvider<String>((ref) => 'All');

class WarrantyScreen extends ConsumerWidget {
  const WarrantyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipts = ref.watch(dashboardReceiptsProvider).value ?? [];
    final filter = ref.watch(warrantyFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSec = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final now = DateTime.now();
    final warrantyItems = receipts.where((r) => r.warrantyMonths != null && r.warrantyMonths! > 0).toList();

    int active = 0, expiring = 0, expired = 0;
    for (final r in warrantyItems) {
      final exp = r.purchaseDate.add(Duration(days: r.warrantyMonths! * 30));
      if (exp.isBefore(now)) {
        expired++;
      } else {
        active++;
        if (exp.difference(now).inDays <= 30) expiring++;
      }
    }

    final filtered = warrantyItems.where((r) {
      final exp = r.purchaseDate.add(Duration(days: r.warrantyMonths! * 30));
      final isExp = exp.isBefore(now);
      final diff = exp.difference(now).inDays;
      switch (filter) {
        case 'Active': return !isExp;
        case 'Expiring': return !isExp && diff <= 30;
        case 'Expired': return isExp;
        default: return true;
      }
    }).toList()
      ..sort((a, b) {
        final expA = a.purchaseDate.add(Duration(days: a.warrantyMonths! * 30));
        final expB = b.purchaseDate.add(Duration(days: b.warrantyMonths! * 30));
        final isExpA = expA.isBefore(now);
        final isExpB = expB.isBefore(now);
        // Active before expired
        if (isExpA != isExpB) return isExpA ? 1 : -1;
        // Active: soonest-expiring first (ascending diff)
        // Expired: most recently expired first (descending, i.e. diff is negative — closer to 0 is more recent)
        return expA.compareTo(expB);
      });

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  'Warranty Vault',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),

            // ── Stats row ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _WarrantyStat(
                        label: 'Active',
                        count: active,
                        color: AppColors.primary,
                        bg: AppColors.primaryLight,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _WarrantyStat(
                        label: 'Expiring',
                        count: expiring,
                        color: AppColors.warning,
                        bg: AppColors.warningLight,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _WarrantyStat(
                        label: 'Expired',
                        count: expired,
                        color: AppColors.error,
                        bg: AppColors.errorLight,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Filter pills ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: ['All', 'Active', 'Expiring', 'Expired'].map((f) {
                      final sel = f == filter;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => ref.read(warrantyFilterProvider.notifier).state = f,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: sel ? (isDark ? AppColors.surfaceDark : Colors.white) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: sel ? [const BoxShadow(color: Color(0x18000000), blurRadius: 4)] : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              f,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 13,
                                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                                color: sel ? (isDark ? AppColors.textPrimaryDark : AppColors.primary) : textSec,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // ── List ──────────────────────────────────────────────────────
            if (filtered.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.only(top: 60),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Icon(Icons.shield_outlined, size: 52, color: textSec.withValues(alpha: 0.3)),
                      const SizedBox(height: 14),
                      Text('No $filter warranties', style: TextStyle(fontFamily: 'Roboto', fontSize: 15, color: textSec)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final r = filtered[index];
                      final exp = r.purchaseDate.add(Duration(days: r.warrantyMonths! * 30));
                      final isExp = exp.isBefore(now);
                      final diff = exp.difference(now).inDays;
                      final parts = r.merchant.split(' | ');
                      final title = parts.first;
                      final store = parts.length > 1 ? parts.last : '';

                      Color badgeBg, badgeFg;
                      String badgeLabel;
                      if (isExp) {
                        badgeBg = AppColors.errorLight;
                        badgeFg = AppColors.error;
                        badgeLabel = 'EXPIRED';
                      } else if (diff <= 30) {
                        badgeBg = AppColors.warningLight;
                        badgeFg = AppColors.warning;
                        badgeLabel = '${diff}D LEFT';
                      } else {
                        badgeBg = AppColors.warrantyGreenBg;
                        badgeFg = AppColors.warrantyGreenFg;
                        badgeLabel = '${diff}D LEFT';
                      }

                      final catColors = _categoryColors(r.category);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
                          ),
                          child: InkWell(
                            onTap: () => context.push('/receipt/${r.id}'),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
                              child: Row(
                                children: [
                                  // Category icon
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: catColors.$3,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(_categoryIcon(r.category), color: catColors.$2, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  // Title + subtitle
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${store.isNotEmpty ? '$store • ' : ''}Expires ${DateFormat('d MMM yyyy').format(exp)}',
                                          style: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: textSec),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Countdown badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
                                    child: Text(
                                      badgeLabel,
                                      style: TextStyle(fontFamily: 'Roboto', fontSize: 11, fontWeight: FontWeight.w700, color: badgeFg),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  // ⋮ Quick actions
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert_rounded, color: textSec, size: 20),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    color: cardBg,
                                    elevation: 6,
                                    padding: EdgeInsets.zero,
                                    onSelected: (value) {
                                      if (value == 'view') {
                                        context.push('/receipt/${r.id}');
                                      } else if (value == 'pdf') {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('PDF export coming soon'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      PopupMenuItem(
                                        value: 'view',
                                        child: Row(
                                          children: [
                                            Icon(Icons.receipt_long_outlined, size: 18, color: textPrimary),
                                            const SizedBox(width: 10),
                                            Text('View Full Receipt', style: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: textPrimary)),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'pdf',
                                        child: Row(
                                          children: [
                                            Icon(Icons.picture_as_pdf_outlined, size: 18, color: AppColors.primary),
                                            SizedBox(width: 10),
                                            Text('Share PDF', style: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: AppColors.primary)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WarrantyStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bg;
  final bool isDark;

  const _WarrantyStat({
    required this.label,
    required this.count,
    required this.color,
    required this.bg,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontFamily: 'Roboto', fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 6),
          Text('$count', style: TextStyle(fontFamily: 'Roboto', fontSize: 28, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

// ── Category helpers ──────────────────────────────────────────────────────────

IconData _categoryIcon(String cat) {
  switch (cat.toLowerCase()) {
    case 'electronics': return Icons.laptop_mac_rounded;
    case 'food': return Icons.restaurant_rounded;
    case 'fashion': return Icons.shopping_bag_rounded;
    case 'grocery': return Icons.shopping_cart_rounded;
    case 'travel': return Icons.flight_takeoff_rounded;
    case 'health': return Icons.local_hospital_rounded;
    default: return Icons.receipt_long_rounded;
  }
}

(Color, Color, Color) _categoryColors(String cat) {
  switch (cat.toLowerCase()) {
    case 'electronics': return (AppColors.catElectrFg, AppColors.catElectrFg, AppColors.catElectrBg);
    case 'food': return (AppColors.catFoodFg, AppColors.catFoodFg, AppColors.catFoodBg);
    case 'fashion': return (AppColors.catFashionFg, AppColors.catFashionFg, AppColors.catFashionBg);
    case 'grocery': return (AppColors.catGroceryFg, AppColors.catGroceryFg, AppColors.catGroceryBg);
    case 'travel': return (AppColors.catTravelFg, AppColors.catTravelFg, AppColors.catTravelBg);
    case 'health': return (AppColors.catHealthFg, AppColors.catHealthFg, AppColors.catHealthBg);
    default: return (AppColors.catOtherFg, AppColors.catOtherFg, AppColors.catOtherBg);
  }
}


```

---

# File: lib/screens/splash/splash_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';


/// 3-page onboarding carousel that matches the reference screenshots exactly.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 340),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _controller,
        onPageChanged: (i) => setState(() => _current = i),
        children: [
          _Slide1(onNext: _next, onSkip: () => context.go('/login')),
          _Slide2(onNext: _next, onSkip: () => context.go('/login')),
          _Slide3(onStart: () => context.go('/login'), onLater: () => context.go('/login')),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slide 1 — "Track Every Purchase"
// ─────────────────────────────────────────────────────────────────────────────
class _Slide1 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _Slide1({required this.onNext, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Hero image area ─────────────────────────────────────────────────
        Expanded(
          flex: 52,
          child: Container(
            width: double.infinity,
            color: AppColors.surfaceVariantLight,
            child: const Center(
              child: _VaultHeroIllustration(),
            ),
          ),
        ),
        // ── Content ─────────────────────────────────────────────────────────
        Expanded(
          flex: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Track Every Purchase',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Scan, store, and organize all your\nreceipts in one secure vault.',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // ── Page dots ───────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Dot(active: true),
                    const SizedBox(width: 6),
                    _Dot(active: false),
                    const SizedBox(width: 6),
                    _Dot(active: false),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onNext,
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onSkip,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slide 2 — "Never Lose a Warranty"
// ─────────────────────────────────────────────────────────────────────────────
class _Slide2 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _Slide2({required this.onNext, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 52,
          child: Container(
            width: double.infinity,
            color: AppColors.primary,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 64),
                  ),
                  const SizedBox(height: 20),
                  // Warranty cards mockup
                  _WarrantyMockCard(
                    icon: Icons.phone_iphone_rounded,
                    label: 'iPhone 15 Pro',
                    days: '186 days left',
                    isGreen: true,
                  ),
                  const SizedBox(height: 8),
                  _WarrantyMockCard(
                    icon: Icons.laptop_mac_rounded,
                    label: 'MacBook Air M2',
                    days: '12 days left',
                    isGreen: false,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Never Lose a Warranty',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Get smart alerts before your warranties\nexpire so you\'re always protected.',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Dot(active: false),
                    const SizedBox(width: 6),
                    _Dot(active: true),
                    const SizedBox(width: 6),
                    _Dot(active: false),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: onNext,
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontFamily: 'Roboto', fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onSkip,
                  child: const Text(
                    'Skip',
                    style: TextStyle(fontFamily: 'Roboto', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slide 3 — "Let's add your first receipt"
// ─────────────────────────────────────────────────────────────────────────────
class _Slide3 extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onLater;

  const _Slide3({required this.onStart, required this.onLater});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 52,
          child: Container(
            width: double.infinity,
            color: const Color(0xFF1A1A1A),
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 32, offset: const Offset(0, 16)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _PhoneMockup(),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Text(
                  "Let's add your first receipt",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tap the + button anytime to scan,\nupload, or manually add a receipt.',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: onStart,
                    child: const Text(
                      'Add My First Receipt',
                      style: TextStyle(fontFamily: 'Roboto', fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onLater,
                  child: const Text(
                    "I'll do it later",
                    style: TextStyle(fontFamily: 'Roboto', fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textSecondaryLight),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Illustrations
// ─────────────────────────────────────────────────────────────────────────────
class _VaultHeroIllustration extends StatelessWidget {
  const _VaultHeroIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.06),
          ),
        ),
        // Vault body
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFF123D3B),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 12)),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xFF40C2BA), AppColors.primary.withValues(alpha: 0.1)],
                  ),
                ),
              ),
              const Icon(Icons.shield_rounded, color: Colors.white, size: 56),
              // Handle ornaments
              Positioned(
                left: 14,
                child: Container(
                  width: 12,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF266662),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Receipt paper floating
        Positioned(
          right: 20,
          top: 40,
          child: Transform.rotate(
            angle: 0.2,
            child: Container(
              width: 52,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
              ),
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  7,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Container(
                      height: 3,
                      width: i % 3 == 0 ? 28 : 20,
                      color: const Color(0xFFE0E0E0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneMockup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 340,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Status bar mockup
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('9:41', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 14),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Column(
              children: [
                Text(
                  'Welcome to ReceiptVault!\nLet\'s add your first receipt.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, height: 1.4),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to get started.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Bottom nav mockup
          Container(
            height: 56,
            color: const Color(0xFF2A2A2A),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.home_rounded, color: AppColors.primaryMid, size: 20),
                const Icon(Icons.bar_chart_rounded, color: Colors.white38, size: 20),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                ),
                const Icon(Icons.search_rounded, color: Colors.white38, size: 20),
                const Icon(Icons.shield_rounded, color: Colors.white38, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WarrantyMockCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String days;
  final bool isGreen;

  const _WarrantyMockCard({
    required this.icon,
    required this.label,
    required this.days,
    required this.isGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isGreen ? AppColors.warrantyGreenBg : AppColors.warrantyAmberBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              days,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isGreen ? AppColors.warrantyGreenFg : AppColors.warrantyAmberFg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 22 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.outlineLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

```

---

# File: lib/theme/colors.dart

```dart
import '../core/theme/colors.dart';

// ─────────────────────────────────────────────────────────────────
// ReceiptVault Modern UI Theme Palette (Light & Dark)
// Aliased to central AppColors (warm sand + deep teal palette)
// ─────────────────────────────────────────────────────────────────

const kPrimary = AppColors.primary;
const kPrimaryDark = AppColors.primaryDark;
const kPrimaryLight = AppColors.primaryLight;
const kSecondary = AppColors.primaryMid;

const kSuccess = AppColors.success;
const kSuccessLight = AppColors.successLight;
const kWarning = AppColors.warning;
const kWarningLight = AppColors.warningLight;
const kError = AppColors.error;

// ── Light Palette (Warm Sand + Deep Teal Style) ──────────────────
const kLightBackground = AppColors.bgLight;
const kLightSurface = AppColors.surfaceLight;
const kLightSurfaceVariant = AppColors.surfaceVariantLight;
const kLightOnBackground = AppColors.textPrimaryLight;
const kLightOnSurface = AppColors.textPrimaryLight;
const kLightOutline = AppColors.outlineLight;

// ── Category Pastel Colors ───────────────────────────────────────
const kCatElectronicsBg = AppColors.catElectrBg;
const kCatElectronicsText = AppColors.catElectrFg;

const kCatFoodBg = AppColors.catFoodBg;
const kCatFoodText = AppColors.catFoodFg;

const kCatFashionBg = AppColors.catFashionBg;
const kCatFashionText = AppColors.catFashionFg;

const kCatGroceryBg = AppColors.catGroceryBg;
const kCatGroceryText = AppColors.catGroceryFg;

const kCatTravelBg = AppColors.catTravelBg;
const kCatTravelText = AppColors.catTravelFg;

const kCatOtherBg = AppColors.catOtherBg;
const kCatOtherText = AppColors.catOtherFg;

// ── Dark Palette (Warm Dark Sand / Charcoal) ─────────────────────
const kDarkBackground = AppColors.bgDark;
const kDarkSurface = AppColors.surfaceDark;
const kDarkSurfaceVariant = AppColors.surfaceVariantDark;
const kDarkOnBackground = AppColors.textPrimaryDark;
const kDarkOnSurface = AppColors.textPrimaryDark;
const kDarkOutline = AppColors.outlineDark;


```

---

# File: lib/theme/theme.dart

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

// ─────────────────────────────────────────────────────────────────
// ReceiptVaultTheme — Material 3, Plus Jakarta Sans font scale
// ─────────────────────────────────────────────────────────────────

final kDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: kPrimary,
  onPrimary: Colors.white,
  primaryContainer: kPrimaryDark,
  onPrimaryContainer: Colors.white,
  secondary: kSecondary,
  onSecondary: Colors.white,
  secondaryContainer: const Color(0xFF1B3A39),
  onSecondaryContainer: kSecondary,
  tertiary: const Color(0xFF7E57C2),
  onTertiary: Colors.white,
  tertiaryContainer: const Color(0xFF2D1F4A),
  onTertiaryContainer: const Color(0xFFD1C4E9),
  error: kError,
  onError: Colors.white,
  errorContainer: const Color(0xFF4A1010),
  onErrorContainer: const Color(0xFFFFCDD2),
  surface: kDarkSurface,
  onSurface: kDarkOnSurface,
  surfaceContainerHighest: kDarkSurfaceVariant,
  onSurfaceVariant: kDarkOnSurface.withValues(alpha: 0.7),
  outline: kDarkOutline,
  outlineVariant: kDarkOutline.withValues(alpha: 0.5),
  shadow: Colors.black,
  scrim: Colors.black87,
  inverseSurface: kLightSurface,
  onInverseSurface: kLightOnSurface,
  inversePrimary: kPrimaryDark,
);

final kLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: kPrimaryDark,
  onPrimary: Colors.white,
  primaryContainer: const Color(0xFFE8EAF6),
  onPrimaryContainer: kPrimaryDark,
  secondary: const Color(0xFF00897B),
  onSecondary: Colors.white,
  secondaryContainer: const Color(0xFFE0F2F1),
  onSecondaryContainer: const Color(0xFF004D40),
  tertiary: const Color(0xFF5E35B1),
  onTertiary: Colors.white,
  tertiaryContainer: const Color(0xFFEDE7F6),
  onTertiaryContainer: const Color(0xFF311B92),
  error: const Color(0xFFD32F2F),
  onError: Colors.white,
  errorContainer: const Color(0xFFFFEBEE),
  onErrorContainer: const Color(0xFFB71C1C),
  surface: kLightSurface,
  onSurface: kLightOnSurface,
  surfaceContainerHighest: kLightSurfaceVariant,
  onSurfaceVariant: kLightOnSurface.withValues(alpha: 0.7),
  outline: kLightOutline,
  outlineVariant: kLightOutline.withValues(alpha: 0.5),
  shadow: Colors.black26,
  scrim: Colors.black38,
  inverseSurface: kDarkSurface,
  onInverseSurface: kDarkOnSurface,
  inversePrimary: kPrimary,
);

ThemeData buildDarkTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: kDarkColorScheme,
  scaffoldBackgroundColor: kDarkBackground,
  fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
  textTheme: _buildDarkText(),
  cardTheme: _buildCardTheme(kDarkSurface),
  appBarTheme: _buildAppBarTheme(kDarkBackground),
  bottomNavigationBarTheme: _buildBottomNavTheme(kDarkSurface),
  navigationBarTheme: _buildNavBarTheme(kDarkSurface),
  floatingActionButtonTheme: _buildFabTheme(),
  filledButtonTheme: _buildFilledButtonTheme(),
  outlinedButtonTheme: _buildOutlinedButtonTheme(),
  inputDecorationTheme: _buildInputTheme(kDarkSurfaceVariant, kDarkOutline),
  chipTheme: _buildChipTheme(kDarkSurfaceVariant),
  dividerTheme: const DividerThemeData(color: kDarkOutline, thickness: 1),
  iconTheme: const IconThemeData(color: kDarkOnSurface),
);

ThemeData buildLightTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: kLightColorScheme,
  scaffoldBackgroundColor: kLightBackground,
  fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
  textTheme: _buildLightText(),
  cardTheme: _buildCardTheme(kLightSurface),
  appBarTheme: _buildAppBarTheme(kLightBackground),
  bottomNavigationBarTheme: _buildBottomNavTheme(kLightSurface),
  navigationBarTheme: _buildNavBarTheme(kLightSurface),
  floatingActionButtonTheme: _buildFabTheme(),
  filledButtonTheme: _buildFilledButtonTheme(),
  outlinedButtonTheme: _buildOutlinedButtonTheme(),
  inputDecorationTheme: _buildInputTheme(kLightSurfaceVariant, kLightOutline),
  chipTheme: _buildChipTheme(kLightSurfaceVariant),
  dividerTheme: const DividerThemeData(color: kLightOutline, thickness: 1),
  iconTheme: const IconThemeData(color: kLightOnSurface),
);

// ── Private builders ─────────────────────────────────────────────

TextTheme _buildDarkText() => _buildTextTheme(kDarkOnBackground);
TextTheme _buildLightText() => _buildTextTheme(kLightOnBackground);

TextTheme _buildTextTheme(Color base) {
  final baseTextTheme = Typography.material2021().black.apply(displayColor: base, bodyColor: base);
  final plusJakartaSansTheme = GoogleFonts.plusJakartaSansTextTheme(baseTextTheme);
  
  return plusJakartaSansTheme.copyWith(
    // Hero numbers (Plus Jakarta Sans Bold (700) – 32–36sp)
    displayLarge: plusJakartaSansTheme.displayLarge?.copyWith(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      color: base,
    ),
    displayMedium: plusJakartaSansTheme.displayMedium?.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: base,
    ),
    
    // Screen titles ("Insights", "Warranty Vault", "My Receipts") (Plus Jakarta Sans Bold (700) – 24–28sp)
    headlineLarge: plusJakartaSansTheme.headlineLarge?.copyWith(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: base,
    ),
    headlineMedium: plusJakartaSansTheme.headlineMedium?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: base,
    ),
    headlineSmall: plusJakartaSansTheme.headlineSmall?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: base,
    ),
    
    // Card titles (store name, product name, category) (Plus Jakarta Sans SemiBold (600) – 16–17sp)
    titleLarge: plusJakartaSansTheme.titleLarge?.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: base,
    ),
    titleMedium: plusJakartaSansTheme.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: base,
    ),
    titleSmall: plusJakartaSansTheme.titleSmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: base,
    ),
    
    // Body text & form labels (Plus Jakarta Sans Regular (400) – 14–15sp)
    bodyLarge: plusJakartaSansTheme.bodyLarge?.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: base,
    ),
    bodyMedium: plusJakartaSansTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: base,
    ),
    
    // Muted metadata (dates, amounts in lists) (Plus Jakarta Sans Regular (400) – 12–13sp, lighter gray)
    bodySmall: plusJakartaSansTheme.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: base.withValues(alpha: 0.65),
    ),
    
    // Buttons (Plus Jakarta Sans SemiBold (600) – 15–16sp)
    labelLarge: plusJakartaSansTheme.labelLarge?.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: base,
    ),
    
    // Overline / Labels (Plus Jakarta Sans Medium (500) – 11–12sp, uppercase, letter-spacing 0.5px)
    labelSmall: plusJakartaSansTheme.labelSmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: base,
      letterSpacing: 0.5,
    ),
  );
}

CardThemeData _buildCardTheme(Color surface) => CardThemeData(
  color: surface,
  elevation: 0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  margin: EdgeInsets.zero,
);

AppBarTheme _buildAppBarTheme(Color bg) => AppBarTheme(
  backgroundColor: bg,
  elevation: 0,
  scrolledUnderElevation: 2,
  centerTitle: false,
  titleTextStyle: GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  ),
);

BottomNavigationBarThemeData _buildBottomNavTheme(Color bg) =>
    BottomNavigationBarThemeData(
      backgroundColor: bg,
      selectedItemColor: kPrimary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );

NavigationBarThemeData _buildNavBarTheme(Color bg) => NavigationBarThemeData(
  backgroundColor: bg,
  indicatorColor: kPrimary.withValues(alpha: 0.2),
  labelTextStyle: WidgetStatePropertyAll(
    GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: kPrimary,
    ),
  ),
  elevation: 8,
  shadowColor: Colors.black38,
);

FloatingActionButtonThemeData _buildFabTheme() => const FloatingActionButtonThemeData(
  backgroundColor: kPrimary,
  foregroundColor: Colors.white,
  elevation: 6,
  shape: CircleBorder(),
);

FilledButtonThemeData _buildFilledButtonTheme() => FilledButtonThemeData(
  style: FilledButton.styleFrom(
    backgroundColor: kPrimary,
    foregroundColor: Colors.white,
    minimumSize: const Size.fromHeight(52),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: GoogleFonts.plusJakartaSans(
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
  ),
);

OutlinedButtonThemeData _buildOutlinedButtonTheme() => OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    foregroundColor: kPrimary,
    side: const BorderSide(color: kPrimary, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    minimumSize: const Size.fromHeight(52),
    textStyle: GoogleFonts.plusJakartaSans(
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
  ),
);

InputDecorationTheme _buildInputTheme(Color fill, Color outline) =>
    InputDecorationTheme(
      filled: true,
      fillColor: fill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kError, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(fontSize: 14),
    );

ChipThemeData _buildChipTheme(Color surface) => ChipThemeData(
  backgroundColor: surface,
  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  side: BorderSide.none,
);

```

---

# File: lib/theme/typography.dart

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

// ─────────────────────────────────────────────────────────────────
// Typography — uses Roboto font family scale
// ─────────────────────────────────────────────────────────────────

final kTypography = Typography.material2021().copyWith(
  white: _buildTextTheme(kDarkOnSurface),
  black: _buildTextTheme(kLightOnSurface),
);

TextTheme _buildTextTheme(Color baseColor) {
  final baseTextTheme = Typography.material2021().black.apply(displayColor: baseColor, bodyColor: baseColor);
  final robotoTheme = GoogleFonts.robotoTextTheme(baseTextTheme);
  
  return robotoTheme.copyWith(
    // Hero numbers (Roboto Bold (700) – 32–36sp)
    displayLarge: robotoTheme.displayLarge?.copyWith(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      color: baseColor,
    ),
    displayMedium: robotoTheme.displayMedium?.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: baseColor,
    ),
    
    // Screen titles (Roboto Bold (700) – 24–28sp)
    headlineLarge: robotoTheme.headlineLarge?.copyWith(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: baseColor,
    ),
    headlineMedium: robotoTheme.headlineMedium?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: baseColor,
    ),
    headlineSmall: robotoTheme.headlineSmall?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: baseColor,
    ),
    
    // Card titles (Roboto SemiBold (600) – 16–17sp)
    titleLarge: robotoTheme.titleLarge?.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: baseColor,
    ),
    titleMedium: robotoTheme.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: baseColor,
    ),
    titleSmall: robotoTheme.titleSmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: baseColor,
    ),
    
    // Body text & form labels (Roboto Regular (400) – 14–15sp)
    bodyLarge: robotoTheme.bodyLarge?.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: baseColor,
    ),
    bodyMedium: robotoTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: baseColor,
    ),
    
    // Muted metadata (Roboto Regular (400) – 12–13sp, lighter gray)
    bodySmall: robotoTheme.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: baseColor.withValues(alpha: 0.65),
    ),
    
    // Buttons (Roboto SemiBold (600) – 15–16sp)
    labelLarge: robotoTheme.labelLarge?.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: baseColor,
    ),
    
    // Overline / Labels (Roboto Medium (500) – 11–12sp, uppercase, letter-spacing 0.5px)
    labelSmall: robotoTheme.labelSmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: baseColor,
      letterSpacing: 0.5,
    ),
  );
}

```

---

# File: lib/widgets/bottom_nav_bar.dart

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Main Shell with bottom navigation that matches the reference design
// ─────────────────────────────────────────────────────────────────────────────
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _activeIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    if (loc.startsWith('/home')) return 0;
    if (loc.startsWith('/analytics')) return 1;
    if (loc.startsWith('/search')) return 3;
    if (loc.startsWith('/warranty')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    final int idx = _activeIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: _ReceiptVaultBottomBar(
        currentIndex: idx,
        bg: bg,
        isDark: isDark,
        onItemTap: (i) {
          switch (i) {
            case 0: context.go('/home'); break;
            case 1: context.go('/analytics'); break;
            case 3: context.go('/search'); break;
            case 4: context.go('/warranty'); break;
          }
        },
        onFabTap: () => context.push('/scan'),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom bottom bar that exactly matches the reference screenshots
// Home | Stats | [+FAB] | Search | Vault
// ─────────────────────────────────────────────────────────────────────────────
class _ReceiptVaultBottomBar extends StatelessWidget {
  final int currentIndex;
  final bool isDark;
  final Color bg;
  final ValueChanged<int> onItemTap;
  final VoidCallback onFabTap;

  const _ReceiptVaultBottomBar({
    required this.currentIndex,
    required this.isDark,
    required this.bg,
    required this.onItemTap,
    required this.onFabTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                isActive: currentIndex == 0,
                isDark: isDark,
                onTap: () => onItemTap(0),
              ),
              _NavItem(
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart_rounded,
                label: 'Stats',
                isActive: currentIndex == 1,
                isDark: isDark,
                onTap: () => onItemTap(1),
              ),
              // ── Centre FAB ──────────────────────────────────────────────
              Expanded(
                child: GestureDetector(
                  onTap: onFabTap,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x440F4C4A),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.search_outlined,
                activeIcon: Icons.search_rounded,
                label: 'Search',
                isActive: currentIndex == 3,
                isDark: isDark,
                onTap: () => onItemTap(3),
              ),
              _NavItem(
                icon: Icons.shield_outlined,
                activeIcon: Icons.shield_rounded,
                label: 'Vault',
                isActive: currentIndex == 4,
                isDark: isDark,
                onTap: () => onItemTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.primaryMid : AppColors.primary;
    final inactiveColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

```

---

# File: lib/widgets/loading_placeholder.dart

```dart
import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

class LoadingPlaceholder extends StatelessWidget {
  final double height;
  const LoadingPlaceholder({super.key, this.height = 80});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: AppColors.primary),
    );
  }
}


```

---

# File: lib/widgets/section_header.dart

```dart
import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

```
