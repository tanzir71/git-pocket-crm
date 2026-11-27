import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_crm/core/phone/phone_service.dart';
import 'package:pocket_crm/features/sync/data/amount_parser.dart';

void main() {
  const phone = PhoneService();

  group('PhoneService.normalise', () {
    test('normalises Bangladesh numbers', () {
      expect(phone.normalise('01712345678', 'BD'), '+8801712345678');
      expect(phone.normalise('0171-234 5678', 'BD'), '+8801712345678');
      expect(phone.normalise('+880 1712-345678', 'BD'), '+8801712345678');
    });

    test('normalises US, UK, India, and Nigeria numbers', () {
      expect(phone.normalise('(415) 555-0100', 'US'), '+14155550100');
      expect(phone.normalise('07400 123456', 'GB'), '+447400123456');
      expect(phone.normalise('98765 43210', 'IN'), '+919876543210');
      expect(phone.normalise('0803 123 4567', 'NG'), '+2348031234567');
    });

    test('returns null for short codes, alphanumeric senders, and garbage without throwing', () {
      expect(phone.normalise('16247', 'BD'), isNull);
      expect(phone.normalise('911', 'US'), isNull);
      expect(phone.normalise('bKash', 'BD'), isNull);
      expect(phone.normalise('GP-INFO', 'BD'), isNull);
      expect(phone.normalise('', 'US'), isNull);
      expect(phone.normalise('9' * 120, 'US'), isNull);
    });

    test('identifies mobile vs landline and extracts 9-digit national suffix', () {
      expect(phone.isMobile('+8801712345678'), isTrue);
      expect(phone.isMobile('+447400123456'), isTrue);
      expect(phone.isMobile('+442079460123'), isFalse); // London landline
      expect(phone.nationalSuffix('+8801712345678'), '712345678');
    });
  });

  group('AmountParser.extract', () {
    const parser = AmountParser();

    test('extracts amounts across multiple currencies', () {
      expect(parser.extract('I will pay Tk 500 tomorrow'), 500.0);
      expect(parser.extract('Paid ৳1,500.50 via cash'), 1500.50);
      expect(parser.extract('Invoice total is \$240.00'), 240.0);
      expect(parser.extract('Sent 200 BDT today'), 200.0);
      expect(parser.extract('Transfer of €75 received'), 75.0);
      expect(parser.extract('Paid £120'), 120.0);
      expect(parser.extract('Sent ₹2,500'), 2500.0);
      expect(parser.extract('Received ₦15,000'), 15000.0);
    });

    test('does not falsely match non-currency phrases', () {
      expect(parser.extract('Take 5 minutes and call back'), isNull);
      expect(parser.extract('See you at 3'), isNull);
    });
  });
}
