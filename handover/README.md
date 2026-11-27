# PocketCRM v2 handover

Written 26 November 2026 from a read of the code, a research pass, and a new design in Figma. Start with `AGENTS.md` in the repository root.

## The short version

- The app today works as a manual tracker but its automation does not. Scheduled and bulk SMS only send while the app is open, failures are recorded as sent, and the native send call fails on Android 6 to 11. Details: `00-current-state.md`.
- The product is being refocused on one loop: something happens with a person (a call, a visit, a message), you note it in seconds, you set the next step, and the app brings it back at the right time. Details: `01-product-direction.md`.
- The interface goes from four tabs and thirteen bottom sheets to three tabs and one Add sheet. The design is in Figma, written out in `02-design-system.md` and `03-screens.md`, and exported as images in `design/`.
- SMS sending moves to a native Android pipeline that works with the app closed and reports the real result of every message. Details: `specs/09` and `specs/10`.
- The repository becomes public and gets a landing page on GitHub Pages. Details: `specs/00` and `specs/15`.

## How it is delivered

Direct commits to `main`, pushed after every spec, in six milestones. No branches, no GitHub Actions, and no testing by the owner. The rules are in `AGENTS.md`.

| Milestone | Specs | What exists at the end | Published as |
|---|---|---|---|
| M0 Open | 00 | The repository is public and holds this handover | tag `m0` |
| M1 Foundation | 01, 02, 03, 15 part A | Current toolchain, a safe typed data layer on the existing data, the design system as code, and the landing page live in its "being built" state | tag `m1`, pre-release with `PocketCRM.apk` |
| M2 Everyday workflow | 04, 05, 06, 07, 08 | Today, People, Person, the Add sheet, the after-call prompt, follow-ups, reconnect and notifications, behind a switch | tag `m2`, pre-release |
| M3 Automation | 09, 10, 11 | SMS that sends with the app closed, personalised bulk messages, the new interface as the default, and setup | tag `m3`, pre-release |
| M4 Trust and reach | 12, 13 | Complete encrypted backups, export, languages, currency, accessibility, dark theme | tag `m4`, pre-release |
| M5 Launch | 14, 15 part B | Signed version 2.0.0 and the landing page with a working download | tags `m5` and `v2.0.0`, full release |

The old interface stays the default until the end of spec 10. From spec 04 the new one runs with `--dart-define=V2=true`, and the M2 pre-release is built that way. Spec 10 makes it the default and deletes the old screens. So if work stops at any milestone, `main` still builds and runs.

## Files

| File | What it is |
|---|---|
| `00-current-state.md` | Audit of the code as it is now, with file and line references |
| `01-product-direction.md` | Users, positioning, what was learned from Dex, Mesh (formerly Clay), Covve, Cloze and field-sales apps, and the resulting feature set |
| `02-design-system.md` | Tokens, type, components and rules, with Figma node links |
| `03-screens.md` | Every app screen: layout, content, states and behaviour |
| `04-research-notes.md` | Platform and package facts with sources, and what is still unverified |
| `design/` | PNG exports of every Figma frame, for building without Figma access |
| `OWNER-NOTES.md` | Information for the owner. It contains no tasks |
| `specs/00` to `specs/15` | The work |

Files the agent creates and keeps current: `DECISIONS.md`, `PROGRESS.md`, `TEST-RESULTS.md`, `UNVERIFIED.md`, `BLOCKED.md`.

## Specs

| Spec | Outcome | Depends on |
|---|---|---|
| 00 Open the repository | Public repository, handover committed | none |
| 01 Toolchain and safety net | Current toolchain, local verify script, signing key, a stopgap that stops false "sent" records | 00 |
| 02 Data layer | drift database on the existing file, schema v5, nothing lost | 01 |
| 03 Theme and components | Tokens, bundled font, the component set from Figma | 01 |
| 04 App shell | Three tabs, routing, state management | 02, 03 |
| 05 Sync | Fast incremental call and SMS sync, global phone numbers, spam fix | 02 |
| 06 People and Person | The list and the person screen | 04, 05 |
| 07 Add and after-call | One capture sheet, call and visit notes, follow-ups | 06 |
| 08 Today and reminders | The Today feed, stay-in-touch cadence, notifications | 07 |
| 09 Native outbox | SMS that sends when the app is closed and reports real results | 02 |
| 10 Bulk messages | Composer, merge fields, paced campaigns, per-person results, cut-over | 08, 09 |
| 11 Setup | Permissions, restricted settings, battery, a reliability check | 09 |
| 12 Backup and export | Complete encrypted backups, CSV and vCard | 02 |
| 13 Global readiness | Languages, currency, accessibility, dark theme | 08, 10 |
| 14 Release | Signed 2.0.0 published from this machine | all app specs |
| 15 Landing page | Static page on GitHub Pages; part A in M1, part B in M5 | 00, 01 for A; 14 for B |

## Design

Figma file: https://www.figma.com/design/spEL8Dv1oSDsZRzuKA3N81/Pocket-CRM

| Frame | Node | Image |
|---|---|---|
| 01 Today | `7:30` | `design/screens/01-today.png` |
| 02 After-call note | `7:132` | `design/screens/02-after-call-note.png` |
| 03 People | `7:210` | `design/screens/03-people.png` |
| 04 Person | `9:261` | `design/screens/04-person.png` |
| 05 Add visit | `9:369` | `design/screens/05-add-visit.png` |
| 06 Messages | `9:471` | `design/screens/06-messages.png` |
| 07 New message | `10:498` | `design/screens/07-new-message.png` |
| 08 Campaign progress | `10:556` | `design/screens/08-campaign-progress.png` |
| 09 Setup | `10:648` | `design/screens/09-setup.png` |
| Components | `5:2` | `design/components.png` |
| Foundations | `10:706` | `design/foundations.png` |
| 10 Landing page, desktop | `14:586` | `design/landing/landing-desktop.png` |
| 11 Landing page, mobile | `14:856` | `design/landing/landing-mobile.png` |

Screen images are exported at twice their size (824 by 1834 for a 412 by 917 frame). The three `design/landing/phone-*.png` files are the phone visuals for the landing page at three times their size, with transparent corners.

A node opens at `https://www.figma.com/design/spEL8Dv1oSDsZRzuKA3N81/Pocket-CRM?node-id=7-30` (replace the colon with a hyphen). The markdown is the source of truth if it ever differs from Figma or from an image.
