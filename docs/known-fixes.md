# ReceiptVault — Known Fixes Log

Running log of bugs identified and resolved. Check here before re-diagnosing any issue.  
Format: `[YYYY-MM-DD] Screen/component — what was wrong → what was fixed`

---

## Open / Pending

*(none logged yet)*

---

## Resolved

- [2026-07-23] `lib/` codebase — resolved 20 analyzer lints (deprecated `activeColor`/`withOpacity`, `sort_child_properties_last`, string interps, const constructors) → 0 issues remaining in `dart analyze`.
- [2026-07-23] `test/` — created initial unit tests in `test/local_receipt_parser_test.dart` for local receipt parsing logic and models.

---

## Rules for This File

- One line per fix; link the screen/widget if helpful.
- If the same bug reappears, add a note rather than a new entry.
- When a fix introduces a new **design rule**, also append it to `docs/design-principles.md`.
- Do not remove resolved entries — they serve as a record against regression.
