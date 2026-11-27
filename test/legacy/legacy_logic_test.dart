import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_crm/spam_filter.dart';
import 'package:pocket_crm/sync_engine.dart';

void main() {
  group('SyncEngine.normalizePhone (legacy)', () {
    test('normalizes Bangladesh local 01 number to +8801', () {
      expect(SyncEngine.normalizePhone('01712345678'), '+8801712345678');
    });

    test('normalizes 8801 number by adding leading plus', () {
      expect(SyncEngine.normalizePhone('8801712345678'), '+8801712345678');
    });

    test('leaves international E.164 number unchanged', () {
      expect(SyncEngine.normalizePhone('+14155550100'), '+14155550100');
    });

    test('cleans formatting punctuation and spaces', () {
      expect(SyncEngine.normalizePhone('0171-234 5678'), '+8801712345678');
    });
  });

  group('SyncEngine.getLast10Digits (legacy)', () {
    test('returns last 10 digits for all standard inputs', () {
      expect(SyncEngine.getLast10Digits('01712345678'), '1712345678');
      expect(SyncEngine.getLast10Digits('8801712345678'), '1712345678');
      expect(SyncEngine.getLast10Digits('+14155550100'), '4155550100');
      expect(SyncEngine.getLast10Digits('0171-234 5678'), '1712345678');
    });
  });

  group('SpamFilter.isSpam (legacy)', () {
    test('flags alphanumeric sender as spam', () {
      expect(SpamFilter.isSpam('bKash', 'Hello'), isTrue);
    });

    test('flags short code sender as spam', () {
      expect(SpamFilter.isSpam('16247', 'Hello'), isTrue);
    });

    test('allows normal personal message', () {
      expect(
        SpamFilter.isSpam('+8801712345678', 'Hey, are we still meeting at 3?'),
        isFalse,
      );
    });

    test('flags customer invoice message as spam (known defect)', () {
      // known defect, fixed in spec 05
      expect(
        SpamFilter.isSpam(
          '+8801712345678',
          'Please send the invoice and the bill reference',
        ),
        isTrue,
      );
    });
  });

  group('parseLegacyPaymentAmount', () {
    test('parses Tk, taka symbol, and BDT amounts', () {
      expect(parseLegacyPaymentAmount('Paid Tk 1,500.50 today'), 1500.50);
      expect(parseLegacyPaymentAmount('Received ৳500'), 500.0);
      expect(parseLegacyPaymentAmount('Amount BDT 200 confirmed'), 200.0);
    });

    test('does not match unrelated words like Take 5', () {
      expect(parseLegacyPaymentAmount('Take 5 minutes and call back'), isNull);
    });
  });
}
