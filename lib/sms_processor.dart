import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';

class SmsProcessor {
  static const MethodChannel _channel = MethodChannel('com.pocketcrm.pocket_crm/sms');
  static bool _isProcessing = false; // Lock to prevent concurrent execution

  /// Helper to send SMS using the device's native SmsManager.
  static Future<bool> sendNativeSms(String phoneNumber, String message) async {
    try {
      final bool result = await _channel.invokeMethod('sendSms', {
        'phoneNumber': phoneNumber,
        'message': message,
      });
      return result;
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
      debugPrint("SmsProcessor: Already processing scheduled SMS queue, skipping concurrent invocation.");
      return;
    }
    _isProcessing = true;

    try {
      final db = await DatabaseHelper.instance.database;

      while (true) {
        final now = DateTime.now().millisecondsSinceEpoch;

        // Query only the oldest single unsent scheduled SMS that is due
        final List<Map<String, dynamic>> dueSmsList = await db.query(
          'scheduled_sms',
          where: 'is_sent = 0 AND scheduled_time <= ?',
          whereArgs: [now],
          orderBy: 'scheduled_time ASC, id ASC',
          limit: 1,
        );

        if (dueSmsList.isEmpty) {
          break; // Queue is fully cleared!
        }

        final sms = dueSmsList.first;
        final smsId = sms['id'] as int;
        final contactId = sms['contact_id'] as int;
        final message = sms['message'] as String;
        final phone = sms['phone_number'] as String;
        final bulkJobId = sms['bulk_job_id'] as int?;

        // 1. Database-level Lock: Instantly mark the SMS as sent in SQLite BEFORE sending it native,
        // preventing any concurrent processors from ever fetching it again.
        await db.update(
          'scheduled_sms',
          {'is_sent': 1},
          where: 'id = ?',
          whereArgs: [smsId],
        );

        // 2. Dispatch the actual native SMS
        debugPrint("SmsProcessor: Dispatching SMS in queue for contact ID $contactId to $phone...");
        final success = await sendNativeSms(phone, message);

        // 3. Log outgoing SMS to relationship thread timeline
        await db.insert('timeline', {
          'contact_id': contactId,
          'type': 'sms_outgoing',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'content': message,
          'native_message_id': 'scheduled_sent_$smsId',
        });

        // 4. Update bulk SMS campaign progress
        if (bulkJobId != null) {
          final remaining = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM scheduled_sms WHERE bulk_job_id = ? AND is_sent = 0',
            [bulkJobId]
          )) ?? 0;
          if (remaining == 0) {
            await db.update(
              'bulk_sms_jobs',
              {'is_sent': 1},
              where: 'id = ?',
              whereArgs: [bulkJobId],
            );
          }
        }

        if (context != null && context.mounted) {
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success 
                  ? 'Sent scheduled SMS to $phone: "$message"'
                  : 'Failed to send scheduled SMS to $phone (logged in timeline)'),
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

        // 5. Transmitter Throttling: Await a 2-second safe delay before the next loop
        // to prevent native OS jamming, skipping, or carrier blocks.
        await Future.delayed(const Duration(seconds: 2));
      }
    } catch (e) {
      debugPrint("SmsProcessor: Error in SMS queue execution: $e");
    } finally {
      _isProcessing = false;
    }
  }
}

