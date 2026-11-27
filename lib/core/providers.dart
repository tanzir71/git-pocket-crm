import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../database_helper.dart';
import '../features/followups/data/followups_repository.dart';
import '../features/history/data/history_repository.dart';
import '../features/messages/data/templates_repository.dart';
import '../features/payments/data/payments_repository.dart';
import '../features/people/data/lists_repository.dart';
import '../features/people/data/people_repository.dart';
import '../features/settings/data/settings_repository.dart';
import '../features/sync/data/sync_state_repository.dart';
import 'db/app_database.dart';

typedef Clock = DateTime Function();

/// Overridable clock for deterministic tests.
final clockProvider = Provider<Clock>((ref) => DateTime.now);

/// Single Drift database instance for the entire process.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return DatabaseHelper.instance.appDatabase;
});

final peopleRepositoryProvider = Provider<PeopleRepository>((ref) {
  return PeopleRepository(ref.watch(appDatabaseProvider));
});

final listsRepositoryProvider = Provider<ListsRepository>((ref) {
  return ListsRepository(ref.watch(appDatabaseProvider));
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(ref.watch(appDatabaseProvider));
});

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepository(ref.watch(appDatabaseProvider));
});

final followUpsRepositoryProvider = Provider<FollowUpsRepository>((ref) {
  return FollowUpsRepository(ref.watch(appDatabaseProvider));
});

final templatesRepositoryProvider = Provider<TemplatesRepository>((ref) {
  return TemplatesRepository(ref.watch(appDatabaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(appDatabaseProvider));
});

final syncStateRepositoryProvider = Provider<SyncStateRepository>((ref) {
  return SyncStateRepository(ref.watch(appDatabaseProvider));
});

/// Watches whether at least one contact exists in the database.
final hasAnyContactsProvider = StreamProvider<bool>((ref) {
  return ref.watch(peopleRepositoryProvider).watchAll().map((list) => list.isNotEmpty);
});

/// Whether the user chose "Do this later" during first-run setup in this session.
class SetupDeferredNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void defer() => state = true;
  void reset() => state = false;
}

final setupDeferredProvider = NotifierProvider<SetupDeferredNotifier, bool>(
  SetupDeferredNotifier.new,
);

/// Watches the saved theme mode setting (`system`, `light`, `dark`).
final themeModeProvider = StreamProvider<ThemeMode>((ref) {
  return ref.watch(settingsRepositoryProvider).watch('theme_mode').map((value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  });
});

/// Watches the saved language override (`null` = system default).
final localeOverrideProvider = StreamProvider<Locale?>((ref) {
  return ref.watch(settingsRepositoryProvider).watch('language').map((value) {
    if (value == null || value.isEmpty || value == 'system') return null;
    return Locale(value);
  });
});
