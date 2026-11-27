/// Result of parsing a legacy v4 payment `content` prefix.
class ParsedLegacyPayment {
  const ParsedLegacyPayment({required this.status, required this.note});

  final String status;
  final String? note;
}

/// Parses legacy payment prefixes from `timeline.content` without mutating
/// the original `content` column.
///
/// Mapping mirrors `thread_screen.dart`:
/// - `[Paid]` -> `paid`
/// - `[Received]` -> `received`
/// - `[To Collect]`, `[Owed to Me]` -> `owed_to_me`
/// - `[To Pay]`, `[I owe]`, `[I Owe]` -> `i_owe`
/// - `Parsed from SMS:` -> `unconfirmed`
ParsedLegacyPayment? parseLegacyPaymentContent(String? content) {
  if (content == null || content.isEmpty) return null;

  const prefixMap = <String, String>{
    '[Paid]': 'paid',
    '[Received]': 'received',
    '[To Collect]': 'owed_to_me',
    '[Owed to Me]': 'owed_to_me',
    '[To Pay]': 'i_owe',
    '[I owe]': 'i_owe',
    '[I Owe]': 'i_owe',
  };

  for (final entry in prefixMap.entries) {
    if (content.startsWith(entry.key)) {
      final remainder = content.substring(entry.key.length).trim();
      return ParsedLegacyPayment(
        status: entry.value,
        note: remainder.isEmpty ? null : remainder,
      );
    }
  }

  if (content.startsWith('Parsed from SMS:')) {
    return const ParsedLegacyPayment(status: 'unconfirmed', note: null);
  }

  return null;
}

/// Parses legacy call duration strings such as:
/// - `Duration: 2 min 5 sec` -> 125
/// - `Duration: 40 sec` -> 40
/// - `Duration: Missed call` -> 0
int? parseLegacyDurationSeconds(String? content) {
  if (content == null || content.isEmpty) return null;

  final minSec = RegExp(r'(\d+)\s*min\s*(\d+)\s*sec', caseSensitive: false)
      .firstMatch(content);
  if (minSec != null) {
    final m = int.tryParse(minSec.group(1)!) ?? 0;
    final s = int.tryParse(minSec.group(2)!) ?? 0;
    return m * 60 + s;
  }

  final minOnly = RegExp(r'(\d+)\s*min', caseSensitive: false).firstMatch(content);
  if (minOnly != null) {
    final m = int.tryParse(minOnly.group(1)!) ?? 0;
    return m * 60;
  }

  final secOnly = RegExp(r'(\d+)\s*sec', caseSensitive: false).firstMatch(content);
  if (secOnly != null) {
    return int.tryParse(secOnly.group(1)!);
  }

  if (content.toLowerCase().contains('missed')) {
    return 0;
  }

  return null;
}
