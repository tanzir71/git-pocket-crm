import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/db/app_database.dart';
import '../../followups/data/followups_repository.dart';
import '../../settings/data/settings_repository.dart';
import 'today_repository.dart';

/// Channel IDs required by Spec 08 step 6.
abstract final class NotificationChannels {
  static const followUps = 'follow_ups';
  static const reconnect = 'reconnect';
  static const afterCalls = 'after_calls';
  static const messages = 'messages';
  static const morningSummary = 'morning_summary';
}

/// Notification action IDs for follow-up reminders.
abstract final class NotificationActionIds {
  static const done = 'followup_done';
  static const tomorrow = 'followup_tomorrow';
}

/// Immutable description of a scheduled notification (used by both the real
/// plugin backend and fake test backends).
class ScheduledNotificationSpec {
  const ScheduledNotificationSpec({
    required this.id,
    required this.channelId,
    required this.channelName,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.payload,
    this.actions = const [],
    this.dailyRepeat = false,
  });

  final int id;
  final String channelId;
  final String channelName;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String payload;
  final List<NotificationActionSpec> actions;
  final bool dailyRepeat;
}

class NotificationActionSpec {
  const NotificationActionSpec({required this.id, required this.label});

  final String id;
  final String label;
}

/// Callback invoked when a notification or one of its action buttons is tapped.
typedef NotificationResponseHandler = Future<void> Function({
  required String? actionId,
  required String? payload,
});

/// Abstraction over `flutter_local_notifications` for deterministic unit tests.
abstract class NotificationsBackend {
  Future<void> initialize(NotificationResponseHandler onResponse);
  Future<void> ensureChannels();
  Future<bool> canScheduleExactAlarms();
  Future<void> cancelAllPending();
  Future<void> cancel(int id);
  Future<void> schedule(ScheduledNotificationSpec spec, {required bool exact});
}

/// Top-level background entry point for Android notification action buttons
/// (e.g. tapping "Done" or "Tomorrow" when the app is closed).
@pragma('vm:entry-point')
Future<void> onBackgroundNotificationResponse(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  final payload = response.payload;
  final actionId = response.actionId;
  if (payload == null || actionId == null || actionId.isEmpty) return;

  final db = AppDatabase.openDefault();
  try {
    final service = NotificationsService(
      db: db,
      backend: FlutterLocalNotificationsBackend(),
    );
    await service.handleResponse(actionId: actionId, payload: payload);
  } finally {
    await db.close();
  }
}

/// Real Android implementation backed by `flutter_local_notifications`.
class FlutterLocalNotificationsBackend implements NotificationsBackend {
  FlutterLocalNotificationsBackend({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _tzInitialized = false;

  void _ensureTimeZone() {
    if (_tzInitialized) return;
    tz_data.initializeTimeZones();
    _tzInitialized = true;
  }

  @override
  Future<void> initialize(NotificationResponseHandler onResponse) async {
    _ensureTimeZone();
    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: androidInit);
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (resp) {
          unawaited(onResponse(actionId: resp.actionId, payload: resp.payload));
        },
        onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationResponse,
      );
    } catch (_) {
      // Safe no-op when running on hosts/tests without an Android plugin registrant.
    }
  }

  @override
  Future<void> ensureChannels() async {
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return;

      const channels = [
        AndroidNotificationChannel(
          NotificationChannels.followUps,
          'Follow-ups',
          description: 'Reminders for scheduled follow-ups',
          importance: Importance.high,
        ),
        AndroidNotificationChannel(
          NotificationChannels.reconnect,
          'Reconnect',
          description: 'Reconnect reminders',
          importance: Importance.defaultImportance,
        ),
        AndroidNotificationChannel(
          NotificationChannels.afterCalls,
          'After calls',
          description: 'Prompts to add a note after calls with saved contacts',
          importance: Importance.high,
        ),
        AndroidNotificationChannel(
          NotificationChannels.messages,
          'Messages',
          description: 'Scheduled message status and campaign progress',
          importance: Importance.defaultImportance,
        ),
        AndroidNotificationChannel(
          NotificationChannels.morningSummary,
          'Morning summary',
          description: 'Daily morning summary of follow-ups and reconnects',
          importance: Importance.defaultImportance,
        ),
      ];

      for (final ch in channels) {
        await android.createNotificationChannel(ch);
      }
    } catch (_) {
      // Safe no-op when platform plugin is not registered.
    }
  }

  @override
  Future<bool> canScheduleExactAlarms() async {
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return false;
      return await android.canScheduleExactNotifications() ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> cancelAllPending() async {
    try {
      await _plugin.cancelAllPendingNotifications();
    } catch (_) {
      // Safe no-op on non-Android/test hosts.
    }
  }

  @override
  Future<void> cancel(int id) async {
    try {
      await _plugin.cancel(id: id);
    } catch (_) {
      // Safe no-op on non-Android/test hosts.
    }
  }

  @override
  Future<void> schedule(ScheduledNotificationSpec spec, {required bool exact}) async {
    _ensureTimeZone();
    try {
      final tzDate = tz.TZDateTime.from(spec.scheduledAt.toUtc(), tz.UTC);
      final androidDetails = AndroidNotificationDetails(
        spec.channelId,
        spec.channelName,
        importance: spec.channelId == NotificationChannels.followUps
            ? Importance.high
            : Importance.defaultImportance,
        priority: spec.channelId == NotificationChannels.followUps
            ? Priority.high
            : Priority.defaultPriority,
        actions: [
          for (final a in spec.actions)
            AndroidNotificationAction(
              a.id,
              a.label,
              showsUserInterface: false,
              cancelNotification: true,
            ),
        ],
      );

      await _plugin.zonedSchedule(
        id: spec.id,
        title: spec.title,
        body: spec.body,
        scheduledDate: tzDate,
        notificationDetails: NotificationDetails(android: androidDetails),
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        payload: spec.payload,
        matchDateTimeComponents: spec.dailyRepeat ? DateTimeComponents.time : null,
      );
    } catch (_) {
      // Safe no-op on non-Android/test hosts.
    }
  }
}

/// Manages all scheduled follow-up reminders and the daily morning summary from
/// the database as a single source of truth (Spec 08 step 6 & 7).
class NotificationsService {
  NotificationsService({
    required AppDatabase db,
    required this.backend,
    DateTime Function()? clock,
    this.onNavigate,
  })  : _db = db,
        _clock = clock ?? DateTime.now,
        _followUps = FollowUpsRepository(db),
        _settings = SettingsRepository(db),
        _today = TodayRepository(db);

  static const int followUpIdBase = 100000;
  static const int morningSummaryId = 90001;

  final AppDatabase _db;
  final NotificationsBackend backend;
  final DateTime Function() _clock;
  final void Function(String route)? onNavigate;
  final FollowUpsRepository _followUps;
  final SettingsRepository _settings;
  final TodayRepository _today;

  bool _initialized = false;

  static int notificationIdForFollowUp(int taskId) => followUpIdBase + taskId;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await backend.initialize(handleResponse);
    await backend.ensureChannels();
  }

  /// Cancels all pending notifications and recreates them directly from the
  /// database so scheduled alarms can never drift from stored data.
  Future<void> rescheduleAll() async {
    final now = _clock();
    final nowMs = now.millisecondsSinceEpoch;
    final exact = await backend.canScheduleExactAlarms();

    await backend.cancelAllPending();

    // 1. Schedule every open follow-up with a future reminder_time (or due_date).
    // Also covers legacy tasks with a future reminder_time (Spec 08 step 7).
    final openTasks = await _followUps.watchAllOpen().first;
    for (final item in openTasks) {
      final fireAtMs = item.task.reminderTime ?? item.task.dueDate;
      if (fireAtMs <= nowMs) continue;
      final contactId = item.task.contactId ?? 0;
      await backend.schedule(
        ScheduledNotificationSpec(
          id: notificationIdForFollowUp(item.task.id),
          channelId: NotificationChannels.followUps,
          channelName: 'Follow-ups',
          title: item.personName.isNotEmpty ? item.personName : 'Follow-up',
          body: item.task.title,
          scheduledAt: DateTime.fromMillisecondsSinceEpoch(fireAtMs),
          payload: 'followup:${item.task.id}:$contactId',
          actions: const [
            NotificationActionSpec(id: NotificationActionIds.done, label: 'Done'),
            NotificationActionSpec(id: NotificationActionIds.tomorrow, label: 'Tomorrow'),
          ],
        ),
        exact: exact,
      );
    }

    // 2. Schedule morning summary (default on, default 09:00) if counts > 0.
    final summaryEnabled = (await _settings.get('morning_summary_enabled')) != '0';
    if (!summaryEnabled) return;

    final hour = int.tryParse((await _settings.get('morning_summary_hour')) ?? '') ?? 9;
    final minute = int.tryParse((await _settings.get('morning_summary_minute')) ?? '') ?? 0;

    DateTime nextSummary = DateTime(now.year, now.month, now.day, hour, minute);
    if (!nextSummary.isAfter(now)) {
      nextSummary = nextSummary.add(const Duration(days: 1));
    }

    final summaryDayEnd =
        DateTime(nextSummary.year, nextSummary.month, nextSummary.day, 23, 59, 59, 999);
    final dueFollowUpsCount = openTasks
        .where((t) => t.task.dueDate <= summaryDayEnd.millisecondsSinceEpoch)
        .length;
    final dueReconnectCount =
        (await _today.getDueToReconnectOnce(now: nextSummary)).length;

    if (dueFollowUpsCount == 0 && dueReconnectCount == 0) {
      return;
    }

    final parts = <String>[
      if (dueFollowUpsCount > 0)
        dueFollowUpsCount == 1
            ? '1 follow-up today'
            : '$dueFollowUpsCount follow-ups today',
      if (dueReconnectCount > 0)
        dueReconnectCount == 1
            ? '1 person to reconnect with'
            : '$dueReconnectCount people to reconnect with',
    ];

    await backend.schedule(
      ScheduledNotificationSpec(
        id: morningSummaryId,
        channelId: NotificationChannels.morningSummary,
        channelName: 'Morning summary',
        title: 'PocketCRM',
        body: parts.join(' · '),
        scheduledAt: nextSummary,
        payload: 'today',
        dailyRepeat: true,
      ),
      exact: exact,
    );
  }

  /// Cancels the notification for a single follow-up (e.g. when completed).
  Future<void> cancelFollowUp(int taskId) async {
    await backend.cancel(notificationIdForFollowUp(taskId));
  }

  /// Handles tapping a notification or its Done / Tomorrow action button.
  Future<void> handleResponse({
    required String? actionId,
    required String? payload,
  }) async {
    if (payload == null || payload.isEmpty) return;

    if (payload == 'today') {
      onNavigate?.call('/today');
      return;
    }

    if (payload.startsWith('followup:')) {
      final parts = payload.split(':');
      final taskId = parts.length >= 2 ? int.tryParse(parts[1]) : null;
      final contactId = parts.length >= 3 ? int.tryParse(parts[2]) : null;

      if (taskId != null && actionId == NotificationActionIds.done) {
        await _followUps.completeFollowUp(taskId);
        await cancelFollowUp(taskId);
        await rescheduleAll();
        return;
      }

      if (taskId != null && actionId == NotificationActionIds.tomorrow) {
        final task = await (_db.select(_db.tasks)..where((t) => t.id.equals(taskId)))
            .getSingleOrNull();
        if (task != null) {
          final currentDue = DateTime.fromMillisecondsSinceEpoch(task.dueDate);
          final nextDue = DateTime(
            currentDue.year,
            currentDue.month,
            currentDue.day + 1,
            currentDue.hour,
            currentDue.minute,
          ).millisecondsSinceEpoch;
          await _followUps.rescheduleFollowUp(taskId, nextDue);
          await rescheduleAll();
        }
        return;
      }

      if (contactId != null && contactId > 0) {
        onNavigate?.call('/people/$contactId');
      } else {
        onNavigate?.call('/today');
      }
    }
  }
}
