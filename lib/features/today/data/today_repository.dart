import '../../../core/db/app_database.dart';
import '../../../core/db/crm_queries.dart';
import 'cadence_calculator.dart';

export '../../../core/db/crm_queries.dart' show OutboxWithPersonRow, PromptCallRow;

/// Repository powering all six Today sections without embedding SQL in `lib/features/`.
class TodayRepository {
  TodayRepository(this._db) : _queries = CrmQueries(_db);

  final AppDatabase _db;
  final CrmQueries _queries;

  Stream<PromptCallRow?> watchPromptCall({
    required DateTime now,
    required String afterCallMode,
  }) {
    final sinceMs = now.subtract(const Duration(hours: 12)).millisecondsSinceEpoch;
    return _queries.watchPromptCall(sinceMs: sinceMs, afterCallMode: afterCallMode);
  }

  Stream<List<DueReconnectItem>> watchDueToReconnect({required DateTime now}) {
    return _queries.watchReconnectCandidates().map((rows) {
      final candidates = rows
          .map(
            (r) => ReconnectCandidate(
              contact: r.contact,
              listCadenceDays: r.listCadenceDays,
              lastInteractionType: r.lastInteractionType,
            ),
          )
          .toList();
      return CadenceCalculator.computeDueList(candidates, now: now);
    });
  }

  Future<List<DueReconnectItem>> getDueToReconnectOnce({required DateTime now}) {
    return watchDueToReconnect(now: now).first;
  }

  Stream<List<UpcomingBirthdayItem>> watchUpcomingBirthdays({required DateTime now}) {
    return (_db.select(_db.contacts)..where((t) => t.birthday.isNotNull()))
        .watch()
        .map((contacts) => CadenceCalculator.computeUpcomingBirthdays(contacts, now: now));
  }

  Stream<List<OutboxWithPersonRow>> watchNeedsAttention() =>
      _queries.watchNeedsAttentionOutbox();

  Stream<List<OutboxWithPersonRow>> watchGoingOutToday({required DateTime now}) {
    final start = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999).millisecondsSinceEpoch;
    return _queries.watchGoingOutTodayOutbox(start, end);
  }

  Stream<bool> watchHasAnyCadence() => _queries.watchHasAnyCadence();
}
