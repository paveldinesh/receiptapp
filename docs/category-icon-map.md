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
