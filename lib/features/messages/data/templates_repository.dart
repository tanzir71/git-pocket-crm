import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

class TemplatesRepository {
  TemplatesRepository(this._db);

  final AppDatabase _db;

  /// Exact Spec 10 first-run templates.
  static const defaultTemplates = <(String name, String body)>[
    (
      'Payment reminder',
      'Hi {first name}, a quick reminder that {amount due} is due. Thank you. {my name}',
    ),
    (
      'Thank you after a visit',
      'Hi {first name}, thank you for your time today. I will follow up shortly. {my name}',
    ),
    (
      'Checking in',
      'Hi {first name}, it has been a while. How are you?',
    ),
  ];

  Stream<List<Template>> watchAll() {
    return (_db.select(_db.templates)..orderBy([(t) => OrderingTerm(expression: t.name)])).watch();
  }

  Future<List<Template>> getAll() {
    return (_db.select(_db.templates)..orderBy([(t) => OrderingTerm(expression: t.name)])).get();
  }

  Future<Template?> getById(int id) {
    return (_db.select(_db.templates)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Template?> getByName(String name) {
    return (_db.select(_db.templates)..where((t) => t.name.equals(name))).getSingleOrNull();
  }

  Future<void> seedDefaultsIfEmpty() async {
    final existing = await getAll();
    if (existing.isNotEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final (name, body) in defaultTemplates) {
      await _db.into(_db.templates).insert(
            TemplatesCompanion.insert(
              name: name,
              body: body,
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  Future<int> upsertTemplate({
    int? id,
    required String name,
    required String body,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (id != null) {
      await (_db.update(_db.templates)..where((t) => t.id.equals(id))).write(
        TemplatesCompanion(
          name: Value(name.trim()),
          body: Value(body),
          updatedAt: Value(now),
        ),
      );
      return id;
    }
    return _db.into(_db.templates).insert(
          TemplatesCompanion.insert(
            name: name.trim(),
            body: body,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  Future<void> deleteTemplate(int id) async {
    await (_db.delete(_db.templates)..where((t) => t.id.equals(id))).go();
  }
}
