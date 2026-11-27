# 04 App shell

## Goal

The new three-tab shell, routing and state management, behind a switch. The old interface stays the default until spec 10.

## Decisions

- **State:** `flutter_riverpod` with hand-written providers. No code generator for providers. Screens read drift streams through `StreamProvider`, so there are no polling timers and no manual refresh calls.
- **Routing:** `go_router` with a `StatefulShellRoute.indexedStack` for the three tabs.
- **Switch:** `const bool kV2 = bool.fromEnvironment('V2', defaultValue: false);`. With `--dart-define=V2=true` the app starts in the new shell. Without it, it starts the old `HomeScreen`. Spec 10 changes the default to true and deletes the old screens. Every spec before that must leave both modes building and running.
- **Folders:**

```
lib/app.dart                      MaterialApp.router, themes, localisation
lib/core/{db,theme,widgets,native,phone,format}/
lib/features/today/{data,ui}/
lib/features/people/{data,ui}/
lib/features/capture/{data,ui}/
lib/features/followups/{data,ui}/
lib/features/messages/{data,ui}/
lib/features/setup/ui/
lib/features/settings/{data,ui}/
lib/legacy/                       the four old screens, moved here unchanged
```

## Steps

1. Add the two packages. Move `lib/screens/*` to `lib/legacy/` and fix imports.
2. Routes: `/today`, `/people`, `/people/:id`, `/messages`, `/messages/new`, `/messages/campaign/:id`, `/messages/sent`, `/messages/templates/:id`, `/setup`, `/settings`, `/settings/backup`, `/dev/gallery` (debug only). Unknown routes go to `/today`. Deep link scheme `pocketcrm://` is registered for `after-call` and `person/:id` (used by notifications in specs 07 and 08).
3. The shell: `Scaffold` with the themed `NavigationBar` (Today, People, Messages). Each tab keeps its own navigation stack and scroll position. Detail routes (`/people/:id`, composer, campaign, setup, settings) cover the navigation bar.
4. Each tab shows its header (title in Display) and an `EmptyState` saying which spec fills it. This is the only placeholder content allowed, and it is gone by spec 10.
5. System back: use `PopScope`. Back from a tab root on People or Messages returns to Today; back on Today leaves the app.
6. App start: when `kV2` is true and no contact exists, go to `/setup`.
7. Provide the database, repositories and a clock as providers, so tests can override them.

## Acceptance criteria

- `flutter run` opens the old app. `flutter run --dart-define=V2=true` opens the new shell on Today.
- Switching tabs keeps each tab's state and shows no spinner.
- A widget test pumps the shell with an in-memory database, taps each destination and finds its title.
- A test asserts both modes build: one test file per mode with the define set in `flutter test --dart-define`.

## Verify

```sh
tool/verify.sh && flutter test --dart-define=V2=true
```
