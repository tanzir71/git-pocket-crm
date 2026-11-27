import 'package:drift/drift.dart';

import 'app_database.dart';

/// Filter options for the People directory.
enum PeopleFilterKind {
  all,
  starred,
  dueToReconnect,
  owesMe,
  list,
}

/// Sort options for the People directory.
enum PeopleSort {
  recent,
  name,
  longest,
}

/// Single-row projection returned by the single-query People directory.
class PersonDirectoryItem {
  const PersonDirectoryItem({
    required this.contact,
    required this.firstListName,
    required this.lastInteractionType,
    required this.hasOverdueFollowUp,
    required this.owesMe,
    required this.netBalance,
    required this.effectiveCadenceDays,
  });

  final Contact contact;
  final String? firstListName;
  final String? lastInteractionType;
  final bool hasOverdueFollowUp;
  final bool owesMe;
  final double netBalance;
  final int? effectiveCadenceDays;

  /// Whether this person's reconnect cadence is currently due at [nowMs].
  bool isDueToReconnect(int nowMs) {
    final days = effectiveCadenceDays;
    if (days == null || days <= 0) return false;
    final snoozedUntil = contact.cadenceSnoozedUntil;
    if (snoozedUntil != null && snoozedUntil > nowMs) return false;
    final last = contact.lastInteractionAt ?? contact.createdAt ?? 0;
    final dueAt = last + days * Duration.millisecondsPerDay;
    return dueAt <= nowMs;
  }
}

/// Summary of a contact list with its member count.
class ListSummaryRow {
  const ListSummaryRow({
    required this.list,
    required this.memberCount,
  });

  final ContactList list;
  final int memberCount;
}

/// Open task joined with its contact's display name.
class TaskWithPersonRow {
  const TaskWithPersonRow({
    required this.task,
    required this.personName,
  });

  final Task task;
  final String personName;
}

/// Centralizes all custom SQL queries inside `lib/core/db/` so feature
/// repositories and UI files never embed raw SQL strings.
class CrmQueries {
  CrmQueries(this._db);

  final AppDatabase _db;

  /// Watches the full People directory in a single SQL query.
  ///
  /// When [searchQuery] is non-empty, resolves matching contact IDs via FTS5
  /// (plus normalized digit matching on phone numbers) or LIKE fallback.
  Stream<List<PersonDirectoryItem>> watchPeopleDirectory({
    required int nowMs,
    required int startOfTodayMs,
    String searchQuery = '',
    PeopleFilterKind filter = PeopleFilterKind.all,
    int? listId,
    PeopleSort sort = PeopleSort.recent,
  }) {
    final trimmed = searchQuery.trim();
    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    final ftsQuery = _buildFtsQuery(trimmed);
    final likePattern = '%${trimmed.toLowerCase()}%';

    final whereClauses = <String>[];
    final variables = <Variable<Object>>[
      Variable<int>(startOfTodayMs),
    ];

    if (trimmed.isNotEmpty) {
      if (_db.fts5Available && ftsQuery.isNotEmpty) {
        if (digitsOnly.length >= 3) {
          whereClauses.add('''
            (
              c.id IN (SELECT contact_id FROM contacts_fts WHERE contacts_fts MATCH ?)
              OR REPLACE(REPLACE(REPLACE(COALESCE(c.phone_number, ''), '-', ''), ' ', ''), '+', '') LIKE ?
              OR EXISTS (
                SELECT 1 FROM contact_phones cp
                WHERE cp.contact_id = c.id
                  AND (
                    REPLACE(REPLACE(REPLACE(COALESCE(cp.e164, ''), '-', ''), ' ', ''), '+', '') LIKE ?
                    OR REPLACE(REPLACE(REPLACE(COALESCE(cp.raw, ''), '-', ''), ' ', ''), '+', '') LIKE ?
                  )
              )
            )
          ''');
          variables.addAll([
            Variable<String>(ftsQuery),
            Variable<String>('%$digitsOnly%'),
            Variable<String>('%$digitsOnly%'),
            Variable<String>('%$digitsOnly%'),
          ]);
        } else {
          whereClauses.add(
            'c.id IN (SELECT contact_id FROM contacts_fts WHERE contacts_fts MATCH ?)',
          );
          variables.add(Variable<String>(ftsQuery));
        }
      } else {
        whereClauses.add('''
          (
            LOWER(c.display_name) LIKE ?
            OR LOWER(COALESCE(c.company, '')) LIKE ?
            OR LOWER(COALESCE(c.phone_number, '')) LIKE ?
            OR LOWER(COALESCE(c.about, '')) LIKE ?
            OR EXISTS (
              SELECT 1 FROM contact_phones cp
              WHERE cp.contact_id = c.id
                AND (LOWER(COALESCE(cp.e164, '')) LIKE ? OR LOWER(COALESCE(cp.raw, '')) LIKE ?)
            )
            OR EXISTS (
              SELECT 1 FROM timeline t
              WHERE t.contact_id = c.id AND COALESCE(t.hidden, 0) = 0
                AND (LOWER(COALESCE(t.note, '')) LIKE ? OR LOWER(COALESCE(t.content, '')) LIKE ?)
            )
          )
        ''');
        variables.addAll(List.filled(8, Variable<String>(likePattern)));
      }
    }

    switch (filter) {
      case PeopleFilterKind.all:
        break;
      case PeopleFilterKind.starred:
        whereClauses.add('c.is_starred = 1');
      case PeopleFilterKind.list:
        if (listId != null) {
          whereClauses.add(
            'EXISTS (SELECT 1 FROM contact_list_members clm WHERE clm.contact_id = c.id AND clm.list_id = ?)',
          );
          variables.add(Variable<int>(listId));
        }
      case PeopleFilterKind.owesMe:
        // Filtered cleanly after balance formula below (also pre-filtered to contacts with debt entries)
        whereClauses.add('''
          EXISTS (
            SELECT 1 FROM timeline t
            WHERE t.contact_id = c.id
              AND t.type = 'payment'
              AND COALESCE(t.hidden, 0) = 0
              AND t.payment_status IN ('owed_to_me', 'i_owe')
          )
        ''');
      case PeopleFilterKind.dueToReconnect:
        whereClauses.add('''
          (
            c.cadence_days IS NOT NULL
            OR EXISTS (
              SELECT 1 FROM contact_list_members clm
              JOIN contact_lists cl ON cl.id = clm.list_id
              WHERE clm.contact_id = c.id AND cl.cadence_days IS NOT NULL
            )
          )
        ''');
    }

    final whereSql = whereClauses.isEmpty ? '' : 'WHERE ${whereClauses.join(' AND ')}';

    final orderSql = switch (sort) {
      PeopleSort.recent =>
        'ORDER BY (c.last_interaction_at IS NULL) ASC, c.last_interaction_at DESC, LOWER(c.display_name) ASC',
      PeopleSort.name => 'ORDER BY LOWER(c.display_name) ASC, c.id ASC',
      PeopleSort.longest =>
        'ORDER BY (c.last_interaction_at IS NULL) ASC, c.last_interaction_at ASC, LOWER(c.display_name) ASC',
    };

    final sql = '''
      SELECT
        c.*,
        (
          SELECT cl.name
          FROM contact_lists cl
          JOIN contact_list_members clm ON clm.list_id = cl.id
          WHERE clm.contact_id = c.id
          ORDER BY LOWER(cl.name) ASC
          LIMIT 1
        ) AS first_list_name,
        (
          SELECT t.type
          FROM timeline t
          WHERE t.contact_id = c.id
            AND COALESCE(t.hidden, 0) = 0
            AND (
              (t.type IN ('call_incoming', 'call_outgoing') AND COALESCE(t.duration_seconds, 0) > 0)
              OR t.type IN ('sms_incoming', 'sms_outgoing', 'visit')
            )
          ORDER BY t.timestamp DESC
          LIMIT 1
        ) AS last_interaction_type,
        EXISTS (
          SELECT 1
          FROM tasks tk
          WHERE tk.contact_id = c.id
            AND tk.is_completed = 0
            AND tk.due_date < ?
        ) AS has_overdue_followup,
        COALESCE(
          c.cadence_days,
          (
            SELECT MIN(cl.cadence_days)
            FROM contact_lists cl
            JOIN contact_list_members clm ON clm.list_id = cl.id
            WHERE clm.contact_id = c.id AND cl.cadence_days IS NOT NULL
          )
        ) AS effective_cadence_days,
        (
          SELECT CASE
            WHEN SUM(CASE WHEN t.payment_status IN ('owed_to_me', 'i_owe') THEN 1 ELSE 0 END) > 0 THEN
              (
                SUM(CASE WHEN t.payment_status = 'owed_to_me' THEN COALESCE(t.amount, 0) ELSE 0 END)
                - SUM(CASE WHEN t.payment_status = 'received' THEN COALESCE(t.amount, 0) ELSE 0 END)
              ) - (
                SUM(CASE WHEN t.payment_status = 'i_owe' THEN COALESCE(t.amount, 0) ELSE 0 END)
                - SUM(CASE WHEN t.payment_status = 'paid' THEN COALESCE(t.amount, 0) ELSE 0 END)
              )
            ELSE 0.0
          END
          FROM timeline t
          WHERE t.contact_id = c.id
            AND t.type = 'payment'
            AND COALESCE(t.hidden, 0) = 0
        ) AS net_balance
      FROM contacts c
      $whereSql
      $orderSql
    ''';

    return _db
        .customSelect(
          sql,
          variables: variables,
          readsFrom: {
            _db.contacts,
            _db.contactPhones,
            _db.contactLists,
            _db.contactListMembers,
            _db.timelineEntries,
            _db.tasks,
          },
        )
        .watch()
        .map((rows) {
      final items = <PersonDirectoryItem>[];
      for (final row in rows) {
        final contact = _db.contacts.map(row.data);
        final net = row.readNullable<double>('net_balance') ?? 0.0;
        final item = PersonDirectoryItem(
          contact: contact,
          firstListName: row.readNullable<String>('first_list_name'),
          lastInteractionType: row.readNullable<String>('last_interaction_type'),
          hasOverdueFollowUp: (row.readNullable<int>('has_overdue_followup') ?? 0) != 0,
          owesMe: net > 0.005,
          netBalance: net,
          effectiveCadenceDays: row.readNullable<int>('effective_cadence_days'),
        );
        if (filter == PeopleFilterKind.owesMe && !item.owesMe) continue;
        if (filter == PeopleFilterKind.dueToReconnect && !item.isDueToReconnect(nowMs)) continue;
        items.add(item);
      }
      return items;
    });
  }

  /// Searches contacts by name, company, phone numbers, about, and note text.
  Future<List<Contact>> searchContacts(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return (_db.select(_db.contacts)
            ..orderBy([
              (t) => OrderingTerm(
                    expression: t.lastInteractionAt,
                    mode: OrderingMode.desc,
                    nulls: NullsOrder.last,
                  ),
              (t) => OrderingTerm(expression: t.displayName),
            ]))
          .get();
    }

    if (_db.fts5Available) {
      final ftsQuery = _buildFtsQuery(trimmed);
      if (ftsQuery.isNotEmpty) {
        try {
          final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
          final rows = await _db.customSelect(
            '''
            SELECT DISTINCT c.*
            FROM contacts c
            LEFT JOIN contact_phones cp ON cp.contact_id = c.id
            WHERE c.id IN (SELECT contact_id FROM contacts_fts WHERE contacts_fts MATCH ?)
               ${digitsOnly.length >= 3 ? "OR REPLACE(REPLACE(REPLACE(COALESCE(c.phone_number, ''), '-', ''), ' ', ''), '+', '') LIKE ? OR REPLACE(REPLACE(REPLACE(COALESCE(cp.e164, ''), '-', ''), ' ', ''), '+', '') LIKE ? OR REPLACE(REPLACE(REPLACE(COALESCE(cp.raw, ''), '-', ''), ' ', ''), '+', '') LIKE ?" : ''}
            ORDER BY c.last_interaction_at DESC, c.display_name ASC
            ''',
            variables: [
              Variable<String>(ftsQuery),
              if (digitsOnly.length >= 3) ...[
                Variable<String>('%$digitsOnly%'),
                Variable<String>('%$digitsOnly%'),
                Variable<String>('%$digitsOnly%'),
              ],
            ],
            readsFrom: {_db.contacts, _db.contactPhones},
          ).get();
          return rows.map((r) => _db.contacts.map(r.data)).toList();
        } catch (_) {
          // Fall through to LIKE fallback on malformed FTS syntax.
        }
      }
    }

    final pattern = '%${trimmed.toLowerCase()}%';
    final rows = await _db.customSelect(
      '''
      SELECT DISTINCT c.*
      FROM contacts c
      LEFT JOIN contact_phones cp ON cp.contact_id = c.id
      LEFT JOIN timeline t ON t.contact_id = c.id AND COALESCE(t.hidden, 0) = 0
      WHERE LOWER(c.display_name) LIKE ?
         OR LOWER(COALESCE(c.company, '')) LIKE ?
         OR LOWER(COALESCE(c.phone_number, '')) LIKE ?
         OR LOWER(COALESCE(c.about, '')) LIKE ?
         OR LOWER(COALESCE(cp.e164, '')) LIKE ?
         OR LOWER(COALESCE(cp.raw, '')) LIKE ?
         OR LOWER(COALESCE(t.note, '')) LIKE ?
         OR LOWER(COALESCE(t.content, '')) LIKE ?
      ORDER BY c.last_interaction_at DESC, c.display_name ASC
      ''',
      variables: List.filled(8, Variable<String>(pattern)),
      readsFrom: {_db.contacts, _db.contactPhones, _db.timelineEntries},
    ).get();
    return rows.map((r) => _db.contacts.map(r.data)).toList();
  }

  Future<void> deleteFtsForContact(int contactId) async {
    if (!_db.fts5Available) return;
    await _db.customStatement(
      'DELETE FROM contacts_fts WHERE contact_id = ?',
      [contactId],
    );
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

  Future<void> recomputeLastInteractions(Iterable<int> contactIds) async {
    for (final cid in contactIds) {
      await recomputeLastInteraction(cid);
    }
  }

  Stream<List<ListSummaryRow>> watchListSummaries() {
    return _db
        .customSelect(
          '''
          SELECT cl.*, COUNT(clm.contact_id) AS member_count
          FROM contact_lists cl
          LEFT JOIN contact_list_members clm ON cl.id = clm.list_id
          GROUP BY cl.id
          ORDER BY LOWER(cl.name) ASC
          ''',
          readsFrom: {_db.contactLists, _db.contactListMembers},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (r) => ListSummaryRow(
                  list: _db.contactLists.map(r.data),
                  memberCount: r.read<int>('member_count'),
                ),
              )
              .toList(),
        );
  }

  Stream<List<Contact>> watchListMembers(int listId) {
    return _db
        .customSelect(
          '''
          SELECT c.*
          FROM contacts c
          JOIN contact_list_members clm ON clm.contact_id = c.id
          WHERE clm.list_id = ?
          ORDER BY LOWER(c.display_name) ASC
          ''',
          variables: [Variable<int>(listId)],
          readsFrom: {_db.contacts, _db.contactListMembers},
        )
        .watch()
        .map((rows) => rows.map((r) => _db.contacts.map(r.data)).toList());
  }

  Future<List<Contact>> getListMembers(int listId) async {
    final rows = await _db.customSelect(
      '''
      SELECT c.*
      FROM contacts c
      JOIN contact_list_members clm ON clm.contact_id = c.id
      WHERE clm.list_id = ?
      ORDER BY LOWER(c.display_name) ASC
      ''',
      variables: [Variable<int>(listId)],
    ).get();
    return rows.map((r) => _db.contacts.map(r.data)).toList();
  }

  Stream<List<ContactList>> watchListsForContact(int contactId) {
    return _db
        .customSelect(
          '''
          SELECT cl.*
          FROM contact_lists cl
          JOIN contact_list_members clm ON clm.list_id = cl.id
          WHERE clm.contact_id = ?
          ORDER BY LOWER(cl.name) ASC
          ''',
          variables: [Variable<int>(contactId)],
          readsFrom: {_db.contactLists, _db.contactListMembers},
        )
        .watch()
        .map((rows) => rows.map((r) => _db.contactLists.map(r.data)).toList());
  }

  Future<int> countListMembersWithoutOwnCadence(int listId) async {
    final row = await _db.customSelect(
      '''
      SELECT COUNT(*) AS cnt
      FROM contacts c
      JOIN contact_list_members clm ON clm.contact_id = c.id
      WHERE clm.list_id = ? AND c.cadence_days IS NULL
      ''',
      variables: [Variable<int>(listId)],
    ).getSingle();
    return row.read<int>('cnt');
  }

  Stream<List<TaskWithPersonRow>> watchDueAndOverdueTasks(int endOfTodayMs) {
    return _db
        .customSelect(
          '''
          SELECT t.*, COALESCE(c.display_name, '') AS person_name
          FROM tasks t
          LEFT JOIN contacts c ON c.id = t.contact_id
          WHERE t.is_completed = 0 AND t.due_date <= ?
          ORDER BY t.due_date ASC, t.id ASC
          ''',
          variables: [Variable<int>(endOfTodayMs)],
          readsFrom: {_db.tasks, _db.contacts},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (r) => TaskWithPersonRow(
                  task: _db.tasks.map(r.data),
                  personName: r.read<String>('person_name'),
                ),
              )
              .toList(),
        );
  }

  Stream<List<TaskWithPersonRow>> watchAllOpenTasks() {
    return _db
        .customSelect(
          '''
          SELECT t.*, COALESCE(c.display_name, '') AS person_name
          FROM tasks t
          LEFT JOIN contacts c ON c.id = t.contact_id
          WHERE t.is_completed = 0
          ORDER BY t.due_date ASC, t.id ASC
          ''',
          readsFrom: {_db.tasks, _db.contacts},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (r) => TaskWithPersonRow(
                  task: _db.tasks.map(r.data),
                  personName: r.read<String>('person_name'),
                ),
              )
              .toList(),
        );
  }

  /// Sync helper: rewrites legacy bare numeric SMS native_message_id rows to `sms:<id>`.
  Future<void> rewriteLegacyBareSmsIds() async {
    final legacySms = await _db.customSelect(
      '''
      SELECT id, native_message_id
      FROM timeline
      WHERE type IN ('sms_incoming', 'sms_outgoing')
        AND native_message_id IS NOT NULL
        AND native_message_id NOT LIKE 'sms:%'
        AND native_message_id NOT LIKE 'outbox:%'
      ''',
    ).get();

    for (final row in legacySms) {
      final id = row.read<int>('id');
      final rawId = row.read<String>('native_message_id').trim();
      if (rawId.isEmpty) continue;
      final prefixed = 'sms:$rawId';
      final clash = await _db.customSelect(
        'SELECT id FROM timeline WHERE native_message_id = ?',
        variables: [Variable<String>(prefixed)],
      ).get();
      if (clash.isEmpty) {
        await _db.customStatement(
          'UPDATE timeline SET native_message_id = ? WHERE id = ?',
          [prefixed, id],
        );
      } else {
        await _db.customStatement(
          'UPDATE timeline SET native_message_id = NULL, hidden = 1 WHERE id = ?',
          [id],
        );
      }
    }
  }

  /// Sync helper: matches a legacy un-stamped call row and stamps it with `call:<id>`.
  /// Returns `true` if an existing row was matched and stamped.
  Future<bool> stampLegacyCallIfPresent({
    required int contactId,
    required String type,
    required int timestampMs,
    required String nativeId,
    required int durationSeconds,
  }) async {
    final existingLegacy = await _db.customSelect(
      '''
      SELECT id FROM timeline
      WHERE contact_id = ?
        AND type = ?
        AND timestamp = ?
        AND native_message_id IS NULL
      LIMIT 1
      ''',
      variables: [
        Variable<int>(contactId),
        Variable<String>(type),
        Variable<int>(timestampMs),
      ],
    ).get();

    if (existingLegacy.isEmpty) return false;
    final rowId = existingLegacy.first.read<int>('id');
    await _db.customStatement(
      'UPDATE timeline SET native_message_id = ?, duration_seconds = COALESCE(duration_seconds, ?), source = ? WHERE id = ?',
      [nativeId, durationSeconds, 'device', rowId],
    );
    return true;
  }

  String _buildFtsQuery(String input) {
    final tokens = input
        .split(RegExp(r'\s+'))
        .map((t) => t.replaceAll(RegExp(r'["*():^]'), '').trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return '';
    return tokens.map((t) => '"$t"*').join(' ');
  }
}
