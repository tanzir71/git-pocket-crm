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

## Spec 15 — Landing page, part A (2026-11-27)

- **Font subsetting:** Subsetted Inter v4.1 `InterVariable.woff2` with `fontTools.subset` to Latin + Latin-1 + punctuation/symbols (`99.5 KB`) so the total first-load payload (HTML + CSS + font + hero WebP) is `157.8 KB`, well under the `400 KB` budget. Kept `OFL.txt` beside it.
- **OG image & visual verification:** Generated `docs/og.png` (`1200x630`) from `tool/og/og.html` and captured `handover/design/landing/built-{desktop,mobile,768,1040,dark}.png` via headless Chromium (Playwright) via `tool/og/render_landing.py`.
- **Design comparison notes:** Built screenshots at `1440px` and `390px` match the Figma frames in layout, colour tokens, type scale, spacing, and section rhythm. Only intentional differences are the Part A "being built" copy/links and the spec's instruction to use 16/24 body copy on web instead of the app's 15/22.

## Spec 04 — App shell (2026-11-27)

- **State & routing:** Added `flutter_riverpod: ^3.5.0` (hand-written providers, no code generation) and `go_router: ^18.1.4` (`StatefulShellRoute.indexedStack`).
- **Localization:** Enabled `flutter_localizations` and `flutter gen-l10n` (`l10n.yaml` + `lib/l10n/app_en.arb`) early in Spec 04 so every v2 screen adheres to Hard Rule 8 (no user-facing string literals in widgets) from the start.
- **V2 feature switch:** `kV2` defaults to `false` until Spec 10; `--dart-define=V2=true` launches `PocketCrmV2App`. Legacy screens moved unchanged to `lib/legacy/`.

## Spec 05 — Sync (2026-11-27)

- **Packages:** Upgraded `flutter_contacts` to `^2.6.0` (using `FlutterContacts.getAll(properties: ContactProperties.allProperties)`), added `phone_numbers_parser: ^9.2.3`, and added dev dependency `pigeon: ^30.0.4`. Added `kotlinx-coroutines-android:1.10.2` in `android/app/build.gradle.kts` for Pigeon 30's Kotlin suspend handlers.
- **Native batched reader:** Implemented `DeviceApiImpl` in Kotlin reading `CallLog.Calls` and `Telephony.Sms` on `Dispatchers.IO` with `_id > ?` watermarks (`Bundle` query args on API 30+, cursor cap fallback below), plus 2-second debounced `ContentObserver`s.
- **Spam filter removal from sync:** `SyncService` never calls `SpamFilter`; messages matching any phone of a saved contact are always stored, and incoming monetary amounts become `suggested_amount` / `suggestion_state = 'open'` suggestions rather than auto-created payment rows. Legacy `SyncEngine.syncAll()` now delegates to `SyncService`.

## Spec 06 — People and Person (2026-11-27)

- **Centralised SQL in `lib/core/db/crm_queries.dart`:** Moved all `customSelect`/`customStatement` queries out of `lib/features/` into `lib/core/db/crm_queries.dart` and added a lint guard test ensuring zero SQL exists anywhere under `lib/features/`.
- **Single-query People directory:** `CrmQueries.watchPeopleDirectory` returns contact metadata, first list name, last interaction kind, overdue follow-up status, effective reconnect cadence, and Spec 02 net balance in one query backed by `SliverChildBuilderDelegate` so 5,000+ rows remain smooth.

## Spec 07 — Add and after-call (2026-11-27)

- **Packages:** Added `image_picker: ^1.1.2` for visit photos (camera and gallery) copied into private app storage via `FileStore`.
- **Voice input decision:** Left the in-field microphone button out and rely on Android's system keyboard voice typing. Existing Flutter speech-recognition plugins (`speech_to_text`) pull `android.permission.INTERNET` into the merged Android manifest, which violates Hard Rule 2 (`tool/check_manifest.sh`).
- **Location:** Uses Android's native `LocationManager` (`ACCESS_COARSE_LOCATION`, 5-second timeout) via Pigeon `DeviceApi.currentLocation()`, storing coordinates only with no reverse geocoding and no network permission.

## Spec 08 — Today and reminders (2026-11-27)

- **Packages:** Added `flutter_local_notifications` (spec-named) and `timezone` (required by `flutter_local_notifications`'s `zonedSchedule` API) plus Android `desugar_jdk_libs:2.1.5` in `android/app/build.gradle.kts`.
- **Rescheduling:** Single idempotent `NotificationsService.rescheduleAll()` cancels and recreates all future follow-up reminders (including legacy `tasks.reminder_time` rows) and the optional daily morning summary from the database so notifications never drift from stored data.

## Spec 09 — Native outbox (2026-11-27)

- **Native dependencies:** Added `androidx.work:work-runtime-ktx:2.10.1` and `testImplementation("junit:junit:4.13.2")` in `android/app/build.gradle.kts` (no new Dart dependencies; UUID v4 is generated directly with `Random.secure()`).
- **SMS counter:** Placed pure `countSms(text)` (3GPP TS 23.038 GSM-7 basic + extension table 160/153 vs UCS-2 UTF-16 70/67) in `lib/core/messages/sms_counter.dart` so Spec 09's single-message sheet and Spec 10's bulk composer share one implementation.
- **Airplane mode handling on Android 14:** On Android 14 API 34, `SmsManager.sendMultipartTextMessage` during airplane mode can fail before invoking `SmsResultReceiver`. `SmsSender` checks `Settings.Global.AIRPLANE_MODE_ON` before dispatching and routes through `SmsResultReceiver.recordSyntheticFailure(..., RESULT_ERROR_RADIO_OFF)` so the 1m/5m/15m retry policy triggers reliably.

## Spec 10 — Bulk messages and cut-over (2026-11-27)

- **Native share sheet without extra packages:** Added `OutboxApi.shareFile(path, mimeType, subject)` backed by `androidx.core.content.FileProvider` (`${applicationId}.fileprovider`) and `Intent.createChooser(ACTION_SEND)` so campaign CSV exports (and Spec 12 exports) open the Android share sheet without adding `share_plus`.
- **Database path without `sqflite`:** Removed `sqflite`, `flutter_sms_inbox`, `call_log`, and `google_fonts`, and replaced `getDatabasesPath()` with `resolvePocketCrmDatabasePath` via `path_provider` (`<appDataDir>/databases/pocket_crm.db` on Android), verified by both unit test and emulator run.
- **Cut-over & lint guard:** Flipped `kV2` to `true`, deleted `lib/legacy/`, `lib/sms_processor.dart`, `lib/sync_engine.dart`, `lib/spam_filter.dart`, `lib/database_helper.dart`, `lib/core/db/legacy_db.dart`, `MainActivity`'s `sendSms` channel, and legacy tests; extended `test/lint_guard_test.dart` to enforce design tokens across all of `lib/` and zero `"legacy"` references.

## Spec 11 — Setup and reliability (2026-11-27)

- **Native setup helpers on `OutboxApi`:** Extended Pigeon `OutboxApi` with `setupInfo()` (`sdkInt`, `manufacturer`, `installedFromStore` via `PackageManager.getInstallSourceInfo`, and optional `ownPhoneNumber` via `SubscriptionManager`/`TelephonyManager`), `openExactAlarmSettings()`, `requestIgnoreBatteryOptimisations()`, and `openAppDetailsSettings()` rather than adding extra platform plugins.
- **R8 keep rules for release APK (`android/app/proguard-rules.pro`):** Testing the signed release APK on Android 14 caught R8 stripping `androidx.work.impl.WorkDatabase_Impl.<init>()` (WorkManager's Room initializer). Added `android/app/proguard-rules.pro` keeping `com.pocketcrm.pocket_crm.**`, WorkManager/Room/Startup initializers, and `com.dexterous.flutterlocalnotifications.**`, with explicit `isMinifyEnabled = true` and `isShrinkResources = true` in `android/app/build.gradle.kts`.
- **OEM battery guidance:** Kept all 6 manufacturer battery guidance lines in `lib/l10n/app_en.arb` and matched `Build.MANUFACTURER` case-insensitively in `OemBatteryVendor.fromManufacturer()`.








