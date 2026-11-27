# 13 Global readiness

## Goal

The app is correct and comfortable for a user anywhere: their language, their currency, their number formats, their preferred text size, a screen reader, and a dark theme.

## Steps

1. **Strings.** `flutter_localizations` and ARB files in `lib/l10n/`. English (`en`) is complete. Add Bengali (`bn`) as the second language to prove the pipeline; translate every string and mark the file as needing a native review in `DECISIONS.md`. Use ICU plurals and selects for every count ("{count, plural, one{1 follow-up} other{{count} follow-ups}}"). A test fails if any ARB key is missing from a language or if a widget contains a string literal that is shown to the user.
2. **Language setting:** System (default), English, Bengali.
3. **Formatting** through the one formatter from spec 06: dates, times (12 or 24 hour follows the system), relative times, numbers and currency all use the active locale. The week starts on the locale's first day in the date picker.
4. **Currency:** a setting holding an ISO code, initially from the device locale, with a searchable picker. New payments store the code. A person's balance is shown per currency when their payments use more than one.
5. **Phone region:** a setting, initially from the SIM country, used as the default when parsing numbers typed without a country code.
6. **Right to left:** all padding and alignment use directional values (`EdgeInsetsDirectional`, `AlignmentDirectional`, `start` and `end`). Add golden tests of Today, Person and the composer under an RTL locale with pseudo-translated text; nothing overlaps or clips, and back and chevron icons mirror.
7. **Text size:** golden tests at text scale 1.3 and 2.0 for the nine designed screens. At 2.0 rows may grow and wrap; nothing may be cut off or overflow.
8. **Screen reader:** every icon button has a label; each row reads as one sentence ("Amara Okafor, Okafor Textiles, called today"); the follow-up circle is announced as a checkbox with the follow-up's title; status is never conveyed by colour alone (the word is always present). Add semantics tests for the nine screens.
9. **Dark theme:** setting System, Light, Dark. Golden tests of the nine screens in dark. Add a unit test that computes the contrast ratio of every text colour on every background it is used on, in both modes, and fails below 4.5 to 1. If a dark pair fails, change the dark value in `app_colors.dart` and in `handover/02-design-system.md`.
10. **System behaviour:** edge-to-edge on Android 15 and later with correct insets under the navigation bar and sheets; predictive back enabled in the manifest; the keyboard never hides the focused field or a sheet's primary button; rotation is supported without losing form input.
11. **App icon and name.** Adaptive icon: `accent/default` background, a white "P" in Inter Semi Bold as the foreground, and a monochrome layer for themed icons. Generate with `flutter_launcher_icons` (dev dependency). App label "PocketCRM". Set the pubspec description to one sentence about the product.
12. **Performance pass:** start-up to first frame of Today under 1.5 seconds on a mid-range phone in release mode (measure on the emulator and record the number in `TEST-RESULTS.md`); no frame over 32 ms while scrolling People with 5,000 rows in a profile-mode integration test.

## Acceptance criteria

- The ARB completeness test and the no-literal test pass.
- All golden suites pass: light, dark, RTL, text scale 1.3 and 2.0.
- The contrast test passes for both themes.
- Semantics tests pass.

## Verify

```sh
flutter gen-l10n
tool/verify.sh
```
