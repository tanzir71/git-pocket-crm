import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

class TemplatesRepository {
  TemplatesRepository(this._db);

  final AppDatabase _db;

  static const defaultTemplates = <(String name, String body)>[
    (
      'Payment reminder',
      'Hi {first_name}, a quick reminder that {amount_due} is due. Thank you!',
    ),
    (
      'Thank you after a visit',
      'Hi {first_name}, thank you for taking the time to meet today. Speak soon, {my_name}.',
    ),
    (
      'Checking in',
      'Hi {first_name}, just checking in to see how things are going. Best, {my_name}.',
    ),
  ];

  Stream<List<Template>> watchAll() {
    return (_db.select(_db.templates)..orderBy([(t) => OrderingTerm(expression: t.name)])).watch();
  }

  Future<List<Template>> getAll() {
    return (_db.select(_db.templates)..orderBy([(t) => OrderingTerm(expression: t.name)])).get();
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
