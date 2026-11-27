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

