# 11 Setup and reliability

## Goal

A new user gets from install to a working app in one screen, including the Android settings that scheduled sending depends on, and can prove to themselves that sending works with the app closed.

## Read first

`handover/03-screens.md` section 09, `handover/04-research-notes.md` "Distribution" and "running in the background". Figma frame `10:648`.

## Steps

1. **Setup screen** with the five rows. Each row's state comes from `OutboxApi.capabilities()` and `permission_handler`, re-read every time the app returns to the foreground, because the user leaves the app to change most of them.
2. **Contacts:** request the permission. If refused twice, the button becomes "Open settings".
3. **Calls and messages:** request call log, SMS and phone state together.
   - **Restricted settings.** On Android 13 and later, an app installed from a file is refused these permissions with no dialog. Detect it: the request returns denied immediately (under 300 ms) and the app was not installed by a store (`getInstallSourceInfo`). Then show a three-step guide in a sheet, with one line each and a button "Open app info" (`Settings.ACTION_APPLICATION_DETAILS_SETTINGS`):
     1. Tap the three dots at the top right.
     2. Tap "Allow restricted settings" and confirm with your screen lock.
     3. Come back here and tap Allow again.
   - If the menu entry is missing on the device, the guide's last line says: "No such option? Open Permissions on that page and allow SMS and Call logs there."
4. **Alarms and reminders:** open `Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM` for the package. Without it the app still works; the row's line then reads "Scheduled messages may be a few minutes late".
5. **Battery:** request `ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` for the package (add the `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission). After it is granted, if `Build.MANUFACTURER` matches a known maker, show one extra line of guidance and an "Open settings" button that opens the app's details page:

| Maker | Line |
|---|---|
| Xiaomi, Redmi, Poco | Turn on Autostart and set Battery saver to No restrictions |
| Oppo, Realme, OnePlus | Allow background activity and Auto-launch |
| Vivo, iQOO | Allow High background power consumption and Autostart |
| Samsung | Add PocketCRM to Never sleeping apps |
| Tecno, Infinix, itel | Allow Auto-start in Phone Master |
| Huawei, Honor | Set App launch to Manage manually and allow all three switches |

   These labels differ between versions and were not verified per device. Keep them as ARB strings so they are easy to correct, and list each maker in `handover/UNVERIFIED.md`.
6. **Notifications:** request the permission.
7. **Privacy note** as designed. It must stay true: the manifest check from spec 01 guards it.
8. **Continue** runs the first sync with a progress line and goes to People. "Do this later" goes to Today; a single quiet row "Finish setup" stays at the top of Today until Contacts and Calls and messages are allowed.
9. **Reliability check** in Settings, "Check setup": the same five rows, then "Send a test message". The user enters their own number (prefilled from the SIM when the phone exposes it). The app schedules "PocketCRM test, scheduled for {time}" two minutes ahead and says: "Close the app and lock your phone. The message should arrive at {time}." On the next open it reports: "Arrived on time", "Arrived {n} minutes late: allow Alarms and reminders, and check the Battery step", or "Not sent: {reason}".
10. **Degraded modes.** Every screen works with any permission missing. Without call and message access, History holds only what the user adds and a quiet line on Today offers setup. Without SMS permission the composer's send button reads "Open in your SMS app" and uses an `sms:` URI.

## Acceptance criteria

- Widget tests with faked capabilities: each row shows the right state and action; Continue is disabled until Contacts is allowed; the restricted-settings guide appears when the fake reports an instant denial and a file install.
- A test of the reliability check with a fake clock and fake outbox: on time, late and failed each produce the right sentence.
- The app can be used from first launch to adding a note with every permission denied.
- Golden test of the screen against frame `10:648`.

## Verify

```sh
tool/verify.sh
```

Emulator check: install the release APK with `adb install` on Android 13 or later, walk through setup by driving the screen with `adb shell input`, and record each row's state. An install through `adb` is not subject to restricted settings, so that guide can only be covered by the widget test; it stays in `handover/UNVERIFIED.md`.
