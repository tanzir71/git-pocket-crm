import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/features/followups/data/followups_repository.dart';
import 'package:pocket_crm/features/history/data/history_repository.dart';
import 'package:pocket_crm/features/messages/data/templates_repository.dart';
import 'package:pocket_crm/features/payments/data/payments_repository.dart';
import 'package:pocket_crm/features/people/data/lists_repository.dart';
import 'package:pocket_crm/features/people/data/people_repository.dart';
import 'package:pocket_crm/features/settings/data/settings_repository.dart';
import 'package:pocket_crm/features/sync/data/sync_state_repository.dart';

void main() {
  late AppDatabase db;
  late PeopleRepository peopleRepo;
  late ListsRepository listsRepo;
  late HistoryRepository historyRepo;
  late PaymentsRepository paymentsRepo;
  late FollowUpsRepository followUpsRepo;
  late TemplatesRepository templatesRepo;
  late SettingsRepository settingsRepo;
  late SyncStateRepository syncStateRepo;

  setUp(() {
    db = AppDatabase.inMemory();
    peopleRepo = PeopleRepository(db);
    listsRepo = ListsRepository(db);
    historyRepo = HistoryRepository(db);
    paymentsRepo = PaymentsRepository(db);
    followUpsRepo = FollowUpsRepository(db);
    templatesRepo = TemplatesRepository(db);
    settingsRepo = SettingsRepository(db);
    syncStateRepo = SyncStateRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('deleting a person cascades to timeline, tasks, phones, and list memberships', () async {
    final personId = await peopleRepo.createPerson(
      displayName: 'Sofia Marin',
      phoneNumber: '+14155550150',
      company: 'Studio Marin',
    );
    await peopleRepo.addPhone(
      contactId: personId,
      e164: '+14155550151',
      label: 'work',
    );
    final listId = await listsRepo.createList('Designers');
    await listsRepo.addMember(listId, personId);
    await historyRepo.addNote(contactId: personId, note: 'Discussed Q4 fixtures');
    await followUpsRepo.createFollowUp(
      contactId: personId,
      title: 'Send finish samples',
      dueDateMs: DateTime.now().millisecondsSinceEpoch + 86400000,
    );

    expect((await db.select(db.contactPhones).get()).length, 2);
    expect((await db.select(db.timelineEntries).get()).length, 1);
    expect((await db.select(db.tasks).get()).length, 1);
    expect((await db.select(db.contactListMembers).get()).length, 1);

    await peopleRepo.deletePerson(personId);

    expect(await db.select(db.contacts).get(), isEmpty);
    expect(await db.select(db.contactPhones).get(), isEmpty);
    expect(await db.select(db.timelineEntries).get(), isEmpty);
    expect(await db.select(db.tasks).get(), isEmpty);
    expect(await db.select(db.contactListMembers).get(), isEmpty);
    // List itself still exists, just empty
    expect((await db.select(db.contactLists).get()).length, 1);
  });

  test('payment balance follows Spec 02 rules', () async {
    final p1 = await peopleRepo.createPerson(
      displayName: 'Amara Okafor',
      phoneNumber: '+14155550201',
    );

    // Only received/paid without any owed_to_me or i_owe -> shows nothing
    await paymentsRepo.addPayment(
      contactId: p1,
      amount: 100,
      paymentStatus: 'received',
      note: 'Cash sale',
    );
    var bal = await paymentsRepo.getBalanceForPerson(p1);
    expect(bal.hasBalance, isFalse);

    // Add owed_to_me 340 -> net = (340 - 100) - (0 - 0) = 240 -> Owes you 240
    await paymentsRepo.addPayment(
      contactId: p1,
      amount: 340,
      paymentStatus: 'owed_to_me',
      note: '40 units',
    );
    bal = await paymentsRepo.getBalanceForPerson(p1);
    expect(bal.owesYou, isTrue);
    expect(bal.netAmount, closeTo(240, 0.001));

    // Add i_owe 400 and paid 100 -> net = 240 - (400 - 100) = -60 -> You owe 60
    await paymentsRepo.addPayment(
      contactId: p1,
      amount: 400,
      paymentStatus: 'i_owe',
      note: 'Return pallet',
    );
    await paymentsRepo.addPayment(
      contactId: p1,
      amount: 100,
      paymentStatus: 'paid',
      note: 'Partial refund',
    );
    bal = await paymentsRepo.getBalanceForPerson(p1);
    expect(bal.youOwe, isTrue);
    expect(bal.netAmount, closeTo(-60, 0.001));
  });

  test('search matches name, company, phone, about, and notes', () async {
    final id = await peopleRepo.createPerson(
      displayName: 'Tanvir Hasan',
      phoneNumber: '+8801712345678',
      company: 'Dhaka Lighting',
      about: 'Wholesale distributor',
    );
    await historyRepo.addNote(
      contactId: id,
      note: 'Asked about solar lanterns for Chittagong warehouse',
    );

    expect((await peopleRepo.search('Tanvir')).length, 1);
    expect((await peopleRepo.search('Dhaka')).length, 1);
    expect((await peopleRepo.search('1712345678')).length, 1);
    expect((await peopleRepo.search('Wholesale')).length, 1);
    expect((await peopleRepo.search('Chittagong')).length, 1);
    expect(await peopleRepo.search('NonexistentTerm'), isEmpty);
  });

  test('templates, settings, and sync_state repositories persist values', () async {
    await templatesRepo.seedDefaultsIfEmpty();
    final templates = await templatesRepo.getAll();
    expect(templates.length, 3);

    await settingsRepo.set('currency', 'USD');
    expect(await settingsRepo.get('currency'), 'USD');

    await syncStateRepo.setInt('last_call_sync_ms', 1700000123456);
    expect(await syncStateRepo.getInt('last_call_sync_ms'), 1700000123456);
  });
}
