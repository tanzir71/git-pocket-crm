import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/messages/sms_counter.dart';
import '../../../core/native/outbox_api.g.dart';
import '../../settings/data/settings_repository.dart';
import 'outbox_repository.dart';

class ScheduledSmsMigrationReport {
  const ScheduledSmsMigrationReport({
    required this.alreadyRan,
    required this.queuedCount,
    required this.missedCount,
    required this.campaignsCreated,
  });

  final bool alreadyRan;
  final int queuedCount;
  final int missedCount;
  final int campaignsCreated;
}

/// One-time Spec 10 Part C migration moving pending v1 `scheduled_sms` and
/// `bulk_sms_jobs` rows into `outbox_messages` and `campaigns`.
class ScheduledSmsMigrator {
  ScheduledSmsMigrator({
    required AppDatabase db,
    required this.outbox,
    DateTime Function()? clock,
    String Function()? idGenerator,
  })  : _db = db,
        _settings = SettingsRepository(db),
        _clock = clock ?? DateTime.now,
        _idGenerator = idGenerator ?? generateUuidV4;

  static const String settingKey = 'v1_scheduled_migrated';

  final AppDatabase _db;
  final OutboxRepository outbox;
  final SettingsRepository _settings;
  final DateTime Function() _clock;
  final String Function() _idGenerator;

  Future<ScheduledSmsMigrationReport> migrateOnce() async {
    final already = await _settings.get(settingKey);
    if (already == '1') {
      return const ScheduledSmsMigrationReport(
        alreadyRan: true,
        queuedCount: 0,
        missedCount: 0,
        campaignsCreated: 0,
      );
    }

    final nowMs = _clock().millisecondsSinceEpoch;
    final pendingRows = await (_db.select(_db.scheduledSmsEntries)
          ..where((t) => t.isSent.equals(0)))
        .get();

    if (pendingRows.isEmpty) {
      await _settings.set(settingKey, '1');
      return const ScheduledSmsMigrationReport(
        alreadyRan: false,
        queuedCount: 0,
        missedCount: 0,
        campaignsCreated: 0,
      );
    }

    final bulkJobs = await _db.select(_db.bulkSmsJobs).get();
    final bulkJobById = <int, BulkSmsJob>{for (final j in bulkJobs) j.id: j};

    final contacts = await _db.select(_db.contacts).get();
    final nameByContactId = <int, String>{
      for (final c in contacts) c.id: c.displayName,
    };

    final campaignIdByBulkJob = <int, String>{};
    final campaignsToUpsert = <CampaignConfig>[];
    final itemsToEnqueue = <OutboxItem>[];

    int queuedCount = 0;
    int missedCount = 0;
    int campaignsCreated = 0;

    await _db.transaction(() async {
      for (final row in pendingRows) {
        String? campaignId;
        final bulkJobId = row.bulkJobId;
        if (bulkJobId != null) {
          campaignId = campaignIdByBulkJob[bulkJobId];
          if (campaignId == null) {
            campaignId = _idGenerator();
            campaignIdByBulkJob[bulkJobId] = campaignId;
            final job = bulkJobById[bulkJobId];
            final campName = job != null ? 'Message to ${job.listName}' : 'Scheduled message';
            final campStatus =
                (job?.scheduledTime ?? row.scheduledTime) > nowMs ? 'scheduled' : 'done';
            await _db.into(_db.campaigns).insert(
                  CampaignsCompanion.insert(
                    id: campaignId,
                    name: campName,
                    bodyTemplate: job?.message ?? row.message,
                    scheduledAt: Value(job?.scheduledTime ?? row.scheduledTime),
                    status: campStatus,
                    paceSeconds: const Value(4),
                    windowStartMin: const Value(9 * 60),
                    windowEndMin: const Value(21 * 60),
                    createdAt: Value(nowMs),
                  ),
                );
            campaignsToUpsert.add(
              CampaignConfig(
                id: campaignId,
                name: campName,
                paceSeconds: 4,
                windowStartMin: 9 * 60,
                windowEndMin: 21 * 60,
                status: campStatus,
              ),
            );
            campaignsCreated++;
          }
        }

        final isFuture = row.scheduledTime > nowMs;
        final status = isFuture ? 'queued' : 'missed';
        final clientId = _idGenerator();
        final parts = countSms(row.message).segments;

        await _db.into(_db.outboxMessages).insert(
              OutboxMessagesCompanion.insert(
                clientId: clientId,
                contactId: Value(row.contactId),
                campaignId: Value(campaignId),
                address: row.phoneNumber,
                body: row.message,
                dueAt: row.scheduledTime,
                status: status,
                errorLabel: Value(isFuture ? null : 'Missed'),
                parts: Value(parts),
                createdAt: Value(nowMs),
                updatedAt: Value(nowMs),
              ),
            );

        if (isFuture) {
          queuedCount++;
          itemsToEnqueue.add(
            OutboxItem(
              clientId: clientId,
              campaignId: campaignId,
              address: row.phoneNumber,
              recipientName:
                  row.contactId != null ? nameByContactId[row.contactId!] : null,
              body: row.message,
              dueAtMs: row.scheduledTime,
              status: 'queued',
            ),
          );
        } else {
          missedCount++;
        }

        // Mark moved row with is_sent = 2 so the move never repeats; is_sent = 1 untouched.
        await (_db.update(_db.scheduledSmsEntries)..where((t) => t.id.equals(row.id)))
            .write(const ScheduledSmsEntriesCompanion(isSent: Value(2)));
      }

      for (final bulkJobId in campaignIdByBulkJob.keys) {
        await (_db.update(_db.bulkSmsJobs)..where((t) => t.id.equals(bulkJobId)))
            .write(const BulkSmsJobsCompanion(isSent: Value(2)));
      }

      await _settings.set(settingKey, '1');
    });

    for (final cfg in campaignsToUpsert) {
      await outbox.upsertCampaign(cfg);
    }
    if (itemsToEnqueue.isNotEmpty) {
      try {
        await outbox.client.enqueue(itemsToEnqueue);
      } catch (_) {}
    }

    return ScheduledSmsMigrationReport(
      alreadyRan: false,
      queuedCount: queuedCount,
      missedCount: missedCount,
      campaignsCreated: campaignsCreated,
    );
  }
}
