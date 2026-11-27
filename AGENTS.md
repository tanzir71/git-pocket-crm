# PocketCRM: instructions for the implementing agent

You are implementing PocketCRM v2 and its landing page in this repository. The owner will not answer questions, review work, or test anything. Every product, design and technical decision is already made in `handover/`. Where a file says "decide", it also gives the rule to decide by.

## What PocketCRM is

A private, on-device relationship app for Android, built with Flutter. It logs calls and SMS per person automatically, lets you add a note in seconds after a call or a visit, reminds you to follow up and to stay in touch, and sends scheduled and bulk personalised SMS from the phone's own SIM. It is for salespeople who work from their phone, and for anyone who wants to look after their relationships. Nothing leaves the phone.

## Read in this order

1. `handover/README.md` (index, milestones and the order of work)
2. `handover/00-current-state.md` (what exists today and what is broken)
3. `handover/01-product-direction.md` (who it is for, what changes, what stays)
4. `handover/02-design-system.md` and `handover/03-screens.md` (the design), with the images in `handover/design/`
5. `handover/04-research-notes.md` (platform facts, package versions, sources)
6. `handover/specs/NN-*.md`, one at a time, in the order the milestones give

## How the work is delivered

1. **Commit directly to `main`.** No branches, no pull requests, no rewriting history, no force push.
2. **Commit at the end of every spec** with a message `spec NN: <what now works>`. Smaller commits inside a spec are fine.
3. **Run `tool/verify.sh` before every push.** Push to `origin main` after every commit that passes it. Never push a state that fails it.
4. **Work in milestones.** `handover/README.md` lists six, M0 to M5. At the end of each one:
   - add a dated section to `handover/PROGRESS.md`: what shipped, what was decided, what is in `UNVERIFIED.md`;
   - update `CHANGELOG.md` in words a user would understand;
   - tag the commit `m0`, `m1`, and so on, and push the tag;
   - from M1 on, build the signed APK with `tool/build_apk.sh` and publish it as a GitHub pre-release named after the milestone, with the file `PocketCRM.apk` attached. M5 publishes `v2.0.0` as a full release.
5. **No GitHub Actions and no other hosted CI.** Do not create anything under `.github/workflows/`. All checks run on this machine through `tool/verify.sh`.
6. **No testing by the owner.** Never ask the owner to install, try, check or confirm anything, and do not write checklists for them. Verify with automated tests and with emulators you drive yourself (see below). What cannot be shown that way goes into `handover/UNVERIFIED.md` as a plain statement of fact, not as a request.
7. **The repository is public.** Spec 00 makes it so. From then on everything you commit is published: no secrets, no keystore, no real names, phone numbers or messages. Fixtures, tests and screenshots use the invented sample data from the design.

## Hard rules

1. Never lose user data. Do not drop or rename an existing table or column. Add new ones. Copy the database file before any migration runs. Every schema change ships with a migration test.
2. The release build must not hold the INTERNET permission. `tool/check_manifest.sh` enforces it and is part of `tool/verify.sh`.
3. Do not submit the app to Google Play and do not remove the SMS or call-log permissions. `handover/04-research-notes.md` explains why.
4. Add no dependency that is not named in a spec. If you must, write the reason in `handover/DECISIONS.md` first.
5. Work one spec at a time, in order. A spec is finished only when its Verify section passes.
6. Keep the old screens working until the screen that replaces them passes its acceptance criteria. Then delete the old one in the same commit.
7. Design rules are not optional: colours and text styles come from the theme tokens only, one typeface, no italics, and the accent colour appears once per screen, on the primary action.
8. Every user-facing string goes in the ARB file. No string literals in widgets.
9. There is no licence file and the owner has not chosen one. Do not add one, and do not describe the project as "open source" anywhere. Say "the source is on GitHub".
10. If you are blocked, write what you tried and what failed in `handover/BLOCKED.md`, then move to the next spec that does not depend on the blocked one. Never report something as working that you did not run.

## Testing without the owner

Use, in this order: unit and widget tests, golden tests, Kotlin unit tests, then emulator checks. Emulator checks are named in the specs and you run them yourself with `adb`. Record every run in `handover/TEST-RESULTS.md` (date, emulator image, command, outcome).

- Start two emulators on consecutive console ports (5554 and 5556). An SMS sent from one emulator to the other's port number as the phone number is delivered to it, so real sending and receiving can be tested with no SIM.
- Inject an incoming SMS: `adb -s emulator-5554 emu sms send <number> <text>`. Simulate a call: `adb emu gsm call <number>`, then `adb emu gsm cancel <number>`.
- Read what arrived: `adb -s emulator-5556 shell content query --uri content://sms/inbox`.
- Background the app and kill its process with `adb shell am kill <package>`. Do not use `am force-stop` in these checks: Android cancels a force-stopped app's alarms and jobs on purpose, so it proves nothing.
- Idle mode: `adb shell dumpsys deviceidle force-idle`, and `unforce` to leave it. Restart: `adb reboot`. Airplane mode: `adb shell cmd connectivity airplane-mode enable`.
- Grant what setup would grant: `adb shell pm grant <package> <permission>`, `adb shell appops set <package> SCHEDULE_EXACT_ALARM allow`.
- Confirm the exact syntax with `adb help` and `adb emu help` on this machine; these are from memory.

If no Android SDK or emulator is available here, do not ask for one. Write one line under each affected spec in `handover/UNVERIFIED.md` ("emulator checks not run: no emulator on this machine") and continue.

`UNVERIFIED.md` always holds these, because no emulator can show them: behaviour on a real mobile network (operator filtering, delivery reports), dual-SIM selection, the "Allow restricted settings" flow for an app installed from a file, and each phone maker's battery management.

## Versions

The package versions in `handover/04-research-notes.md` were read from pub.dev on 26 November 2026. Treat them as a starting point. Run `flutter --version` and `flutter pub outdated` first, use the newest versions that resolve together, and record what you pinned in `handover/DECISIONS.md`.

## Commands

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
tool/verify.sh          # analyze, tests, debug build, manifest check
tool/build_apk.sh       # signed release APK at build/PocketCRM.apk
git push origin main
```

## Done means

For every spec: `tool/verify.sh` passes, the acceptance criteria in the spec are each demonstrated by a test or by a command whose output you read, the commit is pushed, and `handover/DECISIONS.md` lists anything you chose that the spec did not fix.

For the whole project: `https://tanzir71.github.io/git-pocket-crm/` serves the landing page, its download button returns the signed `PocketCRM.apk` from the `v2.0.0` release, and `handover/PROGRESS.md` has an entry for each of the six milestones.
