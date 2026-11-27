/// Extracts a suggested monetary amount next to a known currency marker in an SMS.
/// Never auto-creates a payment row; values become unconfirmed suggestions.
class AmountParser {
  const AmountParser();

  static const _defaultMarkers = <String>[
    '৳',
    'Tk',
    'BDT',
    r'$',
    'USD',
    '€',
    'EUR',
    '£',
    'GBP',
    '₹',
    'Rs',
    'INR',
    '₦',
    'NGN',
  ];

  /// Extracts the first positive monetary amount adjacent to a currency marker
  /// (either `marker amount` like `Tk 500` / `$240` or `amount marker` like `500 BDT`).
  double? extract(String body, {String? extraSymbol, String? extraCode}) {
    if (body.trim().isEmpty) return null;

    final markers = <String>{
      ..._defaultMarkers,
      if (extraSymbol != null && extraSymbol.trim().isNotEmpty) extraSymbol.trim(),
      if (extraCode != null && extraCode.trim().isNotEmpty) extraCode.trim(),
    }.toList()
      // Match longer tokens first (e.g. BDT before B)
      ..sort((a, b) => b.length.compareTo(a.length));

    final symbolMarkers = <String>[];
    final wordMarkers = <String>[];
    for (final m in markers) {
      if (RegExp(r'^[A-Za-z]+$').hasMatch(m)) {
        wordMarkers.add(RegExp.escape(m));
      } else {
        symbolMarkers.add(RegExp.escape(m));
      }
    }

    final parts = <String>[
      if (symbolMarkers.isNotEmpty) '(?:${symbolMarkers.join('|')})',
      if (wordMarkers.isNotEmpty) '(?:\\b(?:${wordMarkers.join('|')})\\b)',
    ];
    final markerPattern = '(?:${parts.join('|')})';

    // Prefix: e.g. "Tk 1,500.50", "৳500", "$240", "Rs. 1200"
    final prefixRegex = RegExp(
      '$markerPattern\\.?\\s*([0-9]{1,3}(?:,[0-9]{3})*(?:\\.[0-9]{1,2})?|[0-9]+(?:\\.[0-9]{1,2})?)',
      caseSensitive: false,
    );
    final prefixMatch = prefixRegex.firstMatch(body);
    if (prefixMatch != null) {
      final parsed = double.tryParse(prefixMatch.group(1)!.replaceAll(',', ''));
      if (parsed != null && parsed > 0) return parsed;
    }

    // Suffix: e.g. "500 BDT", "240 USD", "1,500 Tk"
    final suffixRegex = RegExp(
      '([0-9]{1,3}(?:,[0-9]{3})*(?:\\.[0-9]{1,2})?|[0-9]+(?:\\.[0-9]{1,2})?)\\s*$markerPattern',
      caseSensitive: false,
    );
    final suffixMatch = suffixRegex.firstMatch(body);
    if (suffixMatch != null) {
      final parsed = double.tryParse(suffixMatch.group(1)!.replaceAll(',', ''));
      if (parsed != null && parsed > 0) return parsed;
    }

    return null;
  }
}
