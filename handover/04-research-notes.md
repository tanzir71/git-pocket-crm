# 04 Research notes

Gathered on 26 November 2026. Each item says how well it is supported. "Primary" means an official page was read. "Secondary" means trade press, vendor blogs or issue trackers. "Unverified" means it is stated from general knowledge and must be checked before you rely on it.

## Android: sending SMS

| Fact | Support |
|---|---|
| `SmsManager.getDefault()` and `getSmsManagerForSubscriptionId()` are deprecated from API 31 in favour of `Context.getSystemService(SmsManager.class)` and `createForSubscriptionId(subId)`, which was added in API 31. | Primary: https://developer.android.com/reference/android/telephony/SmsManager |
| On devices below API 31, `getSystemService(SmsManager::class.java)` returns null. The Android page does not say this in words, but it is reported in practice (a Galaxy S9+ on Android 9) and fixed by using `getDefault()`. | Secondary: https://github.com/shounakmulay/Telephony/issues/183 |
| Android limits outgoing SMS per app. AOSP's `SmsUsageMonitor` allows 30 messages per check period. On the current main branch the period is 60,000 ms; older branches use 1,800,000 ms (30 minutes); before that the default was 100 an hour. Over the limit the system asks the user to confirm. Each part of a multi-part message counts. The default SMS app is exempt. Device makers can change both values. | Primary: https://android.googlesource.com/platform/frameworks/opt/telephony/+/master/src/java/com/android/internal/telephony/SmsUsageMonitor.java |
| A message sent through `SmsManager` by an app that is not the default SMS app is written to the system Sent folder by the platform (since Android 4.4). | Unverified in this pass. Spec 09 checks it on an emulator and handles both cases |
| Result codes arrive through the sent `PendingIntent` (`Activity.RESULT_OK`, `RESULT_ERROR_GENERIC_FAILURE` 1, `RESULT_ERROR_RADIO_OFF` 2, `RESULT_ERROR_NULL_PDU` 3, `RESULT_ERROR_NO_SERVICE` 4, `RESULT_ERROR_LIMIT_EXCEEDED` 5, and newer codes). | Unverified numbering; read the constants from the SDK, do not hard-code these numbers |

Consequence for pacing: the default is one message every 4 seconds, which stays under 30 a minute, and a "Careful" pace of one a minute exists for phones that still use the 30-minute window.

## Android: running in the background

| Fact | Support |
|---|---|
| On Android 14 and later, `SCHEDULE_EXACT_ALARM` is denied by default for newly installed apps that target Android 13 or higher. The user grants it on the "Alarms and reminders" page. | Primary: https://developer.android.com/about/versions/14/changes/schedule-exact-alarms |
| `USE_EXACT_ALARM` is for calendar and alarm-clock apps and is restricted on Google Play. | Primary, same page |
| On Android 15, foreground services of type `dataSync` may run for 6 hours in total per 24 hours. Then `onTimeout()` is called. `shortService` runs for about 3 minutes. | Primary, as read in the research pass: the Android 15 behaviour changes and the "Foreground service types" page on developer.android.com. The exact links were not kept; find them by title |
| Device makers (Xiaomi, Realme, Oppo, Vivo, Tecno, Infinix and others) stop background apps more aggressively than stock Android. | Unverified per maker. The labels in `specs/11` are a starting point; see https://dontkillmyapp.com |

## Distribution

| Fact | Support |
|---|---|
| Google Play only allows the SMS and Call Log permission groups for apps that are the default SMS, Phone or Assistant handler, or that fit a listed exception. "SMS and contacts management" by a non-default app is listed as not allowed. A personal CRM that reads SMS and call logs and sends bulk SMS does not qualify. | Primary: https://support.google.com/googleplay/android-developer/answer/10208820 |
| Therefore the app is distributed as an APK outside Play (GitHub Releases, optionally tracked with Obtainium). | Decision |
| Android developer verification began on 30 September 2026 for Brazil, Indonesia, Singapore and Thailand. Google has said a global rollout starts in January 2027 with seven distributors and then extends to all countries and install sources. A free limited-distribution account exists for small audiences (reported as up to 50 devices). | Primary for the programme: https://developer.android.com/developer-verification/guides. The dates and the device limit come from a Google blog post reported in the research pass; confirm them on that page |
| From Android 13, an app installed from a file cannot be granted SMS permissions until the user turns on "Allow restricted settings" in App info. Some Xiaomi users report the menu entry is missing. | Secondary: https://textbee.dev/blog/android-15-send-sms-permission-guide and MIT App Inventor forum threads |

## GitHub Pages

| Fact | Support |
|---|---|
| A Pages site can be published from the `/docs` folder of a branch; every push to that branch republishes it. | Primary: https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site |
| Since GitHub retired its older Pages build system on 30 June 2024, publishing from a branch needs GitHub Actions to be enabled unless the folder contains a `.nojekyll` file, in which case the files are served as they are. | Primary: https://github.blog/changelog/2024-07-08-pages-legacy-worker-sunset |
| GitHub Pages on a private repository needs a paid plan, which is why the repository is made public first. | Unverified in this pass; the spec makes the repository public regardless |

## Bangladesh

All secondary (aggregator and vendor pages, not a BTRC document): application-to-person SMS is meant to go through BTRC-listed aggregators; promotional SMS must be in Bangla; a national do-not-disturb list exists; vendors state promotional sending is limited to 09:00 to 21:00. Sources: https://www.mimsms.com/all-types-of-bulk-sms-have-to-be-sent-in-bengali, https://www.dianahost.com/a2p-bulk-sms-prohibited-content-bangladesh/, https://gotisms.com/blog/bulk-sms-service-bangladesh-guide.

Consequence: bulk sending is presented as personal messages to people the user knows (reminders, thanks, dues), the default send window is 09:00 to 21:00 local time, and people can opt out. An SMS gateway is out of scope.

## Flutter and packages

Versions as read from pub.dev in the research pass. Confirm with `flutter pub outdated`.

| Item | Finding | Decision |
|---|---|---|
| Flutter / Dart | 3.50 / 3.14 stable since 11 November 2026 (secondary: release write-ups). Several write-ups say `material.dart` is deprecated in favour of a standalone `material_ui` package with a `dart fix` migration. | Use the newest stable. Check the official release notes before applying that migration |
| `drift` | 2.34.x, `drift_dev` 2.35.x | Adopt. Typed queries, streams, migrations |
| `sqlite3_flutter_libs` | Marked end of life | Do not add. Follow drift's current setup guide for the native library |
| `flutter_riverpod` | 3.5.0 | Adopt, hand-written providers |
| `go_router` | 18.x | Adopt |
| `flutter_contacts` | 2.6.0, a rewrite with change listeners and vCard | Upgrade |
| `permission_handler` | 13.0.2, needs compileSdk 37; `status` no longer reports permanently denied on Android | Upgrade |
| `flutter_local_notifications` | 23.0.4 | Adopt |
| `workmanager` (Flutter) | 0.10.10 | Not used. Background work is native Kotlin |
| `phone_numbers_parser` | 9.0.x, throws on invalid or over-long input | Adopt, catch the exceptions |
| `flutter_sms_inbox` | 1.0.5, query caps reported | Replace with the Kotlin reader in `specs/05` |
| `call_log` | 6.0.1, more than a year old | Replace with the same reader |
| `another_telephony`, `telephony` | Stale, with the SmsManager error on API 30 and below | Do not use |
| `file_picker` | 13.x, breaking changes in 12 and 13 | Upgrade for picking attachments only |
| `google_fonts` | 9.0.0 | Remove. Bundle Inter |
| `archive`, `cryptography` | 4.6.0, 2.9.0 | Adopt for backups |
| `csv` | 8.0.0 with breaking changes | Upgrade only if still used after `specs/12` |

## The implementing model

"Gemini Neon" is reported as Gemini 4 Neon, a Google model released on 18 November 2026 with a 1M-token context, available in the Gemini app, AI Studio, the API and Antigravity (secondary: https://www.testingcatalog.com/google-launches-gemini-4-neon-on-gemini-antigravity-and-apis/ and a Google for Developers post). It is a model, so what it can run depends on the tool hosting it. Which instruction file each host reads was not confirmed, so both `AGENTS.md` and `GEMINI.md` are provided.

## Products compared

- Dex: https://getdex.com/ and its comparison pages. Reminders with a cadence worked out from the last interaction, group cadences, notes, quick add, a daily agenda on mobile, integrations, $12, $20 and $40 a month.
- Mesh, formerly Clay: https://me.sh/, the App Store listing, https://techcrunch.com/2025/06/12/automattic-acquires-relationship-manager-clay-to-add-an-identity-layer-to-online-tools/. Home feed, reconnect prompts, notes with dictation, natural-language search, groups. One listing reports an Android beta; a Dex review from April 2026 says there is no Android app.
- Covve: https://help.covve.com/help/comms-your-personal-crm and store listings. Prompts for a note after a call made in the app and offers a follow-up with a reminder.
- Cloze: store listings. Automatic logging and one agenda.
- Field sales: https://blog.hubspot.com/sales/mobile-crm-solutions, https://spotio.com/blog/sales-tracking-apps/, https://capsulecrm.com/blog/best-mobile-crm/, https://pipedrive.com/en/blog/field-sales-software.

## Not researched

On-device AI (Gemini Nano through ML Kit, Bangla support), mobile-money SMS formats, gateway prices, per-maker battery settings, Material 3 Expressive support in Flutter, and the current Google Play target-API deadline. None of them blocks v2.
