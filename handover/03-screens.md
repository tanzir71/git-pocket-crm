# 03 Screens

Nine frames exist in Figma, and each is exported as an image in `handover/design/screens/`. This file describes each, then the screens that have no frame yet and are built from the same components. The landing page is specified separately in `specs/15-landing-page.md`. Frame size is 412 by 917. Routes are in `specs/04`.

## 01 Today (`7:30`, route `/today`)

The first screen. It answers "what should I do now".

- **Header.** "Today" in Display, the date in Body secondary ("Thursday 26 November"). Actions: search (opens People with the search field focused) and settings.
- **Sections, in this order. A section with nothing in it is not shown.**

| Section | Contains | Row | Tap | Limit |
|---|---|---|---|---|
| (prompt card, no header) | The most recent call in the last 12 hours with a saved person that has no note and has not been skipped | Prompt card: "You spoke with {name}", "Outgoing call · 4 min · 10:12", buttons Add note (small primary), Follow up (small secondary), Skip (small quiet) | Add note opens the after-call sheet. Follow up opens it with focus on the follow-up field. Skip marks the call reviewed | One card. Older unreviewed calls appear after it is answered |
| Needs attention · n | Messages that failed or were missed while the phone was off | Failed-send row with Retry | Opens the person or the campaign | All |
| Follow-ups · n | Follow-ups due today or overdue, overdue first | Row / Task. Meta is "{person} · today 15:00" or "{person} · overdue by 1 day" in danger | Circle completes it. Row opens the person | 6, then "Show all" |
| Reconnect · n | People whose reconnect date has passed, most overdue first | Row / Person. Meta is "Every month · last spoke 6 weeks ago" | Opens the person. Long press: Snooze 1 week, Change how often | 5, then "Show all" |
| Going out today · n | Scheduled messages and campaigns due today | Row / Event | Opens the message or campaign | All |
| Coming up · n | Birthdays in the next 7 days, when a person has one | Row / Person. Meta is "Birthday on Saturday" | Opens the person | 5 |

- **Floating button.** Plus. Opens the Add sheet with the person empty and the search focused.
- **Empty state** (nothing in any section): Title "All caught up", Body secondary "Follow-ups and people to reconnect with will appear here.", and a secondary button "Choose people to stay in touch with" that opens People in selection mode to set a cadence. Shown only when no person has a cadence yet; otherwise just the title and line.
- **First run** (no people yet): go to Setup instead.

## 02 After-call note (`7:132`, sheet)

Opens from the prompt card, from the after-call notification, and from any call row in History.

- Handle, avatar, "Call with {name}" in Headline, "Outgoing · 4 min · just now" in Caption.
- "How did it go?" with single-choice chips: Spoke (default when duration is over 10 seconds), No answer (default otherwise), Left a message.
- Note field: `bg/subtle`, grows from 3 lines to 8, autofocus, sentence capitalisation. A microphone icon starts voice typing (see `specs/07`).
- "Follow up" with chips: Tomorrow, In 3 days, Next week, Pick date. Choosing one reveals a one-line field for the follow-up title, prefilled "Follow up with {first name}" and selected so typing replaces it. No chip chosen means no follow-up.
- Primary button "Save". Enabled when there is a note, an outcome change, or a follow-up.
- Saving writes the outcome and note onto the existing call entry (it does not create a second entry), creates the follow-up, marks the call reviewed, and shows a snackbar "Saved" with Undo.
- "No answer" changes the default follow-up title to "Call {first name} back" and preselects Tomorrow.

## 03 People (`7:210`, route `/people`)

- Header "People", count in Body secondary. Action: add person.
- Search field. Searches name, company, phone numbers and note text, as you type, with full-text search.
- Chip row, horizontally scrollable: All, Starred, Due to reconnect, Owes me, then the user's lists in alphabetical order, then "New list". Long press on a list chip: Rename, Set how often to reconnect, Message this list, Delete list.
- Sort control: "Recently contacted" (default), "Name", "Longest since contact".
- Rows: Row / Person. Meta is "{company or list} · {last interaction in words}". Trailing is the short age of the last interaction: Now, 1d, 3d, 2w, 4mo. Meta turns danger and reads "follow-up overdue" when the person has an overdue follow-up.
- Long press a row to enter selection mode: Add to list, Set reconnect, Message, Star.
- Floating button: add person (name and phone required; company, email and a note optional).
- Empty search: "No one matches '{query}'" and a button "Add '{query}' as a new person".

## 04 Person (`9:261`, route `/people/:id`)

- Top bar: back, star toggle, more (Edit details, Add to list, Set reconnect, Do not message, Delete person).
- Identity: 56 avatar, name in Title, "{company} · {city}" in Body secondary. Missing parts are omitted, never shown as blanks.
- Attribute chips: the reconnect setting ("Reconnect every 2 weeks", or "Set reconnect" when none) and the person's lists. Tapping the first opens the cadence picker.
- Four actions in a row, each a bordered `bg/surface` tile with icon and Label: Call (dials the primary number; long press picks another number), Message (opens the single-message composer), WhatsApp (opens a chat through a `wa.me` link; hidden when the number is not a mobile), Note (opens the Add sheet on Note).
- **Next · n.** Open follow-ups (Row / Task), scheduled messages (Row / Event, clock), and the balance row when there is one: "Owes you $240" or "You owe $240", with the latest unpaid entry as its text. Tapping the balance row offers "Send a reminder", which opens the composer with the payment reminder template.
- **History.** A filter icon on the right opens a menu: All, Calls, Messages, Notes, Visits, Payments, Files. Entries are Row / Event, newest first, grouped by month once past the current month ("October 2026" in a section header).

| Entry | Title | Text | Time line |
|---|---|---|---|
| Call | "Outgoing call · 4 min", "Incoming call · 2 min", "Missed call" | The note, when there is one. Otherwise nothing | "Today 10:12" |
| Message | "Message received" or "Message sent" | The message, three lines at most, tap to expand | date, plus "Delivered" or "Not sent" for sent ones |
| Note | "Note" | The note | date |
| Visit | "Visit · {place}" | The note | date, plus "2 photos" |
| Payment | "Payment received · $180", "You paid · $40", "Owes you · $240", "You owe · $60" | Description | date |
| File | File name | Description | date |
| Suggested payment | "Looks like a payment · $500" | The message it came from | Buttons Confirm and Dismiss |

- Tapping an entry opens it in the Add sheet for editing. Calls and messages can only have their note and outcome edited. Long press: Delete entry, Add follow-up.
- Floating button: plus. Opens the Add sheet with this person filled in.

## 05 Add (`9:369`, sheet)

One sheet for everything the user adds by hand.

- Title "Add".
- Person field: avatar, name, a Caption reason when it was suggested ("Suggested from your 15:00 follow-up", "Your last call"). Tapping it opens a search list. When opened from a person screen it is fixed.
- Type chips, scrollable: Note, Call, Visit, Task, Payment, File. The last used type is remembered per session. Default is Note.

| Type | Fields |
|---|---|
| Note | Note field |
| Call | Direction (Outgoing or Incoming), time (default now), duration optional, outcome chips, note field. For calls made on another phone |
| Visit | Place (one-line field, prefilled with the person's company and city; a "Current location" control attaches coordinates if permission is granted), time (default now), note field, photos (camera or gallery, shown as a count) |
| Task | Title, due date and time, optional note. This is a follow-up with no entry attached |
| Payment | Amount with the currency symbol, status chips (Received, Paid, Owes me, I owe), description, date |
| File | Pick a file or photo, description |

- Every type except Task ends with the "Follow up" chips described under After-call note.
- Primary button names the thing: "Save note", "Save visit", "Save payment".
- The sheet is at most 90 percent of the screen height and scrolls inside. The button stays pinned above the keyboard.

## 06 Messages (`9:471`, route `/messages`)

- Header "Messages", a Body secondary summary ("3 scheduled · 1 needs attention"). Action: search.
- View chips: Outbox, Campaigns, Templates.
- **Outbox.** Sections: Needs attention (failed and missed, with Retry or Send now and Dismiss), Today, Tomorrow, Later, then "Earlier" with a Row / Setting "Sent this week · 38" that opens the sent list. A single message row is Row / Event with the person's name as title, the message as text and the time. A campaign row has a people icon and the title "{name} to {n} people".
- **Campaigns.** All campaigns, newest first, with state: Scheduled, Sending 14 of 24, Paused, Done · 23 sent · 1 not sent, Stopped.
- **Templates.** Name and first line. Tap to edit. Three templates are created on first run: Payment reminder, Thank you after a visit, Checking in.
- Floating button: pen. Opens New message.
- Empty outbox: "Nothing scheduled" and a line "Messages you schedule will wait here until they are sent."

## 07 New message (`10:498`, route `/messages/new`)

Used for one person or many. With one recipient the Preview block and Pace row are hidden and the button reads "Schedule message" or "Send now".

- Top bar: close (asks to keep as a draft if there is text), "New message", Templates (opens a picker).
- **To.** Chips for each list or person added, with the count. "Add people" opens a picker with lists first, then people. A Caption line reports anyone left out and why: "2 skipped: no mobile number", "1 skipped: asked not to be messaged".
- **Message.** A bordered `bg/surface` field. Merge fields are typed or inserted from the chips beneath and drawn in `accent/default`. Insert chips: First name, Name, Company, Amount due, My name. To the right a live counter: "1 SMS · 67 of 160", counted on the longest message after the fields are filled in. See `specs/10` for counting. When any recipient's rendered text needs more parts than the template suggests, the counter reads "1 to 2 SMS each".
- **Preview.** "Preview" on the left, "{name} · 1 of 24" on the right. The rendered message in a `bg/subtle` bubble. Swipe or tap the counter to step through recipients. A recipient whose merge field is empty shows the fallback and a Caption warning.
- **Settings.** Row / Setting each: Send (Now, or a date and time), From (the SIM; hidden on single-SIM phones), Pace (Fast: 1 every 4 seconds; Steady: 1 every 15 seconds; Careful: 1 a minute; with the total time).
- **Bottom.** Primary button "Schedule 24 messages" or "Send 24 messages". Caption beneath: "Sends only between 09:00 and 21:00", linking to the send-window setting.
- Sending now to more than 10 people asks once: "Send 24 messages from SIM 1? This takes about 2 minutes and uses your SMS plan." with Send and Cancel.

## 08 Campaign progress (`10:556`, route `/messages/campaign/:id`)

- Top bar: back, more (Duplicate, Export results, Delete).
- Name in Title. State line in Body secondary: "Scheduled for today 18:00", "Sending · 14 of 24", "Paused · 14 of 24", "Done · 23 sent · 1 not sent", "Stopped · 14 of 24".
- Progress bar: 6 high, `bg/subtle` track, `accent/default` fill. Left: time remaining. Right: pace.
- Controls: Pause or Resume (small secondary), Stop (small quiet, asks to confirm). When done: "Retry 1 not sent" (small secondary).
- Summary: four numbers in Headline with Caption labels: Sent, Failed, Sending, Waiting. Failed is in danger when above zero.
- Recipients: Row / Person. Meta is the value of the main merge field ("$240 due") or, for a failure, the reason and "tap to retry". Trailing is the state: Waiting (tertiary), Sending (primary), Sent (secondary), Delivered (success), Failed (danger), Skipped (tertiary).
- The same information is in the ongoing notification while sending: "Payment reminder · 14 of 24" with Pause and Stop.

## 09 Setup (`10:648`, route `/setup`)

Shown on first run and from Settings as "Check setup".

- "Finish setup" in Display. One Body secondary sentence.
- Five rows. A done row has a check in a `status/success-soft` circle and "Allowed". A pending row has an empty `bg/subtle` circle and an Allow button.

| Row | Line | What Allow does |
|---|---|---|
| Contacts | Shows your people and matches calls to them | Requests the contacts permission |
| Calls and messages | Builds each person's history on this phone | Requests call log, SMS and phone state. If Android blocks it because the app was installed from a file, shows the three-step "Allow restricted settings" guide (see `specs/11`) |
| Alarms and reminders | Sends scheduled messages at the exact time | Opens the system "Alarms and reminders" page for the app |
| Battery | Stops Android pausing sends when the app is closed | Requests exemption from battery optimisation, then shows the maker-specific step when one is known |
| Notifications | Follow-up reminders and send results | Requests the notification permission |

- A bordered note with a lock icon: "Everything stays on this phone. PocketCRM has no internet access."
- Primary "Continue" (enabled once Contacts is allowed), quiet "Do this later".
- After Continue the first sync runs with a progress line ("Reading your call history · 2,140 of 5,300") and lands on People.

## Screens without a frame

Build these from the same components and rules.

| Screen | Content |
|---|---|
| Settings (`/settings`) | Row / Setting list under section headers. General: Currency, Region for phone numbers, Theme (System, Light, Dark), Language. After calls: Ask for a note (All saved people, Starred only, Never). Reminders: Morning summary (Off or a time), Reconnect nudges (On, Off). Messages: Default SIM, Default pace, Send window, Opt-out words. Data: Sync now with last sync time, Backup and restore, Export, Check setup. About: version, licences |
| Cadence picker (sheet) | Title "How often to reconnect". Single-choice rows: Every week, Every 2 weeks, Every month, Every 3 months, Every 6 months, Every year, Never. For a list, a note: "Applies to the 24 people in Customers who have no setting of their own." |
| Person picker (sheet) | Search field, then "Recent" and all people as Row / Person. In multi-select mode, lists come first with their counts |
| Edit person (sheet) | Name, numbers (several, one marked primary), company, role, city, email, birthday, links, a short "About" note |
| Backup (`/settings/backup`) | See `specs/12` |
| Sent list | Row / Event per message with state. Filter by state |
| Template editor | Name field, message field with merge chips and counter, preview with a sample person |
