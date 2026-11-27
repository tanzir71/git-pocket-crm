import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../features/backup/data/backup_service.dart';
import '../features/backup/data/export_service.dart';
import '../features/capture/data/capture_service.dart';
import '../features/followups/data/followups_repository.dart';
import '../features/history/data/history_repository.dart';
import '../features/messages/data/campaigns_repository.dart';
import '../features/messages/data/outbox_repository.dart';
import '../features/messages/data/scheduled_sms_migrator.dart';
import '../features/messages/data/templates_repository.dart';
import '../features/payments/data/payments_repository.dart';
import '../features/people/data/lists_repository.dart';
import '../features/people/data/people_repository.dart';
import '../features/settings/data/settings_repository.dart';
import '../features/setup/data/setup_controller.dart';
import '../features/sync/data/amount_parser.dart';
import '../features/sync/data/sync_service.dart';
import '../features/sync/data/sync_state_repository.dart';
import '../features/today/data/notifications_service.dart';
import '../features/today/data/today_repository.dart';
import 'db/app_database.dart';
import 'files/file_store.dart';
import 'phone/phone_service.dart';

typedef Clock = DateTime Function();

/// Overridable clock for deterministic tests.
final clockProvider = Provider<Clock>((ref) => DateTime.now);

/// Incremented after a database restore so [appDatabaseProvider] reopens cleanly.
class DbRevisionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state = state + 1;
}

final dbRevisionProvider = NotifierProvider<DbRevisionNotifier, int>(
  DbRevisionNotifier.new,
);

/// Single Drift database instance for the entire process.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  ref.watch(dbRevisionProvider);
  final db = AppDatabase.openDefault();
  ref.onDispose(db.close);
  return db;
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

final phoneServiceProvider = Provider<PhoneService>((ref) => const PhoneService());

final amountParserProvider = Provider<AmountParser>((ref) => const AmountParser());

final deviceDataSourceProvider = Provider<DeviceDataSource>((ref) {
  return PlatformDeviceDataSource();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    db: ref.watch(appDatabaseProvider),
    source: ref.watch(deviceDataSourceProvider),
    phoneService: ref.watch(phoneServiceProvider),
    amountParser: ref.watch(amountParserProvider),
    clock: ref.watch(clockProvider),
  );
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  return ref.watch(syncServiceProvider).statusStream;
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

String _deviceDefaultCurrencyCode() {
  try {
    final locale = PlatformDispatcher.instance.locale.toLanguageTag();
    final code = NumberFormat.simpleCurrency(locale: locale).currencyName;
    if (code != null && code.length == 3) return code.toUpperCase();
  } catch (_) {}
  return 'USD';
}

String _deviceDefaultPhoneRegion() {
  final country = PlatformDispatcher.instance.locale.countryCode?.trim().toUpperCase();
  if (country != null && country.length == 2) return country;
  return 'US';
}

/// Watches the saved currency ISO code (initially from device locale).
final currencyCodeProvider = StreamProvider<String>((ref) {
  return ref.watch(settingsRepositoryProvider).watch('currency_code').map((value) {
    if (value == null || value.trim().isEmpty) return _deviceDefaultCurrencyCode();
    return value.trim().toUpperCase();
  });
});

/// Watches the saved default phone region ISO code (initially from device/SIM locale).
final phoneRegionProvider = StreamProvider<String>((ref) {
  return ref.watch(settingsRepositoryProvider).watch('phone_region').map((value) {
    if (value == null || value.trim().isEmpty) return _deviceDefaultPhoneRegion();
    return value.trim().toUpperCase();
  });
});

/// Watches the persisted People sort order.
final peopleSortProvider = StreamProvider<PeopleSort>((ref) {
  return ref.watch(settingsRepositoryProvider).watch('people_sort').map((value) {
    return switch (value) {
      'name' => PeopleSort.name,
      'longest' => PeopleSort.longest,
      _ => PeopleSort.recent,
    };
  });
});

final fileStoreProvider = Provider<FileStore>((ref) => FileStore());

final capturePlatformAdapterProvider = Provider<CapturePlatformAdapter>((ref) {
  final picker = ImagePicker();
  return DefaultCapturePlatformAdapter(
    imagePicker: (fromCamera) async {
      final file = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );
      return file?.path;
    },
    filePicker: () async {
      final files = await FilePicker.pickFiles();
      if (files.isEmpty) return null;
      return files.first.path;
    },
  );
});

final captureServiceProvider = Provider<CaptureService>((ref) {
  return CaptureService(
    db: ref.watch(appDatabaseProvider),
    fileStore: ref.watch(fileStoreProvider),
    clock: ref.watch(clockProvider),
  );
});

/// Remembers the last selected Add-sheet entry type during the session.
class LastAddEntryTypeNotifier extends Notifier<AddEntryType> {
  @override
  AddEntryType build() => AddEntryType.note;

  void select(AddEntryType type) => state = type;
}

final lastAddEntryTypeProvider =
    NotifierProvider<LastAddEntryTypeNotifier, AddEntryType>(
  LastAddEntryTypeNotifier.new,
);

/// Watches the default follow-up hour (0..23, default 9 = 09:00).
final defaultFollowUpHourProvider = StreamProvider<int>((ref) {
  return ref.watch(settingsRepositoryProvider).watch('default_followup_hour').map((v) {
    final parsed = int.tryParse(v ?? '');
    if (parsed == null || parsed < 0 || parsed > 23) return 9;
    return parsed;
  });
});

/// Watches the "Ask for a note after calls" mode (`all`, `starred`, `never`).
final afterCallModeProvider = StreamProvider<String>((ref) {
  return ref.watch(settingsRepositoryProvider).watch('after_call_mode').map((v) {
    if (v == 'starred' || v == 'never') return v!;
    return 'all';
  });
});

final todayRepositoryProvider = Provider<TodayRepository>((ref) {
  return TodayRepository(ref.watch(appDatabaseProvider));
});

final notificationsBackendProvider = Provider<NotificationsBackend>((ref) {
  return FlutterLocalNotificationsBackend();
});

final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  return NotificationsService(
    db: ref.watch(appDatabaseProvider),
    backend: ref.watch(notificationsBackendProvider),
    clock: ref.watch(clockProvider),
  );
});

final outboxPlatformClientProvider = Provider<OutboxPlatformClient>((ref) {
  return PigeonOutboxPlatformClient();
});

final outboxRepositoryProvider = Provider<OutboxRepository>((ref) {
  return OutboxRepository(
    db: ref.watch(appDatabaseProvider),
    client: ref.watch(outboxPlatformClientProvider),
    clock: ref.watch(clockProvider),
  );
});

final campaignsRepositoryProvider = Provider<CampaignsRepository>((ref) {
  return CampaignsRepository(
    db: ref.watch(appDatabaseProvider),
    outbox: ref.watch(outboxRepositoryProvider),
    phoneService: ref.watch(phoneServiceProvider),
    clock: ref.watch(clockProvider),
  );
});

final scheduledSmsMigratorProvider = Provider<ScheduledSmsMigrator>((ref) {
  return ScheduledSmsMigrator(
    db: ref.watch(appDatabaseProvider),
    outbox: ref.watch(outboxRepositoryProvider),
    clock: ref.watch(clockProvider),
  );
});

final setupPlatformBridgeProvider = Provider<SetupPlatformBridge>((ref) {
  return DefaultSetupPlatformBridge(outbox: ref.watch(outboxRepositoryProvider));
});

final setupCapabilityProvider = FutureProvider.autoDispose<SetupCapabilityState>((ref) {
  return ref.watch(setupPlatformBridgeProvider).readState();
});

final reliabilityCheckServiceProvider = Provider<ReliabilityCheckService>((ref) {
  return ReliabilityCheckService(
    db: ref.watch(appDatabaseProvider),
    outbox: ref.watch(outboxRepositoryProvider),
    clock: ref.watch(clockProvider),
  );
});

final backupSafClientProvider = Provider<BackupSafClient>((ref) {
  return PigeonBackupSafClient();
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(
    db: ref.watch(appDatabaseProvider),
    outboxClient: ref.watch(outboxPlatformClientProvider),
    safClient: ref.watch(backupSafClientProvider),
    cacheDirProvider: getTemporaryDirectory,
    attachmentsDirProvider: () async {
      final docs = await getApplicationDocumentsDirectory();
      return Directory(p.join(docs.path, 'attachments'));
    },
    dbPathProvider: () async {
      final docs = await getApplicationDocumentsDirectory();
      return resolvePocketCrmDatabasePath(
        documentsDirPath: docs.path,
        isAndroid: Platform.isAndroid,
      );
    },
    autoBackupDirProvider: () async {
      if (Platform.isAndroid) {
        final ext = await getExternalStorageDirectory();
        if (ext != null) return Directory(p.join(ext.path, 'auto_backups'));
      }
      final docs = await getApplicationDocumentsDirectory();
      return Directory(p.join(docs.path, 'auto_backups'));
    },
    phoneService: ref.watch(phoneServiceProvider),
    clock: ref.watch(clockProvider),
  );
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(
    db: ref.watch(appDatabaseProvider),
    safClient: ref.watch(backupSafClientProvider),
    outboxClient: ref.watch(outboxPlatformClientProvider),
    cacheDirProvider: getTemporaryDirectory,
    clock: ref.watch(clockProvider),
  );
});
