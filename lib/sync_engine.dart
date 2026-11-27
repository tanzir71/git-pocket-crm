import 'dart:math';

import 'package:permission_handler/permission_handler.dart';

import 'database_helper.dart';
import 'features/sync/data/sync_service.dart';

/// Legacy payment amount extraction from SMS body (unchanged from v1).
double? parseLegacyPaymentAmount(String body) {
  if (body.contains('৳') ||
      body.toLowerCase().contains('tk') ||
      body.toLowerCase().contains('bdt')) {
    final match = RegExp(
      r'(?:৳|tk|bdt)\.?\s*([0-9,]+(?:\.[0-9]+)?)',
      caseSensitive: false,
    ).firstMatch(body);
    if (match != null) {
      final val = match.group(1)?.replaceAll(',', '');
      if (val != null) {
        return double.tryParse(val);
      }
    }
  }
  return null;
}

class SyncEngine {
  static final List<String> _indigoColors = [
    '#3525CD',
    '#4F46E5',
    '#6366F1',
    '#818CF8',
    '#4338CA',
    '#1E1B4B',
  ];

  static String getRandomIndigoColor() {
    final random = Random();
    return _indigoColors[random.nextInt(_indigoColors.length)];
  }

  /// Legacy phone normalisation kept for characterisation tests until spec 10.
  static String normalizePhone(String raw) {
    String cleaned = raw.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('01') && cleaned.length == 11) {
      cleaned = '+88$cleaned';
    }
    if (cleaned.startsWith('8801') && cleaned.length == 13) {
      cleaned = '+$cleaned';
    }
    return cleaned;
  }

  /// Legacy last-10-digits helper kept for characterisation tests until spec 10.
  static String getLast10Digits(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length >= 10) {
      return cleaned.substring(cleaned.length - 10);
    }
    return cleaned;
  }

  /// Checks and requests Android permissions needed by legacy screens.
  static Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.contacts,
      Permission.sms,
      Permission.phone,
    ].request();

    return statuses[Permission.contacts] == PermissionStatus.granted &&
        statuses[Permission.sms] == PermissionStatus.granted &&
        statuses[Permission.phone] == PermissionStatus.granted;
  }

  /// Delegates to the new incremental [SyncService] (spec 05).
  static Future<Map<String, int>> syncAll() async {
    final hasPermissions = await requestPermissions();
    if (!hasPermissions) {
      throw Exception('Insufficient Android system permissions to execute sync.');
    }

    final service = SyncService(
      db: DatabaseHelper.instance.appDatabase,
      source: PlatformDeviceDataSource(),
    );
    try {
      final result = await service.syncAll();
      return {
        'contacts': result.contactsSynced,
        'calls': result.callsSynced,
        'sms': result.smsSynced,
      };
    } finally {
      await service.dispose();
    }
  }
}
