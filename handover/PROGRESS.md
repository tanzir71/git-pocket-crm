# Progress

**Summary:** All six milestones (`M0` through `M5`) are shipped and tagged, with full release `v2.0.0` published on GitHub and the Part B landing page live on GitHub Pages.
Every spec (`00`–`15`) was delivered directly on `main`, verified locally with `tool/verify.sh`, automated unit/widget/golden/JUnit tests, and self-driven Android 14 emulator checks.
The release APK holds zero `INTERNET` permission, preserves all existing user data across migrations, and is signed with the external release keystore.

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

## 2026-11-27 — M2: Everyday workflow

### What shipped
- **Spec 04:** Added `flutter_riverpod` 3.5.0, `go_router` 18.1.4, and ARB localization (`l10n.yaml`, `app_en.arb`); moved legacy screens to `lib/legacy/`; built three-tab `AppShell` behind `--dart-define=V2=true` with `StatefulShellRoute.indexedStack`, `PopScope` back handling, `pocketcrm://` deep links, and first-run `/setup` redirect.
- **Spec 05:** Implemented native Kotlin batched `CallLog` and `Telephony.Sms` reader via Pigeon (`DeviceApi` / `DeviceEvents`, 2s debounced `ContentObserver`s), international E.164 phone normalisation (`phone_numbers_parser` 9.2.3), upgraded `flutter_contacts` 2.6.0, removed `SpamFilter` from new sync, converted incoming SMS monetary mentions into non-intrusive payment suggestions, and verified live sync on an Android 14 emulator.
- **Spec 06:** Centralised all SQL in `lib/core/db/crm_queries.dart` (enforced zero SQL in `lib/features/`), built `AppFormatters` (clock-injectable locale-aware dates, durations, currency), single-query `PeopleScreen` (smooth with 5,000 rows, debounced search, filters, persisted sort, selection mode, duplicate merge, add/edit/list/cadence/person-picker sheets), `PersonScreen` (actions, Next section, paged History with month headers and suggested-payment confirmation), and light/dark goldens.
- **Spec 07:** Added `image_picker` 1.2.4, `FileStore`, native coarse `currentLocation()` and `PhoneStateReceiver` (verified posting `"Add a note about your call with ..."` on Android 14 with the app killed), unified 6-type `AddSheet` with atomic save + 5s Undo, and `AfterCallSheet` editing existing call rows in place.
- **Spec 08:** Added `flutter_local_notifications` 21.0.0 + `timezone` 0.11.2, pure `CadenceCalculator`, full 6-section `TodayScreen` with light/dark goldens, and `NotificationsService` (5 Android channels, follow-up reminders with `Done`/`Tomorrow` actions, morning summary, verified under Doze deep idle and post-reboot re-arming on Android 14).
- Built signed M2 preview APK (`build/PocketCRM.apk`, `--dart-define=V2=true`, `sha256: dc041d98ec96caec46e75a667b01fdc68a60db2aeba075ab13ca89f73080e85c`) and published GitHub pre-release `m2`.

### What was decided
- Kept voice note input on the system keyboard rather than adding a speech plugin that pulls `android.permission.INTERNET` into the merged release manifest.
- Kept `ContentObserver`s registered across `AppLifecycleState.paused` (stopping only on `detached`) so incoming calls pausing the activity under Android's InCallUI still sync immediately.
- Guarded `FlutterLocalNotificationsBackend` calls gracefully on non-Android/test hosts while using `FakeNotificationsBackend` in unit/widget tests.

### What is in UNVERIFIED.md
- Permanent device/network items only (real mobile network behaviour, dual-SIM selection, Android "Allow restricted settings" sideload flow, and per-maker battery management).

## 2026-11-27 — M3: Reliable scheduled and bulk messaging

### What shipped
- **Spec 09:** Replaced the old Flutter-side `Timer.periodic` SMS sender with a native Kotlin outbox (`OutboxDb`, `OutboxStateMachine`, `SmsSender`, `SmsResultReceiver`, `OutboxScheduler`, `AlarmReceiver`, `OutboxDrainWorker`, `OutboxBootReceiver`, `OutboxNotifications`, `OutboxApiImpl`) backed by Pigeon `OutboxApi`, `AlarmManager.setExactAndAllowWhileIdle`, and WorkManager foreground dataSync draining. Supports 1m/5m/15m automatic retry, daily send window, 30-minute missed single-message handling, `LIMIT_EXCEEDED` campaign pausing, GSM-7/UCS-2 multipart SMS counting, `SingleMessageSheet`, and `SyncService` outgoing SMS deduplication. Verified on Android 14 emulator across Doze deep idle + `am kill`, `adb reboot`, airplane-mode retry, 300-char & Bangla multipart, missed >30m, `content://sms/sent` dedup, and 40-message Fast campaign.
- **Spec 10:** Built pure `renderTemplate`, seeded default templates, `CampaignsRepository` (recipient resolution skipping no-mobile/opted-out/duplicates, native CSV export via `FileProvider`), `MergeFieldTextController`, `MessagesScreen`, `NewMessageScreen`, `CampaignScreen`, `SentMessagesScreen`, `TemplateEditorScreen`, opt-out keyword detection (`STOP`, `UNSUBSCRIBE`, `বন্ধ`), one-time idempotent v1 scheduled/bulk SMS migration, and completed the v2 cut-over (`kV2 = true`, deleted `lib/legacy/` and legacy DB/sync/spam files, removed `sqflite`, `flutter_sms_inbox`, `call_log`, and `google_fonts`). Verified Pause/Resume, mid-run `am kill`, and Steady/Careful pacing on Android 14 emulator.
- **Spec 11:** Built the 5-row Setup screen (Figma `10:648`) with live capability refresh on resume, 2-denial Contacts `"Open settings"`, Android 13+ sideloaded Restricted Settings 3-step guide sheet, manufacturer-specific battery guidance for 6 makers, first sync progress, Settings screen (`General`, `After calls`, `Reminders`, `Messages`, `Data`, `About`), 2-minute Reliability Check self-test (`"Check setup"`), and full degraded-mode operation with all permissions denied (including `"Open in your SMS app"` fallback). Added `android/app/proguard-rules.pro` for R8-minified release builds and verified the signed release APK Setup walkthrough on Android 14 emulator.
- Built signed M3 pre-release APK (`build/PocketCRM.apk`, `sha256: 9e7e53089c409c7b58cbf0789110874683ccdfbe39d50baa58f8a4fc30a1a2e5`) and published GitHub pre-release `m3`.

### What was decided
- Kept native file sharing on `OutboxApi.shareFile` via `FileProvider` instead of adding `share_plus`.
- Replaced `sqflite`'s `getDatabasesPath()` with `resolvePocketCrmDatabasePath` via `path_provider`, preserving the exact Android `databases/pocket_crm.db` location.
- Added explicit `android/app/proguard-rules.pro` keeping Pigeon classes, BroadcastReceivers, WorkManager/Room `WorkDatabase_Impl`, and `flutter_local_notifications` models after testing the signed release APK on Android 14.

### What is in UNVERIFIED.md
- Permanent device/network items (real mobile network behaviour, dual-SIM selection, Android "Allow restricted settings" sideload flow, per-maker battery management).
- Spec 09: cross-emulator radio forwarding from `Pixel_8` (API 34) to `Medium_Phone` (API 36) did not populate B's inbox (all 7 outbox checks verified directly on `Pixel_8`).
- Spec 11: Android 13+ file-install restricted settings flow (exempt under `adb install`; covered by widget tests) and per-device verification of the 6 OEM battery setting labels (Xiaomi/Redmi/Poco, Oppo/Realme/OnePlus, Vivo/iQOO, Samsung, Tecno/Infinix/itel, Huawei/Honor).

## 2026-11-27 — M4: Backup and global readiness

### What shipped
- **Spec 12:** Added `archive` 4.7.1 and `cryptography` 2.9.0; built native Android Storage Access Framework Pigeon bridge (`pigeons/backup.dart` + `BackupSafApiImpl.kt` with 64 KB chunked streaming and zero storage permissions); implemented `.pcrm` backups (`VACUUM INTO` snapshot + `manifest.json` + `outbox.json` + `attachments/`) with optional `PCRM1` AES-256-GCM + Argon2id encryption, safe atomic restore (`pocket_crm.before-restore.bak`, automatic forward schema migration, re-enqueuing future outbox items and marking past due single messages missed), idempotent merge import of v1 JSON backups, weekly automatic plain backups keeping the last 4, Android `dataExtractionRules`/`backup_rules` excluding private DB/attachments from cloud backup while allowing device-to-device transfer, and open-format exports (People CSV, People vCard 3.0, Person history CSV).
- **Spec 13:** Translated all 509 ARB keys to Bengali (`lib/l10n/app_bn.arb`) with automated ARB completeness and no-literal widget tests; defaulted currency and phone region from device locale with searchable currency picker and per-currency balances on Person; converted padding/alignment across all UI files to directional RTL layout with RTL goldens (`Today`, `Person`, `New message`); verified zero overflows at `1.3x` and `2.0x` text scale with 18 text-scale goldens across all 9 designed screens; verified TalkBack semantics across all 9 screens and WCAG 2.1 `>= 4.5:1` contrast across both light and dark themes; enabled edge-to-edge and predictive back (`android:enableOnBackInvokedCallback="true"`); generated adaptive + monochrome launcher icon (`flutter_launcher_icons`) and set one-sentence `pubspec.yaml` description.
- Built signed M4 pre-release APK (`build/PocketCRM.apk`, `sha256: c92f2f1b640d63ee97b40d22262cb669a87a2a778c9225cddf9706eb3e023c0f`) and published GitHub pre-release `m4`.

### What was decided
- Defaulted `PCRM1` backup encryption to pure-Dart `Argon2id` (`kdfMethod = 1`) via `cryptography` 2.9.0 while retaining decrypt support for `PBKDF2-HMAC-SHA256` (`kdfMethod = 2`, 600,000 iterations).
- Implemented standards-compliant vCard 3.0 export directly in `ExportService`.
- Marked `lib/l10n/app_bn.arb` in `DECISIONS.md` and `UNVERIFIED.md` as needing native Bengali speaker review.

### What is in UNVERIFIED.md
- Permanent device/network items, Spec 09 cross-emulator forwarding, Spec 11 sideloaded restricted settings & OEM battery labels, plus Spec 13 physical-hardware GPU startup (<1.5s) & 5,000-row scroll frame times (<32ms) and native Bengali translation review.

## 2026-11-27 — M5: Release and landing page

### What shipped
- **Spec 14:** Bumped `pubspec.yaml` to `2.0.0+200`, finalized `CHANGELOG.md` under `2.0.0`, added fail-fast release signing guard in `android/app/build.gradle.kts`, locked merged release permissions in `tool/allowed_permissions.txt` (19 permissions, zero `INTERNET`) enforced by `tool/check_manifest.sh`, added `tool/release.sh`, rewrote `README.md` for v2, added 3-line top summaries to all five handover tracking files, verified the signed R8 release APK via `apksigner` and a clean install + Setup + contact/note walkthrough on Android 14 (`Pixel_8`), and published full GitHub release `v2.0.0` (`PocketCRM.apk`, `sha256: 4351d91f91f5549ea8150d2139b83002d05780e6c10133b46b08dc1050778170`, plus `PocketCRM.apk.sha256`).
- **Spec 15 part B:** Switched `docs/index.html` and `docs/styles.css` to the v2.0.0 release state (`Download for Android` pointing to `releases/latest/download/PocketCRM.apk`, mobile nav `Download` / desktop nav `GitHub`, `tool/allowed_permissions.txt` link), replaced all three phone screenshots with real-app light and dark captures served via `<picture>` and `prefers-color-scheme: dark`, regenerated `docs/og.png` and Playwright verification screenshots (`154.3 KB` first load, zero external requests, zero overflow at `320px` and `200%` text size), and verified the live GitHub Pages site and APK download SHA-256.

### What was decided
- Kept the landing page 100% JavaScript-free by toggling `.nav-btn-desktop` (`GitHub`) and `.nav-btn-mobile` (`Download`) via CSS media query at `1039px`.
- Verified every landing-page statement against the built app and `handover/UNVERIFIED.md` (retained `"at the time you chose"` because scheduled sending was verified on the Android 14 emulator).

### What is in UNVERIFIED.md
- Unchanged from M4: permanent device/network items (real mobile network behaviour, dual-SIM hardware, sideloaded restricted settings, OEM battery managers), Spec 09 cross-emulator forwarding, Spec 11 OEM battery labels, and Spec 13 physical-GPU timings & native Bengali speaker review.





