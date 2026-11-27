import '../../../core/db/app_database.dart';

/// Candidate for the Reconnect section on Today.
class ReconnectCandidate {
  const ReconnectCandidate({
    required this.contact,
    required this.listCadenceDays,
    required this.lastInteractionType,
  });

  final Contact contact;
  final List<int> listCadenceDays;
  final String? lastInteractionType;
}

/// Resolved due-to-reconnect item sorted by overdue ratio descending.
class DueReconnectItem {
  const DueReconnectItem({
    required this.contact,
    required this.effectiveCadenceDays,
    required this.dueAtMs,
    required this.overdueRatio,
    required this.lastInteractionType,
  });

  final Contact contact;
  final int effectiveCadenceDays;
  final int dueAtMs;
  final double overdueRatio;
  final String? lastInteractionType;
}

/// Upcoming birthday item in the next 7 days.
class UpcomingBirthdayItem {
  const UpcomingBirthdayItem({
    required this.contact,
    required this.nextBirthdayDate,
    required this.daysUntil,
  });

  final Contact contact;
  final DateTime nextBirthdayDate;
  final int daysUntil;
}

/// Pure, clock-injectable cadence and birthday calculations (Spec 08).
abstract final class CadenceCalculator {
  /// Effective cadence of a person:
  /// - Their own `cadence_days` wins when set and positive.
  /// - Otherwise, the smallest positive `cadence_days` among their lists.
  /// - Otherwise, `null` (no cadence).
  static int? effectiveCadenceDays(
    int? personCadenceDays,
    Iterable<int?> listCadenceDays,
  ) {
    if (personCadenceDays != null && personCadenceDays > 0) {
      return personCadenceDays;
    }
    int? smallest;
    for (final d in listCadenceDays) {
      if (d != null && d > 0) {
        if (smallest == null || d < smallest) {
          smallest = d;
        }
      }
    }
    return smallest;
  }

  /// Computes the reconnect due timestamp (ms since epoch).
  /// `last_interaction_at + cadence`, or when no interaction exists yet,
  /// `cadenceSetAtMs / createdAtMs + cadence`.
  static int reconnectDueAtMs({
    required int effectiveCadenceDays,
    int? lastInteractionAtMs,
    int? cadenceSetAtMs,
    int? createdAtMs,
  }) {
    final anchor = lastInteractionAtMs ?? cadenceSetAtMs ?? createdAtMs ?? 0;
    return anchor + effectiveCadenceDays * Duration.millisecondsPerDay;
  }

  /// Returns `true` when [nowMs] is at or past [dueAtMs] and not snoozed.
  static bool isDue({
    required int nowMs,
    required int dueAtMs,
    int? snoozedUntilMs,
  }) {
    if (snoozedUntilMs != null && nowMs < snoozedUntilMs) {
      return false;
    }
    return nowMs >= dueAtMs;
  }

  /// Ratio of overdue duration to cadence length; larger means more urgently overdue.
  static double overdueRatio({
    required int nowMs,
    required int dueAtMs,
    required int effectiveCadenceDays,
  }) {
    final cadenceMs = effectiveCadenceDays * Duration.millisecondsPerDay;
    if (cadenceMs <= 0) return 0;
    return (nowMs - dueAtMs) / cadenceMs;
  }

  /// Filters and sorts [candidates] returning everyone currently due to reconnect,
  /// most overdue by ratio first.
  static List<DueReconnectItem> computeDueList(
    Iterable<ReconnectCandidate> candidates, {
    required DateTime now,
  }) {
    final nowMs = now.millisecondsSinceEpoch;
    final due = <DueReconnectItem>[];

    for (final cand in candidates) {
      final effDays = effectiveCadenceDays(cand.contact.cadenceDays, cand.listCadenceDays);
      if (effDays == null) continue;

      final dueAt = reconnectDueAtMs(
        effectiveCadenceDays: effDays,
        lastInteractionAtMs: cand.contact.lastInteractionAt,
        createdAtMs: cand.contact.createdAt,
      );

      if (!isDue(
        nowMs: nowMs,
        dueAtMs: dueAt,
        snoozedUntilMs: cand.contact.cadenceSnoozedUntil,
      )) {
        continue;
      }

      due.add(
        DueReconnectItem(
          contact: cand.contact,
          effectiveCadenceDays: effDays,
          dueAtMs: dueAt,
          overdueRatio: overdueRatio(
            nowMs: nowMs,
            dueAtMs: dueAt,
            effectiveCadenceDays: effDays,
          ),
          lastInteractionType: cand.lastInteractionType,
        ),
      );
    }

    due.sort((a, b) {
      final ratioCmp = b.overdueRatio.compareTo(a.overdueRatio);
      if (ratioCmp != 0) return ratioCmp;
      return a.contact.displayName.toLowerCase().compareTo(b.contact.displayName.toLowerCase());
    });
    return due;
  }

  /// Parses `YYYY-MM-DD`, `--MM-DD`, or `MM-DD` and returns upcoming birthdays
  /// within the next [windowDays] (inclusive, default 7), sorted soonest first.
  static List<UpcomingBirthdayItem> computeUpcomingBirthdays(
    Iterable<Contact> contacts, {
    required DateTime now,
    int windowDays = 7,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final items = <UpcomingBirthdayItem>[];

    for (final c in contacts) {
      final raw = c.birthday?.trim();
      if (raw == null || raw.isEmpty) continue;
      final md = _parseMonthDay(raw);
      if (md == null) continue;

      DateTime candidate = _safeDate(today.year, md.$1, md.$2);
      if (candidate.isBefore(today)) {
        candidate = _safeDate(today.year + 1, md.$1, md.$2);
      }
      final diff = candidate.difference(today).inDays;
      if (diff >= 0 && diff <= windowDays) {
        items.add(
          UpcomingBirthdayItem(
            contact: c,
            nextBirthdayDate: candidate,
            daysUntil: diff,
          ),
        );
      }
    }

    items.sort((a, b) {
      final cmp = a.daysUntil.compareTo(b.daysUntil);
      if (cmp != 0) return cmp;
      return a.contact.displayName.toLowerCase().compareTo(b.contact.displayName.toLowerCase());
    });
    return items;
  }

  static (int, int)? _parseMonthDay(String raw) {
    final matchFull = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(raw);
    if (matchFull != null) {
      final m = int.tryParse(matchFull.group(2)!);
      final d = int.tryParse(matchFull.group(3)!);
      if (m != null && d != null && m >= 1 && m <= 12 && d >= 1 && d <= 31) {
        return (m, d);
      }
    }
    final matchShort = RegExp(r'^(?:--)?(\d{1,2})-(\d{1,2})$').firstMatch(raw);
    if (matchShort != null) {
      final m = int.tryParse(matchShort.group(1)!);
      final d = int.tryParse(matchShort.group(2)!);
      if (m != null && d != null && m >= 1 && m <= 12 && d >= 1 && d <= 31) {
        return (m, d);
      }
    }
    return null;
  }

  static DateTime _safeDate(int year, int month, int day) {
    // Handle Feb 29 on non-leap years -> Feb 28
    if (month == 2 && day == 29) {
      final isLeap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return DateTime(year, 2, isLeap ? 29 : 28);
    }
    return DateTime(year, month, day);
  }
}
