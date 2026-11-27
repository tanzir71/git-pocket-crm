/// Pure SMS encoding & segment counter following 3GPP TS 23.038 (GSM-7) and UCS-2.
enum SmsEncoding {
  gsm7,
  ucs2,
}

class SmsCount {
  const SmsCount({
    required this.encoding,
    required this.units,
    required this.segments,
    required this.perSegmentLimit,
    required this.remainingInSegment,
  });

  final SmsEncoding encoding;

  /// Number of septets (GSM-7, where extension chars count as 2) or UTF-16 code units (UCS-2).
  final int units;

  /// Number of SMS parts required (0 for empty string, else >= 1).
  final int segments;

  /// Single-part max (160 / 70) when segments <= 1, else multipart max (153 / 67).
  final int perSegmentLimit;

  /// Remaining characters/units in the current segment.
  final int remainingInSegment;
}

/// GSM 03.38 basic character set (each costs 1 septet).
const String _gsm7BasicChars =
    '@£\$¥èéùìòÇ\nØø\rÅåΔ_ΦΓΛΩΠΨΣΘΞÆæßÉ !"#¤%&\'()*+,-./0123456789:;<=>?¡'
    'ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿'
    'abcdefghijklmnopqrstuvwxyzäöñüà';

/// GSM 03.38 basic character set extension table (each costs 2 septets: ESC + char).
const String _gsm7ExtChars = '\u000C^{}\\[~]|€';

final Set<int> _gsm7BasicSet = _gsm7BasicChars.runes.toSet();
final Set<int> _gsm7ExtSet = _gsm7ExtChars.runes.toSet();

/// Counts SMS encoding, character units, and segment count for [text].
///
/// - GSM-7: 160 septets in 1 segment, 153 septets per segment for multipart.
///   Extension table characters (`^`, `{`, `}`, `\`, `[`, `~`, `]`, `|`, `€`, `\f`) count as 2 septets.
/// - UCS-2 (any non-GSM-7 char such as Bangla, Arabic, CJK, emoji, curly quotes):
///   70 UTF-16 code units in 1 segment, 67 UTF-16 code units per segment for multipart.
SmsCount countSms(String text) {
  if (text.isEmpty) {
    return const SmsCount(
      encoding: SmsEncoding.gsm7,
      units: 0,
      segments: 0,
      perSegmentLimit: 160,
      remainingInSegment: 160,
    );
  }

  var isGsm7 = true;
  var septets = 0;

  for (final rune in text.runes) {
    if (_gsm7BasicSet.contains(rune)) {
      septets += 1;
    } else if (_gsm7ExtSet.contains(rune)) {
      septets += 2;
    } else {
      isGsm7 = false;
      break;
    }
  }

  if (isGsm7) {
    if (septets <= 160) {
      return SmsCount(
        encoding: SmsEncoding.gsm7,
        units: septets,
        segments: 1,
        perSegmentLimit: 160,
        remainingInSegment: 160 - septets,
      );
    }
    final segments = (septets + 152) ~/ 153;
    final capacity = segments * 153;
    return SmsCount(
      encoding: SmsEncoding.gsm7,
      units: septets,
      segments: segments,
      perSegmentLimit: 153,
      remainingInSegment: capacity - septets,
    );
  }

  // UCS-2 uses UTF-16 code units (`text.length` in Dart, so surrogate pairs like emoji count as 2).
  final codeUnits = text.length;
  if (codeUnits <= 70) {
    return SmsCount(
      encoding: SmsEncoding.ucs2,
      units: codeUnits,
      segments: 1,
      perSegmentLimit: 70,
      remainingInSegment: 70 - codeUnits,
    );
  }
  final segments = (codeUnits + 66) ~/ 67;
  final capacity = segments * 67;
  return SmsCount(
    encoding: SmsEncoding.ucs2,
    units: codeUnits,
    segments: segments,
    perSegmentLimit: 67,
    remainingInSegment: capacity - codeUnits,
  );
}
