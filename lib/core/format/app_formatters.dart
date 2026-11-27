import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

/// Unified, locale-aware, clock-injectable formatter implementing the rules in
/// `handover/02-design-system.md` ("Writing") and Spec 06.
class AppFormatters {
  AppFormatters({
    DateTime Function()? clock,
    this.localeName = 'en',
    this.currencyCode = 'USD',
    this.use24Hour = true,
  }) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final String localeName;
  final String currencyCode;
  final bool use24Hour;

  DateTime get now => _clock();

  static const Map<String, String> currencySymbols = {
    'USD': '\$',
    'BDT': '৳',
    'EUR': '€',
    'GBP': '£',
    'INR': '₹',
    'NGN': '₦',
    'CAD': 'CA\$',
    'AUD': 'A\$',
    'JPY': '¥',
    'AED': 'AED ',
    'SAR': 'SAR ',
    'PKR': 'Rs ',
    'KES': 'KSh ',
    'ZAR': 'R',
    'BRL': 'R\$',
    'MXN': 'MX\$',
    'PHP': '₱',
    'IDR': 'Rp ',
    'MYR': 'RM ',
    'SGD': 'S\$',
  };

  static String symbolForCurrency(String code) {
    final upper = code.trim().toUpperCase();
    return currencySymbols[upper] ?? '$upper ';
  }

  /// Formats a monetary amount using the active locale and currency code.
  /// Omits `.00` for whole numbers (`$240`, `৳1,500`), keeps 2 decimals otherwise (`$240.50`).
  String formatCurrency(double amount, {String? overrideCurrencyCode}) {
    final code = (overrideCurrencyCode != null && overrideCurrencyCode.trim().isNotEmpty)
        ? overrideCurrencyCode.trim().toUpperCase()
        : currencyCode.toUpperCase();
    final symbol = symbolForCurrency(code);
    final isWhole = (amount - amount.roundToDouble()).abs() < 0.005;
    final fmt = NumberFormat.currency(
      locale: localeName,
      symbol: symbol,
      decimalDigits: isWhole ? 0 : 2,
    );
    return fmt.format(amount);
  }

  /// Formats a call duration per design rules: `"4 min"` (or `"30 s"` under a minute).
  String formatDuration(int? seconds, AppLocalizations l10n) {
    if (seconds == null || seconds <= 0) return '';
    if (seconds < 60) {
      return l10n.durationSeconds(seconds);
    }
    final mins = (seconds / 60).round();
    return l10n.durationMinutes(mins);
  }

  /// Trailing short age for People rows: `Now` (<1h), `3h`, `1d`, `3d`, `2w`, `4mo`, `2y`.
  String formatShortAge(int? timestampMs, AppLocalizations l10n) {
    if (timestampMs == null || timestampMs <= 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final diff = now.difference(dt);
    if (diff.isNegative || diff.inMinutes < 60) {
      return l10n.ageNow;
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h';
    }
    final days = diff.inDays;
    if (days < 14) {
      return '${days}d';
    }
    if (days < 60) {
      return '${(days / 7).floor()}w';
    }
    if (days < 365) {
      return '${(days / 30).floor()}mo';
    }
    return '${(days / 365).floor()}y';
  }

  /// Last interaction in words for People row meta:
  /// `"called today"`, `"messaged yesterday"`, `"visited 3 days ago"`,
  /// `"last spoke 6 weeks ago"`, `"no contact yet"`.
  String formatLastInteractionWords(
    int? timestampMs,
    String? interactionType,
    AppLocalizations l10n,
  ) {
    if (timestampMs == null || timestampMs <= 0) {
      return l10n.noContactYet;
    }
    final dt = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final current = now;
    final todayStart = DateTime(current.year, current.month, current.day);
    final targetStart = DateTime(dt.year, dt.month, dt.day);
    final dayDiff = todayStart.difference(targetStart).inDays;

    final isCall = interactionType != null && interactionType.startsWith('call_');
    final isSms = interactionType != null && interactionType.startsWith('sms_');
    final isVisit = interactionType == 'visit';

    if (dayDiff <= 0) {
      if (isCall) return l10n.calledToday;
      if (isSms) return l10n.messagedToday;
      if (isVisit) return l10n.visitedToday;
      return l10n.lastSpokeToday;
    }
    if (dayDiff == 1) {
      if (isCall) return l10n.calledYesterday;
      if (isSms) return l10n.messagedYesterday;
      if (isVisit) return l10n.visitedYesterday;
      return l10n.lastSpokeYesterday;
    }

    final age = _verboseAge(dayDiff);
    if (isCall) return l10n.calledAgo(age);
    if (isSms) return l10n.messagedAgo(age);
    if (isVisit) return l10n.visitedAgo(age);
    return l10n.lastSpokeAgo(age);
  }

  String _verboseAge(int days) {
    if (days < 14) {
      return '$days days';
    }
    if (days < 60) {
      final weeks = (days / 7).floor();
      return weeks == 1 ? '1 week' : '$weeks weeks';
    }
    if (days < 365) {
      final months = (days / 30).floor();
      return months == 1 ? '1 month' : '$months months';
    }
    final years = (days / 365).floor();
    return years == 1 ? '1 year' : '$years years';
  }

  /// Formats a date+time per Writing rules:
  /// Relative within a week (`"Today 10:12"`, `"Yesterday 14:30"`, `"Monday 09:00"`),
  /// absolute after 7 days (`"23 November"` or `"23 November 2025"` for another year).
  String formatRelativeDateTime(int timestampMs, AppLocalizations l10n) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final current = now;
    final todayStart = DateTime(current.year, current.month, current.day);
    final targetStart = DateTime(dt.year, dt.month, dt.day);
    final dayDiff = todayStart.difference(targetStart).inDays;
    final timeStr = formatTime(dt);

    if (dayDiff == 0) {
      return '${l10n.todayLabel} $timeStr';
    }
    if (dayDiff == 1) {
      return '${l10n.yesterdayLabel} $timeStr';
    }
    if (dayDiff == -1) {
      return '${l10n.dueTomorrow} $timeStr';
    }
    if (dayDiff > 1 && dayDiff < 7) {
      final weekday = DateFormat('EEEE', localeName).format(dt);
      return '$weekday $timeStr';
    }
    if (dayDiff < -1 && dayDiff > -7) {
      final weekday = DateFormat('EEEE', localeName).format(dt);
      return '$weekday $timeStr';
    }
    if (dt.year == current.year) {
      return DateFormat('d MMMM', localeName).format(dt);
    }
    return DateFormat('d MMMM y', localeName).format(dt);
  }

  /// Formats a follow-up due date meta (e.g. `"Today 15:00"`, `"Tomorrow 09:00"`, `"overdue by 2 days"`).
  ({String text, bool isOverdue}) formatFollowUpDue(int dueDateMs, AppLocalizations l10n) {
    final dt = DateTime.fromMillisecondsSinceEpoch(dueDateMs);
    final current = now;
    final todayStart = DateTime(current.year, current.month, current.day);
    final targetStart = DateTime(dt.year, dt.month, dt.day);
    final dayDiff = todayStart.difference(targetStart).inDays;

    if (dayDiff > 0) {
      return (text: l10n.overdueByDays(dayDiff), isOverdue: true);
    }
    return (text: formatRelativeDateTime(dueDateMs, l10n), isOverdue: false);
  }

  String formatTime(DateTime dt) {
    return use24Hour
        ? DateFormat.Hm(localeName).format(dt)
        : DateFormat.jm(localeName).format(dt);
  }

  /// Formats header date like `"Thursday 26 November"`.
  String formatHeaderDate(DateTime dt) {
    return DateFormat('EEEE d MMMM', localeName).format(dt);
  }

  /// Formats a month section header like `"October 2026"`.
  String formatMonthHeader(DateTime dt) {
    return DateFormat('MMMM y', localeName).format(dt);
  }

  /// Formats a cadence in days into a localized phrase.
  String formatCadence(int? days, AppLocalizations l10n) {
    if (days == null || days <= 0) return l10n.cadenceNever;
    return switch (days) {
      7 => l10n.cadenceWeekly,
      14 => l10n.cadenceBiweekly,
      30 => l10n.cadenceMonthly,
      90 => l10n.cadenceQuarterly,
      180 => l10n.cadenceHalfYearly,
      365 => l10n.cadenceYearly,
      _ => l10n.cadenceEveryNDays(days),
    };
  }
}
