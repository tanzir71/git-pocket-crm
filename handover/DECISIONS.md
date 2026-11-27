# Decisions

Log of technical, dependency, and design choices made during implementation where a spec left room to decide.

## Spec 01 — Toolchain and safety net (2026-11-27)

- **Flutter / Dart SDK:**
  - `Flutter 3.50.1 • channel stable • revision ae9b586f34 • 2026-11-18`
  - `Dart 3.14.0 (stable) • DevTools 2.61.0`
- **`material_ui` migration:** Flutter 3.50 deprecates `package:flutter/material.dart` (since 3.47.0-0.0.pre) in favour of the standalone `material_ui` package. Added `material_ui: ^1.11.1` to `pubspec.yaml` and migrated imports to `package:material_ui/material_ui.dart`.
- **Upgraded & pinned dependencies:** `permission_handler: ^13.0.2`, `file_picker: ^13.4.1` (migrated from `FilePicker.platform.*` to static `FilePicker.*` returning `List<PlatformFile>`), `intl: ^0.20.3`, `path: ^1.9.1`, `path_provider: ^2.1.6`, `url_launcher: ^6.3.3`, `open_filex: ^5.0.0`. Removed unused `csv` and `cupertino_icons`. Raised Android `compileSdk` to `37` as required by `permission_handler` 13.0.2, and updated Gradle to `9.5.0`, AGP to `9.3.1`, and Kotlin to `2.4.20` per Flutter 3.50.1 requirements. Adjusted `android/gradle.properties` JVM heap to `-Xmx2G -XX:MaxMetaspaceSize=1G` to prevent Windows virtual memory exhaustion.
- **Release signing key:** Created `~/.pocketcrm/pocketcrm-release.jks` (RSA 4096, alias `pocketcrm`) and `~/.pocketcrm/key.properties` outside the repository. Configured `android/app/build.gradle.kts` to read `$PCRM_KEY_PROPERTIES` or default to `~/.pocketcrm/key.properties`, with no debug-key fallback.
- **Shell scripts on Windows:** `tool/verify.sh`, `tool/check_manifest.sh`, and `tool/build_apk.sh` are written for Git Bash (`C:\Program Files\Git\bin\bash.exe`) and Linux/macOS bash.

## Spec 02 — Data layer (2026-11-27)

- **Drift & native SQLite:** Added `drift: ^2.32.0` (resolved `2.35.4`), `sqlite3: ^3.0.0` (`3.5.2`), `drift_dev: ^2.32.0` (`2.35.3`), and `build_runner: ^2.4.15` (`2.17.1`). Did not add `sqlite3_flutter_libs` (EOL); `sqlite3` 3.x bundles SQLite automatically via Dart native build hooks.
- **Single SQLite connection:** `DatabaseHelper` now returns `LegacyDb` backed by the single Drift `AppDatabase` (`NativeDatabase.createInBackground`). `sqflite` is imported only for `getDatabasesPath()`, `ConflictAlgorithm`, and legacy `Sqflite.firstIntValue`; `openDatabase` is no longer called anywhere in `lib/`.
- **Full-text search:** Created `contacts_fts` using SQLite FTS5 over `display_name`, `company`, `phones`, `about`, and `notes`, with automatic fallback to `LIKE` if FTS5 is unavailable on a host runtime.

## Spec 03 — Theme and components (2026-11-27)

- **Bundled font:** Downloaded official Inter v4.1 (`Inter-Regular.ttf`, `Inter-Medium.ttf`, `Inter-SemiBold.ttf`, and SIL Open Font License `OFL.txt`) from `rsms/inter` GitHub releases into `assets/fonts/` and registered `OFL.txt` via `LicenseRegistry` in `AppTheme.registerFontLicenses()`.
- **Design token enforcement:** Added `AppColors` `ThemeExtension` and `AppTokens` matching every value in `handover/02-design-system.md`, plus `test/lint_guard_test.dart` ensuring zero hardcoded colors, `FontStyle.italic`, `GoogleFonts.`, or `withOpacity(` in `lib/core/widgets` and `lib/features`.


