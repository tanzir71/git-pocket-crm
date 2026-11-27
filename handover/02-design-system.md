# 02 Design system

The design lives in Figma (`Pocket-CRM`, page "PocketCRM v2") as variables, text styles, 49 local components and nine screens. This file states the same values so the app can be built without opening Figma.

## Rules

1. **One accent, once.** `accent/default` is used for the single primary action on a screen (a filled button or the floating button), for the progress bar, and for merge fields inside message text. Nothing else.
2. **Selection is ink, not accent.** A selected chip or tab is `bg/inverse` with `text/on-inverse`.
3. **Flat lists.** Rows sit directly on `bg/canvas` with no borders, dividers or card backgrounds. A card (`bg/surface`, 1 px `border/hairline`, radius 16) is used only for something the person must answer, such as the after-call prompt.
4. **Status is text.** Status colours are used as text or as a 16 px icon. The only tinted backgrounds are the 32 px circle behind a failed send and the 28 px circle behind a completed setup step.
5. **One typeface, three weights.** Inter Regular, Medium and Semi Bold. No italics anywhere. No second family.
6. **No element is used so often that it stops meaning anything.** One card per screen at most. Chips only for filters, choices and attributes. Icons only where they carry meaning the label does not.
7. **Touch targets** are at least 48 by 48 dp even when the visible shape is smaller.
8. **Never hard-code** a colour, font size or radius in a widget. Read them from the theme.

## Colour

Light and Dark are two modes of the Figma collection `Color`.

| Token | Light | Dark | Use |
|---|---|---|---|
| `bg/canvas` | `#F7F7F5` | `#0F0F11` | Screen background |
| `bg/surface` | `#FFFFFF` | `#18181B` | Sheets, the nav bar, cards, bordered buttons |
| `bg/subtle` | `#EFEFEC` | `#232327` | Input fields, icon circles, secondary buttons, the active nav pill |
| `bg/inverse` | `#17171A` | `#F4F4F2` | Selected chip |
| `text/primary` | `#17171A` | `#F4F4F2` | Titles, body text, icons |
| `text/secondary` | `#4A4A54` | `#A9A9B2` | Supporting text, section headers |
| `text/tertiary` | `#6B6B76` | `#8A8A95` | Timestamps, placeholders, inactive nav |
| `text/on-accent` | `#FFFFFF` | `#121018` | Text and icons on the accent |
| `text/on-inverse` | `#FFFFFF` | `#17171A` | Text on a selected chip |
| `border/hairline` | `#E7E7E3` | `#2A2A2F` | 1 px borders |
| `border/strong` | `#CFCFCA` | `#3A3A41` | Unchecked follow-up circle, 1.5 px |
| `accent/default` | `#3525CD` | `#8F84FF` | Primary action |
| `accent/soft` | `#EEEDFB` | `#25224A` | Reserved. Not used on any v2 screen |
| `status/success` | `#177A4C` | `#5CC592` | Delivered, allowed |
| `status/warning` | `#9A5B00` | `#E2A93B` | Due soon. Reserved |
| `status/danger` | `#C8372D` | `#F0786E` | Overdue, failed |
| `status/success-soft` | `#E6F4EC` | `#15301F` | Circle behind a completed setup step |
| `status/warning-soft` | `#FBF0DC` | `#33270E` | Reserved |
| `status/danger-soft` | `#FBEAE8` | `#3A1A17` | Circle behind a failed send |
| `avatar/sand/bg`, `/ink` | `#EFE7DA`, `#6B5A3C` | `#3A3226`, `#E0CFAE` | Avatar tone 0 |
| `avatar/sage/bg`, `/ink` | `#E1ECE4`, `#3F6350` | `#24332A`, `#B4D3C0` | Avatar tone 1 |
| `avatar/sky/bg`, `/ink` | `#E0EAF4`, `#3C5A7A` | `#22303F`, `#B3CCE6` | Avatar tone 2 |
| `avatar/rose/bg`, `/ink` | `#F4E3E3`, `#84494B` | `#3D2728`, `#E6BDBE` | Avatar tone 3 |
| `avatar/lilac/bg`, `/ink` | `#E8E4F6`, `#55488F` | `#2C2843`, `#C9C1EE` | Avatar tone 4 |

The sheet scrim is black at 45 percent opacity in both modes.

Light-mode text colours were checked against `bg/canvas` and `bg/subtle` for a contrast ratio of at least 4.5 to 1. The dark values were chosen by the same method but have not been rendered, so check them with a golden test in spec 13 and adjust only the dark column if a pair falls short.

An avatar's tone is `contact.id % 5`. The old random `avatar_color` column is ignored.

## Type

Inter, bundled in the app. Other scripts (Bangla, Arabic, Devanagari and so on) fall back to the system font, which is the correct behaviour.

| Style | Size / line height | Weight | Letter spacing | Use |
|---|---|---|---|---|
| Display | 28 / 34 | 600 | -0.4 | Tab titles: Today, People, Messages |
| Title | 20 / 26 | 600 | -0.2 | Person name, sheet title, campaign name |
| Headline | 16 / 22 | 600 | -0.1 | Top bar title, sheet subject, summary numbers |
| Body Strong | 15 / 22 | 500 | 0 | Row titles, button labels |
| Body | 15 / 22 | 400 | 0 | Notes, message text, inputs, follow-up titles |
| Label | 13 / 18 | 500 | 0 | Section headers, chips, nav labels, small buttons |
| Caption | 12 / 16 | 400 | 0 | Metadata, timestamps, helper text |

Flutter `TextTheme` mapping: `headlineMedium` Display, `titleLarge` Title, `titleMedium` Headline, `labelLarge` Body Strong, `bodyLarge` and `bodyMedium` Body, `labelMedium` Label, `bodySmall` Caption. Text must scale with the system font size setting. Layouts are tested at 1.0 and 1.3.

## Space, radius, elevation

- Spacing scale: 4, 8, 12, 16, 20, 24, 32. Screen side padding is 20.
- Radius: 8 small, 10 small buttons, 12 controls and fields, 16 cards and the floating button, 28 the top corners of a sheet, full for chips and avatars.
- Elevation: none, except the floating button (shadow y 4, blur 12, black 18 percent) and sheets (scrim only).

## Components

Names match the Figma components in frame `5:2`.

| Component | Spec |
|---|---|
| Status bar | System. Draw edge to edge, transparent, icons follow the theme |
| Nav bar | Height 80 including 18 bottom inset, `bg/surface`, 1 px top hairline. Three destinations: Today, People, Messages. Active: 56 by 30 pill in `bg/subtle`, icon and Label in `text/primary`. Inactive: `text/tertiary`, no pill. Use `NavigationBar` themed to match |
| Button / Primary | Height 48, radius 12, `accent/default`, Body Strong in `text/on-accent`. Full width at the bottom of a sheet or form |
| Button / Secondary | Same shape, `bg/subtle`, `text/primary` |
| Button / Quiet | No fill, `text/secondary` |
| Button / Small Primary, Small Secondary, Small Quiet | Height 36, radius 10, Label text, horizontal padding 14 (8 for quiet) |
| Chip / Default | Height 32, full radius, `bg/surface`, 1 px hairline, Label in `text/secondary`, horizontal padding 12 |
| Chip / Selected | `bg/inverse`, Label in `text/on-inverse`, no border |
| Avatar | 40 circle, initials in Label, tone colours. 56 on the person screen |
| FAB | 56 square, radius 16, `accent/default`, 24 icon, 20 from the right edge, 16 above the nav bar |
| Section header | Label in `text/secondary`, padding 20 left and right, 20 top, 6 bottom. Text is "Follow-ups · 3": name, middle dot, count |
| Row / Person | Padding 20 by 10, gap 12. Avatar, then Body Strong title and Caption meta (one line each, truncated), then a Caption trailing value in `text/tertiary` |
| Row / Task | Padding 20 by 10, gap 12. A 22 circle with a 1.5 px `border/strong` outline, then Body title (two lines at most) and Caption meta. Overdue meta is `status/danger` |
| Row / Event | Padding 20 by 10, gap 12, top aligned. A 32 circle in `bg/subtle` with a 16 icon, then Body Strong title, Body text in `text/secondary` (three lines at most), Caption time in `text/tertiary` |
| Row / Setting | Padding 20 by 14. Body label, Body value in `text/secondary`, 16 chevron |
| Field | `bg/subtle`, radius 12, height 48 for one line, padding 14. No border, no floating label. The label, when needed, is a Label line above the field |
| Sheet | `bg/surface`, top radius 28, padding 20 sides, 12 top, 28 bottom, 16 between blocks. A 36 by 4 handle in `bg/subtle`. Scrim behind |
| Prompt card | `bg/surface`, 1 px hairline, radius 16, padding 16, gap 14 |

## Icons

Figma uses 24 px outline icons with a 1.75 px stroke. In Flutter use the built-in outlined Material icons so no icon package is needed.

| Figma | Flutter `Icons.` |
|---|---|
| sun | `wb_sunny_outlined` |
| users | `people_outline` |
| send | `send_outlined` |
| plus | `add` |
| search | `search` |
| sliders | `tune` |
| user-plus | `person_add_alt_1_outlined` |
| phone | `call_outlined` |
| message | `chat_bubble_outline` |
| chat | `forum_outlined` (WhatsApp action; do not use the WhatsApp logo) |
| pen | `edit_outlined` |
| map-pin | `place_outlined` |
| clock | `schedule` |
| banknote | `payments_outlined` |
| note | `description_outlined` |
| paperclip | `attach_file` |
| camera | `photo_camera_outlined` |
| mic | `mic_none` |
| star | `star_border` and `star` when on |
| more | `more_vert` |
| arrow-left | `arrow_back` |
| x | `close` |
| check | `check` |
| chevron-right, chevron-down | `chevron_right`, `expand_more` |
| alert | `error_outline` |
| bell | `notifications_none` |
| lock | `lock_outline` |
| pause | `pause` |
| calendar | `calendar_today_outlined` |

## Landing page

The landing page (Figma frames `14:586` and `14:856`, images in `handover/design/landing/`) uses the same colour tokens, the same buttons and the same typeface. It adds five text styles, named `Web / ...` in Figma:

| Style | Size / line height | Weight | Letter spacing |
|---|---|---|---|
| Web / Hero | 56 / 60 | 600 | -1.4 |
| Web / H2 | 36 / 42 | 600 | -0.7 |
| Web / H2 Small | 26 / 32 | 600 | -0.4 |
| Web / Lead | 19 / 30 | 400 | -0.1 |
| Web / Lead Small | 17 / 26 | 400 | 0 |

Its rules are the app's: one accent per view, flat rows separated by hairlines, no cards except the one note in Install, no icons used as decoration, real screens as the only imagery. The full specification is `specs/15-landing-page.md`.

## Motion

- Sheets slide up over 250 ms with a decelerate curve and dismiss by drag or back.
- Checking a follow-up fills the circle, strikes the title, and removes the row after 600 ms with a snackbar that offers Undo for 5 seconds.
- Lists never show a full-screen spinner. Data comes from database streams, so a screen shows its last known content at once. The first load ever shows three placeholder rows.
- Respect the system "remove animations" setting.

## Writing

Sentence case everywhere. No exclamation marks. Say what happened and what to do: "Not sent to Daniel Reyes. No service." with a Retry button. Dates are relative within a week ("Today 10:12", "Monday", "Friday 09:00") and absolute after that ("23 November"). Durations read "4 min". Numbers, dates and currency are formatted by locale.
