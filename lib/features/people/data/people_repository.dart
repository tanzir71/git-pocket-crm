import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/crm_queries.dart';

export '../../../core/db/crm_queries.dart'
    show PeopleFilterKind, PeopleSort, PersonDirectoryItem;

/// A resolved merge suggestion pairing two existing contacts sharing a number.
class ResolvedMergeSuggestion {
  const ResolvedMergeSuggestion({
    required this.contactA,
    required this.contactB,
    required this.e164,
  });

  final Contact contactA;
  final Contact contactB;
  final String e164;
}

/// Editable phone entry for the Add/Edit person sheet.
class PhoneDraft {
  const PhoneDraft({
    required this.raw,
    this.e164,
    this.label = 'mobile',
    this.isPrimary = false,
    this.isMobile = true,
  });

  final String raw;
  final String? e164;
  final String label;
  final bool isPrimary;
  final bool isMobile;
}

class PeopleRepository {
  PeopleRepository(this._db) : _queries = CrmQueries(_db);

  final AppDatabase _db;
  final CrmQueries _queries;

  Stream<List<Contact>> watchAll() {
    return (_db.select(_db.contacts)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.lastInteractionAt,
                  mode: OrderingMode.desc,
                  nulls: NullsOrder.last,
                ),
            (t) => OrderingTerm(expression: t.displayName),
          ]))
        .watch();
  }

  Future<List<Contact>> getAll() {
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

  /// Single-query People directory stream supporting search, filter, and sort.
  Stream<List<PersonDirectoryItem>> watchDirectory({
    required DateTime now,
    String searchQuery = '',
    PeopleFilterKind filter = PeopleFilterKind.all,
    int? listId,
    PeopleSort sort = PeopleSort.recent,
  }) {
    final startOfTodayMs = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    return _queries.watchPeopleDirectory(
      nowMs: now.millisecondsSinceEpoch,
      startOfTodayMs: startOfTodayMs,
      searchQuery: searchQuery,
      filter: filter,
      listId: listId,
      sort: sort,
    );
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
          ..orderBy([
            (t) => OrderingTerm(expression: t.isPrimary, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.id),
          ]))
        .watch();
  }

  Future<List<ContactPhone>> getPhones(int contactId) {
    return (_db.select(_db.contactPhones)
          ..where((t) => t.contactId.equals(contactId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.isPrimary, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.id),
          ]))
        .get();
  }

  /// Finds an existing contact owning [e164] (or exact [raw]), optionally
  /// excluding [excludeContactId].
  Future<Contact?> findByPhone(String value, {int? excludeContactId}) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final phoneRow = await (_db.select(_db.contactPhones)
          ..where((t) => t.e164.equals(trimmed) | t.raw.equals(trimmed))
          ..limit(1))
        .getSingleOrNull();
    if (phoneRow != null && phoneRow.contactId != excludeContactId) {
      return getById(phoneRow.contactId);
    }

    final contactRow = await (_db.select(_db.contacts)
          ..where((t) => t.phoneNumber.equals(trimmed))
          ..limit(1))
        .getSingleOrNull();
    if (contactRow != null && contactRow.id != excludeContactId) {
      return contactRow;
    }
    return null;
  }

  /// Searches people by name, company, phone numbers, about, and note text.
  Future<List<Contact>> search(String query) => _queries.searchContacts(query);

  Future<int> createPerson({
    required String displayName,
    required String phoneNumber,
    String? company,
    String? role,
    String? city,
    String? email,
    String? birthday,
    String? about,
    String? linkedinUrl,
    String? facebookUrl,
    String source = 'manual',
    bool isMobile = true,
    List<PhoneDraft>? phones,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final effectivePhones = (phones != null && phones.isNotEmpty)
        ? phones
        : [
            PhoneDraft(
              raw: phoneNumber.trim(),
              e164: phoneNumber.trim().startsWith('+') ? phoneNumber.trim() : null,
              isPrimary: true,
              isMobile: isMobile,
            ),
          ];

    final primary = effectivePhones.firstWhere(
      (p) => p.isPrimary,
      orElse: () => effectivePhones.first,
    );
    final primaryValue = (primary.e164 != null && primary.e164!.isNotEmpty)
        ? primary.e164!
        : primary.raw.trim();

    final id = await _db.transaction(() async {
      final contactId = await _db.into(_db.contacts).insert(
            ContactsCompanion.insert(
              displayName: displayName.trim(),
              phoneNumber: Value(primaryValue.isEmpty ? null : primaryValue),
              company: Value(_nullIfEmpty(company)),
              role: Value(_nullIfEmpty(role)),
              city: Value(_nullIfEmpty(city)),
              email: Value(_nullIfEmpty(email)),
              gmailAddress: Value(_nullIfEmpty(email)),
              birthday: Value(_nullIfEmpty(birthday)),
              linkedinUrl: Value(_nullIfEmpty(linkedinUrl)),
              facebookUrl: Value(_nullIfEmpty(facebookUrl)),
              about: Value(_nullIfEmpty(about)),
              pinnedNote: Value(_nullIfEmpty(about)),
              source: Value(source),
              createdAt: Value(now),
            ),
          );

      for (final phone in effectivePhones) {
        final raw = phone.raw.trim();
        if (raw.isEmpty) continue;
        final e164 = (phone.e164 != null && phone.e164!.trim().isNotEmpty)
            ? phone.e164!.trim()
            : null;
        await _db.into(_db.contactPhones).insert(
              ContactPhonesCompanion.insert(
                contactId: contactId,
                e164: Value(e164 ?? raw),
                raw: Value(raw),
                label: Value(phone.label),
                isPrimary: Value(phone.isPrimary ? 1 : 0),
                isMobile: Value(phone.isMobile ? 1 : 0),
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

  /// Replaces all phone rows for [contactId] and updates `contacts.phone_number`
  /// to match the chosen primary number.
  Future<void> replacePhones(int contactId, List<PhoneDraft> phones) async {
    final cleaned = phones.where((p) => p.raw.trim().isNotEmpty).toList();
    if (cleaned.isEmpty) return;

    final primary = cleaned.firstWhere(
      (p) => p.isPrimary,
      orElse: () => cleaned.first,
    );
    final primaryDisplay = (primary.e164 != null && primary.e164!.trim().isNotEmpty)
        ? primary.e164!.trim()
        : primary.raw.trim();

    await _db.transaction(() async {
      await (_db.delete(_db.contactPhones)..where((t) => t.contactId.equals(contactId))).go();
      for (final p in cleaned) {
        final raw = p.raw.trim();
        final e164 = (p.e164 != null && p.e164!.trim().isNotEmpty) ? p.e164!.trim() : null;
        await _db.into(_db.contactPhones).insert(
              ContactPhonesCompanion.insert(
                contactId: contactId,
                e164: Value(e164 ?? raw),
                raw: Value(raw),
                label: Value(p.label),
                isPrimary: Value(identical(p, primary) ? 1 : 0),
                isMobile: Value(p.isMobile ? 1 : 0),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
      await (_db.update(_db.contacts)..where((t) => t.id.equals(contactId))).write(
        ContactsCompanion(phoneNumber: Value(primaryDisplay)),
      );
    });
    await _db.rebuildFtsForContact(contactId);
  }

  Future<void> toggleStar(int id) async {
    final existing = await getById(id);
    if (existing == null) return;
    await (_db.update(_db.contacts)..where((t) => t.id.equals(id))).write(
      ContactsCompanion(isStarred: Value(existing.isStarred == 1 ? 0 : 1)),
    );
  }

  Future<void> setStarred(Iterable<int> ids, bool starred) async {
    final idList = ids.toList();
    if (idList.isEmpty) return;
    await (_db.update(_db.contacts)..where((t) => t.id.isIn(idList))).write(
      ContactsCompanion(isStarred: Value(starred ? 1 : 0)),
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

  Future<void> setCadenceForMany(Iterable<int> ids, int? cadenceDays) async {
    final idList = ids.toList();
    if (idList.isEmpty) return;
    await (_db.update(_db.contacts)..where((t) => t.id.isIn(idList))).write(
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

  Future<int> countTimelineForPerson(int contactId) async {
    final rows = await (_db.select(_db.timelineEntries)
          ..where((t) => t.contactId.equals(contactId) & t.hidden.equals(0)))
        .get();
    return rows.length;
  }

  Future<void> deletePerson(int id) async {
    await (_db.delete(_db.contacts)..where((t) => t.id.equals(id))).go();
    await _queries.deleteFtsForContact(id);
  }

  /// Watches the first unresolved merge suggestion stored by Spec 05.
  Stream<ResolvedMergeSuggestion?> watchFirstMergeSuggestion() {
    return (_db.select(_db.syncStates)..where((t) => t.key.equals('merge_suggestions')))
        .watchSingleOrNull()
        .asyncMap((row) async {
      final raw = row?.value;
      if (raw == null || raw.trim().isEmpty) return null;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! List) return null;
        for (final item in decoded) {
          if (item is! Map<String, dynamic>) continue;
          final idA = item['contactIdA'] as int?;
          final idB = item['contactIdB'] as int?;
          final e164 = item['e164'] as String? ?? '';
          if (idA == null || idB == null || idA == idB) continue;
          final a = await getById(idA);
          final b = await getById(idB);
          if (a != null && b != null) {
            return ResolvedMergeSuggestion(contactA: a, contactB: b, e164: e164);
          }
        }
      } catch (_) {
        return null;
      }
      return null;
    });
  }

  Future<void> dismissMergeSuggestion(int contactIdA, int contactIdB) async {
    final row = await (_db.select(_db.syncStates)
          ..where((t) => t.key.equals('merge_suggestions')))
        .getSingleOrNull();
    if (row?.value == null) return;
    try {
      final decoded = jsonDecode(row!.value!) as List<dynamic>;
      final remaining = decoded.where((item) {
        if (item is! Map<String, dynamic>) return false;
        final a = item['contactIdA'] as int?;
        final b = item['contactIdB'] as int?;
        return !((a == contactIdA && b == contactIdB) || (a == contactIdB && b == contactIdA));
      }).toList();
      if (remaining.isEmpty) {
        await (_db.delete(_db.syncStates)..where((t) => t.key.equals('merge_suggestions'))).go();
      } else {
        await _db.into(_db.syncStates).insertOnConflictUpdate(
              SyncStatesCompanion.insert(
                key: 'merge_suggestions',
                value: Value(jsonEncode(remaining)),
              ),
            );
      }
    } catch (_) {
      await (_db.delete(_db.syncStates)..where((t) => t.key.equals('merge_suggestions'))).go();
    }
  }

  /// Merges [contactIdA] and [contactIdB] into whichever contact has more history
  /// entries (ties keep [contactIdA]), moving timeline, follow-ups, list memberships,
  /// phones, outbox messages, and scheduled SMS in one transaction, then deletes the other.
  Future<int> mergePeople(int contactIdA, int contactIdB) async {
    if (contactIdA == contactIdB) return contactIdA;

    final aEntries = await (_db.select(_db.timelineEntries)
          ..where((t) => t.contactId.equals(contactIdA)))
        .get();
    final bEntries = await (_db.select(_db.timelineEntries)
          ..where((t) => t.contactId.equals(contactIdB)))
        .get();

    final keepId = bEntries.length > aEntries.length ? contactIdB : contactIdA;
    final dropId = keepId == contactIdA ? contactIdB : contactIdA;

    await _db.transaction(() async {
      final keepContact = await getById(keepId);
      final dropContact = await getById(dropId);
      if (keepContact == null || dropContact == null) return;

      // Move timeline entries
      await (_db.update(_db.timelineEntries)..where((t) => t.contactId.equals(dropId))).write(
        TimelineEntriesCompanion(contactId: Value(keepId)),
      );

      // Move tasks
      await (_db.update(_db.tasks)..where((t) => t.contactId.equals(dropId))).write(
        TasksCompanion(contactId: Value(keepId)),
      );

      // Move outbox messages & legacy scheduled SMS
      await (_db.update(_db.outboxMessages)..where((t) => t.contactId.equals(dropId))).write(
        OutboxMessagesCompanion(contactId: Value(keepId)),
      );
      await (_db.update(_db.scheduledSmsEntries)..where((t) => t.contactId.equals(dropId))).write(
        ScheduledSmsEntriesCompanion(contactId: Value(keepId)),
      );

      // Move list memberships without violating UNIQUE(list_id, contact_id)
      final dropMemberships = await (_db.select(_db.contactListMembers)
            ..where((t) => t.contactId.equals(dropId)))
          .get();
      for (final m in dropMemberships) {
        if (m.listId != null) {
          await _db.into(_db.contactListMembers).insert(
                ContactListMembersCompanion.insert(
                  listId: Value(m.listId),
                  contactId: Value(keepId),
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }
      await (_db.delete(_db.contactListMembers)..where((t) => t.contactId.equals(dropId))).go();

      // Move non-duplicate phones
      final keepPhones = await getPhones(keepId);
      final keepE164s = keepPhones.map((p) => p.e164).whereType<String>().toSet();
      final dropPhones = await getPhones(dropId);
      for (final p in dropPhones) {
        if (p.e164 != null && keepE164s.contains(p.e164)) {
          await (_db.delete(_db.contactPhones)..where((t) => t.id.equals(p.id))).go();
        } else {
          await (_db.update(_db.contactPhones)..where((t) => t.id.equals(p.id))).write(
            ContactPhonesCompanion(
              contactId: Value(keepId),
              isPrimary: const Value(0),
            ),
          );
        }
      }

      // Fill missing metadata on keepContact from dropContact
      await (_db.update(_db.contacts)..where((t) => t.id.equals(keepId))).write(
        ContactsCompanion(
          company: Value(keepContact.company ?? dropContact.company),
          role: Value(keepContact.role ?? dropContact.role),
          city: Value(keepContact.city ?? dropContact.city),
          email: Value(keepContact.email ?? dropContact.email),
          birthday: Value(keepContact.birthday ?? dropContact.birthday),
          about: Value(keepContact.about ?? dropContact.about),
          isStarred: Value(
            (keepContact.isStarred == 1 || dropContact.isStarred == 1) ? 1 : 0,
          ),
          cadenceDays: Value(keepContact.cadenceDays ?? dropContact.cadenceDays),
        ),
      );

      // Delete dropped contact
      await (_db.delete(_db.contacts)..where((t) => t.id.equals(dropId))).go();
    });

    await _queries.deleteFtsForContact(dropId);
    await _queries.recomputeLastInteraction(keepId);
    await _db.rebuildFtsForContact(keepId);
    await dismissMergeSuggestion(contactIdA, contactIdB);
    return keepId;
  }

  String? _nullIfEmpty(String? v) {
    final t = v?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}
