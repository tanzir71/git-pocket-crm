import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

class FollowUpWithPerson {
  const FollowUpWithPerson({
    required this.task,
    required this.personName,
  });

  final Task task;
  final String personName;
}

class FollowUpsRepository {
  FollowUpsRepository(this._db);

  final AppDatabase _db;

  Stream<List<Task>> watchOpenForPerson(int contactId) {
    return (_db.select(_db.tasks)
          ..where((t) => t.contactId.equals(contactId) & t.isCompleted.equals(0))
          ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
        .watch();
  }

  Stream<List<FollowUpWithPerson>> watchDueAndOverdue(int endOfTodayMs) {
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
                (r) => FollowUpWithPerson(
                  task: _db.tasks.map(r.data),
                  personName: r.read<String>('person_name'),
                ),
              )
              .toList(),
        );
  }

  Stream<List<FollowUpWithPerson>> watchAllOpen() {
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
                (r) => FollowUpWithPerson(
                  task: _db.tasks.map(r.data),
                  personName: r.read<String>('person_name'),
                ),
              )
              .toList(),
        );
  }

  Future<int> createFollowUp({
    required int contactId,
    required String title,
    required int dueDateMs,
    int? reminderTimeMs,
    String? note,
    int? sourceTimelineId,
  }) {
    return _db.into(_db.tasks).insert(
          TasksCompanion.insert(
            contactId: Value(contactId),
            title: title.trim(),
            dueDate: dueDateMs,
            reminderTime: Value(reminderTimeMs ?? dueDateMs),
            note: Value(note),
            createdAt: Value(DateTime.now().millisecondsSinceEpoch),
            sourceTimelineId: Value(sourceTimelineId),
          ),
        );
  }

  Future<void> completeFollowUp(int id) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        isCompleted: const Value(1),
        completedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> uncompleteFollowUp(int id) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      const TasksCompanion(
        isCompleted: Value(0),
        completedAt: Value(null),
      ),
    );
  }

  Future<void> deleteFollowUp(int id) async {
    await (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
  }
}
