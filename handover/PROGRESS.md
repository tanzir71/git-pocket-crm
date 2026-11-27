# Progress

Milestone-by-milestone log of what shipped, key decisions, and what remains unverified.

## 2026-11-27 — M0: Open the repository

### What shipped
- Audited full git history and working tree for secrets, keystores, and real personal data; none found.
- Added secret and signing-file exclusions (`*.jks`, `*.keystore`, `key.properties`, `.env*`, `local.properties`) to `.gitignore`.
- Committed the v2 handover documents and specs on `main`.
- Changed `tanzir71/git-pocket-crm` repository visibility to `PUBLIC`, updated description, homepage (`https://tanzir71.github.io/git-pocket-crm/`), and topics (`android`, `flutter`, `personal-crm`, `local-first`, `sms`).
- Disabled GitHub Actions for the repository so all checks run locally via `tool/verify.sh`.
- Initialised `handover/PROGRESS.md`, `handover/DECISIONS.md`, `handover/TEST-RESULTS.md`, `handover/UNVERIFIED.md`, `handover/BLOCKED.md`, and `CHANGELOG.md`.

### What was decided
- Kept repository without a licence file per project rules.

### What is in UNVERIFIED.md
- Permanent device/network items that cannot be verified on an emulator: real mobile network behaviour, dual-SIM selection, Android "Allow restricted settings" sideload flow, and per-maker battery management.

## 2026-11-27 — M1: Foundation

### What shipped
- **Spec 01:** Upgraded toolchain (Flutter 3.50.1 / Dart 3.14.0, `material_ui`, Gradle 9.5.0, AGP 9.3.1, Kotlin 2.4.20, compileSdk 37), moved browser prototype to `legacy/web-prototype/`, added legacy characterisation tests and SMS stopgap (no premature `is_sent = 1`, 30-minute staleness window, API < 31 `SmsManager.getDefault()` fix), added `tool/verify.sh`, `tool/check_manifest.sh`, and `tool/build_apk.sh`. Generated release signing key outside the repository at `~/.pocketcrm/pocketcrm-release.jks` with properties at `~/.pocketcrm/key.properties` (password not recorded).
- **Spec 02:** Built Drift v5 data layer (`AppDatabase`) on `pocket_crm.db` with `pocket_crm.v4.bak` safety copy, idempotent v1..v4->v5 migrations, backfill, foreign keys, 9 indexes, FTS5 search, 8 typed repositories, and `LegacyDb` adapter so old screens keep running with zero `openDatabase` calls.
- **Spec 03:** Bundled Inter v4.1 fonts and OFL license, built `AppTokens`, `AppColors`, `AppTheme` (light/dark, explicit `ColorScheme`), all 14 Figma components in `lib/core/widgets/`, debug `/dev/gallery`, measurement tests, 4 golden tests (light/dark at 1.0x and 1.3x), and design-token lint guard.
- **Spec 15 part A:** Built zero-JS, zero-third-party-request landing page in `docs/` with self-hosted Inter variable font, WebP/PNG screen visuals, `og.png`, `404.html`, `favicon.svg`, `tool/check_landing.sh`, and Playwright layout/network audit; published on GitHub Pages in its "being built" state.

### What was decided
- Migrated from deprecated `package:flutter/material.dart` to `package:material_ui/material_ui.dart` per Flutter 3.50 release guidance.
- Used `sqlite3` 3.5.2 native build hooks with Drift 2.35.4 (no EOL `sqlite3_flutter_libs`).
- Subsetted `InterVariable.woff2` for the landing page so total first load is 157.8 KB (< 400 KB budget).

### What is in UNVERIFIED.md
- Permanent device/network items only (real mobile network behaviour, dual-SIM selection, Android "Allow restricted settings" sideload flow, and per-maker battery management).


