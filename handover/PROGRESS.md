# Progress

Milestone-by-milestone log of what shipped, key decisions, and what remains unverified.

## 2026-11-27 — M0: Open the repository

### What shipped
- Audited full git history and working tree for secrets, keystores, and real personal data; none found.
- Added secret and signing-file exclusions (`*.jks`, `*.keystore`, `key.properties`, `.env*`, `local.properties`) to `.gitignore`.
- Committed the v2 handover documents and specs on `main`.
- Changed `tanzir71/git-pocket-crm` repository visibility to `PUBLIC`, updated description, homepage (`https://tanzir71.github.io/git-pocket-crm/`), and topics (`android`, `flutter`, `personal-crm`, `local-first`, `sms`).
- Disabled GitHub Actions for the repository so all checks run locally via `tool/verify.sh`.
- Initialised `handover/PROGRESS.md`, `handover/DECISIONS.md`, `handover/TEST-RESULTS.md`, `handover/UNVERIFIED.md`, `handover/BLOCKED.md`, and `CHANGELOG.md`.

### What was decided
- Kept repository without a licence file per project rules.

### What is in UNVERIFIED.md
- Permanent device/network items that cannot be verified on an emulator: real mobile network behaviour, dual-SIM selection, Android "Allow restricted settings" sideload flow, and per-maker battery management.

## In progress — M1: Foundation

- **Spec 01 (2026-11-27):** Upgraded toolchain (Flutter 3.50.1 / Dart 3.14.0, `material_ui`, Gradle 9.5.0, AGP 9.3.1, Kotlin 2.4.20, compileSdk 37), moved browser prototype to `legacy/web-prototype/`, added legacy characterisation tests and SMS stopgap, added `tool/verify.sh`, `tool/check_manifest.sh`, and `tool/build_apk.sh`. Generated release signing key outside the repository at `~/.pocketcrm/pocketcrm-release.jks` with properties at `~/.pocketcrm/key.properties` (password not recorded).

