# PocketCRM

A local-first personal relationship tracker for Android, built with Flutter. It builds a per-contact timeline from your phone's SMS and call log, lets you add notes, payments, promises and tasks, and schedules SMS. All data is stored in a local SQLite database on the device.

The repo also contains an older browser prototype in `legacy/web-prototype/` that stores data in IndexedDB.

## Features

- Contacts synced from the device, with starring, contact lists and per-contact social/email fields
- Timeline per contact: incoming/outgoing/missed calls, SMS, notes, payments, screenshots, attachments and promises
- Bangladesh-aware phone number normalization (`01...` to `+8801...`)
- Heuristic spam/promotional SMS filter (weighted keywords, alphanumeric and short-code senders)
- Tasks with due dates and reminders, scheduled SMS and bulk SMS jobs to contact lists
- Local JSON backup from the backup screen

## Tech stack

Flutter and Dart (SDK ^3.12), `material_ui`, `sqflite`, `flutter_contacts`, `flutter_sms_inbox`, `call_log`, `permission_handler`, `file_picker`, `google_fonts`.

## Getting started

Prerequisites: the Flutter SDK. SMS and call-log access only works on an Android device, since the app requests the `READ_CONTACTS`, `READ_SMS`, `SEND_SMS` and `READ_CALL_LOG` permissions.

```sh
flutter pub get
flutter run
flutter test
```

## Browser prototype

The legacy browser prototype has been archived under `legacy/web-prototype/`. Open `legacy/web-prototype/index.html` in a browser (or serve the folder with any static server). It includes a share-sheet simulator and stores data locally in IndexedDB (`PocketCRM_DB`). It does not read real SMS or call data.

## Project structure

```
lib/main.dart             app entry
lib/database_helper.dart  SQLite schema and queries
lib/sync_engine.dart      contact, SMS and call-log sync
lib/sms_processor.dart    SMS handling
lib/spam_filter.dart      promotional/transactional SMS scoring
lib/screens/              home, thread, directory and backup screens
test/                     unit and widget tests
legacy/web-prototype/     archived browser prototype
```
