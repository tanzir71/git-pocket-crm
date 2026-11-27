# 02 Data layer

## Goal

One typed database layer on drift, opened on the existing `pocket_crm.db` file, at schema version 5, with every existing row intact. The old screens keep working on top of it.

## Read first

`lib/database_helper.dart` (the whole file is the v4 schema), `handover/00-current-state.md`, `handover/03-screens.md` for what the new columns are for.

## Decisions

- **drift** with `drift_dev` and `build_runner`. Set up the native SQLite library the way drift's current documentation says; do not add `sqlite3_flutter_libs` if it is marked end of life.
- **Only one SQLite library may ever open the database file.** Two copies of SQLite in one process do not see each other's locks and can corrupt the file. So from this spec on, `sqflite` no longer opens the database. Keep the `sqflite` package only for `getDatabasesPath()`, so the file location does not change.
- **Nothing is dropped or renamed.** New columns and tables only.
- The database runs on a background isolate (`NativeDatabase.createInBackground`).
- Times stay as integer milliseconds since the epoch, as they are today.

## Steps

1. **Safety copy.** Before the database is opened for the first time by the new code: if `pocket_crm.db` exists and `pocket_crm.v4.bak` does not, copy the file, plus `-wal` and `-shm` files if present, to `pocket_crm.v4.bak*`. Do this in plain `dart:io` before drift opens anything.
2. **Define the schema** in `lib/core/db/`. Existing tables keep their names and columns exactly: `contacts`, `timeline`, `scheduled_sms`, `tasks`, `contact_lists`, `contact_list_members`, `bulk_sms_jobs`.
3. **Add columns.**

| Table | New columns |
|---|---|
| `contacts` | `company` TEXT, `role` TEXT, `city` TEXT, `email` TEXT, `birthday` TEXT (`MM-DD` or `YYYY-MM-DD`), `about` TEXT, `cadence_days` INT, `cadence_snoozed_until` INT, `last_interaction_at` INT, `do_not_message` INT default 0, `device_contact_id` TEXT, `source` TEXT default `'device'`, `created_at` INT |
| `timeline` | `note` TEXT, `outcome` TEXT (`spoke`, `no_answer`, `left_message`), `duration_seconds` INT, `place_name` TEXT, `lat` REAL, `lng` REAL, `currency` TEXT, `payment_status` TEXT (`received`, `paid`, `owed_to_me`, `i_owe`, `unconfirmed`), `suggested_amount` REAL, `suggestion_state` TEXT (`open`, `confirmed`, `dismissed`), `reviewed_at` INT, `hidden` INT default 0, `source` TEXT (`device`, `manual`, `app`), `outbox_client_id` TEXT, `edited_at` INT |
| `tasks` | `note` TEXT, `created_at` INT, `completed_at` INT, `source_timeline_id` INT |
| `contact_lists` | `cadence_days` INT, `created_at` INT |

4. **Add tables.**

| Table | Columns |
|---|---|
| `contact_phones` | `id`, `contact_id` (cascade), `e164` TEXT, `raw` TEXT, `label` TEXT, `is_primary` INT, `is_mobile` INT. Unique on `e164` |
| `timeline_attachments` | `id`, `timeline_id` (cascade), `path` TEXT, `mime` TEXT, `created_at` INT |
| `templates` | `id`, `name` TEXT unique, `body` TEXT, `created_at`, `updated_at` |
| `campaigns` | `id` TEXT primary key (UUID), `name`, `body_template`, `scheduled_at` INT, `status` TEXT (`draft`, `scheduled`, `running`, `paused`, `done`, `stopped`), `sub_id` INT, `pace_seconds` INT, `window_start_min` INT, `window_end_min` INT, `created_at` |
| `outbox_messages` | `client_id` TEXT primary key (UUID), `contact_id` (set null on delete), `campaign_id` TEXT, `address` TEXT, `body` TEXT, `due_at` INT, `sub_id` INT, `status` TEXT (`queued`, `sending`, `sent`, `delivered`, `failed`, `cancelled`, `missed`, `skipped`), `error_code` INT, `error_label` TEXT, `parts` INT, `attempt` INT, `sent_at` INT, `delivered_at` INT, `provider_sms_id` TEXT, `merge_summary` TEXT, `created_at`, `updated_at` |
| `settings` | `key` TEXT primary key, `value` TEXT |
| `sync_state` | `key` TEXT primary key, `value` TEXT |

5. **Indexes.** `timeline(contact_id, timestamp DESC)`, unique `timeline(native_message_id)` where it is not null, `timeline(type, timestamp)`, `tasks(is_completed, due_date)`, `tasks(contact_id)`, `contact_phones(contact_id)`, `outbox_messages(status, due_at)`, `outbox_messages(campaign_id)`, `contacts(last_interaction_at)`. Before creating the unique index, find duplicate `native_message_id` values and set all but the lowest id in each group to null with `hidden = 1`.
6. **Migration.** `schemaVersion = 5`. `onUpgrade` must handle any starting version from 1 to 4 by first applying the same steps the old `_onUpgrade` did (see `database_helper.dart:126-165`), then the v5 changes. `beforeOpen` runs `PRAGMA foreign_keys = ON`.
7. **Backfill**, inside the migration transaction:
   - `contact_phones`: one row per contact from `contacts.phone_number`, `is_primary = 1`, `e164` set to the stored value for now (spec 05 normalises).
   - `contacts.email` from `gmail_address`; `contacts.about` from `pinned_note`; `created_at` from `last_sync_time` when above zero.
   - `timeline.payment_status` for `type = 'payment'`: from the prefix in `content` using the mapping in `thread_screen.dart:2531` (`[Paid]` paid, `[Received]` received, `[To Collect]` and `[Owed to Me]` owed_to_me, `[To Pay]`, `[I owe]` and `[I Owe]` i_owe). Put the text after the prefix in `note`. Rows whose content starts with `Parsed from SMS:` get `payment_status = 'unconfirmed'`. Do not modify `content`.
   - `timeline.duration_seconds` for call rows by parsing `Duration: 2 min 5 sec` and `Duration: 40 sec` from `content`.
   - `timeline.hidden = 1` for `type = 'sms_scheduled'` and for `type = 'promise'` rows, which only describe a system action.
   - `timeline.source = 'device'` for calls and SMS, `'manual'` for the rest.
   - `contacts.last_interaction_at`: the latest `timestamp` among that contact's rows of type `call_incoming` or `call_outgoing` with a duration above zero, `sms_incoming`, `sms_outgoing`.
   - Delete rows in `timeline`, `tasks`, `scheduled_sms` and `contact_list_members` whose contact or list no longer exists. Log how many.
8. **Repositories** in `lib/features/*/data/` returning typed models and streams: people, history, follow-ups, lists, payments (including the balance rule below), templates, settings, sync state. No widget may run SQL.
   - **Balance for a person** = sum of `owed_to_me` minus sum of `received`, minus (sum of `i_owe` minus sum of `paid`), over rows where `payment_status` is one of those four, and only when the person has at least one `owed_to_me` or `i_owe` row. Positive reads "Owes you", negative reads "You owe", zero shows nothing.
9. **Search.** An FTS5 table over name, company, phone numbers, `about` and note text, kept current by the repositories. If FTS5 is not available in the bundled library, fall back to `LIKE` behind the same repository method and record it in `DECISIONS.md`.
10. **Keep the old screens running.** Replace the body of `DatabaseHelper.database` so it returns a small adapter, `LegacyDb`, that implements the calls the old screens use (`query`, `rawQuery`, `insert`, `update`, `delete`, `execute`, `transaction`, and a `Transaction` with the same methods) with the same named parameters, on top of the drift connection (`customSelect`, `customStatement`, `customInsert`, `customUpdate`). Keep `Sqflite.firstIntValue` usages working, or replace them with a local helper. Update `test/widget_test.dart` to use an in-memory drift database.

## Acceptance criteria

- **Migration test.** A test creates a database from the literal v4 `CREATE TABLE` statements copied into a fixture, inserts at least: 3 contacts, 2 list rows with members, calls and SMS, payments with each of the seven prefixes, an auto-parsed payment, a task, a scheduled SMS, a bulk job, an orphan timeline row, and two rows sharing a `native_message_id`. It closes the file, opens it with the new database class, and asserts: every non-orphan row count is unchanged, every original column value is unchanged, each backfill above produced the expected value, foreign keys are on, and the indexes exist.
- The same test starting from a v1 schema (without lists, `reminder_time` and `is_pinned`) also passes.
- Deleting a contact through the repository removes its timeline rows, tasks, phones and list memberships.
- The app opens with existing data and every old screen still loads and saves.
- `grep -R "openDatabase" lib` finds nothing.

## Verify

```sh
dart run build_runner build --delete-conflicting-outputs
tool/verify.sh
```

## Out of scope

Moving scheduled SMS into the new outbox (spec 10). Normalising phone numbers (spec 05). Any screen change.
