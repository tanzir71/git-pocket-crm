import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

import '../../../core/db/app_database.dart';
import '../../../core/format/app_formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../messages/data/outbox_repository.dart';
import '../../settings/data/settings_repository.dart';

/// Known phone makers that apply extra background-process restrictions (Spec 11 step 5).
enum OemBatteryVendor {
  xiaomi,
  oppo,
  vivo,
  samsung,
  tecno,
  huawei,
}

/// Detects a known OEM vendor from Android's `Build.MANUFACTURER`.
OemBatteryVendor? detectOemBatteryVendor(String manufacturer) {
  final m = manufacturer.trim().toLowerCase();
  if (m.isEmpty) return null;
  if (m.contains('xiaomi') || m.contains('redmi') || m.contains('poco')) {
    return OemBatteryVendor.xiaomi;
  }
  if (m.contains('oppo') || m.contains('realme') || m.contains('oneplus')) {
    return OemBatteryVendor.oppo;
  }
  if (m.contains('vivo') || m.contains('iqoo')) {
    return OemBatteryVendor.vivo;
  }
  if (m.contains('samsung')) {
    return OemBatteryVendor.samsung;
  }
  if (m.contains('tecno') || m.contains('infinix') || m.contains('itel')) {
    return OemBatteryVendor.tecno;
  }
  if (m.contains('huawei') || m.contains('honor')) {
    return OemBatteryVendor.huawei;
  }
  return null;
}

/// Returns the localized ARB battery guidance line for [vendor].
String oemBatteryGuidance(OemBatteryVendor vendor, AppLocalizations l10n) {
  return switch (vendor) {
    OemBatteryVendor.xiaomi => l10n.oemBatteryXiaomi,
    OemBatteryVendor.oppo => l10n.oemBatteryOppo,
    OemBatteryVendor.vivo => l10n.oemBatteryVivo,
    OemBatteryVendor.samsung => l10n.oemBatterySamsung,
    OemBatteryVendor.tecno => l10n.oemBatteryTecno,
    OemBatteryVendor.huawei => l10n.oemBatteryHuawei,
  };
}

/// Snapshot of all five Setup rows plus device metadata.
class SetupCapabilityState {
  const SetupCapabilityState({
    required this.contactsGranted,
    required this.callsAndMessagesGranted,
    required this.exactAlarmsGranted,
    required this.batteryGranted,
    required this.notificationsGranted,
    this.sdkInt = 34,
    this.manufacturer = '',
    this.installedFromStore = false,
    this.ownPhoneNumber,
  });

  static const allGranted = SetupCapabilityState(
    contactsGranted: true,
    callsAndMessagesGranted: true,
    exactAlarmsGranted: true,
    batteryGranted: true,
    notificationsGranted: true,
  );

  static const allDenied = SetupCapabilityState(
    contactsGranted: false,
    callsAndMessagesGranted: false,
    exactAlarmsGranted: false,
    batteryGranted: false,
    notificationsGranted: false,
  );

  final bool contactsGranted;
  final bool callsAndMessagesGranted;
  final bool exactAlarmsGranted;
  final bool batteryGranted;
  final bool notificationsGranted;
  final int sdkInt;
  final String manufacturer;
  final bool installedFromStore;
  final String? ownPhoneNumber;

  bool get needsFinishSetupBanner => !contactsGranted || !callsAndMessagesGranted;

  OemBatteryVendor? get oemVendor => detectOemBatteryVendor(manufacturer);
}

class CallsSmsRequestResult {
  const CallsSmsRequestResult({
    required this.granted,
    required this.elapsed,
  });

  final bool granted;
  final Duration elapsed;

  /// True when Android 13+ immediately refused a sideloaded APK with no dialog (Spec 11 step 3).
  bool isRestrictedSettingsBlocked({
    required int sdkInt,
    required bool installedFromStore,
  }) {
    return !granted &&
        elapsed.inMilliseconds < 300 &&
        sdkInt >= 33 &&
        !installedFromStore;
  }
}

/// Platform abstraction for reading/requesting the 5 setup rows (faked in tests).
abstract class SetupPlatformBridge {
  Future<SetupCapabilityState> readState();
  Future<bool> requestContacts();
  Future<CallsSmsRequestResult> requestCallsAndMessages();
  Future<void> openExactAlarmSettings();
  Future<void> requestIgnoreBatteryOptimisations();
  Future<bool> requestNotifications();
  Future<void> openAppDetailsSettings();
}

/// Real Android implementation backed by `permission_handler` + `OutboxRepository`.
class DefaultSetupPlatformBridge implements SetupPlatformBridge {
  DefaultSetupPlatformBridge({required this.outbox});

  final OutboxRepository outbox;

  @override
  Future<SetupCapabilityState> readState() async {
    if (!Platform.isAndroid) {
      // Non-Android / desktop test host default: treat as granted unless a test overrides.
      return SetupCapabilityState.allGranted;
    }
    final contacts = await Permission.contacts.isGranted;
    final phone = await Permission.phone.isGranted;
    final sms = await Permission.sms.isGranted;
    final caps = await outbox.capabilities();
    final info = await outbox.setupInfo();

    return SetupCapabilityState(
      contactsGranted: contacts,
      callsAndMessagesGranted: phone && sms && caps.smsPermission,
      exactAlarmsGranted: caps.exactAlarms,
      batteryGranted: caps.ignoringBatteryOptimisation,
      notificationsGranted: caps.notifications,
      sdkInt: info.sdkInt,
      manufacturer: info.manufacturer,
      installedFromStore: info.installedFromStore,
      ownPhoneNumber: info.ownPhoneNumber,
    );
  }

  @override
  Future<bool> requestContacts() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  @override
  Future<CallsSmsRequestResult> requestCallsAndMessages() async {
    if (!Platform.isAndroid) {
      return const CallsSmsRequestResult(granted: true, elapsed: Duration.zero);
    }
    final sw = Stopwatch()..start();
    final results = await [Permission.phone, Permission.sms].request();
    sw.stop();
    final granted = (results[Permission.phone]?.isGranted ?? false) &&
        (results[Permission.sms]?.isGranted ?? false);
    return CallsSmsRequestResult(granted: granted, elapsed: sw.elapsed);
  }

  @override
  Future<void> openExactAlarmSettings() => outbox.openExactAlarmSettings();

  @override
  Future<void> requestIgnoreBatteryOptimisations() =>
      outbox.requestIgnoreBatteryOptimisations();

  @override
  Future<bool> requestNotifications() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  @override
  Future<void> openAppDetailsSettings() => outbox.openAppDetailsSettings();
}

enum ReliabilityOutcomeKind { none, pending, onTime, late, failed }

class ReliabilityCheckOutcome {
  const ReliabilityCheckOutcome({
    required this.kind,
    this.dueAtMs,
    this.minutesLate = 0,
    this.failureReason,
  });

  static const none = ReliabilityCheckOutcome(kind: ReliabilityOutcomeKind.none);

  final ReliabilityOutcomeKind kind;
  final int? dueAtMs;
  final int minutesLate;
  final String? failureReason;

  String formatMessage(AppLocalizations l10n, AppFormatters fmt) {
    return switch (kind) {
      ReliabilityOutcomeKind.none => '',
      ReliabilityOutcomeKind.pending => l10n.reliabilityScheduledNotice(
          fmt.formatTime(DateTime.fromMillisecondsSinceEpoch(dueAtMs ?? 0)),
        ),
      ReliabilityOutcomeKind.onTime => l10n.reliabilityResultOnTime,
      ReliabilityOutcomeKind.late => l10n.reliabilityResultLate(minutesLate),
      ReliabilityOutcomeKind.failed =>
        l10n.reliabilityResultFailed(failureReason ?? l10n.statusNotSent),
    };
  }
}

/// Schedules and evaluates the 2-minute self-test SMS (Spec 11 step 9).
class ReliabilityCheckService {
  ReliabilityCheckService({
    required AppDatabase db,
    required this.outbox,
    DateTime Function()? clock,
  })  : _db = db,
        _settings = SettingsRepository(db),
        _clock = clock ?? DateTime.now;

  static const String _clientIdKey = 'reliability_test_client_id';
  static const int onTimeToleranceMs = 90 * 1000; // <= 90s counts as on time

  final AppDatabase _db;
  final OutboxRepository outbox;
  final SettingsRepository _settings;
  final DateTime Function() _clock;

  Future<({String clientId, int dueAtMs})> scheduleTestMessage({
    required String ownNumber,
    required String formattedTime,
    required String body,
  }) async {
    final dueAt = _clock().add(const Duration(minutes: 2));
    final dueAtMs = dueAt.millisecondsSinceEpoch;
    final clientId = await outbox.scheduleSingle(
      contactId: null,
      address: ownNumber.trim(),
      recipientName: ownNumber.trim(),
      body: body,
      dueAtMs: dueAtMs,
    );
    await _settings.set(_clientIdKey, clientId);
    return (clientId: clientId, dueAtMs: dueAtMs);
  }

  Future<ReliabilityCheckOutcome> evaluate() async {
    final clientId = await _settings.get(_clientIdKey);
    if (clientId == null || clientId.isEmpty) {
      return ReliabilityCheckOutcome.none;
    }

    final row = await (_db.select(_db.outboxMessages)
          ..where((t) => t.clientId.equals(clientId)))
        .getSingleOrNull();
    if (row == null) return ReliabilityCheckOutcome.none;

    if (row.status == 'queued' || row.status == 'sending') {
      return ReliabilityCheckOutcome(
        kind: ReliabilityOutcomeKind.pending,
        dueAtMs: row.dueAt,
      );
    }

    if (row.status == 'sent' || row.status == 'delivered') {
      final actualMs = row.sentAt ?? row.deliveredAt ?? row.dueAt;
      final delayMs = actualMs - row.dueAt;
      if (delayMs <= onTimeToleranceMs) {
        return ReliabilityCheckOutcome(
          kind: ReliabilityOutcomeKind.onTime,
          dueAtMs: row.dueAt,
        );
      }
      final minsLate = (delayMs / 60000).round().clamp(1, 999);
      return ReliabilityCheckOutcome(
        kind: ReliabilityOutcomeKind.late,
        dueAtMs: row.dueAt,
        minutesLate: minsLate,
      );
    }

    final reason = row.status == 'missed'
        ? 'Missed'
        : (row.errorCode != null
            ? smsErrorReasonLabel(row.errorCode)
            : (row.errorLabel ?? 'Not sent'));
    return ReliabilityCheckOutcome(
      kind: ReliabilityOutcomeKind.failed,
      dueAtMs: row.dueAt,
      failureReason: reason,
    );
  }
}
