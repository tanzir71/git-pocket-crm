import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

class HistoryRepository {
  HistoryRepository(this._db);

  final AppDatabase _db;

  Stream<List<TimelineEntry>> watchForPerson(
    int contactId, {
    Set<String>? types,
    bool includeHidden = false,
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
      ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)]);
    return query.watch();
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

  Future<void> deleteEntry(int timelineId) async {
    final existing = await getById(timelineId);
    if (existing == null) return;
    await (_db.delete(_db.timelineEntries)..where((t) => t.id.equals(timelineId))).go();
    if (existing.contactId != null) {
      await recomputeLastInteraction(existing.contactId!);
      await _db.rebuildFtsForContact(existing.contactId!);
    }
  }

  Future<void> recomputeLastInteraction(int contactId) async {
    await _db.customStatement(
      '''
      UPDATE contacts
      SET last_interaction_at = (
        SELECT MAX(t.timestamp)
        FROM timeline t
        WHERE t.contact_id = ?
          AND COALESCE(t.hidden, 0) = 0
          AND (
            (t.type IN ('call_incoming', 'call_outgoing') AND COALESCE(t.duration_seconds, 0) > 0)
            OR t.type IN ('sms_incoming', 'sms_outgoing', 'visit')
          )
      )
      WHERE id = ?
      ''',
      [contactId, contactId],
    );
  }
}
