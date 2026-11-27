import 'package:phone_numbers_parser/phone_numbers_parser.dart';

/// International phone number normalisation and classification.
/// Never throws on invalid, malformed, or over-long input.
class PhoneService {
  const PhoneService();

  static final RegExp _hasLetters = RegExp(r'[a-zA-Z]');
  static final RegExp _nonDigits = RegExp(r'\D');

  /// Normalises [raw] using [defaultRegionIso] (2-letter ISO code, e.g. 'BD', 'US').
  /// Returns E.164 (e.g. `+8801712345678`) or `null` for short codes,
  /// alphanumeric senders, or unparseable input.
  String? normalise(String raw, String defaultRegionIso) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    // Alphanumeric corporate/transactional senders (e.g. "bKash", "GP-INFO")
    if (_hasLetters.hasMatch(trimmed)) return null;

    // Guard against over-long strings that can make parser throw or waste CPU
    if (trimmed.length > 40) return null;

    // Reject short codes (e.g. 16247, 911, 123456)
    final digits = trimmed.replaceAll(_nonDigits, '');
    if (digits.length < 7 || digits.length > 15) return null;

    final regionCountry = _isoCodeFrom(defaultRegionIso);

    try {
      final parsed = trimmed.startsWith('+')
          ? PhoneNumber.parse(trimmed)
          : PhoneNumber.parse(trimmed, destinationCountry: regionCountry);

      if (!parsed.isValidLength()) {
        // Fallback: some local numbers are stored with country code but missing '+'
        if (!trimmed.startsWith('+')) {
          final withPlus = PhoneNumber.parse('+$digits');
          if (withPlus.isValidLength() && withPlus.isValid()) {
            return withPlus.international;
          }
        }
        return null;
      }

      if (!parsed.isValid()) {
        if (!trimmed.startsWith('+')) {
          final withPlus = PhoneNumber.parse('+$digits');
          if (withPlus.isValid()) {
            return withPlus.international;
          }
        }
        return null;
      }

      return parsed.international;
    } catch (_) {
      return null;
    }
  }

  /// Returns `true` if [e164] is a valid mobile (or shared mobile/fixed) number.
  bool isMobile(String e164) {
    final trimmed = e164.trim();
    if (trimmed.isEmpty || _hasLetters.hasMatch(trimmed) || trimmed.length > 40) {
      return false;
    }
    try {
      final parsed = PhoneNumber.parse(trimmed);
      if (parsed.isValid(type: PhoneNumberType.mobile)) return true;
      // In countries like the US/CA, mobile and fixed lines share number ranges,
      // so `PhoneNumberType.mobile` is true for valid NANP numbers; if it is
      // specifically valid only as fixedLine and not mobile, return false.
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Extracts the last [digits] numeric digits (default 9) for unique fallback matching.
  String? nationalSuffix(String input, {int digits = 9}) {
    final cleaned = input.replaceAll(_nonDigits, '');
    if (cleaned.length < digits) return null;
    return cleaned.substring(cleaned.length - digits);
  }

  IsoCode _isoCodeFrom(String regionIso) {
    final upper = regionIso.trim().toUpperCase();
    for (final code in IsoCode.values) {
      if (code.name == upper) return code;
    }
    return IsoCode.US;
  }
}
