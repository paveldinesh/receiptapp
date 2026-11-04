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
