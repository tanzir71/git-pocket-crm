import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

class PeopleRepository {
  PeopleRepository(this._db);

  final AppDatabase _db;

  Stream<List<Contact>> watchAll() {
    return (_db.select(_db.contacts)
          ..orderBy([
            (t) => OrderingTerm(expression: t.lastInteractionAt, mode: OrderingMode.desc, nulls: NullsOrder.last),
            (t) => OrderingTerm(expression: t.displayName),
          ]))
        .watch();
  }

  Future<List<Contact>> getAll() {
    return (_db.select(_db.contacts)
          ..orderBy([
            (t) => OrderingTerm(expression: t.lastInteractionAt, mode: OrderingMode.desc, nulls: NullsOrder.last),
            (t) => OrderingTerm(expression: t.displayName),
          ]))
        .get();
  }

  Stream<Contact?> watchById(int id) {
    return (_db.select(_db.contacts)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<Contact?> getById(int id) {
    return (_db.select(_db.contacts)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<List<Contact>> watchStarred() {
    return (_db.select(_db.contacts)
          ..where((t) => t.isStarred.equals(1))
          ..orderBy([(t) => OrderingTerm(expression: t.displayName)]))
        .watch();
  }

  Stream<List<ContactPhone>> watchPhones(int contactId) {
    return (_db.select(_db.contactPhones)
          ..where((t) => t.contactId.equals(contactId))
          ..orderBy([(t) => OrderingTerm(expression: t.isPrimary, mode: OrderingMode.desc), (t) => OrderingTerm(expression: t.id)]))
        .watch();
  }

  Future<List<ContactPhone>> getPhones(int contactId) {
    return (_db.select(_db.contactPhones)
          ..where((t) => t.contactId.equals(contactId))
          ..orderBy([(t) => OrderingTerm(expression: t.isPrimary, mode: OrderingMode.desc), (t) => OrderingTerm(expression: t.id)]))
        .get();
  }

  /// Searches people by name, company, phone numbers, about, and note text.
  /// Uses FTS5 when available and falls back to `LIKE` otherwise.
  Future<List<Contact>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return getAll();
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

  String _buildFtsQuery(String input) {
    final tokens = input
        .split(RegExp(r'\s+'))
        .map((t) => t.replaceAll(RegExp(r'["*():^]'), '').trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return '';
    return tokens.map((t) => '"$t"*').join(' ');
  }

  Future<int> createPerson({
    required String displayName,
    required String phoneNumber,
    String? company,
    String? role,
    String? city,
    String? email,
    String? birthday,
    String? about,
    String source = 'manual',
    bool isMobile = true,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = await _db.transaction(() async {
      final contactId = await _db.into(_db.contacts).insert(
            ContactsCompanion.insert(
              displayName: displayName,
              phoneNumber: Value(phoneNumber),
              company: Value(company),
              role: Value(role),
              city: Value(city),
              email: Value(email),
              gmailAddress: Value(email),
              birthday: Value(birthday),
              about: Value(about),
              pinnedNote: Value(about),
              source: Value(source),
              createdAt: Value(now),
            ),
          );

      if (phoneNumber.trim().isNotEmpty) {
        await _db.into(_db.contactPhones).insert(
              ContactPhonesCompanion.insert(
                contactId: contactId,
                e164: Value(phoneNumber.trim()),
                raw: Value(phoneNumber.trim()),
                label: const Value('mobile'),
                isPrimary: const Value(1),
                isMobile: Value(isMobile ? 1 : 0),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }

      return contactId;
    });

    await _db.rebuildFtsForContact(id);
    return id;
  }

  Future<void> updatePerson(int id, ContactsCompanion update) async {
    await (_db.update(_db.contacts)..where((t) => t.id.equals(id))).write(update);
    await _db.rebuildFtsForContact(id);
  }

  Future<void> toggleStar(int id) async {
    final existing = await getById(id);
    if (existing == null) return;
    await (_db.update(_db.contacts)..where((t) => t.id.equals(id))).write(
      ContactsCompanion(isStarred: Value(existing.isStarred == 1 ? 0 : 1)),
    );
  }

  Future<void> setCadence(int id, int? cadenceDays) async {
    await (_db.update(_db.contacts)..where((t) => t.id.equals(id))).write(
      ContactsCompanion(
        cadenceDays: Value(cadenceDays),
        cadenceSnoozedUntil: const Value(null),
      ),
    );
  }

  Future<void> snoozeReconnect(int id, int? untilMs) async {
    await (_db.update(_db.contacts)..where((t) => t.id.equals(id))).write(
      ContactsCompanion(cadenceSnoozedUntil: Value(untilMs)),
    );
  }

  Future<void> setDoNotMessage(int id, bool value) async {
    await (_db.update(_db.contacts)..where((t) => t.id.equals(id))).write(
      ContactsCompanion(doNotMessage: Value(value ? 1 : 0)),
    );
  }

  Future<int> addPhone({
    required int contactId,
    required String e164,
    String? raw,
    String? label,
    bool isPrimary = false,
    bool isMobile = true,
  }) async {
    final phoneId = await _db.transaction(() async {
      if (isPrimary) {
        await (_db.update(_db.contactPhones)..where((t) => t.contactId.equals(contactId)))
            .write(const ContactPhonesCompanion(isPrimary: Value(0)));
        await (_db.update(_db.contacts)..where((t) => t.id.equals(contactId)))
            .write(ContactsCompanion(phoneNumber: Value(e164)));
      }
      return _db.into(_db.contactPhones).insert(
            ContactPhonesCompanion.insert(
              contactId: contactId,
              e164: Value(e164),
              raw: Value(raw ?? e164),
              label: Value(label),
              isPrimary: Value(isPrimary ? 1 : 0),
              isMobile: Value(isMobile ? 1 : 0),
            ),
            mode: InsertMode.insertOrReplace,
          );
    });
    await _db.rebuildFtsForContact(contactId);
    return phoneId;
  }

  Future<void> deletePhone(int phoneId, int contactId) async {
    await (_db.delete(_db.contactPhones)..where((t) => t.id.equals(phoneId))).go();
    await _db.rebuildFtsForContact(contactId);
  }

  Future<void> deletePerson(int id) async {
    await (_db.delete(_db.contacts)..where((t) => t.id.equals(id))).go();
    if (_db.fts5Available) {
      await _db.customStatement('DELETE FROM contacts_fts WHERE contact_id = ?', [id]);
    }
  }
}
