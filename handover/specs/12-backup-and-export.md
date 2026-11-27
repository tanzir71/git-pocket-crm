# 12 Backup and export

## Goal

A backup holds everything, can be protected with a passphrase, is saved wherever the user chooses, and restores completely. People and history can be exported to open formats.

## Read first

`lib/legacy/backup_screen.dart` as it was before deletion (git history) for the old JSON format, which must still import.

## Decisions

- **Format:** a single file `PocketCRM {yyyy-MM-dd}.pcrm`. It is a zip holding `manifest.json` (format version, app version, schema version, created time, row counts per table, whether attachments are included), `db.sqlite` (made with `VACUUM INTO` so it is a consistent copy), `outbox.json` (the native outbox rows, from `changesSince(0)`), and `attachments/`.
- **Passphrase (optional):** the zip is encrypted as one blob with AES-256-GCM. The key comes from the passphrase with Argon2id if the `cryptography` package provides it on Android, otherwise PBKDF2-HMAC-SHA256 with at least 600,000 iterations. File layout: the ASCII magic `PCRM1`, one byte for the key-derivation method, the salt, the nonce, then the ciphertext and tag. A plain backup is the bare zip.
- **Saving and opening use the Storage Access Framework** through a small Pigeon bridge that streams between a file in the app cache and a content URI, so large backups never sit in memory: `createDocument(name, mime)` returns a URI, `copyFileToUri(path, uri)`, `pickDocument(mimeTypes)` copies the picked file into the cache and returns its path. No storage permission is requested anywhere in the app.

## Steps

1. **Backup screen** (`/settings/backup`): last backup time; "Back up now" with a switch "Include photos and files" (on) and "Protect with a passphrase" (off; when on, two fields and the sentence "If you forget this passphrase the backup cannot be opened."); "Restore from a backup"; "Automatic backups" row.
2. **Create:** build in the cache directory, show progress by stage, save through the bridge, delete the cache copy, record the time.
3. **Restore:** pick a file; detect plain, encrypted or old JSON; ask for the passphrase if needed (a wrong one says "That passphrase does not open this backup"); read the manifest and show what it holds ("412 people, 9,300 history entries, 31 files, from 12 November"); ask "Replace everything on this phone with this backup?". Then: copy the current database to `pocket_crm.before-restore.bak`, close the database, replace the file and attachments, reopen (migrations run if the backup is from an older schema), and send queued outbox rows to the native side again. Scheduled messages whose time has passed become missed.
4. **Old JSON backups** (`pocket_crm_backup.json`, version 1) import in merge mode using the same matching rules the old screen used: contacts by phone number, timeline by native id or by contact, type and timestamp, tasks by contact, title and due date.
5. **Automatic backups:** weekly, plain, without attachments, into the app's own external files directory, keeping the last four. Explain on the screen: "Kept on this phone and removed if the app is uninstalled. Save a backup elsewhere now and then." Run it from the app's start-up path when the last one is older than seven days; no background job is needed.
6. **Android backup rules:** add `dataExtractionRules` that exclude the database and attachments from cloud backup and include them in device-to-device transfer.
7. **Export** (Settings, Data): "People as CSV" (name, numbers, company, role, city, email, lists, last contact, balance), "People as vCard" (through `flutter_contacts` if it offers export, otherwise write vCard 3.0 by hand), and on a person's menu "Export history as CSV". All go through the bridge or the share sheet.
8. Delete every use of `Permission.storage` and every hard-coded `/storage/emulated/0` path.

## Acceptance criteria

- Round-trip test: fill a database with every table populated and three attachment files, back up with a passphrase, wipe, restore, and compare every table row for row and every file byte for byte.
- A backup made at schema v5 restores correctly after the schema has moved on (simulate with a v5 fixture file and the current code).
- A wrong passphrase and a truncated file both fail with a clear message and leave the current data untouched.
- An old JSON fixture imports without duplicates when imported twice.
- `grep -R "Permission.storage\|/storage/emulated" lib` finds nothing.

## Verify

```sh
tool/verify.sh
```
