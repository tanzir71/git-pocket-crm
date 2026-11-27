import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/crm_queries.dart';

class ContactListSummary {
  const ContactListSummary({
    required this.list,
    required this.memberCount,
  });

  final ContactList list;
  final int memberCount;
}

class ListsRepository {
  ListsRepository(this._db) : _queries = CrmQueries(_db);

  final AppDatabase _db;
  final CrmQueries _queries;

  Stream<List<ContactListSummary>> watchLists() {
    return _queries.watchListSummaries().map(
          (rows) => rows
              .map(
                (r) => ContactListSummary(
                  list: r.list,
                  memberCount: r.memberCount,
                ),
              )
              .toList(),
        );
  }

  Stream<List<Contact>> watchMembers(int listId) => _queries.watchListMembers(listId);

  Future<List<Contact>> getMembers(int listId) => _queries.getListMembers(listId);

  Stream<List<ContactList>> watchListsForPerson(int contactId) =>
      _queries.watchListsForContact(contactId);

  Future<int> countMembersWithoutOwnCadence(int listId) =>
      _queries.countListMembersWithoutOwnCadence(listId);

  Future<int> createList(String name, {int? cadenceDays}) {
    return _db.into(_db.contactLists).insert(
          ContactListsCompanion.insert(
            name: name.trim(),
            cadenceDays: Value(cadenceDays),
            createdAt: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  Future<void> renameList(int id, String name) async {
    await (_db.update(_db.contactLists)..where((t) => t.id.equals(id))).write(
      ContactListsCompanion(name: Value(name.trim())),
    );
  }

  Future<void> setCadence(int id, int? cadenceDays) async {
    await (_db.update(_db.contactLists)..where((t) => t.id.equals(id))).write(
      ContactListsCompanion(cadenceDays: Value(cadenceDays)),
    );
  }

  Future<void> deleteList(int id) async {
    await (_db.delete(_db.contactLists)..where((t) => t.id.equals(id))).go();
  }

  Future<void> addMember(int listId, int contactId) async {
    await _db.into(_db.contactListMembers).insert(
          ContactListMembersCompanion.insert(
            listId: Value(listId),
            contactId: Value(contactId),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> addMembers(int listId, Iterable<int> contactIds) async {
    await _db.transaction(() async {
      for (final cid in contactIds) {
        await _db.into(_db.contactListMembers).insert(
              ContactListMembersCompanion.insert(
                listId: Value(listId),
                contactId: Value(cid),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    });
  }

  Future<void> removeMember(int listId, int contactId) async {
    await (_db.delete(_db.contactListMembers)
          ..where((t) => t.listId.equals(listId) & t.contactId.equals(contactId)))
        .go();
  }

  Future<void> setListsForPerson(int contactId, Set<int> listIds) async {
    await _db.transaction(() async {
      await (_db.delete(_db.contactListMembers)
            ..where((t) => t.contactId.equals(contactId)))
          .go();
      for (final listId in listIds) {
        await _db.into(_db.contactListMembers).insert(
              ContactListMembersCompanion.insert(
                listId: Value(listId),
                contactId: Value(contactId),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    });
  }
}
