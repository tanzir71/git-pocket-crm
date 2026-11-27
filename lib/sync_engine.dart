import 'dart:math';
import 'package:call_log/call_log.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_helper.dart';
import 'spam_filter.dart';

/// Legacy payment amount extraction from SMS body (unchanged from v1).
double? parseLegacyPaymentAmount(String body) {
  if (body.contains('৳') ||
      body.toLowerCase().contains('tk') ||
      body.toLowerCase().contains('bdt')) {
    // Regexp to capture digits after currency signs
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
    '#3525CD', // Deep Indigo
    '#4F46E5', // Indigo 600
    '#6366F1', // Indigo 500
    '#818CF8', // Indigo 400
    '#4338CA', // Indigo 700
    '#1E1B4B', // Slate Indigo
  ];

  static String getRandomIndigoColor() {
    final random = Random();
    return _indigoColors[random.nextInt(_indigoColors.length)];
  }

  /// Normalizes a phone number to standard international format or simple digit string.
  /// Standardizes Bangladesh numbers starting with '01' to '+8801'.
  static String normalizePhone(String raw) {
    String cleaned = raw.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('01') && cleaned.length == 11) {
      cleaned = '+88$cleaned';
    }
    // Handle local numbers without country code if they are 11 digits
    if (cleaned.startsWith('8801') && cleaned.length == 13) {
      cleaned = '+$cleaned';
    }
    return cleaned;
  }

  /// Extracts the last 10 digits of a phone number for robust, format-agnostic matching.
  static String getLast10Digits(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length >= 10) {
      return cleaned.substring(cleaned.length - 10);
    }
    return cleaned;
  }

  /// Checks and requests all necessary Android permissions
  static Future<bool> requestPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.contacts,
      Permission.sms,
      Permission.phone, // For call log access
    ].request();

    return statuses[Permission.contacts] == PermissionStatus.granted &&
        statuses[Permission.sms] == PermissionStatus.granted &&
        statuses[Permission.phone] == PermissionStatus.granted;
  }

  /// Natively syncs device contacts, call logs, and SMS messages.
  static Future<Map<String, int>> syncAll() async {
    int contactsSynced = 0;
    int callsSynced = 0;
    int smsSynced = 0;

    final bool hasPermissions = await requestPermissions();
    if (!hasPermissions) {
      throw Exception("Insufficient Android system permissions to execute sync.");
    }

    final db = await DatabaseHelper.instance.database;

    // 1. Sync Contacts from device
    final deviceContacts = await FlutterContacts.getContacts(withProperties: true);
    
    // Fetch current SQLite contacts to prevent duplicates
    final List<Map<String, dynamic>> dbContactsList = await db.query('contacts');
    final Map<String, Map<String, dynamic>> dbContactsMap = {
      for (var c in dbContactsList) normalizePhone(c['phone_number'] ?? ''): c
    };

    for (var deviceContact in deviceContacts) {
      if (deviceContact.phones.isEmpty) continue;

      final rawPhone = deviceContact.phones.first.number;
      final normalized = normalizePhone(rawPhone);

      // Skip empty or automated spammers in contacts sync
      if (normalized.isEmpty || SpamFilter.isSpam(normalized, "")) continue;

      final displayName = deviceContact.displayName.isNotEmpty 
          ? deviceContact.displayName 
          : rawPhone;

      if (dbContactsMap.containsKey(normalized)) {
        // Update name if changed
        final existing = dbContactsMap[normalized]!;
        if (existing['display_name'] != displayName) {
          await db.update(
            'contacts',
            {'display_name': displayName},
            where: 'id = ?',
            whereArgs: [existing['id']],
          );
        }
      } else {
        // Insert new local contact
        final newId = await db.insert('contacts', {
          'phone_number': normalized,
          'display_name': displayName,
          'avatar_color': getRandomIndigoColor(),
          'is_starred': 0,
          'facebook_url': '',
          'linkedin_url': '',
          'gmail_address': '',
          'pinned_note': '',
          'last_sync_time': DateTime.now().millisecondsSinceEpoch
        });
        dbContactsMap[normalized] = {
          'id': newId,
          'phone_number': normalized,
          'display_name': displayName,
        };
        contactsSynced++;
      }
    }

    // Refresh contact list with full SQLite mappings keyed by last 10 digits
    final List<Map<String, dynamic>> activeDbContacts = await db.query('contacts');
    final Map<String, int> phoneToIdMap = {};
    for (var c in activeDbContacts) {
      final phone = c['phone_number'] ?? '';
      final key = getLast10Digits(phone);
      if (key.isNotEmpty) {
        phoneToIdMap[key] = c['id'] as int;
      }
    }

    // 2. Sync Phone Call Logs
    final Iterable<CallLogEntry> callEntries = await CallLog.query();
    await db.transaction((txn) async {
      for (var entry in callEntries) {
        final rawNumber = entry.number ?? '';
        final key = getLast10Digits(rawNumber);

        if (key.isEmpty || !phoneToIdMap.containsKey(key)) continue;
        final contactId = phoneToIdMap[key]!;

        // Determine chronological details
        final timestamp = entry.timestamp ?? DateTime.now().millisecondsSinceEpoch;
        final duration = entry.duration ?? 0;
        final minutes = duration ~/ 60;
        final seconds = duration % 60;
        String durationStr = minutes > 0 ? "$minutes min $seconds sec" : "$seconds sec";

        // Map call types
        String callType = 'call_incoming';
        if (entry.callType == CallType.outgoing) {
          callType = 'call_outgoing';
        } else if (entry.callType == CallType.missed) {
          callType = 'call_missed';
          durationStr = "Missed call";
        }

        // Check if call log already synced
        final duplicateCheck = await txn.query(
          'timeline',
          where: 'contact_id = ? AND type = ? AND timestamp = ?',
          whereArgs: [contactId, callType, timestamp],
        );

        if (duplicateCheck.isEmpty) {
          await txn.insert('timeline', {
            'contact_id': contactId,
            'type': callType,
            'timestamp': timestamp,
            'content': "Duration: $durationStr",
            'amount': null,
            'attachment_path': null,
            'native_message_id': null,
          });
          callsSynced++;
        }
      }
    });

    // 3. Sync SMS Messages
    final SmsQuery query = SmsQuery();
    final List<SmsMessage> smsList = await query.querySms(
      kinds: [SmsQueryKind.inbox, SmsQueryKind.sent],
    );

    await db.transaction((txn) async {
      for (var message in smsList) {
        final rawSender = message.address ?? '';
        final body = message.body ?? '';

        // Skip corporate promotions and general transactional spam
        if (SpamFilter.isSpam(rawSender, body)) continue;

        final key = getLast10Digits(rawSender);
        if (key.isEmpty || !phoneToIdMap.containsKey(key)) continue;
        final contactId = phoneToIdMap[key]!;

        final timestamp = message.date?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;
        final nativeId = message.id?.toString() ?? '${contactId}_$timestamp';

        // Check if SMS already stored
        final duplicateCheck = await txn.query(
          'timeline',
          where: 'native_message_id = ?',
          whereArgs: [nativeId],
        );

        if (duplicateCheck.isEmpty) {
          final isSent = message.kind == SmsMessageKind.sent;
          final timelineType = isSent ? 'sms_outgoing' : 'sms_incoming';

          // Extract standard payment numbers (e.g. bKash, Tk, ৳)
          final double? paymentAmount = parseLegacyPaymentAmount(body);

          await txn.insert('timeline', {
            'contact_id': contactId,
            'type': timelineType,
            'timestamp': timestamp,
            'content': body,
            'amount': paymentAmount,
            'attachment_path': null,
            'native_message_id': nativeId,
          });
          smsSynced++;

          // If a payment was successfully parsed, create an explicit sibling 'payment' item in timeline
          if (paymentAmount != null) {
            await txn.insert('timeline', {
              'contact_id': contactId,
              'type': 'payment',
              'timestamp': timestamp,
              'content': 'Parsed from SMS: ${body.length > 60 ? '${body.substring(0, 60)}...' : body}',
              'amount': paymentAmount,
              'attachment_path': null,
              'native_message_id': '${nativeId}_payment',
            });
          }
        }
      }
    });

    // Update contacts sync timestamp
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.update('contacts', {'last_sync_time': now});

    return {
      'contacts': contactsSynced,
      'calls': callsSynced,
      'sms': smsSynced,
    };
  }
}
