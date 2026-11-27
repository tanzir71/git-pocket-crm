import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

class SyncStateRepository {
  SyncStateRepository(this._db);

  final AppDatabase _db;

  Stream<String?> watch(String key) {
    return (_db.select(_db.syncStates)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  Future<String?> get(String key) async {
    final row = await (_db.select(_db.syncStates)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<int?> getInt(String key) async {
    final raw = await get(key);
    return raw == null ? null : int.tryParse(raw);
  }

  Future<void> set(String key, String? value) async {
    if (value == null) {
      await (_db.delete(_db.syncStates)..where((t) => t.key.equals(key))).go();
      return;
    }
    await _db.into(_db.syncStates).insertOnConflictUpdate(
          SyncStatesCompanion.insert(key: key, value: Value(value)),
        );
  }

  Future<void> setInt(String key, int value) => set(key, value.toString());
}
