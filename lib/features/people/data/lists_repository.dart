import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

class ContactListSummary {
  const ContactListSummary({
    required this.list,
    required this.memberCount,
  });

  final ContactList list;
  final int memberCount;
}

class ListsRepository {
  ListsRepository(this._db);

  final AppDatabase _db;

  Stream<List<ContactListSummary>> watchLists() {
    return _db
        .customSelect(
          '''
          SELECT cl.*, COUNT(clm.contact_id) AS member_count
          FROM contact_lists cl
          LEFT JOIN contact_list_members clm ON cl.id = clm.list_id
          GROUP BY cl.id
          ORDER BY cl.name ASC
          ''',
          readsFrom: {_db.contactLists, _db.contactListMembers},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (r) => ContactListSummary(
                  list: _db.contactLists.map(r.data),
                  memberCount: r.read<int>('member_count'),
                ),
              )
              .toList(),
        );
  }

  Stream<List<Contact>> watchMembers(int listId) {
    return _db
        .customSelect(
          '''
          SELECT c.*
          FROM contacts c
          JOIN contact_list_members clm ON clm.contact_id = c.id
          WHERE clm.list_id = ?
          ORDER BY c.display_name ASC
          ''',
          variables: [Variable<int>(listId)],
          readsFrom: {_db.contacts, _db.contactListMembers},
        )
        .watch()
        .map((rows) => rows.map((r) => _db.contacts.map(r.data)).toList());
  }

  Future<List<Contact>> getMembers(int listId) async {
    final rows = await _db.customSelect(
      '''
      SELECT c.*
      FROM contacts c
      JOIN contact_list_members clm ON clm.contact_id = c.id
      WHERE clm.list_id = ?
      ORDER BY c.display_name ASC
      ''',
      variables: [Variable<int>(listId)],
    ).get();
    return rows.map((r) => _db.contacts.map(r.data)).toList();
  }

  Stream<List<ContactList>> watchListsForPerson(int contactId) {
    return _db
        .customSelect(
          '''
          SELECT cl.*
          FROM contact_lists cl
          JOIN contact_list_members clm ON clm.list_id = cl.id
          WHERE clm.contact_id = ?
          ORDER BY cl.name ASC
          ''',
          variables: [Variable<int>(contactId)],
          readsFrom: {_db.contactLists, _db.contactListMembers},
        )
        .watch()
        .map((rows) => rows.map((r) => _db.contactLists.map(r.data)).toList());
  }

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

  Future<void> removeMember(int listId, int contactId) async {
    await (_db.delete(_db.contactListMembers)
          ..where((t) => t.listId.equals(listId) & t.contactId.equals(contactId)))
        .go();
  }
}
