import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/crm_queries.dart';
import '../../../core/messages/template_renderer.dart';
import '../../../core/native/outbox_api.g.dart';
import '../../../core/phone/phone_service.dart';
import 'outbox_repository.dart';

export '../../../core/db/crm_queries.dart'
    show CampaignRecipientRow, CampaignSummaryRow, OutboxWithPersonRow;

enum SkipReason {
  noMobile,
  optedOut,
  duplicate,
}

class SkippedRecipient {
  const SkippedRecipient({
    required this.contact,
    required this.reason,
  });

  final Contact contact;
  final SkipReason reason;
}

class ResolvedRecipient {
  const ResolvedRecipient({
    required this.contact,
    required this.address,
    required this.amountDue,
  });

  final Contact contact;
  final String address;
  final double amountDue;

  TemplatePerson toTemplatePerson({String? currencyCode}) => TemplatePerson(
        displayName: contact.displayName,
        company: contact.company,
        amountDue: amountDue,
        currencyCode: currencyCode,
      );
}

class RecipientResolution {
  const RecipientResolution({
    required this.recipients,
    required this.skipped,
  });

  final List<ResolvedRecipient> recipients;
  final List<SkippedRecipient> skipped;

  int countSkipped(SkipReason reason) =>
      skipped.where((s) => s.reason == reason).length;
}

/// Pace presets defined in Spec 10 step 8.
enum CampaignPace {
  fast(4),
  steady(15),
  careful(60);

  const CampaignPace(this.seconds);
  final int seconds;

  static CampaignPace fromSetting(String? value) {
    return switch (value) {
      'steady' => CampaignPace.steady,
      'careful' => CampaignPace.careful,
      _ => CampaignPace.fast,
    };
  }
}

class CampaignsRepository {
  CampaignsRepository({
    required AppDatabase db,
    required this.outbox,
    this.phoneService = const PhoneService(),
    DateTime Function()? clock,
    String Function()? idGenerator,
  })  : _db = db,
        _queries = CrmQueries(db),
        _clock = clock ?? DateTime.now,
        _idGenerator = idGenerator ?? generateUuidV4;

  final AppDatabase _db;
  final OutboxRepository outbox;
  final CrmQueries _queries;
  final PhoneService phoneService;
  final DateTime Function() _clock;
  final String Function() _idGenerator;

  /// Resolves selected lists and individual contact IDs into unique sendable
  /// mobile recipients plus structured skip reasons (Spec 10 step 5).
  Future<RecipientResolution> resolveRecipients({
    required Set<int> listIds,
    required Set<int> contactIds,
    String defaultRegion = 'US',
  }) async {
    final uniqueContactIds = <int>{...contactIds};
    for (final listId in listIds) {
      final members = await _queries.getListMembers(listId);
      for (final m in members) {
        uniqueContactIds.add(m.id);
      }
    }
    if (uniqueContactIds.isEmpty) {
      return const RecipientResolution(recipients: [], skipped: []);
    }

    final contacts = await (_db.select(_db.contacts)
          ..where((t) => t.id.isIn(uniqueContactIds))
          ..orderBy([(t) => OrderingTerm(expression: t.displayName)]))
        .get();
    final phones = await (_db.select(_db.contactPhones)
          ..where((t) => t.contactId.isIn(uniqueContactIds)))
        .get();
    final balances = await _queries.getPositiveBalancesForContacts(uniqueContactIds);

    final phonesByContact = <int, List<ContactPhone>>{};
    for (final ph in phones) {
      phonesByContact.putIfAbsent(ph.contactId, () => <ContactPhone>[]).add(ph);
    }

    final resolved = <ResolvedRecipient>[];
    final skipped = <SkippedRecipient>[];
    final seenNumbers = <String>{};

    for (final contact in contacts) {
      if (contact.doNotMessage == 1) {
        skipped.add(SkippedRecipient(contact: contact, reason: SkipReason.optedOut));
        continue;
      }

      final mobile = _selectMobileNumber(
        contact,
        phonesByContact[contact.id] ?? const [],
        defaultRegion,
      );
      if (mobile == null) {
        skipped.add(SkippedRecipient(contact: contact, reason: SkipReason.noMobile));
        continue;
      }

      final dedupKey = phoneService.normalise(mobile, defaultRegion) ??
          mobile.replaceAll(RegExp(r'\s+'), '');
      if (!seenNumbers.add(dedupKey)) {
        skipped.add(SkippedRecipient(contact: contact, reason: SkipReason.duplicate));
        continue;
      }

      resolved.add(
        ResolvedRecipient(
          contact: contact,
          address: mobile,
          amountDue: balances[contact.id] ?? 0.0,
        ),
      );
    }

    return RecipientResolution(recipients: resolved, skipped: skipped);
  }

  String? _selectMobileNumber(
    Contact contact,
    List<ContactPhone> phones,
    String defaultRegion,
  ) {
    if (phones.isNotEmpty) {
      // Primary number if it is mobile, else first mobile.
      for (final ph in phones) {
        if (ph.isPrimary == 1 && ph.isMobile == 1) {
          final num = (ph.e164 ?? ph.raw ?? '').trim();
          if (num.isNotEmpty) return num;
        }
      }
      for (final ph in phones) {
        if (ph.isMobile == 1) {
          final num = (ph.e164 ?? ph.raw ?? '').trim();
          if (num.isNotEmpty) return num;
        }
      }
      return null;
    }

    final fallback = (contact.phoneNumber ?? '').trim();
    if (fallback.isEmpty) return null;
    final e164 = phoneService.normalise(fallback, defaultRegion);
    if (e164 != null && !phoneService.isMobile(e164)) {
      return null;
    }
    return e164 ?? fallback;
  }

  /// Schedules a single message or a multi-recipient campaign.
  /// Returns the created `campaignId` when a campaign was created, or `null`
  /// for a single non-campaign message.
  Future<String?> scheduleMessageOrCampaign({
    required String name,
    required String templateBody,
    required List<ResolvedRecipient> recipients,
    required int dueAtMs,
    required TemplateSettings settings,
    int? subId,
    int paceSeconds = 4,
    int windowStartMin = 9 * 60,
    int windowEndMin = 21 * 60,
    bool forceCampaign = false,
  }) async {
    if (recipients.isEmpty) return null;

    if (recipients.length == 1 && !forceCampaign) {
      final r = recipients.first;
      final rendered = renderTemplate(
        templateBody,
        r.toTemplatePerson(currencyCode: settings.currencyCode),
        settings,
      );
      await outbox.scheduleSingle(
        contactId: r.contact.id,
        address: r.address,
        recipientName: r.contact.displayName,
        body: rendered.text,
        dueAtMs: dueAtMs,
        subId: subId,
      );
      return null;
    }

    final nowMs = _clock().millisecondsSinceEpoch;
    final campaignId = _idGenerator();
    final initialStatus = dueAtMs <= nowMs + 5000 ? 'sending' : 'scheduled';

    await _db.into(_db.campaigns).insert(
          CampaignsCompanion.insert(
            id: campaignId,
            name: name.trim().isEmpty ? 'Message' : name.trim(),
            bodyTemplate: templateBody,
            scheduledAt: Value(dueAtMs),
            status: initialStatus,
            subId: Value(subId),
            paceSeconds: Value(paceSeconds),
            windowStartMin: Value(windowStartMin),
            windowEndMin: Value(windowEndMin),
            createdAt: Value(nowMs),
          ),
        );

    await outbox.upsertCampaign(
      CampaignConfig(
        id: campaignId,
        name: name.trim().isEmpty ? 'Message' : name.trim(),
        paceSeconds: paceSeconds,
        windowStartMin: windowStartMin,
        windowEndMin: windowEndMin,
        status: initialStatus,
      ),
    );

    final inputs = <ScheduleOutboxInput>[];
    for (final r in recipients) {
      final rendered = renderTemplate(
        templateBody,
        r.toTemplatePerson(currencyCode: settings.currencyCode),
        settings,
      );
      inputs.add(
        ScheduleOutboxInput(
          contactId: r.contact.id,
          campaignId: campaignId,
          address: r.address,
          recipientName: r.contact.displayName,
          body: rendered.text,
          dueAtMs: dueAtMs,
          subId: subId,
          mergeSummary: rendered.primaryMergeSummary,
        ),
      );
    }

    await outbox.scheduleBatch(inputs);
    return campaignId;
  }

  Stream<List<OutboxWithPersonRow>> watchQueuedSingles() =>
      _queries.watchQueuedSingleOutbox();

  Stream<List<CampaignSummaryRow>> watchCampaignSummaries() =>
      _queries.watchCampaignSummaries();

  Stream<Campaign?> watchCampaign(String id) {
    return (_db.select(_db.campaigns)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Stream<List<CampaignRecipientRow>> watchCampaignRecipients(String campaignId) =>
      _queries.watchCampaignRecipients(campaignId);

  Stream<List<OutboxWithPersonRow>> watchSentMessages({String? statusFilter}) =>
      _queries.watchSentOutbox(statusFilter: statusFilter);

  Stream<int> watchSentThisWeekCount({required DateTime now}) {
    final weekAgo = now.subtract(const Duration(days: 7)).millisecondsSinceEpoch;
    return _queries.watchSentOutboxCountSince(weekAgo);
  }

  Future<void> deleteCampaign(String campaignId) async {
    await outbox.stopCampaign(campaignId);
    await _db.transaction(() async {
      await (_db.delete(_db.outboxMessages)
            ..where((t) => t.campaignId.equals(campaignId)))
          .go();
      await (_db.delete(_db.campaigns)..where((t) => t.id.equals(campaignId))).go();
    });
  }

  /// Generates RFC 4180 CSV content (`name,number,state,time,reason`) for a campaign.
  static String buildCampaignCsv(List<CampaignRecipientRow> rows) {
    final buf = StringBuffer('name,number,state,time,reason\n');
    for (final r in rows) {
      final m = r.message;
      final ts = m.deliveredAt ?? m.sentAt ?? m.dueAt;
      final iso = DateTime.fromMillisecondsSinceEpoch(ts).toUtc().toIso8601String();
      final reason = m.errorCode != null
          ? smsErrorReasonLabel(m.errorCode)
          : (m.errorLabel ?? '');
      buf.writeln(
        [
          _csvEscape(r.personName),
          _csvEscape(m.address),
          _csvEscape(m.status),
          _csvEscape(iso),
          _csvEscape(reason),
        ].join(','),
      );
    }
    return buf.toString();
  }

  /// Writes campaign CSV to a temporary file and returns its path.
  Future<String> writeCampaignCsvFile(
    String campaignName,
    List<CampaignRecipientRow> rows,
  ) async {
    final dir = await getTemporaryDirectory();
    final safeName = campaignName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final fileName = '${safeName.isEmpty ? 'campaign' : safeName}_results.csv';
    final file = File(p.join(dir.path, fileName));
    await file.writeAsString(buildCampaignCsv(rows));
    return file.path;
  }

  static String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
