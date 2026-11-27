# Unverified

Plain statements of fact for behaviours that cannot be verified automatically or on an emulator on this machine.

## Permanent (cannot be shown on an emulator)

- Behaviour on a real mobile network (operator filtering, carrier rate limits, and real delivery reports).
- Dual-SIM selection on multi-SIM physical hardware.
- The Android "Allow restricted settings" flow for an APK installed from a file.
- Per-manufacturer battery management screens and background process policies (Xiaomi, Realme, Oppo, Vivo, Samsung, Tecno, Infinix, and others).

## Spec 09 — Native outbox

- Cross-emulator radio forwarding from `Pixel_8` (Android 14 API 34 `netsimd`) to a second emulator (`Medium_Phone` Android 16 API 36) did not populate the second emulator's `content://sms/inbox`; sent/delivered callbacks, multipart/Bangla text integrity in `content://sms/sent`, Doze/reboot/airplane-mode retry, missed handling, and `SyncService` deduplication were all verified directly on `Pixel_8` (Android 14 API 34).

## Spec 11 — Setup and reliability

- Android 13+ "Allow restricted settings" flow for an APK installed from a file: `adb install` is exempt from Android's restricted settings gate, so the detection and three-step guide sheet are verified by widget tests (`test/setup/setup_and_reliability_test.dart`) rather than an emulator sideload.
- Manufacturer-specific battery setting labels were not verified on physical hardware for each maker (kept as ARB strings for easy correction):
  - Xiaomi, Redmi, Poco (`Turn on Autostart and set Battery saver to No restrictions`)
  - Oppo, Realme, OnePlus (`Allow background activity and Auto-launch`)
  - Vivo, iQOO (`Allow High background power consumption and Autostart`)
  - Samsung (`Add PocketCRM to Never sleeping apps`)
  - Tecno, Infinix, itel (`Allow Auto-start in Phone Master`)
  - Huawei, Honor (`Set App launch to Manage manually and allow all three switches`)

