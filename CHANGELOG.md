# Changelog

All notable changes to PocketCRM are documented in this file.

## Milestone 1: Foundation (2026-11-27)

- Fixed scheduled SMS sending on Android 6 through 11, and stopped failed sends from being recorded as sent.
- Upgraded the app database safely (with an automatic backup before migrating) so contacts, history, tasks, lists, and payments carry forward without losing data.
- Bundled the Inter font inside the app so typography works completely offline without needing internet access.
- Removed the unused contacts-write permission and verified the release build has no internet permission.
- Published the PocketCRM landing page on GitHub Pages.

## Milestone 0: Open the repository (2026-11-27)

- Made the PocketCRM repository public on GitHub and added the v2 design and implementation handover.
