# 05 Sync

## Goal

Calls, SMS and contacts flow into each person's history quickly, incrementally and correctly, for phone numbers from any country. Messages from saved people are never filtered out.

## Read first

`lib/sync_engine.dart`, `lib/spam_filter.dart`, `handover/00-current-state.md` defects 1, 3, 4, 5, 6.

## Decisions

- **Reading the phone is native.** A small Kotlin class queries `CallLog.Calls` and `Telephony.Sms` through `ContentResolver`, in batches, by `_id` watermark. It is exposed to Dart with **Pigeon** (typed, generated). `flutter_sms_inbox` and `call_log` are no longer used by new code and leave the project in spec 10.
- **Contacts** come from `flutter_contacts` (upgrade to the current major), with all phone numbers.
- **Phone numbers** are parsed with `phone_numbers_parser` and stored as E.164. The default region is a setting, first taken from the SIM country, then the device locale.
- **The spam filter is removed from sync.** A message is attached to a person only when its sender matches one of that person's numbers, and such a message is always kept. Messages from numbers that belong to nobody are ignored, as today.
- **Amounts in messages become suggestions,** never payments.

## Steps

1. **Pigeon API** in `pigeons/device.dart`, generating `lib/core/native/device_api.g.dart` and Kotlin:

```
DeviceApi (host)
  List<CallRecord> readCalls(int afterId, int limit)      // id, number, type, date, durationSeconds
  List<SmsRecord>  readSms(int afterId, int limit)        // id, address, body, date, box (inbox|sent), subId
  String? simCountryIso()
  void startObserving() / stopObserving()
DeviceEvents (flutter)
  void onDeviceDataChanged(String kind)                   // "calls" | "sms"
```

   Kotlin: query with `selection = "_id > ?"`, `sortOrder = "_id ASC LIMIT n"`, on a background thread. `startObserving` registers `ContentObserver`s on both URIs while the app is in the foreground and debounces events by 2 seconds.
2. **Phone service** in `lib/core/phone/`: `normalise(raw, region)` returns E.164 or null and never throws; `isMobile(e164)`; `nationalSuffix(e164)`. Tests cover Bangladesh (`01712345678` gives `+8801712345678`), the United States, the United Kingdom, India and Nigeria, numbers with spaces and dashes, short codes and alphanumeric senders (both give null).
3. **One-time number migration.** For every `contact_phones` row, normalise `raw`; when two contacts end up with the same E.164, keep both contacts and leave the second number unnormalised with a flag for the merge suggestion in spec 06.
4. **Contacts sync.** For each device contact with at least one number: match by `device_contact_id`, else by any E.164; update name, company, email and birthday when the device value changed and the app value was not edited in the app; insert missing numbers. New people get `source = 'device'`. Never delete a person because they left the device address book.
5. **Calls and SMS sync.** Loop: read 500 after the watermark in `sync_state`, map each record's number to a contact through an in-memory map of E.164 to contact id (fallback: a unique match on the last 9 digits), insert with `insertOrIgnore`, advance the watermark, repeat until a batch is empty. All inserts of a batch are one transaction.
   - Native ids: calls `call:<id>`, SMS `sms:<id>` in `native_message_id`.
   - First run after this spec: existing SMS rows have a bare numeric id. Rewrite those to `sms:<id>` first. Existing call rows have no id, so during the first pass only, skip a call when a row with the same contact, type and timestamp exists, and stamp that row with the id. Start both watermarks at 0 so messages that the old filter dropped are recovered.
   - Call rows: `type` as today, `duration_seconds`, `source = 'device'`. Leave `content` empty for new rows.
   - After each batch update `contacts.last_interaction_at` for the contacts touched, using the rule in spec 02 step 7.
6. **Amount suggestions.** For incoming SMS from a person, look for an amount next to a currency marker: the user's currency symbol and code, plus `৳`, `Tk`, `BDT`, `$`, `USD`, `€`, `EUR`, `£`, `GBP`, `₹`, `Rs`, `INR`, `₦`, `NGN`. On a match set `suggested_amount` and `suggestion_state = 'open'` on that SMS row. Create nothing else.
7. **When it runs.** On app start and on return to the foreground (at most once a minute), when `onDeviceDataChanged` fires, and on pull to refresh in People. Expose a `SyncStatus` stream: idle, running with counts, failed with a reason, and the time of the last success.
8. Delete the `SpamFilter` call sites in new code. Keep the class and its tests for the old screens until spec 10.

## Acceptance criteria

- With a fake `DeviceApi` returning 20,000 SMS and 5,000 calls, a full sync completes in a test without loading everything into memory at once (assert batch calls), and a second sync reads nothing.
- The message `("+8801712345678", "Please send the invoice and the bill reference")` from a saved person is stored.
- A person with two numbers receives calls from both in their history.
- "I will pay Tk 500 tomorrow" produces one SMS row with `suggested_amount = 500` and no payment row.
- Re-running sync after migrating an old database creates no duplicate rows (test with rows in the old id format).
- The old `SyncEngine.syncAll` is still callable from the old screens and now delegates to the new service.

## Verify

```sh
dart run pigeon --input pigeons/device.dart
tool/verify.sh
```

Emulator check: save a contact, inject three SMS and two calls from its number with `adb emu`, and confirm they appear in that person's history within 5 seconds while the app is open. Record the time a full first sync takes on the emulator.

## Out of scope

Reading SMS while the app is closed. Nothing is lost by waiting: the phone keeps them and the next sync reads them.
