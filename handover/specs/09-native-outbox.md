# 09 Native outbox

## Goal

An SMS scheduled in the app is sent at its time with the app closed, from the chosen SIM, and its real result (sent, delivered, failed with a reason) comes back to the app. Nothing is ever marked sent unless Android reported it.

## Read first

`handover/00-current-state.md` "Does the automation work", `handover/04-research-notes.md` sections on sending and background work.

## Decisions

- **The send pipeline is Kotlin.** It must run when no Flutter engine exists, so no Dart isolate is involved in sending.
- **The native side owns its own small database file, `outbox.db`** (a plain `SQLiteOpenHelper`). It does not open `pocket_crm.db`. Dart keeps its own record in `outbox_messages` and reconciles through the API below. One owner per file, so two SQLite libraries never touch the same file.
- **Scheduling:** `AlarmManager.setExactAndAllowWhileIdle` when `canScheduleExactAlarms()` is true, else `setAndAllowWhileIdle` (and the app says "may be a few minutes late"). The alarm starts a unique expedited `WorkManager` job that drains the queue. A 15-minute periodic job is the safety net.
- **Long runs** (a campaign) happen inside that worker as a long-running worker with `setForeground` and foreground service type `dataSync`, with a progress notification.
- **A late single message is not sent.** If its time passed more than 30 minutes ago (the phone was off), it becomes `missed` and waits for the user. Campaign messages do resume, inside the send window.
- **Send window:** default 09:00 to 21:00 local time. A message due outside it waits for the window to open. The window is per campaign and a global default.

## Steps

1. **Kotlin package `com.pocketcrm.pocket_crm.outbox`.**
   - `OutboxDb`: table `messages(client_id TEXT PRIMARY KEY, campaign_id TEXT, address TEXT, body TEXT, due_at INTEGER, sub_id INTEGER, status TEXT, attempt INTEGER, parts_total INTEGER, parts_sent INTEGER, parts_failed INTEGER, parts_delivered INTEGER, error_code INTEGER, sent_at INTEGER, delivered_at INTEGER, seq INTEGER)`, table `campaigns(id TEXT PRIMARY KEY, name TEXT, pace_seconds INTEGER, window_start_min INTEGER, window_end_min INTEGER, status TEXT, seq INTEGER)`, and a one-row counter table. Every write to a row sets `seq` to the next counter value, so "what changed since N" is one indexed query.
   - `OutboxStateMachine`: a pure Kotlin class with no Android imports that holds all rules: allowed transitions (`queued` to `sending` to `sent` or `failed`; `sent` to `delivered`; `queued` to `cancelled`, `missed` or `skipped`; `failed` to `queued` on retry), the retry policy, the window calculation, the missed rule, and the campaign pause rule. Unit-test it with plain JUnit.
   - `SmsSender`: chooses the manager as below, calls `divideMessage`, and sends with `sendMultipartTextMessage` giving one sent and one delivery `PendingIntent` per part.

```kotlin
val base = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S)
    context.getSystemService(SmsManager::class.java)
else @Suppress("DEPRECATION") SmsManager.getDefault()
val manager = when {
    subId == null -> base
    Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> base.createForSubscriptionId(subId)
    else -> @Suppress("DEPRECATION") SmsManager.getSmsManagerForSubscriptionId(subId)
}
```

   - Each `PendingIntent` targets `SmsResultReceiver` explicitly by class, with a unique data URI `pocketcrm://sms/{client_id}/{part}/{sent|delivered}`. Use `FLAG_IMMUTABLE` for sent intents. Delivery intents need the report extras, so use `FLAG_MUTABLE` there (allowed because the intent is explicit).
   - `SmsResultReceiver` (manifest, not exported): on a sent result, count the part as sent when the result code is `Activity.RESULT_OK`, else as failed and store the code. When all parts are in: all OK gives `sent`; any failure gives `failed`. On a delivery report, count the part; when all parts are delivered the message is `delivered`. Treat delivery as optional: many networks never send reports, so `sent` is a final, good state.
   - **Retry:** only for "no service" and "radio off" results, up to 3 attempts, after 1, 5 and 15 minutes, and only inside the window. When Android reports the sending limit was exceeded, pause the campaign, post a notification ("Android paused sending. Resume in a few minutes, or choose a slower pace."), and do not retry on its own. Read result-code constants from `SmsManager`; do not hard-code numbers.
   - `OutboxScheduler`: finds the earliest `queued` message, sets the alarm for it, and is called after every change. `AlarmReceiver` enqueues `OutboxDrainWorker` as unique work named `outbox-drain` (keep existing).
   - `OutboxDrainWorker` (`CoroutineWorker`): loop: claim the earliest due message with `UPDATE messages SET status='sending' WHERE client_id=? AND status='queued'` and proceed only if one row changed; apply the missed and window rules; send; for campaign messages wait `pace_seconds` before the next claim. Call `setForeground` as soon as the run is a campaign or holds more than 3 messages. Exit when nothing is due, then call the scheduler. On `onStopped`, set any message still `sending` with no parts reported back to `queued`.
   - `BootReceiver`: on boot completed, package replaced, time set, time zone changed, and exact-alarm permission changed, call the scheduler and mark overdue single messages as missed.
2. **Manifest.** Permissions: `SEND_SMS`, `READ_PHONE_STATE`, `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_DATA_SYNC`, `POST_NOTIFICATIONS`, `WAKE_LOCK`. Declare the receivers, and the `dataSync` type on WorkManager's foreground service as the WorkManager documentation describes.
3. **Pigeon API** `pigeons/outbox.dart`:

```
OutboxApi (host)
  void enqueue(List<OutboxItem> items)          // clientId, campaignId?, address, body, dueAt, subId?  (idempotent on clientId)
  void upsertCampaign(CampaignConfig c)         // id, name, paceSeconds, windowStartMin, windowEndMin
  void cancel(List<String> clientIds)
  void retry(List<String> clientIds)            // failed or missed -> queued, due now
  void pauseCampaign(String id) / resumeCampaign(String id) / stopCampaign(String id)
  ChangeSet changesSince(int seq)               // items + latestSeq
  List<SimInfo> sims()                          // subId, slot, carrierName, displayName, isDefault
  Capabilities capabilities()                   // exactAlarms, ignoringBatteryOptimisation, notifications, smsPermission
OutboxEvents (flutter)
  void onOutboxChanged(int latestSeq)
```

4. **Dart `OutboxRepository`.**
   - `schedule(...)`: insert `outbox_messages` rows with new UUIDs and status `queued`, then call `enqueue`. If the call fails, the rows stay `queued` and are re-sent to the native side on the next start (enqueue is idempotent).
   - `reconcile()`: call `changesSince(lastSeq)`, update the rows, store the new sequence in `sync_state`. Run on start, on return to the foreground, and on `onOutboxChanged`.
   - When a row first becomes `sent`, insert one `timeline` row of type `sms_outgoing` with `native_message_id = 'outbox:{client_id}'`, `outbox_client_id` set, and update `last_interaction_at`.
   - **No doubles with sync.** Android usually also writes the sent message to the system SMS store, and spec 05 will read it. In sync, when an outgoing SMS matches an outbox row (same address, same body, sent within 2 minutes), set `provider_sms_id` on the outbox row and skip the insert.
5. **Interface for a single message** (the bulk composer is spec 10): on the Person screen the Message action opens a small composer sheet: message field with the live counter, Send now or a time, SIM row when there are two. Scheduled messages appear under Next on the person, under "Going out today" on Today, and failed or missed ones under "Needs attention" with Retry or Send now, and Dismiss.
6. **Notifications** on the Messages channel: one when a single scheduled message is sent ("Sent to {name}"), one when it fails ("Not sent to {name}. {reason}." with Retry). Post them from Kotlin, so they appear with the app closed.
7. **Reason labels** for the interface, mapped from result codes in Dart: No service, Airplane mode or radio off, Sending limit reached, Not allowed by the network, Unknown error ({code}).

## Acceptance criteria

- JUnit tests of `OutboxStateMachine`: every allowed and refused transition; retry counts and delays; a message due at 22:30 with a 09:00 to 21:00 window is rescheduled to 09:00 the next day; a single message 31 minutes late becomes missed; a limit-exceeded result pauses the campaign.
- A JUnit test with a fake sender runs two drain loops at once over 50 messages and each message is sent exactly once.
- Dart tests of `OutboxRepository` with a fake `OutboxApi`: reconcile applies changes in order; a `sent` change creates exactly one timeline row even when reconcile runs twice; the sync de-duplication rule works.
- `grep -R "Timer.periodic" lib/features` finds nothing.
- The merged manifest contains the listed permissions and still no INTERNET.

## Verify

```sh
dart run pigeon --input pigeons/outbox.dart
(cd android && ./gradlew :app:testDebugUnitTest)
tool/verify.sh && flutter test --dart-define=V2=true
```

Emulator checks. Run them yourself on two emulators, A and B, as described under "Testing without the owner" in `AGENTS.md`, and record each result in `handover/TEST-RESULTS.md`:

1. On A, schedule a message to B's number 3 minutes ahead, background the app, kill its process with `am kill`, and force idle mode. The message is in B's inbox within a minute of the time, and A shows Sent when reopened.
2. The same, with `adb reboot` of A before the time.
3. Airplane mode on, send now: the message shows Not sent with the reason. Airplane mode off within 15 minutes: the retry sends it.
4. A 300-character message and a Bangla message arrive whole on B.
5. Schedule a message, shut A down through its time, start it an hour later: it shows as missed under Needs attention and B received nothing.
6. Read A's own SMS store (`content query --uri content://sms/sent`) to see whether Android recorded the sent message, and confirm the person's history shows it once either way.
7. Send 40 messages to B at Fast pace and record whether Android shows its sending-limit confirmation, with the emulator's Android version.

These cannot be shown on an emulator and stay in `handover/UNVERIFIED.md`: operator filtering and delivery reports on a real network, sending from a chosen SIM on a dual-SIM phone, and phone makers' battery management.

## Out of scope

Bulk composing and the campaign screen (spec 10). Moving old scheduled rows over (spec 10). Battery and restricted-settings guidance (spec 11).
