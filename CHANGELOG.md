# Changelog

All notable changes to PocketCRM are documented in this file.

## Milestone 3: Reliable scheduled and bulk messaging (2026-11-27)

- New native Android SMS outbox so scheduled and bulk messages send reliably even when PocketCRM is closed, the phone is idle, or after a restart, with automatic retries on temporary signal loss and send-window support.
- New Messages tab, New message composer with reusable templates and live personalised preview (`{first_name}`, `{full_name}`, `{company}`, `{balance}`, `{city}`), live SMS/character counter, dual-SIM selector, Slow/Steady/Fast sending paces, and live Campaign progress screen with Pause, Resume, Stop, Retry failed, and CSV export.
- Automatic opt-out detection when a contact replies STOP, UNSUBSCRIBE, or বন্ধ so future bulk messages skip them automatically.
- Completed the move to PocketCRM v2 as the default app and removed the legacy v1 screens while carrying forward existing contacts, history, tasks, and pending scheduled messages.
- New Setup screen guiding Contacts, Calls and messages (including Android 13+ restricted settings instructions), Alarms and reminders, Battery (with manufacturer tips), and Notifications, plus a "Check setup" 2-minute self-test in Settings and full support for using PocketCRM with any or all permissions turned off.

## Milestone 2: Everyday workflow (2026-11-27)

- New Today screen showing recent unreviewed calls to note, due and overdue follow-ups, people due to reconnect with, scheduled messages going out today, and upcoming birthdays.
- New People directory and Person screen with fast search (including partial phone numbers), Starred / Due to reconnect / Owes me / custom list filters, duplicate contact merging, paged history grouped by month, and one-tap Call, Message, WhatsApp, and Note actions.
- Fast international call, SMS, and contact sync that keeps all messages from saved contacts (never filtering them out as spam) and highlights amounts mentioned in messages as suggestions to confirm or dismiss instead of auto-recording payments.
- New unified Add sheet for notes, calls, visits (with photos and optional coarse coordinates), follow-ups, payments, and files, plus an After-call note sheet and after-call notification when a call ends.
- Follow-up reminder notifications with Done and Tomorrow actions and an optional daily morning summary that survive idle mode and phone restarts.

## Milestone 1: Foundation (2026-11-27)

- Fixed scheduled SMS sending on Android 6 through 11, and stopped failed sends from being recorded as sent.
- Upgraded the app database safely (with an automatic backup before migrating) so contacts, history, tasks, lists, and payments carry forward without losing data.
- Bundled the Inter font inside the app so typography works completely offline without needing internet access.
- Removed the unused contacts-write permission and verified the release build has no internet permission.
- Published the PocketCRM landing page on GitHub Pages.

## Milestone 0: Open the repository (2026-11-27)

- Made the PocketCRM repository public on GitHub and added the v2 design and implementation handover.
