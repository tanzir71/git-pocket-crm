# 14 Release

## Goal

Version 2.0.0, signed, built on this machine, published as a GitHub release, with honest documentation. With spec 15 part B this is milestone M5.

## Read first

Spec 01 step 11 (the signing key and `tool/build_apk.sh` already exist). `handover/OWNER-NOTES.md`.

## Steps

1. **Signing.** Confirm the release signing config in `android/app/build.gradle.kts` reads the properties file at the path in the environment variable `PCRM_KEY_PROPERTIES`, or by default `.pocketcrm/key.properties` in the user's home folder, and that the release build fails with a clear message if it is missing. There must be no debug-key fallback. Confirm no keystore or properties file is tracked by git.
2. **Shrinking.** Turn on R8 and resource shrinking for release. Add keep rules for the Pigeon-generated classes, the receivers and the worker. Run the full emulator checks from specs 09 and 10 once against the release APK and fix anything R8 removed.
3. **Version.** `1.0.0+1` becomes `2.0.0+200`. Finish `CHANGELOG.md`: what changed for a user, in plain words, under a `2.0.0` heading.
4. **Permission allow-list.** Extend `tool/check_manifest.sh` to compare the merged release manifest's permissions with the explicit list in `tool/allowed_permissions.txt`, and fail on any difference. The list must not contain INTERNET. The landing page links to this file.
5. **`tool/release.sh <version>`**: runs `tool/verify.sh`; builds one universal APK with `flutter build apk --release`; copies it to `build/PocketCRM.apk` (the file name never carries a version, so the address `releases/latest/download/PocketCRM.apk` always works); writes `build/PocketCRM.apk.sha256`; tags `v<version>`; pushes the tag; and runs

```sh
gh release create v2.0.0 build/PocketCRM.apk build/PocketCRM.apk.sha256 \
  --title "PocketCRM 2.0.0" --notes-file build/release-notes.md --latest
```

   The notes are the `2.0.0` section of the changelog, the SHA-256, and the three install steps from the landing page.
6. **README.** Rewrite for v2: what the app is, a link to the landing page, the privacy position (no internet permission, with a link to `tool/allowed_permissions.txt`), how to install from a file including the "Allow restricted settings" step, why it is not on Google Play (one paragraph, linking the policy), how to build, the project layout, and a link to `handover/UNVERIFIED.md` under the heading "Not yet proven on real hardware". Use two of the images in `docs/assets/`.
7. **In-app About:** version, licences of the packages and of Inter, and the sentence "PocketCRM cannot connect to the internet."
8. **Final sweep.** No `TODO` without a reason beside it, no `print`, no unused dependency, no dead files, no file under `.github/workflows/`. `DECISIONS.md`, `PROGRESS.md`, `TEST-RESULTS.md`, `UNVERIFIED.md` and `BLOCKED.md` are current and each begins with a three-line summary.
9. Run `tool/release.sh 2.0.0`. Then do spec 15 part B. Then write the M5 entry in `PROGRESS.md`, commit, push, tag `m5`, push the tag.

## Acceptance criteria

- `tool/build_apk.sh` produces `build/PocketCRM.apk`, and `apksigner verify --print-certs` shows the release certificate, not the Android debug certificate.
- The permission allow-list check passes.
- The release APK installed on a clean emulator opens to Setup, completes it with permissions granted by `adb`, and adds a note. Recorded in `TEST-RESULTS.md`.
- `gh release view v2.0.0 --json assets` lists `PocketCRM.apk`, and `curl -sIL https://github.com/tanzir71/git-pocket-crm/releases/latest/download/PocketCRM.apk` ends in a 200.

## Verify

```sh
tool/verify.sh && tool/build_apk.sh
```
