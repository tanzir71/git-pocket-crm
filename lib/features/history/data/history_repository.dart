import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/crm_queries.dart';

class HistoryRepository {
  HistoryRepository(this._db) : _queries = CrmQueries(_db);

  final AppDatabase _db;
  final CrmQueries _queries;

  Stream<List<TimelineEntry>> watchForPerson(
    int contactId, {
    Set<String>? types,
    bool includeHidden = false,
    int? limit,
  }) {
    final query = _db.select(_db.timelineEntries)
      ..where((t) {
        Expression<bool> pred = t.contactId.equals(contactId);
        if (!includeHidden) {
          pred = pred & t.hidden.equals(0);
        }
        if (types != null && types.isNotEmpty) {
          pred = pred & t.type.isIn(types);
        }
        return pred;
      })
      ..orderBy([
        (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      ]);
    if (limit != null && limit > 0) {
      query.limit(limit);
    }
    return query.watch();
  }

  /// Watches map of `timelineId -> attachment count` for a contact's visible entries.
  Stream<Map<int, int>> watchAttachmentCountsForPerson(int contactId) {
    return _db.select(_db.timelineAttachments).watch().map((rows) {
      final counts = <int, int>{};
      for (final r in rows) {
        counts[r.timelineId] = (counts[r.timelineId] ?? 0) + 1;
      }
      return counts;
    });
  }

  /// Watches scheduled/pending outbox messages for [contactId] (shown under Next).
  Stream<List<OutboxMessage>> watchScheduledOutboxForPerson(int contactId) {
    return (_db.select(_db.outboxMessages)
          ..where(
            (t) =>
                t.contactId.equals(contactId) &
                t.status.isIn(const ['queued', 'sending']),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.dueAt)]))
        .watch();
  }

  Future<TimelineEntry?> getById(int id) {
    return (_db.select(_db.timelineEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<List<TimelineEntry>> watchUnreviewedCalls({required int sinceMs}) {
    final query = _db.select(_db.timelineEntries)
      ..where(
        (t) =>
            t.type.isIn(const ['call_incoming', 'call_outgoing', 'call_missed']) &
            t.timestamp.isBiggerOrEqualValue(sinceMs) &
            t.reviewedAt.isNull() &
            t.note.isNull() &
            t.hidden.equals(0),
      )
      ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)]);
    return query.watch();
  }

  Stream<List<TimelineAttachment>> watchAttachments(int timelineId) {
    return (_db.select(_db.timelineAttachments)
          ..where((t) => t.timelineId.equals(timelineId))
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .watch();
  }

  Future<int> addNote({
    required int contactId,
    required String note,
    int? timestamp,
  }) async {
    final ts = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    final id = await _db.into(_db.timelineEntries).insert(
          TimelineEntriesCompanion.insert(
            contactId: Value(contactId),
            type: 'note',
            timestamp: ts,
            content: Value(note),
            note: Value(note),
            source: const Value('manual'),
          ),
        );
    await _db.rebuildFtsForContact(contactId);
    return id;
  }

  Future<int> addCall({
    required int contactId,
    required String directionType, // call_outgoing, call_incoming, call_missed
    required int timestamp,
    int? durationSeconds,
    String? outcome,
    String? note,
    String source = 'manual',
    bool reviewed = true,
  }) async {
    final id = await _db.into(_db.timelineEntries).insert(
          TimelineEntriesCompanion.insert(
            contactId: Value(contactId),
            type: directionType,
            timestamp: timestamp,
            content: Value(note ?? ''),
            note: Value(note),
            outcome: Value(outcome),
            durationSeconds: Value(durationSeconds),
            reviewedAt: Value(reviewed ? DateTime.now().millisecondsSinceEpoch : null),
            source: Value(source),
          ),
        );
    await recomputeLastInteraction(contactId);
    await _db.rebuildFtsForContact(contactId);
    return id;
  }

  Future<int> addVisit({
    required int contactId,
    required String placeName,
    required int timestamp,
    String? note,
    double? lat,
    double? lng,
    List<String> attachmentPaths = const [],
  }) async {
    final id = await _db.transaction(() async {
      final entryId = await _db.into(_db.timelineEntries).insert(
            TimelineEntriesCompanion.insert(
              contactId: Value(contactId),
              type: 'visit',
              timestamp: timestamp,
              content: Value(note ?? placeName),
              note: Value(note),
              placeName: Value(placeName),
              lat: Value(lat),
              lng: Value(lng),
              source: const Value('manual'),
            ),
          );
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final path in attachmentPaths) {
        await _db.into(_db.timelineAttachments).insert(
              TimelineAttachmentsCompanion.insert(
                timelineId: entryId,
                path: path,
                createdAt: Value(now),
              ),
            );
      }
      return entryId;
    });
    await recomputeLastInteraction(contactId);
    await _db.rebuildFtsForContact(contactId);
    return id;
  }

  Future<int> addFile({
    required int contactId,
    required String filePath,
    String? description,
    String? mime,
    int? timestamp,
  }) async {
    final ts = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    final id = await _db.transaction(() async {
      final entryId = await _db.into(_db.timelineEntries).insert(
            TimelineEntriesCompanion.insert(
              contactId: Value(contactId),
              type: 'attachment',
              timestamp: ts,
              content: Value(description ?? ''),
              note: Value(description),
              attachmentPath: Value(filePath),
              source: const Value('manual'),
            ),
          );
      await _db.into(_db.timelineAttachments).insert(
            TimelineAttachmentsCompanion.insert(
              timelineId: entryId,
              path: filePath,
              mime: Value(mime),
              createdAt: Value(ts),
            ),
          );
      return entryId;
    });
    await _db.rebuildFtsForContact(contactId);
    return id;
  }

  Future<void> updateCallNoteAndOutcome({
    required int timelineId,
    String? note,
    String? outcome,
  }) async {
    final existing = await getById(timelineId);
    if (existing == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.timelineEntries)..where((t) => t.id.equals(timelineId))).write(
      TimelineEntriesCompanion(
        note: Value(note),
        outcome: Value(outcome),
        reviewedAt: Value(now),
        editedAt: Value(now),
      ),
    );
    if (existing.contactId != null) {
      await _db.rebuildFtsForContact(existing.contactId!);
    }
  }

  Future<void> markCallReviewed(int timelineId) async {
    await (_db.update(_db.timelineEntries)..where((t) => t.id.equals(timelineId))).write(
      TimelineEntriesCompanion(
        reviewedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> updateEntry(int timelineId, TimelineEntriesCompanion update) async {
    final existing = await getById(timelineId);
    if (existing == null) return;
    await (_db.update(_db.timelineEntries)..where((t) => t.id.equals(timelineId))).write(
      update.copyWith(editedAt: Value(DateTime.now().millisecondsSinceEpoch)),
    );
    if (existing.contactId != null) {
      await recomputeLastInteraction(existing.contactId!);
      await _db.rebuildFtsForContact(existing.contactId!);
    }
  }

  Future<void> hideEntry(int timelineId) async {
    final existing = await getById(timelineId);
    if (existing == null) return;
    await (_db.update(_db.timelineEntries)..where((t) => t.id.equals(timelineId))).write(
      const TimelineEntriesCompanion(hidden: Value(1)),
    );
    if (existing.contactId != null) {
      await recomputeLastInteraction(existing.contactId!);
      await _db.rebuildFtsForContact(existing.contactId!);
    }
  }

  Future<void> unhideEntry(int timelineId) async {
    final existing = await getById(timelineId);
    if (existing == null) return;
    await (_db.update(_db.timelineEntries)..where((t) => t.id.equals(timelineId))).write(
      const TimelineEntriesCompanion(hidden: Value(0)),
    );
    if (existing.contactId != null) {
      await recomputeLastInteraction(existing.contactId!);
      await _db.rebuildFtsForContact(existing.contactId!);
    }
  }

  Future<TimelineEntry?> deleteEntry(int timelineId) async {
    final existing = await getById(timelineId);
    if (existing == null) return null;
    await (_db.delete(_db.timelineEntries)..where((t) => t.id.equals(timelineId))).go();
    if (existing.contactId != null) {
      await recomputeLastInteraction(existing.contactId!);
      await _db.rebuildFtsForContact(existing.contactId!);
    }
    return existing;
  }

  /// Restores a previously deleted entry (used for 5-second Undo snackbar).
  Future<int> restoreEntry(TimelineEntry entry) async {
    final id = await _db.into(_db.timelineEntries).insert(
          TimelineEntriesCompanion.insert(
            contactId: Value(entry.contactId),
            type: entry.type,
            timestamp: entry.timestamp,
            content: Value(entry.content),
            amount: Value(entry.amount),
            attachmentPath: Value(entry.attachmentPath),
            nativeMessageId: Value(entry.nativeMessageId),
            isPinned: Value(entry.isPinned),
            note: Value(entry.note),
            outcome: Value(entry.outcome),
            durationSeconds: Value(entry.durationSeconds),
            placeName: Value(entry.placeName),
            lat: Value(entry.lat),
            lng: Value(entry.lng),
            currency: Value(entry.currency),
            paymentStatus: Value(entry.paymentStatus),
            suggestedAmount: Value(entry.suggestedAmount),
            suggestionState: Value(entry.suggestionState),
            reviewedAt: Value(entry.reviewedAt),
            hidden: Value(entry.hidden),
            source: Value(entry.source),
            outboxClientId: Value(entry.outboxClientId),
            editedAt: Value(entry.editedAt),
          ),
        );
    if (entry.contactId != null) {
      await recomputeLastInteraction(entry.contactId!);
      await _db.rebuildFtsForContact(entry.contactId!);
    }
    return id;
  }

  Future<void> recomputeLastInteraction(int contactId) =>
      _queries.recomputeLastInteraction(contactId);
}
