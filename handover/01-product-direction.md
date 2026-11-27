# 01 Product direction

## Who it is for

**The salesperson who works from a phone.** Makes and takes calls all day, visits shops, offices and sites, has to remember what was said and what was promised, chases payments, and sends the same reminder to many customers. Today this lives in the call log, a paper notebook and memory.

**The everyday person.** Has a few dozen people who matter (family, friends, a doctor, a landlord, clients of a side business) and loses track of when they last spoke, what was said, and what they meant to do next. They do not think they need a CRM, so the app must never look or sound like one.

One app serves both because the loop is the same. The salesperson runs it thirty times a day and the everyday person three times a week.

## The loop

1. **Something happens with a person.** A call, a message, a visit. Calls and messages are logged by the app, not by the user.
2. **Note it in seconds.** One sheet, one text field, voice typing, done in under ten seconds. Right after a call the app offers this without being asked.
3. **Set the next step.** Tomorrow, in three days, next week, or a date. One tap.
4. **The app brings it back.** Today shows what is due. A notification arrives at the right time. If nothing was planned and too long has passed, the person appears under Reconnect.

Everything in v2 either belongs to this loop or is removed from the main path.

## What was learned from the tools it will be compared with

| Tool | What it does best | What PocketCRM takes |
|---|---|---|
| Dex (getdex.com) | A single keep-in-touch loop. You set how often you want to speak to someone and the next date is worked out from the last real interaction. A frequency can be set for a whole group. One quick-add entry point. A daily agenda on mobile. $12 to $40 a month, no free plan. It reminds; it does not send automated message sequences. | The cadence model, group cadence, one entry point for adding anything |
| Mesh, formerly Clay (me.sh) | A calm home feed of reminders, birthdays and reconnect prompts. Note-taking before, during and after a conversation, with dictation. Natural-language search. Bought by Automattic in June 2025. iOS, Mac, Windows and web; no general Android release. Free to 1,000 contacts, then $10 a month. | The tone: quiet, typographic, no dashboards. Notes as the centre of a person's page |
| Covve | Mobile first. After a call made through it, it asks for a note and offers a follow-up with a reminder. Reminders every few weeks, months or quarters. Data encrypted on the device. From $12.99 a month. | The after-call prompt, which is the single most useful pattern for a salesperson |
| Cloze | History that builds itself from calls, email and meetings, and one agenda for meetings, reminders and follow-ups. | Automatic history, and one list for "what do I do today" |
| Field-sales apps (HubSpot mobile, Pipedrive, SPOTIO, Capsule) | Log a note the moment a visit ends, create the follow-up before leaving, one-tap logging, voice notes, a location check-in, working offline. | Visits as a first-class entry, note plus next step in one action |
| Folk | Light lists and pipelines on desktop. Weak on mobile. | Nothing for v2. Lists already cover grouping |

Sources are in `04-research-notes.md`.

## Where PocketCRM can be better than all of them

- **It is an Android app that reads the phone.** Calls and SMS appear in each person's history with no account, no connection to set up, and no carrier restriction. Mesh has no general Android app, Cloze's call logging depends on a few US carriers, and Covve logs only what starts inside it.
- **It can send.** Scheduled and personalised bulk SMS from the user's own SIM, with a real result for every message. Dex, Mesh and Covve remind the user to get in touch but do not send SMS from the user's own number.
- **It is private by construction.** No account, no server, and no internet permission. The others ask users to trust a cloud with their whole address book.
- **It works with no signal.** Everything is local, which matters on the road.

## Principles

1. **Ten seconds to capture.** If adding a note takes longer than writing it on paper, the app has lost.
2. **Every entry can end with a next step.** Follow-up chips sit on every capture form.
3. **The app does the logging.** The user adds meaning, never data entry.
4. **One place to look.** Today answers "what should I do now" without tapping anything.
5. **Plain words.** People, History, Follow-up, Reconnect. No leads, deals, pipelines, enrichment or threads.
6. **Honest automation.** Before sending: what, to whom, when, from which SIM. After sending: what happened, per person. Nothing is ever recorded as sent unless Android confirmed it.
7. **Quiet.** No counters for their own sake, no badges that do not need action, one accent colour used for the one thing to do next.

## What stays, changes, is added and is removed

**Stays, refined**

- Per-person history built from calls and SMS
- Notes, payments with four statuses, files and photos
- Follow-ups (today's tasks) with a due time and a reminder
- Starred people and contact lists
- Scheduled SMS to one person
- Bulk SMS to a list
- Backup and restore

**Changes**

| Today | v2 |
|---|---|
| Dashboard, Contacts, SMS Queue, Tasks | Today, People, Messages |
| Floating button, then a chooser, then a five-type form | One Add sheet. The type is a row of chips, the person is already filled in |
| Tasks tab | Follow-ups live on Today and on each person. There is no separate tab |
| Lists hidden under SMS Queue | Lists are chips on People |
| Person screen with eight stacked regions | Identity, four actions, Next, History |
| Payments guessed from SMS and saved | Amounts found in SMS become a suggestion the user confirms |
| Spam filter applied to everyone | Messages from saved people are never filtered |
| Bulk job sends identical text | Merge fields, live preview per person, pace, SIM, send window |
| "Sent" means "we tried" | Queued, sending, sent, delivered, failed with a reason, cancelled |

**Added**

- **After-call prompt.** When a call with a saved person ends, a notification and a card on Today offer "Add note" and "Follow up".
- **Visits.** A visit is an entry type with a place, a time, a note, photos and a follow-up.
- **Reconnect cadence.** Per person or per list: every week, two weeks, month, three months, six months, year. The due date moves whenever there is a real interaction.
- **System notifications** for follow-ups, reconnect nudges, send results and an optional morning summary.
- **Owes-you balance** on a person, from payment entries, with a one-tap reminder message.
- **Templates** with merge fields.
- **Per-person campaign results** with retry.
- **Setup and reliability check** that walks through the Android settings scheduled sending depends on.
- **Global support**: phone numbers for any country, currency by locale, translated strings, dark theme.

**Removed from v2**

- The two dashboard counters and the sync card (sync status moves to Settings)
- The social panel as a block on the person screen (links stay, inside the person's details)
- Timeline rows that only describe a system action ("SMS Scheduled", "Reminder Alert Triggered"). They are hidden, not deleted
- The browser prototype, moved to `legacy/`

## Not in v2

Team sharing, cloud sync, email and calendar integration, deal pipelines and forecasting, AI features that need a network, automatic reply to missed calls, multi-step drip sequences, an SMS gateway, an iOS app, a Google Play release. Each is either against the privacy promise, against platform policy, or a second product. Lists plus a person's status text cover what a solo salesperson needs from a pipeline.

## Words

| Use | Never |
|---|---|
| People, person | Contacts directory, leads |
| History | Relationship thread, timeline, interactions |
| Follow-up | Promise, task checklist |
| Reconnect | Engagement, cadence (in the interface) |
| Add | Log event |
| Message, campaign | SMS queue, bulk job |
| Not sent | Failed job |
| List | Segment, audience |
