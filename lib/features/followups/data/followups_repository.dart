import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/crm_queries.dart';

class FollowUpWithPerson {
  const FollowUpWithPerson({
    required this.task,
    required this.personName,
  });

  final Task task;
  final String personName;
}

class FollowUpsRepository {
  FollowUpsRepository(this._db) : _queries = CrmQueries(_db);

  final AppDatabase _db;
  final CrmQueries _queries;

  Stream<List<Task>> watchOpenForPerson(int contactId) {
    return (_db.select(_db.tasks)
          ..where((t) => t.contactId.equals(contactId) & t.isCompleted.equals(0))
          ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
        .watch();
  }

  Stream<List<FollowUpWithPerson>> watchDueAndOverdue(int endOfTodayMs) {
    return _queries.watchDueAndOverdueTasks(endOfTodayMs).map(
          (rows) => rows
              .map((r) => FollowUpWithPerson(task: r.task, personName: r.personName))
              .toList(),
        );
  }

  Stream<List<FollowUpWithPerson>> watchAllOpen() {
    return _queries.watchAllOpenTasks().map(
          (rows) => rows
              .map((r) => FollowUpWithPerson(task: r.task, personName: r.personName))
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
