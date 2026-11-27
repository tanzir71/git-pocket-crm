# Test results

**Summary:** Every spec (`01`–`15`) passed `tool/verify.sh` (`flutter analyze` 0 issues, 106 Flutter unit/widget/golden tests, Kotlin JUnit outbox state-machine tests, debug APK, release manifest allow-list with zero `INTERNET`, and landing page checks).
Android 14 (`Pixel_8` API 34) emulator runs verified live call/SMS/contact sync, after-call notifications, Doze/reboot reminders, all 7 native SMS outbox checks, bulk Pause/Resume/`am kill`/pacing, and the signed R8 release APK Setup + note-capture walkthrough.
Hardware-only items (live carrier networks, dual-SIM hardware, sideloaded restricted settings, OEM battery screens, physical GPU frame timings) are tracked separately in `handover/UNVERIFIED.md`.

Record of automated test runs and Android emulator verification runs (date, image, command, outcome).

## 2026-11-27 — Spec 01

- **Environment:** Host Windows 11, Flutter 3.50.1, Dart 3.14.0
- **Command:** `bash tool/verify.sh && bash tool/build_apk.sh`
- **Outcome:** PASSED. `flutter analyze` reported 0 issues; `flutter test` passed 15/15 tests (legacy phone normalisation, spam filter including known defect assertion, payment regex, SMS processor stopgap, app smoke test); `assembleDebug` succeeded; `tool/check_manifest.sh` confirmed no `INTERNET` permission in merged release manifest; `build/PocketCRM.apk` built and signed (`sha256: 03d6f4940f3395ee84cc90c8d81f70ac4046256d35e3187d64b4683d6217b00a`).

## 2026-11-27 — Spec 02

- **Environment:** Host Windows 11, Flutter 3.50.1, Dart 3.14.0, Drift 2.35.4, sqlite3 3.5.2
- **Command:** `dart run build_runner build --delete-conflicting-outputs` && `bash tool/verify.sh`
- **Outcome:** PASSED. 0 `openDatabase` references in `lib/`; `flutter analyze` reported 0 issues; all 21 tests passed (v4->v5 migration with safety copy, all 7 payment prefixes, duration backfill, duplicate `native_message_id` dedup, orphan removal, 9 indexes, FTS5; v1->v5 migration; cascading deletes; balance formula; search; legacy tests; smoke test); `assembleDebug` and `check_manifest.sh` passed.

## 2026-11-27 — Spec 03

- **Environment:** Host Windows 11, Flutter 3.50.1, Dart 3.14.0
- **Command:** `bash tool/verify.sh`
- **Outcome:** PASSED. `flutter analyze` reported 0 issues; all 31 tests passed (lint guard, component measurements, 4 Inter-rendered golden tests at width 412 in light/dark 1.0x & 1.3x, plus all Spec 01 & 02 tests); `assembleDebug` and `check_manifest.sh` passed.

## 2026-11-27 — Spec 15 part A (Landing page)

- **Environment:** Host Windows 11, Python 3.13.17, Playwright Chromium
- **Command:** `python tool/og/render_landing.py && bash tool/check_landing.sh`
- **Outcome:** PASSED. 0 external network requests (6 same-origin requests only); 0 horizontal overflow at 320px (`320/320`) and at 200% font size on 390px (`390/390`); first load payload 157.8 KB (< 400 KB); 1 `<h1>`, all `<img>` have `alt`, `width`, `height`; `.nojekyll` present.

## 2026-11-27 — Spec 04

- **Environment:** Host Windows 11, Flutter 3.50.1, Dart 3.14.0
- **Command:** `bash tool/verify.sh && flutter test --dart-define=V2=true`
- **Outcome:** PASSED. `flutter analyze` reported 0 issues; all 34 tests passed in both `V2=false` and `V2=true` modes (including `app_shell_test` tab switching & first-run `/setup` redirect and `mode_switch_test`); `assembleDebug`, `check_manifest.sh`, and `check_landing.sh` passed.

## 2026-11-27 — Spec 05

- **Environment (host):** Host Windows 11, Flutter 3.50.1, Dart 3.14.0, Pigeon 30.0.4, `phone_numbers_parser` 9.2.3, `flutter_contacts` 2.6.0
- **Command:** `dart run pigeon --input pigeons/device.dart && bash tool/verify.sh && flutter test --dart-define=V2=true`
- **Outcome:** PASSED. `flutter analyze` reported 0 issues; all 44 tests passed in both `V2=false` and `V2=true` modes (including international phone normalisation across BD/US/GB/IN/NG, amount suggestion extraction across 8 currencies, 20,000 SMS + 5,000 calls batched sync in 500-row batches with zero reads on second sync, invoice SMS preserved without spam filter, multi-number calls, legacy ID dedup, and merge suggestion flagging); `assembleDebug`, `check_manifest.sh`, and `check_landing.sh` passed.
- **Environment (emulator):** Android Emulator `Pixel_8` (`android-34`, `google_apis_playstore`, `x86_64`, Android 14, debug APK `--dart-define=V2=true`)
- **Command:** `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk`, granted `READ_CONTACTS`, `READ_CALL_LOG`, `READ_SMS`, `READ_PHONE_STATE`, inserted contact "Amara Okafor" (`+14155550100`), injected 3 SMS (`adb emu sms send`) and 2 calls (`adb emu gsm call/accept/cancel`), inspected `databases/pocket_crm.db`.
- **Outcome:** PASSED. Full first sync (cold debug start, 1 contact + 3 SMS + 2 calls) completed cleanly (`contacts`: `Amara Okafor`, `contact_phones`: `+14155550100`, `timeline`: 2 calls `call:1` 6s incoming, `call:2` 0s missed, 3 SMS `sms:1..3`, with `"Please send the invoice and the bill reference"` kept and `"I will pay Tk 500 tomorrow"` stamped `suggested_amount=500.0, suggestion_state='open'` with zero payment rows; cold debug activity launch 11.3s + sync). Live incoming SMS while app open auto-synced via `ContentObserver` (2s debounce + incremental sync; verified `sms:4` in `timeline` within ~3-4s on device, 8.2s including polling overhead). Also verified that keeping `ContentObserver` active across `AppLifecycleState.paused` (only stopping on `detached`) ensures incoming calls (which briefly pause the activity under Android's InCallUI) trigger CallLog sync immediately.

## 2026-11-27 — Spec 06

- **Environment:** Host Windows 11, Flutter 3.50.1, Dart 3.14.0
- **Command:** `bash tool/verify.sh && flutter test --dart-define=V2=true`
- **Outcome:** PASSED. `flutter analyze` reported 0 issues; all 54 tests passed in both `V2=false` and `V2=true` modes (including zero SQL in `lib/features/`, partial-phone search, `Owes me` exact positive-balance filter, overdue danger meta, 5,000-row virtualization build-counter test, transactional duplicate merge, Person call note + visit place/photos + suggested-payment confirmation -> balance row, non-mobile WhatsApp hiding, and 4 committed Figma-sized 412x917 light/dark goldens for People and Person visually verified against frames `7:210` and `9:261`); `assembleDebug`, `check_manifest.sh`, and `check_landing.sh` passed.

## 2026-11-27 — Spec 07

- **Environment (host):** Host Windows 11, Flutter 3.50.1, Dart 3.14.0, `image_picker` 1.2.4, Pigeon 30.0.4
- **Command:** `dart run pigeon --input pigeons/device.dart && bash tool/verify.sh && flutter test --dart-define=V2=true`
- **Outcome:** PASSED. `flutter analyze` reported 0 issues; all 61 tests passed in both `V2=false` and `V2=true` modes (including atomic Visit with 2 photos via `FileStore` + 3-day follow-up linked via `source_timeline_id` + `last_interaction_at` update + full transactional Undo restoring all table counts; After-call sheet "No answer" editing existing call row in place + creating tomorrow "Call Amara back" follow-up with zero duplicate rows; 3-interaction note capture on Person screen; and 4 committed Figma-sized 412x917 light/dark goldens for Add Visit and After-call visually verified against frames `9:369` and `7:132`); `assembleDebug`, `check_manifest.sh` (confirmed zero `INTERNET` permission), and `check_landing.sh` passed.
- **Environment (emulator):** Android Emulator `Pixel_8` (`android-34`, Android 14, debug APK)
- **Command:** Installed debug APK, granted `READ_CONTACTS`, `READ_CALL_LOG`, `READ_PHONE_STATE`, `POST_NOTIFICATIONS`, saved contact "Amara Okafor" (`+14155550100`), killed background process with `adb shell am kill`, simulated incoming call `adb emu gsm call 4155550100` -> `gsm cancel 4155550100`, inspected `dumpsys notification --noredact` and verified `pocketcrm://after-call?number=4155550100` deep link intent resolution.
- **Outcome:** PASSED. `PhoneStateReceiver` detected RINGING->IDLE transition, resolved `"Amara Okafor"` via `ContactsContract.PhoneLookup`, and posted high-importance notification id `7100` on channel `after_calls` titled `"Add a note about your call with Amara Okafor"` with 2 actions (`Add note`, `Follow up`) within 3 seconds. Deep link `pocketcrm://after-call?number=4155550100` resolved cleanly to `MainActivity`.

## 2026-11-27 — Spec 08

- **Environment (host):** Host Windows 11, Flutter 3.50.1, Dart 3.14.0, `flutter_local_notifications` 21.0.0, `timezone` 0.11.2
- **Command:** `bash tool/verify.sh && flutter test --dart-define=V2=true`
- **Outcome:** PASSED. `flutter analyze` reported 0 issues; all 69 tests passed in both `V2=false` and `V2=true` modes (including `CadenceCalculator` own-vs-list precedence, smallest list cadence, new interaction moving due date, snooze, no-interaction fallback, upcoming birthdays; `NotificationsService` with `FakeNotificationsBackend` verifying follow-up scheduling with `Done`/`Tomorrow` actions, cancel on complete, `Done` completing task in DB, `Tomorrow` rescheduling +1 day, and morning summary skipped when counts are 0; `TodayScreen` Figma section order, Skip action, and `"All caught up"` empty state; and 2 committed 412x917 light/dark Today goldens visually verified against Figma frame `7:30`); `assembleDebug`, `check_manifest.sh` (zero `INTERNET` permission), and `check_landing.sh` passed.
- **Environment (emulator):** Android Emulator `Pixel_8` (`android-34`, Android 14, debug APK `--dart-define=V2=true`)
- **Command:** Installed debug APK, granted `POST_NOTIFICATIONS` and `READ_CONTACTS`, seeded contact "Amara Okafor" + future follow-ups, launched app so `NotificationsService.rescheduleAll()` armed alarms, backgrounded + `adb shell am kill com.pocketcrm.pocket_crm` + `adb shell dumpsys deviceidle force-idle`, verified notification in `dumpsys notification --noredact`; then seeded a +130s follow-up, ran `adb reboot`, and verified `ScheduledNotificationBootReceiver` re-armed both follow-up (`id=100003`, `Done`/`Tomorrow` actions) and daily 09:00 morning summary (`id=90001`) in `dumpsys alarm`.
- **Outcome:** PASSED. All 5 channels (`follow_ups`, `reconnect`, `after_calls`, `messages`, `morning_summary`) created; Follow-up 1 (`"Send invoice to Amara"`) fired while app was killed and device was in Doze `IDLE` state; after `adb reboot`, `ScheduledNotificationBootReceiver` automatically ran without launching the app and re-armed both `AlarmManager` `RTC_WAKEUP` alarms (`100003` and `90001`).
- **M2 Signed APK:** `bash tool/build_apk.sh --dart-define=V2=true` produced `build/PocketCRM.apk` (`63.9 MB`, `sha256: dc041d98ec96caec46e75a667b01fdc68a60db2aeba075ab13ca89f73080e85c`).

## 2026-11-27 — Spec 09

- **Environment (host):** Host Windows 11, Flutter 3.50.1, Dart 3.14.0, Pigeon 30.0.4, `androidx.work:work-runtime-ktx:2.10.1`, JUnit 4.13.2
- **Command:** `dart run pigeon --input pigeons/outbox.dart && (cd android && ./gradlew :app:testDebugUnitTest) && bash tool/verify.sh && flutter test --dart-define=V2=true`
- **Outcome:** PASSED. Kotlin JUnit tests (`OutboxStateMachineTest`: every allowed/refused transition, retry counts & 1m/5m/15m delays, 22:30 -> next-day 09:00 send window, 31-min missed single-message rule, `LIMIT_EXCEEDED` campaign pause, and 2 concurrent drain loops over 50 messages sending each exactly once) passed; `flutter analyze` reported 0 issues; all 75 Flutter tests passed in both `V2=false` and `V2=true` modes (including `OutboxRepository` ordered reconcile, idempotent single `sms_outgoing` timeline insert, `SyncService` outgoing SMS deduplication stamping `provider_sms_id`, `countSms` GSM-7/extension/UCS-2 boundaries, and `SingleMessageSheet` dual-SIM + live counter); `Timer.periodic` absent from `lib/features`; `check_manifest.sh` confirmed required outbox permissions and zero `INTERNET` permission.
- **Environment (emulator):** Android Emulator A `Pixel_8` (`android-34`, Android 14, `google_apis_playstore`, port `5554`) and Emulator B `Medium_Phone` (`android-36`, Android 16, port `5556`), debug APK (`--dart-define=V2=true`) installed on A with permissions granted.
- **Outcome:**
  - **Check 1 (3-min scheduled, `am kill`, Doze `force-idle`):** PASSED on A. With app killed via `am kill` and `dumpsys deviceidle get deep` = `IDLE`, `AlarmManager.setExactAndAllowWhileIdle` fired on time -> `OutboxDrainWorker` -> `SmsSender` -> `SmsResultReceiver` recorded `delivered` (`chk1-doze`) and wrote `content://sms/sent` `_id=11`; reopening A reconciled `outbox_messages` to `delivered` and created timeline row `outbox:chk1-doze`.
  - **Check 2 (3-min scheduled + `adb reboot`):** PASSED on A. Confirmed `chk2-reboot-v2` (`due_at=1795773793507`) in `outbox.db` and `ACTION_OUTBOX_ALARM` in `dumpsys alarm` before `adb reboot`. After 60.9s reboot with app never reopened, `OutboxBootReceiver` re-armed the alarm and delivered `chk2-reboot-v2` at `1795773796045` (+2.5s after due time); reopening A reconciled `delivered` (`provider_sms_id='sms:54'`) and single timeline row `outbox:chk2-reboot-v2`.
  - **Check 3 (Airplane mode fail + automatic retry):** PASSED on A. With `airplane-mode enable`, `SmsSender` detected airplane mode -> `RESULT_ERROR_RADIO_OFF` -> scheduled 1-minute retry; after `airplane-mode disable`, the retry alarm fired automatically and delivered `chk3-airplane-v2` (`delivered`, `provider_sms_id='sms:12'`, single timeline row).
  - **Check 4 (300-char ASCII multipart + Bangla UCS-2):** PASSED on A. `chk4-300` (300 chars, 2 parts) and `chk4-bn` (63-char Bangla UCS-2, 1 part) both reached `delivered` with full text intact in `content://sms/sent` (`_id=6` and `_id=7`). Note: cross-emulator radio forwarding from `Pixel_8` (API 34 `netsimd` modem) to `Medium_Phone` (API 36) did not deliver into B's `content://sms/inbox` (recorded in `UNVERIFIED.md`).
  - **Check 5 (Missed >30m):** PASSED on A. Single message `chk5-missed` due 61 minutes earlier transitioned to `missed` (`Missed`) and was never sent.
  - **Check 6 (`content://sms/sent` dedup):** PASSED on A. Confirmed Android 14 writes `sendMultipartTextMessage` messages to `content://sms/sent`; `SyncService` matched each by normalized E.164 + body within 2 minutes, stamped `provider_sms_id` (`sms:6`, `sms:7`, `sms:10`, `sms:12`, `sms:54`), and kept exactly 1 `sms_outgoing` row per message in `timeline`.
  - **Check 7 (40 messages at Fast pace = 5s):** PASSED on A (`Pixel_8` Android 14 API 34). All 40/40 messages (`chk7-fast40`) reached `delivered` and the campaign transitioned to `done`. Android 14 API 34 emulator did not show an `SmsUsageMonitor` sending-limit confirmation dialog for 40 messages at 5s pace.

## 2026-11-27 — Spec 10

- **Environment (host):** Host Windows 11, Flutter 3.50.1, Dart 3.14.0 (v2 default with no `--dart-define`, legacy packages `sqflite`, `flutter_sms_inbox`, `call_log`, `google_fonts` removed)
- **Command:** `(cd android && ./gradlew :app:testDebugUnitTest) && bash tool/verify.sh`
- **Outcome:** PASSED. `flutter analyze` reported 0 issues; all 80 Flutter tests passed (including `renderTemplate` across all 5 fields, default/explicit fallbacks, punctuation cleanup, unknown field flagging; `countSms` 160/161 GSM-7, `{` extension double-count, 70/71 Bangla UCS-2, emoji 2-unit UCS-2; Figma `10:498` preview `"Hi Amara, a quick reminder that $240 is due on Friday. Thank you!"`; 24-person list with 2 no-mobile + 1 opted-out -> 21 rendered outbox rows; `STOP` & `বন্ধ` opt-out detection; idempotent v4 `scheduled_sms` + `bulk_sms_jobs` cut-over migration; `resolvePocketCrmDatabasePath` exact Android `databases/pocket_crm.db` match; full-`lib/` design lint guard + zero `"legacy"` references in `lib/`; and 6 visually verified light/dark goldens for Messages, New message, and Campaign progress); Kotlin JUnit passed; `assembleDebug`, `check_manifest.sh` (zero `INTERNET`), and `check_landing.sh` passed.
- **Environment (emulator):** Android Emulator `Pixel_8` (`android-34`, Android 14, debug APK with v2 default)
- **Outcome:**
  - **Pause & Resume mid-run (`s10-pr2`, 10 messages, Fast 4s):** PASSED. Paused at 2/10, verified 0 messages sent over a 12s hold (`t+5s=2/10`, `t+17s=2/10`), resumed and completed `10/10 delivered` (`status='done'`).
  - **Mid-run `am kill` (`s10-amkill`, 10 messages, Fast 4s):** PASSED. Killed app process mid-run with `adb shell am kill com.pocketcrm.pocket_crm`; `OutboxDrainWorker` completed all `10/10 delivered` with exactly 10 matching rows in `content://sms/sent` (zero duplicates).
  - **Pacing (`s10-steady` 15s, `s10-careful` 60s):** PASSED. Measured inter-message gaps: Steady `14.9s` (`2/3` within 45s window), Careful `58.3s` (`2/2 delivered`, `status='done'`).
  - **Database path after `sqflite` removal:** Verified `path_provider` opened `databases/pocket_crm.db` in the exact same Android directory `/data/user/0/com.pocketcrm.pocket_crm/databases/pocket_crm.db`.

## 2026-11-27 — Spec 11

- **Environment (host):** Host Windows 11, Flutter 3.50.1, Dart 3.14.0, Pigeon 30.0.4, `android/app/proguard-rules.pro` (R8 + resource shrinking enabled for release)
- **Command:** `(cd android && ./gradlew :app:testDebugUnitTest) && bash tool/verify.sh && bash tool/build_apk.sh`
- **Outcome:** PASSED. `flutter analyze` reported 0 issues; all 86 Flutter tests passed (including `SetupScreen` live capability states, Continue disabled until Contacts allowed, 2-denial Contacts -> `"Open settings"`, Android 13+ file-install instant denial opening the 3-step Restricted Settings guide sheet, Samsung OEM battery guidance, `ReliabilityCheckService` exact copy for pending/on time/late/failed, full degraded-mode workflow from first launch -> `"Do this later"` -> Today `"Finish setup"` row -> adding a note with every permission denied, composer `"Open in your SMS app"` `sms:` URI fallback without SMS permission, and 2 committed light/dark Setup goldens visually verified against Figma frame `10:648`); Kotlin JUnit passed; `assembleDebug`, `check_manifest.sh` (zero `INTERNET`), and `check_landing.sh` passed.
- **Environment (emulator):** Android Emulator `Pixel_8` (`android-34`, Android 14, signed release APK `build/PocketCRM.apk`, `sha256: 9e7e53089c409c7b58cbf0789110874683ccdfbe39d50baa58f8a4fc30a1a2e5`)
- **Command:** Installed signed release APK via `adb install -r --no-streaming build/PocketCRM.apk`, cleared app data (`pm clear`), launched `MainActivity`, drove all 5 Setup rows via `adb shell input tap` + system dialogs/settings, then tapped `Continue`.
- **Outcome:** PASSED. All 5 Setup rows started as `Allow` and refreshed live on foreground return to `Allowed`:
  1. `Contacts`: `Allow` -> Android Contacts dialog (`Allow`) -> `Allowed`
  2. `Calls and messages`: `Allow` -> Android Call logs + SMS + Phone state dialogs (`Allow`) -> `Allowed`
  3. `Alarms and reminders`: `Allow` -> Android Exact Alarms settings toggle on + Back -> `Allowed`
  4. `Battery`: `Allow` -> Android ignore battery optimizations dialog (`Allow`) -> `Allowed`
  5. `Notifications`: `Allow` -> Android Notifications dialog (`Allow`) -> `Allowed`
  Tapping `Continue` ran first sync and navigated cleanly to `People`. (Android 13+ sideload restricted settings is exempt under `adb install` and stays recorded in `handover/UNVERIFIED.md`.)
- **M3 Signed APK:** `bash tool/build_apk.sh` produced `build/PocketCRM.apk` (`65.1 MB`, `sha256: 9e7e53089c409c7b58cbf0789110874683ccdfbe39d50baa58f8a4fc30a1a2e5`).

## 2026-11-27 — Spec 12

- **Environment (host):** Host Windows 11, Flutter 3.50.1, Dart 3.14.0, `archive` 4.7.1, `cryptography` 2.9.0, Pigeon 30.0.4
- **Command:** `grep -R "Permission.storage\|/storage/emulated" lib; (cd android && ./gradlew :app:testDebugUnitTest) && bash tool/verify.sh`
- **Outcome:** PASSED. `grep` returned zero matches; `flutter analyze` reported 0 issues; all 94 Flutter tests passed (including encrypted `PCRM1` Argon2id round-trip across every table + 3 binary/text attachment files -> wipe -> restore row-for-row & byte-for-byte + `pocket_crm.before-restore.bak` + future outbox re-enqueue & past-due missed marking; literal v4->v5 schema-upgrade restore; wrong passphrase & truncated plain/encrypted file rejection leaving live data untouched; v1 JSON backup idempotent double-import with zero duplicates; weekly automatic backups keeping last 4 plain archives; RFC 4180 People CSV, vCard 3.0, and Person history CSV exports; `BackupSettingsScreen` widget test; and full-`lib/` lint guards); Kotlin JUnit passed; `assembleDebug`, `check_manifest.sh` (zero `INTERNET`), and `check_landing.sh` passed.

## 2026-11-27 — Spec 13

- **Environment (host):** Host Windows 11, Flutter 3.50.1, Dart 3.14.0, `flutter_launcher_icons` 0.14.4
- **Command:** `flutter gen-l10n && bash tool/verify.sh && bash tool/build_apk.sh`
- **Outcome:** PASSED. `flutter analyze` reported 0 issues; all 106 Flutter tests passed (including ARB completeness across all 509 keys and placeholders between `app_en.arb` and `app_bn.arb`, zero hardcoded English `Text` literals in `lib/core/widgets` and `lib/features`, WCAG 2.1 `>= 4.5:1` contrast test across all light & dark text token pairs, multi-currency `computeBalancesByCurrency`, Bengali locale rendering, TalkBack semantics checks across all 9 designed screens, zero `RenderFlex` overflows at `1.0x`/`1.3x`/`2.0x` across all 9 designed screens, 3 RTL goldens (`Today`, `Person`, `New message`), and 18 text-scale `1.3x`/`2.0x` goldens); `assembleDebug`, `check_manifest.sh` (zero `INTERNET`), and `check_landing.sh` passed.
- **Environment (emulator):** Android Emulator `Pixel_8` (`android-34`, Android 14, `-gpu swiftshader_indirect`, signed M4 release APK `build/PocketCRM.apk`, `sha256: c92f2f1b640d63ee97b40d22262cb669a87a2a778c9225cddf9706eb3e023c0f`)
- **Command:** Installed M4 release APK via `adb install -r --no-streaming build/PocketCRM.apk`; measured 3 cold starts via `adb shell am start -W -n com.pocketcrm.pocket_crm/com.pocketcrm.pocket_crm.MainActivity`.
- **Outcome:** Cold start `TotalTime` under software-rendered SwiftShader GPU: `[3290 ms, 4161 ms, 3422 ms]` (median `3422 ms`). Hardware-accelerated cold start (<1.5s) and profile-mode 5,000-row scroll frame time (<32ms) on physical hardware are noted in `handover/UNVERIFIED.md` (single-query 5,000-row People directory performance is verified in `test/people/people_and_person_test.dart`).
- **M4 Signed APK:** `bash tool/build_apk.sh` produced `build/PocketCRM.apk` (`69.0 MB`, `sha256: c92f2f1b640d63ee97b40d22262cb669a87a2a778c9225cddf9706eb3e023c0f`).

## 2026-11-27 — Spec 14

- **Environment (host):** Host Windows 11, Flutter 3.50.1, Dart 3.14.0, Android SDK build-tools `apksigner`
- **Command:** `bash tool/verify.sh && bash tool/build_apk.sh && apksigner verify --print-certs build/PocketCRM.apk`
- **Outcome:** PASSED. `flutter analyze` reported 0 issues; all 106 Flutter tests passed; `tool/check_manifest.sh` confirmed zero `INTERNET` and exact match against `tool/allowed_permissions.txt`; `tool/check_landing.sh` passed; `build/PocketCRM.apk` (`2.0.0+200`, `69.0 MB`, `sha256: 4351d91f91f5549ea8150d2139b83002d05780e6c10133b46b08dc1050778170`) verified by `apksigner` with release cert `CN=PocketCRM, OU=Mobile, O=PocketCRM` (`sha256: a95afb89926aabf96904be21dd77f7fefec3e1c5df89fe8d4482cd35e04b5a14`, not Android debug cert).
- **Environment (emulator):** Android Emulator `Pixel_8` (`android-34`, Android 14, signed R8-minified `2.0.0+200` release APK `build/PocketCRM.apk`)
- **Command:** Clean install via `adb install -r --no-streaming build/PocketCRM.apk`, `pm clear`, launched `MainActivity` -> verified Setup opened -> granted permissions via `adb` -> verified `5/5 Allowed` -> tapped `Continue` -> created contact `Amara Okafor` -> added note `"Release v2 verified"`.
- **Outcome:** PASSED. Clean install opened directly to Setup, refreshed all 5 rows to `Allowed`, navigated to People, created contact, and saved/displayed the note cleanly in the R8 release build.

## 2026-11-27 — Spec 15 part B (Landing page)

- **Environment:** Host Windows 11, Python 3.13.17, Playwright Chromium, `curl`
- **Command:** `python tool/og/render_landing.py && bash tool/check_landing.sh && bash tool/verify.sh`
- **Outcome:** PASSED. Replaced all three phone screenshots with real-app light and dark captures (`626x1393` WebP q=82 + PNG fallback via `<picture>` and `prefers-color-scheme: dark`), regenerated `docs/og.png` from the real Today screenshot, and updated nav/hero/privacy/install links and copy to Part B (`Download for Android` -> `releases/latest/download/PocketCRM.apk`, `tool/allowed_permissions.txt`). Playwright audit confirmed 0 external network requests (6 same-origin requests only), 0 horizontal overflow at `320px` (`320/320`) and at `200%` font size on `390px` (`390/390`), and first-load payload of `154.3 KB` (`< 400 KB`). Visually compared `built-desktop.png`, `built-mobile.png`, `built-dark.png`, and `docs/og.png` against the design.









