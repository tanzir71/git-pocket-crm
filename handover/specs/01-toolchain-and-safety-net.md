# 01 Toolchain and safety net

## Goal

A current toolchain, one local script that checks everything, a signing key, tests around the logic that is about to be rewritten, and a small stopgap so the existing SMS code stops recording failures as sent. No visible redesign.

## Read first

`handover/00-current-state.md`. Files: `pubspec.yaml`, `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`, `android/app/src/main/kotlin/com/pocketcrm/pocket_crm/MainActivity.kt`, `lib/sms_processor.dart`, `lib/sync_engine.dart`, `lib/spam_filter.dart`, `lib/screens/home_screen.dart` lines 246 to 378.

## Steps

1. Stay on `main`. Record the output of `flutter --version` in `handover/DECISIONS.md`.
2. Move to the newest stable Flutter. Run `dart fix --apply`. If the SDK now deprecates `package:flutter/material.dart`, read the official release notes and apply the migration they describe; record it in `DECISIONS.md`.
3. Run `flutter pub outdated`. Upgrade `permission_handler`, `file_picker`, `intl`, `path`, `path_provider`, `url_launcher`, `open_filex` to the newest versions that resolve together and fix what breaks. Raise `compileSdk` if `permission_handler` requires it. Leave `sqflite`, `flutter_sms_inbox`, `call_log`, `flutter_contacts` and `google_fonts` as they are; later specs replace them. Remove `csv` and `cupertino_icons` if nothing imports them.
4. Move `index.html`, `js/`, `css/`, `test_output.txt` and `test_output_utf8.txt` to `legacy/web-prototype/` with `git mv`. Update the README paragraph that mentions them.
5. In `analysis_options.yaml` enable `avoid_print`, `unawaited_futures`, `use_build_context_synchronously`, `prefer_const_constructors`, `prefer_final_locals`. Fix the findings in files you touch in this spec. For `lib/screens/*` add a file-level ignore with the comment `// legacy: deleted in spec 10`.
6. In the Android manifest set `android:label="PocketCRM"` and remove `WRITE_CONTACTS`.
7. Add characterisation tests in `test/legacy/`. They record what the code does today, including the known defects, so later specs change behaviour on purpose.
   - `SyncEngine.normalizePhone`: `01712345678` gives `+8801712345678`; `8801712345678` gives `+8801712345678`; `+14155550100` is unchanged; `0171-234 5678` is cleaned.
   - `SyncEngine.getLast10Digits` for the same inputs.
   - `SpamFilter.isSpam`: alphanumeric sender `bKash` is true; short code `16247` is true; a personal message is false; `("+8801712345678", "Please send the invoice and the bill reference")` is true, marked `// known defect, fixed in spec 05`.
   - The payment amount regular expression from `sync_engine.dart:223`, extracted into a top-level function without changing it: `Tk 1,500.50`, `৳500`, `BDT 200` parse; `Take 5` does not.
8. SMS stopgap. Spec 09 replaces all of this; keep the change small.
   - `MainActivity.kt`: use `getSystemService(SmsManager::class.java)` only when `Build.VERSION.SDK_INT >= Build.VERSION_CODES.S`. Otherwise use `SmsManager.getDefault()`.
   - `SmsProcessor.processDueSms`: do not set `is_sent` before sending. After `sendNativeSms` returns true, set `is_sent = 1` and insert the `sms_outgoing` row. When it returns false, leave the row unsent, remember its id in a static set so it is not retried in this app session, show the existing failure snackbar and continue.
   - Only send rows that are due and no more than 30 minutes late: `scheduled_time <= now AND scheduled_time >= now - 30 minutes`. Older rows stay in the queue for the user to send or cancel by hand.
   - `_simulateSendBulkJob` in `home_screen.dart`: stop sending in its own loop. Set `scheduled_time` of the job's unsent rows to now and call `SmsProcessor.processDueSms`, so there is one sender and one lock.
9. Add `tool/check_manifest.sh`. It runs `./gradlew :app:processReleaseMainManifest` in `android/`, finds the merged release manifest under `build/`, and exits non-zero if it contains `android.permission.INTERNET`.
10. Add `tool/verify.sh`: `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`, `tool/check_manifest.sh`, stopping at the first failure. It is the only gate before a push. Do not add GitHub Actions or any other hosted CI. Write the scripts in `tool/` so they run in the shell this machine has (Git Bash on Windows is fine).
11. **Signing key.** If `.pocketcrm/key.properties` does not exist in the user's home folder, create the folder, generate a keystore there with `keytool -genkeypair -keystore pocketcrm-release.jks -keyalg RSA -keysize 4096 -validity 10000 -alias pocketcrm` using a random 32-character password, and write `key.properties` beside it with `storeFile`, `storePassword`, `keyAlias` and `keyPassword`. Never print the password, never copy either file into the repository. In `android/app/build.gradle.kts` add a `release` signing config that reads that properties file (path overridable with the environment variable `PCRM_KEY_PROPERTIES`) and remove the debug-key fallback. Record in `handover/PROGRESS.md` that the key was created and where, without the password.
12. Add `tool/build_apk.sh`: runs `flutter build apk --release` (passing through any `--dart-define` given to it), copies the universal APK to `build/PocketCRM.apk` and prints its SHA-256.
13. **Milestone M1** ends after specs 02, 03 and 15 part A. Then build with `tool/build_apk.sh` and publish: `gh release create m1 build/PocketCRM.apk --prerelease --title "Milestone 1: foundation" --notes-file <the M1 section of PROGRESS.md>`. Use the same pattern for `m2` (built with `--dart-define=V2=true`), `m3` and `m4`.

## Acceptance criteria

- `flutter analyze` reports no issues.
- The new tests pass, and the one marked as a known defect asserts today's wrong result.
- The app builds and opens to the existing home screen.
- A failed send no longer creates an `sms_outgoing` row. Covered by a unit test of `SmsProcessor` with the method channel mocked to return false.
- `tool/verify.sh` passes.
- `tool/build_apk.sh` produces `build/PocketCRM.apk` signed with the release key, and `git status` shows no keystore or properties file.

## Verify

```sh
tool/verify.sh && tool/build_apk.sh
```

## Out of scope

Any change to screens beyond the lines named above. Any database change.
