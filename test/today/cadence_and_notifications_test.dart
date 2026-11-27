import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/features/followups/data/followups_repository.dart';
import 'package:pocket_crm/features/people/data/lists_repository.dart';
import 'package:pocket_crm/features/people/data/people_repository.dart';
import 'package:pocket_crm/features/today/data/cadence_calculator.dart';
import 'package:pocket_crm/features/today/data/notifications_service.dart';
import 'package:pocket_crm/features/today/data/today_repository.dart';

class FakeNotificationsBackend implements NotificationsBackend {
  bool initialized = false;
  bool channelsCreated = false;
  bool exactAllowed = true;
  final Map<int, ScheduledNotificationSpec> scheduled = {};
  final List<int> cancelledIds = [];
  NotificationResponseHandler? responseHandler;

  @override
  Future<void> initialize(NotificationResponseHandler onResponse) async {
    initialized = true;
    responseHandler = onResponse;
  }

  @override
  Future<void> ensureChannels() async {
    channelsCreated = true;
  }

  @override
  Future<bool> canScheduleExactAlarms() async => exactAllowed;

  @override
  Future<void> cancelAllPending() async {
    scheduled.clear();
  }

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
    scheduled.remove(id);
  }

  @override
  Future<void> schedule(ScheduledNotificationSpec spec, {required bool exact}) async {
    scheduled[spec.id] = spec;
  }
}

void main() {
  final fixedNow = DateTime(2026, 11, 26, 8, 0);

  group('CadenceCalculator', () {
    test('own cadence wins over list cadence; smallest list cadence applies otherwise', () {
      expect(CadenceCalculator.effectiveCadenceDays(30, [7, 14]), 30);
      expect(CadenceCalculator.effectiveCadenceDays(null, [90, 14, 30]), 14);
      expect(CadenceCalculator.effectiveCadenceDays(null, [null, 0]), isNull);
    });

    test('new SMS moves due date; snooze hides until date; no-interaction uses createdAt',
        () async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      final people = PeopleRepository(db);
      final lists = ListsRepository(db);
      final today = TodayRepository(db);

      final listId = await lists.createList('Customers', cadenceDays: 14);
      final amaraId = await people.createPerson(
        displayName: 'Amara Okafor',
        phoneNumber: '+2348031234567',
      );
      await lists.addMember(listId, amaraId);

      // No interaction yet; set createdAt 15 days ago -> due now (15 >= 14)
      final fifteenDaysAgo = fixedNow.subtract(const Duration(days: 15)).millisecondsSinceEpoch;
      await people.updatePerson(amaraId, ContactsCompanion(createdAt: Value(fifteenDaysAgo)));

      var dueList = await today.getDueToReconnectOnce(now: fixedNow);
      expect(dueList.map((e) => e.contact.id), [amaraId]);

      // Snooze for 7 days -> hidden
      final snoozeUntil = fixedNow.add(const Duration(days: 7)).millisecondsSinceEpoch;
      await people.snoozeReconnect(amaraId, snoozeUntil);
      dueList = await today.getDueToReconnectOnce(now: fixedNow);
      expect(dueList, isEmpty);

      // After snooze expires -> due again
      dueList = await today.getDueToReconnectOnce(
        now: fixedNow.add(const Duration(days: 8)),
      );
      expect(dueList.map((e) => e.contact.id), [amaraId]);

      // Clear snooze and record a fresh SMS today -> moves due date forward, no longer due
      await people.snoozeReconnect(amaraId, null);
      await people.updatePerson(
        amaraId,
        ContactsCompanion(lastInteractionAt: Value(fixedNow.millisecondsSinceEpoch)),
      );
      dueList = await today.getDueToReconnectOnce(now: fixedNow);
      expect(dueList, isEmpty);
    });

    test('upcoming birthdays returns next 7 days sorted soonest first', () async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      final people = PeopleRepository(db);
      await people.createPerson(
        displayName: 'Today Person',
        phoneNumber: '+14155550101',
        birthday: '1990-11-26',
      );
      await people.createPerson(
        displayName: 'Saturday Person',
        phoneNumber: '+14155550102',
        birthday: '1988-11-28',
      );
      await people.createPerson(
        displayName: 'Far Future',
        phoneNumber: '+14155550103',
        birthday: '1992-12-20',
      );

      final all = await people.getAll();
      final upcoming = CadenceCalculator.computeUpcomingBirthdays(all, now: fixedNow);
      expect(upcoming.map((u) => u.contact.displayName).toList(), [
        'Today Person',
        'Saturday Person',
      ]);
      expect(upcoming.first.daysUntil, 0);
      expect(upcoming.last.daysUntil, 2);
    });
  });

  group('NotificationsService with FakeNotificationsBackend', () {
    test('schedules follow-up with actions, cancels on complete, handles Done and Tomorrow',
        () async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      final people = PeopleRepository(db);
      final followUps = FollowUpsRepository(db);
      final backend = FakeNotificationsBackend();

      String? lastNavigatedRoute;
      final service = NotificationsService(
        db: db,
        backend: backend,
        clock: () => fixedNow,
        onNavigate: (r) => lastNavigatedRoute = r,
      );
      await service.initialize();
      expect(backend.initialized, isTrue);
      expect(backend.channelsCreated, isTrue);

      // Nothing due -> morning summary is NOT scheduled
      await service.rescheduleAll();
      expect(backend.scheduled, isEmpty);

      final amaraId = await people.createPerson(
        displayName: 'Amara Okafor',
        phoneNumber: '+2348031234567',
      );
      final dueAt = DateTime(2026, 11, 26, 15, 0);
      final taskId = await followUps.createFollowUp(
        contactId: amaraId,
        title: 'Send revised pricing sheet',
        dueDateMs: dueAt.millisecondsSinceEpoch,
      );

      await service.rescheduleAll();
      final notifId = NotificationsService.notificationIdForFollowUp(taskId);
      expect(backend.scheduled.containsKey(notifId), isTrue);
      final spec = backend.scheduled[notifId]!;
      expect(spec.title, 'Amara Okafor');
      expect(spec.body, 'Send revised pricing sheet');
      expect(spec.scheduledAt, dueAt);
      expect(spec.actions.map((a) => a.id).toList(), [
        NotificationActionIds.done,
        NotificationActionIds.tomorrow,
      ]);

      // Morning summary IS scheduled because 1 follow-up is due today
      expect(backend.scheduled.containsKey(NotificationsService.morningSummaryId), isTrue);
      expect(
        backend.scheduled[NotificationsService.morningSummaryId]!.body,
        '1 follow-up today',
      );

      // Tapping notification body navigates to /people/:id
      await service.handleResponse(actionId: null, payload: spec.payload);
      expect(lastNavigatedRoute, '/people/$amaraId');

      // Tapping Tomorrow moves due date +1 day and reschedules
      await service.handleResponse(
        actionId: NotificationActionIds.tomorrow,
        payload: spec.payload,
      );
      final rescheduledTask =
          await (db.select(db.tasks)..where((t) => t.id.equals(taskId))).getSingle();
      expect(
        rescheduledTask.dueDate,
        DateTime(2026, 11, 27, 15, 0).millisecondsSinceEpoch,
      );
      expect(backend.scheduled[notifId]!.scheduledAt, DateTime(2026, 11, 27, 15, 0));

      // Tapping Done completes the follow-up in DB and cancels notification
      await service.handleResponse(
        actionId: NotificationActionIds.done,
        payload: spec.payload,
      );
      final completedTask =
          await (db.select(db.tasks)..where((t) => t.id.equals(taskId))).getSingle();
      expect(completedTask.isCompleted, 1);
      expect(backend.cancelledIds, contains(notifId));
      expect(backend.scheduled.containsKey(notifId), isFalse);
    });
  });
}
