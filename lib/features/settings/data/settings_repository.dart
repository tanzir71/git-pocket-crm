import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Stream<String?> watch(String key) {
    return (_db.select(_db.settings)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  Future<String?> get(String key) async {
    final row = await (_db.select(_db.settings)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<Map<String, String?>> getAll() async {
    final rows = await _db.select(_db.settings).get();
    return {for (final r in rows) r.key: r.value};
  }

  Future<void> set(String key, String? value) async {
    if (value == null) {
      await (_db.delete(_db.settings)..where((t) => t.key.equals(key))).go();
      return;
    }
    await _db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: Value(value)),
        );
  }
}
