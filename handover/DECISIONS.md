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
