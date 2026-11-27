# Test results

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





