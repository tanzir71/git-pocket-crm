class SpamFilter {
  // Alphanumeric senders (e.g., "GP-INFO", "bKash", "BL-FLASH")
  static final RegExp _alphaNumericSender = RegExp(r'[a-zA-Z]{3,}');
  // Short codes (usually 3 to 6 digits)
  static final RegExp _shortCodeSender = RegExp(r'^\+?[0-9]{3,7}$');

  // Weighted keywords for marketing/promotions
  static const Map<String, double> _promoKeywords = {
    'offer': 2.0,
    'promo': 2.5,
    'discount': 2.0,
    'cashback': 2.5,
    'sale': 1.5,
    'win': 1.5,
    'gift': 1.5,
    'subscribe': 2.0,
    'recharge': 1.5,
    'pack': 1.5,
    'internet': 1.5,
    'activation': 2.0,
    'exclusive': 1.5,
    'coupon': 2.0,
    'chances': 1.5,
    'shopping': 1.0,
    'buy': 1.0,
  };

  // Weighted keywords for automated transactions
  static const Map<String, double> _transactionKeywords = {
    'otp': 3.0,
    'verification': 2.5,
    'code': 1.5,
    'trxid': 3.0,
    'debited': 2.5,
    'credited': 2.5,
    'recharge successful': 2.5,
    'sent money': 2.0,
    'received money': 2.0,
    'payment of': 1.5,
    'txn': 2.0,
    'stat': 1.5,
    'balance': 1.5,
    'reference': 1.0,
    'ref': 1.0,
    'bill': 1.5,
    'invoice': 2.0,
    'security code': 2.0,
  };

  /// Determines if a sender address or message content represents corporate/promotional spam
  static bool isSpam(String sender, String body) {
    final senderClean = sender.trim();
    final bodyLower = body.toLowerCase();

    // 1. Check sender format first (very high accuracy indicator)
    // If sender is strictly alphanumeric (contains letters and is at least 3 chars), it's corporate/automated
    if (_alphaNumericSender.hasMatch(senderClean) && !senderClean.startsWith('+')) {
      return true;
    }

    // Shortcodes are always automated systems
    if (_shortCodeSender.hasMatch(senderClean)) {
      return true;
    }

    // 2. Score the message content
    double score = 0.0;

    // Check promotional keywords
    _promoKeywords.forEach((keyword, weight) {
      if (bodyLower.contains(keyword)) {
        score += weight;
      }
    });

    // Check transactional keywords
    _transactionKeywords.forEach((keyword, weight) {
      if (bodyLower.contains(keyword)) {
        score += weight;
      }
    });

    // If there is high keyword concentration (score >= 3.0), we flag it as automated/marketing
    if (score >= 3.0) {
      return true;
    }

    // Bangladesh typical short number filters (e.g. 01700000000 but some custom push SMS)
    // If a number starts with standard carrier prefix but has unusual character combinations in the body
    if (bodyLower.contains('dial *') || bodyLower.contains('visit shorturl')) {
      return true;
    }

    return false;
  }
}
