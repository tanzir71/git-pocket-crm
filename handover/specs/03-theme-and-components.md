# 03 Theme and components

## Goal

The design system from `handover/02-design-system.md` as Flutter code: tokens, light and dark themes, the bundled font, and one widget per Figma component, each with a golden test. No screen uses them yet.

## Read first

`handover/02-design-system.md` in full. Figma frames `5:2` (Components) and `10:706` (Foundations) if you have access.

## Steps

1. **Font.** Add `Inter-Regular.ttf`, `Inter-Medium.ttf` and `Inter-SemiBold.ttf` to `assets/fonts/` from the Inter release on GitHub (SIL Open Font License; add the licence file beside them and to the licence registry). Declare the family in `pubspec.yaml`. If you cannot download them, write that in `BLOCKED.md`, use the default font family for now, and continue.
2. **Tokens.** `lib/core/theme/tokens.dart`: constants for spacing, radius and durations. `lib/core/theme/app_colors.dart`: a `ThemeExtension<AppColors>` holding every colour in the table, with `light` and `dark` instances. `lib/core/theme/app_theme.dart`: `ThemeData` for both modes.
   - Build `ColorScheme` explicitly, not from a seed: `primary` accent/default, `onPrimary` text/on-accent, `surface` bg/canvas, `surfaceContainerLowest` bg/surface, `surfaceContainerHigh` bg/subtle, `onSurface` text/primary, `onSurfaceVariant` text/secondary, `outline` border/strong, `outlineVariant` border/hairline, `error` status/danger, `inverseSurface` bg/inverse, `onInverseSurface` text/on-inverse.
   - `TextTheme` as mapped in the design file. No `FontStyle.italic` anywhere.
   - Component themes so stock widgets match: `NavigationBarThemeData` (height 80, indicator bg/subtle, label styles), `FilledButtonThemeData`, `BottomSheetThemeData` (bg/surface, top radius 28, scrim black at 45 percent), `InputDecorationTheme` (filled bg/subtle, radius 12, no border), `SnackBarThemeData` (floating, bg/inverse), `DividerThemeData`.
   - Draw edge to edge. Status and navigation bar icons follow the theme brightness.
3. **Widgets** in `lib/core/widgets/`, one file each, with no data access: `AppButton` (primary, secondary, quiet; regular and small), `AppChip` (default, selected, optional leading icon), `Avatar` (sizes 40 and 56, tone from an integer), `SectionHeader`, `PersonRow`, `TaskRow`, `EventRow`, `SettingRow`, `AppField` (one line and multi-line, optional trailing icon button), `PromptCard`, `AppFab`, `EmptyState`, `showAppSheet` (handle, padding, pinned bottom button, keyboard inset), `StatusText` (maps a message state to its label and colour).
   - Every tappable widget has a minimum tap area of 48 by 48 and a semantic label.
   - Rows truncate as specified and never overflow at text scale 1.3.
4. **Gallery.** A debug-only route `/dev/gallery` that shows every widget in both themes. It is the reference when comparing with Figma.
5. **Golden tests** in `test/golden/` for each widget: light and dark, text scale 1.0 and 1.3, at a width of 412. Load the bundled font in the test setup so text renders.
6. **Lint guard.** Add a test that scans `lib/features` and `lib/core/widgets` and fails if it finds `Color(0x`, `Colors.` (other than `Colors.transparent`), `FontStyle.italic`, `GoogleFonts.` or `withOpacity(`.

## Acceptance criteria

- The gallery matches the Figma components for size, radius, padding and colour. Check five measurements per component against `02-design-system.md` in widget tests (for example the primary button is 48 high with a 12 radius).
- Golden tests pass in both themes.
- The lint guard passes.

## Verify

```sh
tool/verify.sh
```

## Out of scope

Using the widgets on real screens. Removing `google_fonts` (it leaves with the old screens in spec 10).
