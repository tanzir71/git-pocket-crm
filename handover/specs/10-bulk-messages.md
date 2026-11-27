# 10 Bulk messages and cut-over

## Goal

Personalised messages to many people, paced and resumable, with a result per person. Then the new interface becomes the default and the old screens are deleted.

## Read first

`handover/03-screens.md` sections 06, 07 and 08. Figma frames `9:471`, `10:498`, `10:556`.

## Part A: templates, merge fields, counting

1. **Merge fields** are written in braces: `{first name}`, `{name}`, `{company}`, `{amount due}`, `{my name}`. A fallback follows a bar: `{first name|there}`. Unknown fields are left as typed and flagged in the composer.

| Field | Value | Default fallback |
|---|---|---|
| `{first name}` | First word of the person's name | "there" |
| `{name}` | Full name | "there" |
| `{company}` | Company | empty |
| `{amount due}` | The positive balance, formatted with the currency | empty |
| `{my name}` | The user's name from settings | empty |

2. **`renderTemplate(template, person, settings)`** is a pure function. After substitution, collapse double spaces and remove a space before punctuation left by an empty field.
3. **`countSms(text)`** is a pure function returning the encoding, the number of characters counted, the number of parts, and the characters left in the last part.
   - If every character is in the GSM 7-bit basic set or its extension table, the encoding is GSM-7. The extension characters `^ { } \ [ ~ ] |` and the euro sign count as two. One part holds 160; when longer, each part holds 153.
   - Otherwise the encoding is UCS-2, counted in UTF-16 code units. One part holds 70; when longer, each part holds 67. Any Bangla, Arabic, Hindi or emoji character forces UCS-2.
   - Note that merge fields in braces are replaced before counting, so braces in the template do not count.
4. **Templates** screen and editor. On first run create three: "Payment reminder" (`Hi {first name}, a quick reminder that {amount due} is due. Thank you. {my name}`), "Thank you after a visit" (`Hi {first name}, thank you for your time today. I will follow up shortly. {my name}`), "Checking in" (`Hi {first name}, it has been a while. How are you?`).

## Part B: composer and campaigns

5. **Recipients.** Resolve lists and people to a set of persons, then to one number each: the primary number if it is a mobile, else the first mobile. Leave out, and report by reason: no mobile number, asked not to be messaged, duplicate number.
6. **Composer** as designed, for one or many recipients. The preview renders the real message for the person shown. The counter shows the largest part count across all recipients, and "1 to 2 SMS each" when they differ. A recipient with an empty field and no fallback is listed under "Check these" before scheduling.
7. **Scheduling a campaign:** create the `campaigns` row; render and store the final text for every recipient in `outbox_messages` now, so what was previewed is what is sent; call `upsertCampaign` then `enqueue` with the same `due_at` for all. The native worker spaces them by the pace.
8. **Pace options:** Fast, every 4 seconds; Steady, every 15 seconds; Careful, every 60 seconds. Show the total time. The default is a setting, initially Fast.
9. **Campaign progress** screen from a stream over the campaign's `outbox_messages`. Pause, Resume and Stop call the API. "Retry n not sent" calls `retry`. Export results writes a CSV (name, number, state, time, reason) through the share sheet.
10. **Messages tab:** Outbox, Campaigns and Templates views as designed.
11. **Opt-out.** In sync, when an incoming SMS from a person, trimmed and upper-cased, equals one of the opt-out words (setting, default `STOP`, `UNSUBSCRIBE`, `বন্ধ`), set `do_not_message = 1` and show "Asked not to be messaged" under that message in History. The person screen shows the state and lets the user turn it off.
12. **Payment reminder shortcut:** the balance row on a person opens the composer with that person and the "Payment reminder" template.

## Part C: cut-over

13. **Move old scheduled messages.** For each `scheduled_sms` row with `is_sent = 0`: create an `outbox_messages` row. If its time is in the future, enqueue it. If its time has passed, give it status `missed` so it waits under Needs attention. Rows from a `bulk_sms_jobs` job become one campaign named "Message to {list_name}". Rows with `is_sent = 1` are left alone. Mark each moved row by setting `is_sent = 2` so the move never repeats. Run this once, guarded by a `settings` key.
14. **Flip the switch.** `kV2` defaults to true. Remove the define from `tool/` scripts and from the milestone build command.
15. **Delete** `lib/legacy/`, `lib/sms_processor.dart`, `lib/sync_engine.dart`, `lib/spam_filter.dart` and their tests, `LegacyDb`, the `sendSms` method channel in `MainActivity.kt`, and the packages `flutter_sms_inbox`, `call_log`, `google_fonts` and `sqflite` (replace `getDatabasesPath()` with the same path computed through `path_provider`, and assert in a migration test that the path string is unchanged). Remove every placeholder `EmptyState` added in spec 04.
16. Run the lint guard from spec 03 across all of `lib/`.

## Acceptance criteria

- Unit tests for `renderTemplate`: each field, each fallback, an empty field next to punctuation, an unknown field.
- Unit tests for `countSms`: 160 GSM characters is 1 part and 161 is 2; a text with `{` literal counts it as two; 70 Bangla characters is 1 part and 71 is 2; an emoji forces UCS-2 and counts as two units.
- A widget test of the composer with the Figma sample data matches frame `10:498`: the preview reads "Hi Amara, a quick reminder that $240 is due on Friday. Thank you!".
- A test schedules a campaign to a list of 24 where 2 people have no mobile and 1 opted out: 21 outbox rows, the three reasons reported, every row's text is the rendered text.
- The cut-over test starts from a v4 fixture with future, overdue and sent scheduled rows and a bulk job, and ends with the right outbox rows and states, and running it twice changes nothing.
- `grep -R "legacy" lib` finds nothing. The app starts on Today with no define.

## Verify

```sh
tool/verify.sh
```

Emulator checks, recorded in `handover/TEST-RESULTS.md`: a campaign of 10 messages from emulator A to emulator B at each pace, counting what arrives on B; pause and resume mid-run; kill the app's process mid-run with `am kill` and confirm the run continues or resumes and B receives each message exactly once.
