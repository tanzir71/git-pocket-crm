# 06 People and Person

## Goal

The People tab and the Person screen, as designed, on real data. Visible with `--dart-define=V2=true`.

## Read first

`handover/03-screens.md` sections 03 and 04, and "Screens without a frame" (cadence picker, person picker, edit person). Figma frames `7:210` and `9:261`.

## Steps

1. **People list.** A single query returns, per person: name, company, first list name, last interaction time and kind, whether an overdue follow-up exists, starred, tone. Expose it as a stream with parameters for search text, filter and sort. Render with `ListView.builder` and `PersonRow`; it must stay smooth with 5,000 people.
   - Meta text: "{company or first list} · {last interaction in words}". Words: "called today", "messaged yesterday", "visited 3 days ago", "last spoke 6 weeks ago", "no contact yet". With an overdue follow-up: "{company} · follow-up overdue" in danger.
   - Trailing: Now (under an hour), then `3h`, `1d`, `3d`, `2w`, `4mo`, `2y`.
2. **Search** uses the repository search from spec 02, debounced by 150 ms, and matches name, company, any phone number typed with or without spaces or country code, `about` and note text.
3. **Filter chips:** All, Starred, Due to reconnect (see the rule in spec 08; until then the chip lists people with a cadence whose due date has passed, using a repository method you add now), Owes me (balance above zero), each list, "New list". Long-press menu on a list chip as specified.
4. **Sort:** Recently contacted, Name, Longest since contact. Remember the choice in `settings`.
5. **Selection mode** on long press: Add to list, Set reconnect, Message (enabled in spec 10; show it disabled until then), Star.
6. **Add person** sheet and **Edit person** sheet with the fields listed in the screens file. Numbers are normalised with the phone service; an invalid number shows "This number does not look complete" under the field and still allows saving as raw text. A new person with a number that already belongs to someone offers "Open {name}" instead of creating a duplicate.
7. **Merge suggestion.** When spec 05 flagged two people sharing a number, show one dismissible row at the top of People: "{A} and {B} share a number" with Merge and Keep separate. Merging moves history, follow-ups, list memberships and numbers to the person with more history and deletes the other, in one transaction.
8. **Person screen.**
   - Identity, attribute chips, the four actions. Call uses `url_launcher` with a `tel:` URI. WhatsApp opens `https://wa.me/<digits without plus>`; hide it when the primary number is not a mobile. Message is enabled in spec 10; until then it opens the phone's SMS app with an `sms:` URI.
   - **Next:** open follow-ups by due time, then scheduled messages for this person (from `outbox_messages`; empty until spec 09), then the balance row when the balance is not zero.
   - **History:** rows where `hidden = 0`, newest first, paged 50 at a time, with the mapping table from the screens file. Month headers after the current month. The filter menu sets a type filter that persists while the screen is open.
   - Suggested payments show Confirm and Dismiss. Confirm asks for the status (Received, Paid, Owes me, I owe), creates a `payment` row dated as the message, and sets `suggestion_state = 'confirmed'`. Legacy `unconfirmed` payment rows are shown the same way; confirming sets their `payment_status`.
   - Long press an entry: Delete entry (with Undo), Add follow-up. Device calls and messages cannot be deleted, only hidden; say "Hide from history".
   - More menu: Edit details, Add to list, Set reconnect, Do not message (toggles `do_not_message` and shows a Caption line under the identity), Delete person (confirm with the count of entries that will go).
9. **Lists.** Create, rename, delete, add and remove members, set a list cadence. Deleting a list never deletes people.
10. **Dates and numbers** go through one formatter in `lib/core/format/` that implements the rules in "Writing" in the design file. It takes a clock so tests are stable.

## Acceptance criteria

- Widget tests for People: search by partial phone number finds the person; the Owes me chip lists exactly the people with a positive balance; an overdue person shows the danger meta.
- Widget tests for Person: a call with a note shows the note under the call; a visit shows its place in the title; confirming a suggested payment creates one payment row and the balance row appears.
- Golden tests of both screens, light and dark, with the sample data used in Figma, compared by eye against frames `7:210` and `9:261`.
- Scrolling a list of 5,000 generated people builds only visible rows (assert with a build counter).
- No file in `lib/features` contains SQL.

## Verify

```sh
tool/verify.sh && flutter test --dart-define=V2=true
```
