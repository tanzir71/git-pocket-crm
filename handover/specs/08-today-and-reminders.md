# 08 Today and reminders

## Goal

The Today tab, the reconnect cadence, and system notifications that arrive whether or not the app is open.

## Read first

`handover/03-screens.md` section 01. Figma frame `7:30`.

## Decisions

- Notifications use `flutter_local_notifications`. Reminders are scheduled with the plugin's zoned scheduling, exact when the user has allowed exact alarms and inexact otherwise.
- **Effective cadence** of a person = their own `cadence_days`; if null, the smallest `cadence_days` among their lists; if none, no cadence.
- **Reconnect due date** = `last_interaction_at + cadence`. With no interaction yet, the date the cadence was set plus the cadence. A person is due when now is past that date and past `cadence_snoozed_until`.
- Any real interaction moves the date on its own, because it updates `last_interaction_at` (specs 05 and 07). Nothing needs to be ticked off.

## Steps

1. **Today providers**, one per section, each a stream: prompt call, needs attention (empty until spec 09), follow-ups due (due before the end of today, not completed, overdue first), reconnect (due people, most overdue first, by ratio of overdue time to cadence), going out today (empty until spec 09), birthdays in the next 7 days.
2. **Today screen** with the sections, limits, row contents and empty states from the screens file. Sections animate in and out; the screen never shows a spinner.
3. **Prompt card actions:** Add note and Follow up open the after-call sheet; Skip sets `reviewed_at`. After it is answered, the next unreviewed call from the last 12 hours takes its place.
4. **Cadence picker** sheet for a person, a selection of people, and a list. Reconnect row long-press actions: Snooze 1 week, Change how often.
5. **First-use help:** the empty-state button "Choose people to stay in touch with" opens People in selection mode, then the cadence picker.
6. **Notifications.**
   - Channels: Follow-ups, Reconnect, After calls, Messages, Morning summary. Ask for the notification permission the first time the user sets a reminder, a follow-up or a cadence, with one sentence of explanation above the system dialog.
   - **Follow-up reminder** at the follow-up's time: title "{person}", text the follow-up title, actions Done and Tomorrow. Done completes it without opening the app. Tomorrow moves it to the same time the next day. Tapping opens the person.
   - **Morning summary** at a set time (default 09:00, default on): "3 follow-ups today · 2 people to reconnect with". Not sent when both are zero. Tapping opens Today.
   - **Reconnect** has no notifications of its own; it is part of the summary. The Reconnect channel exists for a later version and stays unused.
   - Reschedule every pending notification on app start, after a restart of the phone, after a time zone change, and whenever a follow-up changes. Keep a single function that cancels and re-creates them from the database, so the schedule can never drift from the data.
7. **Old data:** existing rows in `tasks` with a future `reminder_time` get notifications scheduled the first time this code runs.

## Acceptance criteria

- Unit tests for the cadence rules: own cadence wins over a list; the smallest list cadence applies; a new SMS moves the due date; snooze hides a person until its date; a person with no interaction is due one cadence after it was set.
- A widget test of Today with the Figma sample data shows the same sections, order and texts as frame `7:30`.
- With nothing due, the empty state appears and no section headers do.
- A test with a fake notifications plugin: creating a follow-up schedules one notification with the right time and actions; completing it cancels it; the Done action completes the follow-up.
- Golden test of Today, light and dark.

## Verify

```sh
tool/verify.sh && flutter test --dart-define=V2=true
```

Emulator check: a follow-up reminder appears within a minute of its time with the app's process killed and the device in idle mode, and again after `adb reboot`.
