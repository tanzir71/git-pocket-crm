import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

class PersonBalance {
  const PersonBalance({
    required this.netAmount,
    required this.hasTrackableEntries,
    this.latestUnpaidNote,
    this.currency,
  });

  static const zero = PersonBalance(netAmount: 0, hasTrackableEntries: false);

  /// Positive means the person owes the user ("Owes you").
  /// Negative means the user owes the person ("You owe").
  final double netAmount;
  final bool hasTrackableEntries;
  final String? latestUnpaidNote;
  final String? currency;

  bool get owesYou => hasTrackableEntries && netAmount > 0.005;
  bool get youOwe => hasTrackableEntries && netAmount < -0.005;
  bool get hasBalance => owesYou || youOwe;
  double get absoluteAmount => netAmount.abs();
}

class PaymentsRepository {
  PaymentsRepository(this._db);

  final AppDatabase _db;

  /// Pure computation matching Spec 02 step 8:
  /// `balance = (sum(owed_to_me) - sum(received)) - (sum(i_owe) - sum(paid))`
  /// over rows with `payment_status` in `{owed_to_me, received, i_owe, paid}`,
  /// and only when at least one `owed_to_me` or `i_owe` row exists.
  static PersonBalance computeBalance(List<TimelineEntry> entries) {
    double owedToMe = 0;
    double received = 0;
    double iOwe = 0;
    double paid = 0;
    bool hasDebtEntry = false;
    String? latestUnpaidNote;
    int latestUnpaidTs = -1;
    String? currency;

    for (final entry in entries) {
      if (entry.hidden == 1) continue;
      final status = entry.paymentStatus;
      final amt = entry.amount ?? 0;
      switch (status) {
        case 'owed_to_me':
          hasDebtEntry = true;
          owedToMe += amt;
          if (entry.timestamp > latestUnpaidTs) {
            latestUnpaidTs = entry.timestamp;
            latestUnpaidNote = entry.note ?? entry.content;
            currency = entry.currency ?? currency;
          }
        case 'received':
          received += amt;
          currency ??= entry.currency;
        case 'i_owe':
          hasDebtEntry = true;
          iOwe += amt;
          if (entry.timestamp > latestUnpaidTs) {
            latestUnpaidTs = entry.timestamp;
            latestUnpaidNote = entry.note ?? entry.content;
            currency = entry.currency ?? currency;
          }
        case 'paid':
          paid += amt;
          currency ??= entry.currency;
        default:
          break;
      }
    }

    if (!hasDebtEntry) {
      return PersonBalance.zero;
    }

    final net = (owedToMe - received) - (iOwe - paid);
    return PersonBalance(
      netAmount: net,
      hasTrackableEntries: true,
      latestUnpaidNote: latestUnpaidNote,
      currency: currency,
    );
  }

  Stream<PersonBalance> watchBalanceForPerson(int contactId) {
    return (_db.select(_db.timelineEntries)
          ..where(
            (t) =>
                t.contactId.equals(contactId) &
                t.type.equals('payment') &
                t.hidden.equals(0),
          ))
        .watch()
        .map(computeBalance);
  }

  Future<PersonBalance> getBalanceForPerson(int contactId) async {
    final rows = await (_db.select(_db.timelineEntries)
          ..where(
            (t) =>
                t.contactId.equals(contactId) &
                t.type.equals('payment') &
                t.hidden.equals(0),
          ))
        .get();
    return computeBalance(rows);
  }

  /// Watches map of `contactId -> PersonBalance` for everyone with `owesYou`.
  Stream<Map<int, PersonBalance>> watchPeopleWhoOweMe() {
    return (_db.select(_db.timelineEntries)
          ..where((t) => t.type.equals('payment') & t.hidden.equals(0)))
        .watch()
        .map((rows) {
      final grouped = <int, List<TimelineEntry>>{};
      for (final row in rows) {
        final cid = row.contactId;
        if (cid == null) continue;
        grouped.putIfAbsent(cid, () => []).add(row);
      }
      final result = <int, PersonBalance>{};
      grouped.forEach((cid, entries) {
        final bal = computeBalance(entries);
        if (bal.owesYou) {
          result[cid] = bal;
        }
      });
      return result;
    });
  }

  Future<int> addPayment({
    required int contactId,
    required double amount,
    required String paymentStatus, // received, paid, owed_to_me, i_owe
    String? note,
    String? currency,
    int? timestamp,
  }) async {
    final ts = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    final id = await _db.into(_db.timelineEntries).insert(
          TimelineEntriesCompanion.insert(
            contactId: Value(contactId),
            type: 'payment',
            timestamp: ts,
            amount: Value(amount),
            currency: Value(currency),
            paymentStatus: Value(paymentStatus),
            note: Value(note),
            content: Value(note ?? ''),
            source: const Value('manual'),
          ),
        );
    await _db.rebuildFtsForContact(contactId);
    return id;
  }

  Future<void> confirmSuggestedPayment({
    required int timelineId,
    required double amount,
    required String paymentStatus,
    String? note,
    String? currency,
  }) async {
    final entry = await (_db.select(_db.timelineEntries)..where((t) => t.id.equals(timelineId)))
        .getSingleOrNull();
    if (entry == null || entry.contactId == null) return;

    await _db.transaction(() async {
      await (_db.update(_db.timelineEntries)..where((t) => t.id.equals(timelineId))).write(
        const TimelineEntriesCompanion(suggestionState: Value('confirmed')),
      );
      await _db.into(_db.timelineEntries).insert(
            TimelineEntriesCompanion.insert(
              contactId: Value(entry.contactId),
              type: 'payment',
              timestamp: entry.timestamp,
              amount: Value(amount),
              currency: Value(currency),
              paymentStatus: Value(paymentStatus),
              note: Value(note ?? entry.content),
              content: Value(note ?? entry.content ?? ''),
              source: const Value('manual'),
            ),
          );
    });
  }

  Future<void> dismissSuggestedPayment(int timelineId) async {
    await (_db.update(_db.timelineEntries)..where((t) => t.id.equals(timelineId))).write(
      const TimelineEntriesCompanion(suggestionState: Value('dismissed')),
    );
  }
}
