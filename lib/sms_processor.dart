import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class SmsProcessor {
  static const MethodChannel _channel = MethodChannel('com.pocketcrm.pocket_crm/sms');
  static const int _maxLateWindowMs = 30 * 60 * 1000; // 30 minutes
  static bool _isProcessing = false; // Lock to prevent concurrent execution

  /// Row IDs that failed to send during the current app session so they are not retried automatically.
  static final Set<int> _failedIdsInSession = <int>{};

  @visibleForTesting
  static Duration throttleDelay = const Duration(seconds: 2);

  @visibleForTesting
  static void resetSessionState() {
    _failedIdsInSession.clear();
    _isProcessing = false;
  }

  /// Helper to send SMS using the device's native SmsManager.
  static Future<bool> sendNativeSms(String phoneNumber, String message) async {
    try {
      final result = await _channel.invokeMethod<bool>('sendSms', {
        'phoneNumber': phoneNumber,
        'message': message,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint("Failed to send native SMS: '${e.message}'.");
      return false;
    } catch (e) {
      debugPrint("Failed to send native SMS: '$e'.");
      return false;
    }
  }

  static Future<void> processDueSms(BuildContext? context, VoidCallback? onSent) async {
    if (_isProcessing) {
      debugPrint('SmsProcessor: Already processing scheduled SMS queue, skipping concurrent invocation.');
      return;
    }
    _isProcessing = true;

    try {
      final db = await DatabaseHelper.instance.database;

      while (true) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final earliestAllowed = now - _maxLateWindowMs;

        final whereBuffer = StringBuffer(
          'is_sent = 0 AND scheduled_time <= ? AND scheduled_time >= ?',
        );
        final whereArgs = <Object?>[now, earliestAllowed];
        if (_failedIdsInSession.isNotEmpty) {
          final placeholders = List.filled(_failedIdsInSession.length, '?').join(',');
          whereBuffer.write(' AND id NOT IN ($placeholders)');
          whereArgs.addAll(_failedIdsInSession);
        }

        // Query only the oldest single unsent scheduled SMS within the 30-minute window
        final List<Map<String, dynamic>> dueSmsList = await db.query(
          'scheduled_sms',
          where: whereBuffer.toString(),
          whereArgs: whereArgs,
          orderBy: 'scheduled_time ASC, id ASC',
          limit: 1,
        );

        if (dueSmsList.isEmpty) {
          break;
        }

        final sms = dueSmsList.first;
        final smsId = sms['id'] as int;
        final contactId = sms['contact_id'] as int;
        final message = sms['message'] as String;
        final phone = sms['phone_number'] as String;
        final bulkJobId = sms['bulk_job_id'] as int?;

        // 1. Dispatch the actual native SMS before mutating sent state
        debugPrint('SmsProcessor: Dispatching SMS in queue for contact ID $contactId to $phone...');
        final success = await sendNativeSms(phone, message);

        if (success) {
          // 2. Mark sent and log outgoing SMS only when sendNativeSms returned true
          await db.update(
            'scheduled_sms',
            {'is_sent': 1},
            where: 'id = ?',
            whereArgs: [smsId],
          );

          await db.insert('timeline', {
            'contact_id': contactId,
            'type': 'sms_outgoing',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'content': message,
            'native_message_id': 'scheduled_sent_$smsId',
          });

          // 3. Update bulk SMS campaign progress
          if (bulkJobId != null) {
            final remaining = Sqflite.firstIntValue(await db.rawQuery(
                  'SELECT COUNT(*) FROM scheduled_sms WHERE bulk_job_id = ? AND is_sent = 0',
                  [bulkJobId],
                )) ??
                0;
            if (remaining == 0) {
              await db.update(
                'bulk_sms_jobs',
                {'is_sent': 1},
                where: 'id = ?',
                whereArgs: [bulkJobId],
              );
            }
          }
        } else {
          // Leave row unsent and avoid retrying it automatically in this session
          _failedIdsInSession.add(smsId);
        }

        if (context != null && context.mounted) {
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Sent scheduled SMS to $phone: "$message"'
                      : 'Failed to send scheduled SMS to $phone',
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: success ? const Color(0xFF3525CD) : Colors.redAccent,
                duration: const Duration(seconds: 3),
              ),
            );
          } catch (_) {}
        }

        if (onSent != null) {
          try {
            onSent();
          } catch (_) {}
        }

        // 4. Transmitter throttling before checking the next due message
        if (throttleDelay > Duration.zero) {
          await Future<void>.delayed(throttleDelay);
        }
      }
    } catch (e) {
      debugPrint('SmsProcessor: Error in SMS queue execution: $e');
    } finally {
      _isProcessing = false;
    }
  }
}
