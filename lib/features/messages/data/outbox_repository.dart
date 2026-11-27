import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/crm_queries.dart';
import '../../../core/messages/sms_counter.dart';
import '../../../core/native/outbox_api.g.dart';
import '../../../l10n/app_localizations.dart';
import '../../sync/data/sync_state_repository.dart';

/// Named Android `SmsManager` result-code constants for Dart UI reason mapping.
abstract final class AndroidSmsResultCodes {
  static const int genericFailure = 1;
  static const int radioOff = 2;
  static const int nullPdu = 3;
  static const int noService = 4;
  static const int limitExceeded = 5;
  static const int shortCodeNotAllowed = 7;
  static const int shortCodeNeverAllowed = 8;
  static const int networkReject = 10;
  static const int radioNotAvailable = 22;
}

/// Maps a native Android `SmsManager` error code to a user-facing reason label.
String smsErrorReasonLabel(int? code, [AppLocalizations? l10n]) {
  if (code == null) {
    return l10n?.smsErrorGeneric ?? 'Not sent';
  }
  return switch (code) {
    AndroidSmsResultCodes.noService => l10n?.smsErrorNoService ?? 'No service',
    AndroidSmsResultCodes.radioOff ||
    AndroidSmsResultCodes.radioNotAvailable =>
      l10n?.smsErrorRadioOff ?? 'Airplane mode or radio off',
    AndroidSmsResultCodes.limitExceeded =>
      l10n?.smsErrorLimitReached ?? 'Sending limit reached',
    AndroidSmsResultCodes.shortCodeNotAllowed ||
    AndroidSmsResultCodes.shortCodeNeverAllowed ||
    AndroidSmsResultCodes.networkReject =>
      l10n?.smsErrorNotAllowed ?? 'Not allowed by the network',
    _ => l10n?.smsErrorUnknown(code) ?? 'Unknown error ($code)',
  };
}

/// Testable abstraction over Pigeon's generated [OutboxApi].
abstract class OutboxPlatformClient {
  Future<void> enqueue(List<OutboxItem> items);
  Future<void> upsertCampaign(CampaignConfig config);
  Future<void> cancel(List<String> clientIds);
  Future<void> retry(List<String> clientIds);
  Future<void> pauseCampaign(String id);
  Future<void> resumeCampaign(String id);
  Future<void> stopCampaign(String id);
  Future<ChangeSet> changesSince(int seq);
  Future<List<SimInfo>> sims();
  Future<OutboxCapabilities> capabilities();
  Future<void> shareFile(String path, String mimeType, String subject);
  Future<SetupPlatformInfo> setupInfo();
  Future<void> openExactAlarmSettings();
  Future<void> requestIgnoreBatteryOptimisations();
  Future<void> openAppDetailsSettings();
  void listenForChanges(void Function(int latestSeq) onChanged);
}

class _OutboxEventsBridge extends OutboxEvents {
  _OutboxEventsBridge(this._onChanged);

  final void Function(int latestSeq) _onChanged;

  @override
  void onOutboxChanged(int latestSeq) {
    _onChanged(latestSeq);
  }
}

/// Real Android Pigeon implementation of [OutboxPlatformClient].
class PigeonOutboxPlatformClient implements OutboxPlatformClient {
  PigeonOutboxPlatformClient({OutboxApi? api}) : _api = api ?? OutboxApi();

  final OutboxApi _api;

  @override
  Future<void> enqueue(List<OutboxItem> items) async {
    if (!Platform.isAndroid) return;
    await _api.enqueue(items);
  }

  @override
  Future<void> upsertCampaign(CampaignConfig config) async {
    if (!Platform.isAndroid) return;
    await _api.upsertCampaign(config);
  }

  @override
  Future<void> cancel(List<String> clientIds) async {
    if (!Platform.isAndroid) return;
    await _api.cancel(clientIds);
  }

  @override
  Future<void> retry(List<String> clientIds) async {
    if (!Platform.isAndroid) return;
    await _api.retry(clientIds);
  }

  @override
  Future<void> pauseCampaign(String id) async {
    if (!Platform.isAndroid) return;
    await _api.pauseCampaign(id);
  }

  @override
  Future<void> resumeCampaign(String id) async {
    if (!Platform.isAndroid) return;
    await _api.resumeCampaign(id);
  }

  @override
  Future<void> stopCampaign(String id) async {
    if (!Platform.isAndroid) return;
    await _api.stopCampaign(id);
  }

  @override
  Future<ChangeSet> changesSince(int seq) async {
    if (!Platform.isAndroid) return ChangeSet(items: const [], latestSeq: seq);
    return _api.changesSince(seq);
  }

  @override
  Future<List<SimInfo>> sims() async {
    if (!Platform.isAndroid) return const [];
    try {
      return await _api.sims();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<OutboxCapabilities> capabilities() async {
    if (!Platform.isAndroid) {
      return OutboxCapabilities(
        exactAlarms: false,
        ignoringBatteryOptimisation: false,
        notifications: false,
        smsPermission: false,
      );
    }
    try {
      return await _api.capabilities();
    } catch (_) {
      return OutboxCapabilities(
        exactAlarms: false,
        ignoringBatteryOptimisation: false,
        notifications: false,
        smsPermission: false,
      );
    }
  }

  @override
  Future<void> shareFile(String path, String mimeType, String subject) async {
    if (!Platform.isAndroid) return;
    try {
      await _api.shareFile(path, mimeType, subject);
    } catch (_) {}
  }

  @override
  Future<SetupPlatformInfo> setupInfo() async {
    if (!Platform.isAndroid) {
      return SetupPlatformInfo(
        sdkInt: 0,
        manufacturer: '',
        installedFromStore: false,
      );
    }
    try {
      return await _api.setupInfo();
    } catch (_) {
      return SetupPlatformInfo(
        sdkInt: 0,
        manufacturer: '',
        installedFromStore: false,
      );
    }
  }

  @override
  Future<void> openExactAlarmSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _api.openExactAlarmSettings();
    } catch (_) {}
  }

  @override
  Future<void> requestIgnoreBatteryOptimisations() async {
    if (!Platform.isAndroid) return;
    try {
      await _api.requestIgnoreBatteryOptimisations();
    } catch (_) {}
  }

  @override
  Future<void> openAppDetailsSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _api.openAppDetailsSettings();
    } catch (_) {}
  }

  @override
  void listenForChanges(void Function(int latestSeq) onChanged) {
    if (!Platform.isAndroid) return;
    OutboxEvents.setUp(_OutboxEventsBridge(onChanged));
  }
}

/// Input specification for scheduling an outbox message.
class ScheduleOutboxInput {
  const ScheduleOutboxInput({
    this.clientId,
    this.contactId,
    this.campaignId,
    required this.address,
    this.recipientName,
    required this.body,
    required this.dueAtMs,
    this.subId,
    this.mergeSummary,
  });

  final String? clientId;
  final int? contactId;
  final String? campaignId;
  final String address;
  final String? recipientName;
  final String body;
  final int dueAtMs;
  final int? subId;
  final String? mergeSummary;
}

/// Generates a RFC 4122 version-4 UUID without adding external dependencies.
String generateUuidV4([Random? rng]) {
  final random = rng ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(int start, int end) =>
      bytes.sublist(start, end).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}

/// Coordinates Dart's `outbox_messages` table with Kotlin's native `outbox.db`.
class OutboxRepository {
  OutboxRepository({
    required AppDatabase db,
    required this.client,
    DateTime Function()? clock,
    String Function()? idGenerator,
  })  : _db = db,
        _clock = clock ?? DateTime.now,
        _idGenerator = idGenerator ?? generateUuidV4,
        _syncState = SyncStateRepository(db),
        _queries = CrmQueries(db);

  final AppDatabase _db;
  final OutboxPlatformClient client;
  final DateTime Function() _clock;
  final String Function() _idGenerator;
  final SyncStateRepository _syncState;
  final CrmQueries _queries;

  static const String _seqKey = 'outbox_last_seq';
  bool _reconciling = false;

  /// Registers the Flutter-side listener for native outbox change notifications.
  void startListening() {
    client.listenForChanges((_) {
      unawaited(reconcile());
    });
  }

  /// Inserts a single message into `outbox_messages` with a new UUID and
  /// forwards it to the native outbox. If the native call fails, the row stays
  /// `queued` in Dart and will be pushed idempotently on the next [reconcile].
  Future<String> scheduleSingle({
    required int? contactId,
    required String address,
    String? recipientName,
    required String body,
    required int dueAtMs,
    int? subId,
  }) async {
    final ids = await scheduleBatch([
      ScheduleOutboxInput(
        contactId: contactId,
        address: address,
        recipientName: recipientName,
        body: body,
        dueAtMs: dueAtMs,
        subId: subId,
      ),
    ]);
    return ids.first;
  }

  /// Inserts one or more messages into `outbox_messages` and enqueues them natively.
  Future<List<String>> scheduleBatch(List<ScheduleOutboxInput> inputs) async {
    if (inputs.isEmpty) return const [];
    final nowMs = _clock().millisecondsSinceEpoch;
    final nativeItems = <OutboxItem>[];
    final ids = <String>[];

    await _db.transaction(() async {
      for (final input in inputs) {
        final clientId = input.clientId ?? _idGenerator();
        ids.add(clientId);
        final segments = countSms(input.body).segments;
        await _db.into(_db.outboxMessages).insert(
              OutboxMessagesCompanion.insert(
                clientId: clientId,
                contactId: Value(input.contactId),
                campaignId: Value(input.campaignId),
                address: input.address,
                body: input.body,
                dueAt: input.dueAtMs,
                subId: Value(input.subId),
                status: 'queued',
                parts: Value(segments),
                mergeSummary: Value(input.mergeSummary),
                createdAt: Value(nowMs),
                updatedAt: Value(nowMs),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        nativeItems.add(
          OutboxItem(
            clientId: clientId,
            campaignId: input.campaignId,
            address: input.address,
            recipientName: input.recipientName,
            body: input.body,
            dueAtMs: input.dueAtMs,
            subId: input.subId,
            status: 'queued',
          ),
        );
      }
    });

    try {
      await client.enqueue(nativeItems);
    } catch (_) {
      // Kept as `queued` in Dart; `reconcile()` re-enqueues idempotently on next start/resume.
    }

    return ids;
  }

  /// Re-pushes any local `queued` rows to native (idempotent) and pulls all
  /// native state changes since the last persisted `outbox_last_seq`.
  Future<int> reconcile() async {
    if (_reconciling) return 0;
    _reconciling = true;
    try {
      // 1. Ensure any locally-queued rows exist natively (idempotent on clientId).
      final queuedRows = await _queries.getQueuedOutboxWithPerson();
      if (queuedRows.isNotEmpty) {
        try {
          await client.enqueue([
            for (final row in queuedRows)
              OutboxItem(
                clientId: row.message.clientId,
                campaignId: row.message.campaignId,
                address: row.message.address,
                recipientName: row.personName,
                body: row.message.body,
                dueAtMs: row.message.dueAt,
                subId: row.message.subId,
                status: row.message.status,
              ),
          ]);
        } catch (_) {
          // Proceed to pull changes if possible.
        }
      }

      // 2. Pull changes since lastSeq in order.
      final lastSeq = await _syncState.getInt(_seqKey) ?? 0;
      final changeSet = await client.changesSince(lastSeq);
      if (changeSet.items.isEmpty) {
        if (changeSet.latestSeq > lastSeq) {
          await _syncState.setInt(_seqKey, changeSet.latestSeq);
        }
        return 0;
      }

      final nowMs = _clock().millisecondsSinceEpoch;
      final touchedContacts = <int>{};
      final affectedCampaigns = <String>{};

      await _db.transaction(() async {
        for (final item in changeSet.items) {
          final existing = await (_db.select(_db.outboxMessages)
                ..where((t) => t.clientId.equals(item.clientId)))
              .getSingleOrNull();
          if (existing == null) continue;

          final errorLabel = item.errorCode != null
              ? smsErrorReasonLabel(item.errorCode)
              : (item.status == 'missed' ? 'Missed' : null);

          await (_db.update(_db.outboxMessages)
                ..where((t) => t.clientId.equals(item.clientId)))
              .write(
            OutboxMessagesCompanion(
              status: Value(item.status),
              dueAt: Value(item.dueAtMs),
              attempt: Value(item.attempt),
              parts: item.partsTotal > 0 ? Value(item.partsTotal) : const Value.absent(),
              errorCode: Value(item.errorCode),
              errorLabel: Value(errorLabel),
              sentAt: Value(item.sentAtMs ?? existing.sentAt),
              deliveredAt: Value(item.deliveredAtMs ?? existing.deliveredAt),
              updatedAt: Value(nowMs),
            ),
          );

          if (item.campaignId != null) {
            affectedCampaigns.add(item.campaignId!);
          }

          // When a row first becomes `sent` (or `delivered` directly), insert
          // exactly ONE `sms_outgoing` timeline row keyed by `outbox:{clientId}`.
          final becameSent = item.status == 'sent' || item.status == 'delivered';
          if (becameSent && existing.contactId != null) {
            final nativeId = 'outbox:${item.clientId}';
            final ts = item.sentAtMs ?? item.deliveredAtMs ?? existing.dueAt;
            final insertedId = await _db.into(_db.timelineEntries).insert(
                  TimelineEntriesCompanion.insert(
                    contactId: Value(existing.contactId),
                    type: 'sms_outgoing',
                    timestamp: ts,
                    content: Value(existing.body),
                    nativeMessageId: Value(nativeId),
                    outboxClientId: Value(item.clientId),
                    source: const Value('app'),
                  ),
                  mode: InsertMode.insertOrIgnore,
                );
            if (insertedId > 0) {
              touchedContacts.add(existing.contactId!);
            }
          }
        }

        if (touchedContacts.isNotEmpty) {
          await _queries.recomputeLastInteractions(touchedContacts);
        }

        for (final campaignId in affectedCampaigns) {
          await _refreshCampaignStatus(campaignId);
        }

        await _syncState.setInt(_seqKey, changeSet.latestSeq);
      });

      return changeSet.items.length;
    } finally {
      _reconciling = false;
    }
  }

  Future<void> _refreshCampaignStatus(String campaignId) async {
    final campaign = await (_db.select(_db.campaigns)
          ..where((t) => t.id.equals(campaignId)))
        .getSingleOrNull();
    if (campaign == null) return;
    if (campaign.status == 'paused' || campaign.status == 'stopped') return;

    final rows = await (_db.select(_db.outboxMessages)
          ..where((t) => t.campaignId.equals(campaignId)))
        .get();
    if (rows.isEmpty) return;
    final hasQueuedOrSending =
        rows.any((r) => r.status == 'queued' || r.status == 'sending');
    if (!hasQueuedOrSending) {
      await (_db.update(_db.campaigns)..where((t) => t.id.equals(campaignId)))
          .write(const CampaignsCompanion(status: Value('done')));
    }
  }

  Future<void> cancel(List<String> clientIds) async {
    if (clientIds.isEmpty) return;
    final nowMs = _clock().millisecondsSinceEpoch;
    await (_db.update(_db.outboxMessages)
          ..where((t) => t.clientId.isIn(clientIds)))
        .write(
      OutboxMessagesCompanion(
        status: const Value('cancelled'),
        updatedAt: Value(nowMs),
      ),
    );
    try {
      await client.cancel(clientIds);
    } catch (_) {}
  }

  Future<void> retry(List<String> clientIds) async {
    if (clientIds.isEmpty) return;
    final nowMs = _clock().millisecondsSinceEpoch;
    await (_db.update(_db.outboxMessages)
          ..where((t) => t.clientId.isIn(clientIds)))
        .write(
      OutboxMessagesCompanion(
        status: const Value('queued'),
        dueAt: Value(nowMs),
        attempt: const Value(0),
        errorCode: const Value(null),
        errorLabel: const Value(null),
        updatedAt: Value(nowMs),
      ),
    );
    try {
      await client.retry(clientIds);
    } catch (_) {}
  }

  Future<void> upsertCampaign(CampaignConfig config) async {
    try {
      await client.upsertCampaign(config);
    } catch (_) {}
  }

  Future<void> pauseCampaign(String id) async {
    await (_db.update(_db.campaigns)..where((t) => t.id.equals(id)))
        .write(const CampaignsCompanion(status: Value('paused')));
    try {
      await client.pauseCampaign(id);
    } catch (_) {}
  }

  Future<void> resumeCampaign(String id) async {
    await (_db.update(_db.campaigns)..where((t) => t.id.equals(id)))
        .write(const CampaignsCompanion(status: Value('sending')));
    try {
      await client.resumeCampaign(id);
    } catch (_) {}
  }

  Future<void> stopCampaign(String id) async {
    final nowMs = _clock().millisecondsSinceEpoch;
    await _db.transaction(() async {
      await (_db.update(_db.campaigns)..where((t) => t.id.equals(id)))
          .write(const CampaignsCompanion(status: Value('stopped')));
      await (_db.update(_db.outboxMessages)
            ..where((t) => t.campaignId.equals(id) & t.status.equals('queued')))
          .write(
        OutboxMessagesCompanion(
          status: const Value('cancelled'),
          updatedAt: Value(nowMs),
        ),
      );
    });
    try {
      await client.stopCampaign(id);
    } catch (_) {}
  }

  Future<List<SimInfo>> sims() => client.sims();

  Future<OutboxCapabilities> capabilities() => client.capabilities();

  Future<void> shareFile(String path, String mimeType, String subject) =>
      client.shareFile(path, mimeType, subject);

  Future<SetupPlatformInfo> setupInfo() => client.setupInfo();
  Future<void> openExactAlarmSettings() => client.openExactAlarmSettings();
  Future<void> requestIgnoreBatteryOptimisations() =>
      client.requestIgnoreBatteryOptimisations();
  Future<void> openAppDetailsSettings() => client.openAppDetailsSettings();
}
