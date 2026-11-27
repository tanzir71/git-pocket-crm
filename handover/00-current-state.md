# 00 Current state

Findings come from reading every source file on 26 November 2026. The app was not run on a device for this audit, so anything described as "fails on device" is what the code will do, not something observed. Line numbers refer to the commit `064fd72`.

## What the app is

A Flutter app for Android (Dart SDK ^3.12, Flutter 3.38 or later, Gradle 9.1, AGP 9.0.1, Kotlin 2.3.20, compileSdk 36), about 8,700 lines of Dart. All data lives in a local SQLite file, `pocket_crm.db`, schema version 4, through `sqflite`. The repository also holds an older browser prototype (`index.html`, `js/`, `css/`) that is not part of the app.

| Area | Files |
|---|---|
| Entry and theme | `lib/main.dart` (39 lines) |
| Database | `lib/database_helper.dart` (325) |
| Sync | `lib/sync_engine.dart` (269), `lib/spam_filter.dart` (96) |
| SMS sending | `lib/sms_processor.dart` (130), `android/.../MainActivity.kt` |
| Screens | `home_screen.dart` (3,576), `thread_screen.dart` (2,764), `backup_screen.dart` (1,133), `directory_screen.dart` (436) |
| Tests | `test/widget_test.dart`: one smoke test against a mocked `Database` |

Features that exist: contacts synced from the phone, starring, contact lists, a per-person timeline (calls, SMS, notes, payments, files, tasks), tasks with due dates and reminders, scheduled SMS to one person, a bulk SMS job to a list, a keyword spam filter, JSON backup and restore.

## Does the automation work

| Feature | State | Why |
|---|---|---|
| Send one SMS | Works on Android 12 and later. Fails on Android 6 to 11. | `MainActivity.kt` calls `context.getSystemService(SmsManager::class.java)` whenever the SDK is 23 or higher. That call only returns a manager from API 31. Below that it returns null, the assignment to a non-null Kotlin type throws, and the channel returns `SMS_SEND_FAILED`. |
| Know whether an SMS was sent | Not built | `sendTextMessage` is called with null sent and delivery intents. "Success" only means no exception was thrown. |
| Scheduled SMS | Only fires while the app is open on the home or person screen | The only scheduler is `Timer.periodic` in `home_screen.dart:49` (15 s) and `thread_screen.dart:66` (10 s). There is no alarm, worker or service. |
| Overdue scheduled SMS | Sent in a burst the next time the app opens, at any hour | `SmsProcessor.processDueSms` sends everything with `scheduled_time <= now`. |
| Failed SMS | Recorded as sent | `sms_processor.dart:60-80` sets `is_sent = 1` before sending, then writes an `sms_outgoing` timeline row whatever the result. There is no status, retry or error. |
| Bulk SMS job | Sends the same text to every member, one every 2 s, only while the app is open | `database_helper.dart:234` creates one `scheduled_sms` row per member with an identical message. No merge fields, no per-person result. |
| "Send Remaining Now" | Can double-send | `home_screen.dart:296-352` loops over unsent rows with no delay and does not take the `_isProcessing` lock, so it can run at the same time as the timer. |
| Cancel a bulk job | Works, but the job is then marked sent | `home_screen.dart:354-378` sets `is_sent = 1` on cancel. Cancelled and sent cannot be told apart. |
| Choose a SIM | Not built | No subscription id is passed. |
| Task reminder | A snackbar, only if the app is open at that moment | `home_screen.dart:62-128`. No notification permission, no system notification. |

## Other defects, most serious first

1. **Messages from saved contacts are dropped from their history.** `sync_engine.dart:199` runs every SMS through `SpamFilter.isSpam`, including messages from people in the contact list. The filter adds weights for substrings such as `bill`, `invoice`, `payment of`, `balance`, `code`, `ref`, `win`, `sale` and flags a message at a score of 3.0 (`spam_filter.dart:8-86`). A customer writing "please send the invoice and bill reference" is silently excluded.
2. **Cascading deletes never run.** Tables declare `ON DELETE CASCADE` but `PRAGMA foreign_keys` is never turned on (no `onConfigure` in `database_helper.dart:26`). Deleting a contact or list leaves orphan rows.
3. **Sync rescans everything, on the UI thread.** `CallLog.query()` and `querySms()` read the full call log and inbox every time, and each row triggers a duplicate-check `SELECT` (`sync_engine.dart:166`, `:209`). The `timeline` table has no index. On a phone with tens of thousands of messages this will take a long time and freeze the screen.
4. **Only the first phone number of each contact is kept** (`sync_engine.dart:85`). Calls and messages from a person's second number are never matched.
5. **Phone normalisation is Bangladesh-only** (`sync_engine.dart:26-36`), with a last-ten-digits fallback that can match two different numbers.
6. **Payments are created from guesses.** Any SMS from a contact containing `Tk`, `BDT` or `৳` followed by a number creates a `payment` row automatically (`sync_engine.dart:219-254`). "I will pay Tk 500 tomorrow" becomes a recorded payment. Payment status is stored as a text prefix inside `content` (`[Paid]`, `[To Collect]`, and so on; see `thread_screen.dart:2531`).
7. **Backups are incomplete and unencrypted.** Export writes contacts, timeline, tasks and scheduled SMS to a fixed file in Downloads (`backup_screen.dart:94-166`). Contact lists, list members, bulk jobs and attachment files are left out. It asks for `Permission.storage`, which Android 13 and later always deny.
8. **Fonts do not load in release builds.** `google_fonts` fetches Outfit and Inter over the network at run time (191 call sites), but only the debug manifest holds the INTERNET permission. A release build falls back to the system font. The README says the app is fully offline, so the fix is to bundle the font, not to add the permission.
9. **Release configuration is a placeholder.** The release build is signed with the debug key, the app label is `pocket_crm`, lint is disabled for release, and `WRITE_CONTACTS` is requested but never used.
10. **Pseudo-events pollute the history.** Scheduling an SMS, creating a task and firing a reminder each insert a descriptive text row into `timeline` (`sms_scheduled`, `promise`). They are not interactions and they go stale when the thing they describe is cancelled.

## Structure

- No state management: 75 `setState` calls, two polling timers that reload every query every 10 to 15 seconds.
- No data layer: 83 raw database calls, most of them inside widget code, returning untyped maps.
- Two files hold 72 percent of the Dart code. `GlobalCreateBottomSheet` alone is about 970 lines.
- 334 hard-coded `Color(0x...)` literals and 76 calls to the deprecated `withOpacity`.
- One test. It checks that the title text renders.

## Why it feels heavy

| What the user meets | Where |
|---|---|
| Four tabs (Dashboard, Contacts, SMS Queue, Tasks) plus a floating button that opens a chooser, which opens a second sheet | `home_screen.dart:1037`, `:2421`, `:2584` |
| One "Log Event" form holding five types, a contact search and a new-contact form | `home_screen.dart:2603-3576` |
| A dashboard that leads with two counters (contacts, interactions) and a sync card, with the things to act on reduced to two summary lines at the bottom | `home_screen.dart:1223-1303` |
| Contact lists placed as a sub-tab of "SMS Queue" | `home_screen.dart:1497-1516` |
| A person screen that stacks an expanding header, a social panel, a search field, six filter chips, a task checklist, an SMS queue, a five-button toolbar and a month-collapsing timeline | `thread_screen.dart:1263-2530` |
| Thirteen different bottom sheets | all screens |
| Labels that describe the system, not the task: "Relationship Thread", "Tasks Checklist", "Upcoming Activity Summary", "Log Event / Task", "Enrichment", "promise" | throughout |
| Two typefaces, and indigo tints on icons, chips, borders, avatars and buttons at once | throughout |
| A full-screen spinner on every tab change, because each tap reruns all dashboard queries | `home_screen.dart:1039-1044`, `:134` |

## What is worth keeping

- The core idea: one timeline per person that fills itself from the phone's calls and messages.
- The data: every table and column in schema v4 carries forward unchanged.
- The payment statuses (paid, received, owed to me, I owe), which are the basis of the new "owes you" balance and payment reminders.
- Contact lists, which become the audience for bulk messages and the unit for a shared reconnect cadence.
- Attachment copying into app storage (`database_helper.dart:287`).
- Being local-only. It is the product's main difference from every tool it was compared with.
