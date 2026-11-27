# 07 Add and after-call

## Goal

One sheet to add anything about a person in under ten seconds, and a prompt to note a call the moment it ends. This is the centre of the product.

## Read first

`handover/01-product-direction.md` "The loop", `handover/03-screens.md` sections 02 and 05. Figma frames `7:132` and `9:369`.

## Decisions

- The Add sheet replaces the old chooser sheet, the old "Log Event" sheet and the five dialogs on the old person screen.
- Voice input: use the keyboard's own voice typing by default. Add the microphone button only if a speech package can be added without bringing the INTERNET permission into the merged release manifest (`tool/check_manifest.sh` decides). If it cannot, leave the button out and record that in `DECISIONS.md`.
- Photos use `image_picker` (camera and gallery). Files use `file_picker`. Everything picked is copied into app storage, as `DatabaseHelper.replicateAttachment` does today; move that function into a `FileStore` class.
- Location for a visit is optional and stores coordinates only. There is no reverse geocoding because the app has no network access. Use the platform location API through a small Pigeon method (`currentLocation()`, coarse accuracy, 5 second timeout). Request the location permission only when the user taps "Current location".

## Steps

1. **Add sheet** (`lib/features/capture/ui/add_sheet.dart`), opened with an optional person, type, and entry to edit.
   - Person suggestion when none is given, in this order: the person of the most recent unreviewed call in the last 12 hours ("Your last call"), the person of the next follow-up due within 2 hours ("Suggested from your 15:00 follow-up"), otherwise empty with the picker open.
   - Type chips and fields exactly as in the screens file. Switching type keeps the note text.
   - Follow-up chips. Tomorrow means 09:00 tomorrow. In 3 days and Next week mean 09:00 on that day. Pick date opens date then time. The default time is a setting.
   - Saving is one transaction: the entry, its attachments, the follow-up (with `source_timeline_id`), and `last_interaction_at` when the type counts as contact (Visit always; Call when the outcome is Spoke).
   - After saving: close, snackbar "Saved" with Undo (5 seconds) that reverses the whole transaction.
   - Validation is inline and specific: "Add an amount", "Choose a person". The primary button is disabled until the form can be saved.
2. **Payment** entries store `amount`, `currency` (from settings) and `payment_status`. New rows do not write a prefix into `content`.
3. **After-call sheet** (`after_call_sheet.dart`): as specified. It edits the existing device call row (`outcome`, `note`, `reviewed_at`) and never creates a second row.
4. **Knowing a call ended.**
   - In the app: after each sync, the newest call in the last 12 hours with a saved person, a null `reviewed_at`, and matching the "Ask for a note" setting, feeds the Today prompt card (spec 08 renders it).
   - With the app closed: a manifest-declared Kotlin `BroadcastReceiver` for `android.intent.action.PHONE_STATE`. When the state returns to idle after a call, look the number up in the phone's contacts (`ContactsContract.PhoneLookup`); if it is a saved contact and the setting allows it, post a notification "Add a note about your call with {name}" with actions Add note and Follow up. Both open `pocketcrm://after-call?number={e164}`. The app then runs a sync and opens the sheet on that person's latest call. Needs `READ_PHONE_STATE` and `READ_CALL_LOG`. The receiver does nothing else and holds no database.
   - Setting "Ask for a note after calls": All saved people (default), Starred only, Never. Mirror the value to the native side through a Pigeon call so the receiver can read it from `SharedPreferences`.
   - If the receiver cannot be made to work on the emulator, the in-app card still covers the need. Record the result in `handover/TEST-RESULTS.md` and, if it could not be shown, in `handover/UNVERIFIED.md`; do not block on it.
5. **Follow-ups repository:** create, complete (sets `completed_at`), reopen, reschedule, delete. Completing from any screen uses the motion described in the design file.
6. **Editing:** tapping a history entry opens the Add sheet in edit mode with "Save changes" and a Delete action.

## Acceptance criteria

- A widget test adds a visit with a note, two photos and a follow-up in 3 days: one `timeline` row of type `visit` with the place, two attachment rows, one follow-up due at 09:00 three days later linked to the visit, and `last_interaction_at` updated.
- A widget test saves the after-call sheet with "No answer": the call row has `outcome = 'no_answer'`, a follow-up titled "Call {first name} back" is due tomorrow, and no new timeline row exists.
- Undo after a save leaves the database exactly as before (compare row counts across all tables).
- A stopwatch test (integration test with a fake clock is enough): from tapping the floating button on a person screen to a saved one-line note takes three interactions: open, type, save.
- Golden tests of the Add sheet on Visit and of the after-call sheet against frames `9:369` and `7:132`.

## Verify

```sh
tool/verify.sh && flutter test --dart-define=V2=true
```

Emulator check: with the app's process killed, simulate a call from a saved number with `adb emu gsm call` and end it with `adb emu gsm cancel`. The notification appears within 10 seconds and opens the sheet on that call.
