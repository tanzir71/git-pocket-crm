/**
 * PocketCRM SMS Spam and Automated message classifier.
 * Filters out brand advertisements, banking transactions, and OTPs.
 */
class SMSSpamFilter {
  constructor() {
    // Keywords and their weights/correlation factors
    this.highSpamKeywords = [
      'OTP', 'PROMO', 'OFFER', 'DISCOUNT', 'CASHBACK', 'VALID TILL',
      'SUBSCRIBE', 'CLICK TO', 'BKASH CASH', 'NAGAD PAYMENT', 'CONGRATS',
      'CONGRATULATIONS', 'BUY 1 GET 1', 'FREE SHIPPING', 'LIMITED TIME',
      'DIAL *', 'RELOAD', 'CASH IN', 'CASH OUT', 'DEAR CUSTOMER', 'VERIFICATION CODE'
    ];
    
    this.automatedHeaders = [
      'GP', 'BL', 'ROBI', 'TELE', 'BKASH', 'NAGAD', 'CITYBANK',
      'AD-', 'INFO-', 'SMS-', 'OTP', 'PROMO', 'UCELL'
    ];
  }

  /**
   * Classify an incoming message.
   * Returns { isSpam: boolean, reason: string, score: number }
   */
  classify(sender, text) {
    const cleanSender = sender.trim().toUpperCase();
    const cleanText = text.trim().toUpperCase();
    let score = 0;
    const triggeredKeywords = [];

    // Rule 1: Numeric shortcodes or alpha headers (e.g. "GP-OFFER", "8822")
    const isShortcode = /^[0-9]{3,6}$/.test(cleanSender);
    const hasBrandHeader = this.automatedHeaders.some(header => cleanSender.includes(header));
    
    if (isShortcode) {
      score += 40;
      triggeredKeywords.push('SHORT_SENDER_CODE');
    }
    if (hasBrandHeader) {
      score += 50;
      triggeredKeywords.push(`BRAND_HEADER_${cleanSender}`);
    }

    // Rule 2: Keyword scanning
    this.highSpamKeywords.forEach(kw => {
      if (cleanText.includes(kw)) {
        score += 35;
        triggeredKeywords.push(kw);
      }
    });

    // Rule 3: Presence of verification code / digit combinations
    if (cleanText.includes('CODE') && /\b[0-9]{4,6}\b/.test(cleanText)) {
      score += 50;
      triggeredKeywords.push('OTP_PATTERN');
    }

    const isSpam = score >= 50;
    return {
      isSpam,
      score,
      reason: isSpam ? `Triggered: [${triggeredKeywords.join(', ')}]` : 'Classified as Personal Contact',
      sender,
      text
    };
  }

  /**
   * Run a simulation of importing phone contacts and active call/sms logs.
   * Fires callback for each message parsed to build an interactive log.
   */
  async simulatePhoneImport(onProgress) {
    const rawFeed = [
      { sender: '+880 1711-555222', text: 'Hey, I can check the split AC today around 3 PM if you are home.', isContact: true },
      { sender: 'GP-OFFER', text: 'Congratulations! Get 1.5GB Internet free on 50Tk recharge. Valid till 24 May. Dial *121*5000#' },
      { sender: 'bKash', text: 'bKash Cash In: ৳2,000 from +8801755512345 successful. Ref: AC Repair deposit. Balance: ৳14,500. TrxID: 2026_XM_4492' },
      { sender: '+1 (555) 019-2834', text: 'Jane here. Just double checked the blueprints for Q4 site. They look spectacular. Ready to lock it in?' },
      { sender: '88221', text: 'Your verification code is 449012. Do not share this OTP with anyone.' },
      { sender: '+1 (555) 128-9902', text: 'Service scheduled for Friday. I will send over the visual assets today.' },
      { sender: 'NAGAD', text: 'Cash In of Rs. 500 received. Charge 0.00. Current Balance 3200.00' },
      { sender: 'BurgerKing', text: 'Hungry? 50% discount on Whopper combos. Click to buy: https://bk.com/promo' },
      { sender: '+880 1912-888444', text: 'Hi doctor, are you available for a checkup tomorrow evening?' },
      { sender: '+1 (555) 238-9921', text: 'Confirming our sync. The wellness team is ready for the presentation.' },
      { sender: 'CITYBANK', text: 'Dear Customer, your card was charged ৳12,000 at Banani AC Market. Remaining limit: ৳145,000.' },
      { sender: '+1 (555) 776-2210', text: 'We have dispatched the hardware prototype. Expected delivery by Tuesday. Let me know when it arrives!' }
    ];

    for (let i = 0; i < rawFeed.length; i++) {
      const msg = rawFeed[i];
      const analysis = this.classify(msg.sender, msg.text);
      
      // Delay to simulate processing animation
      await new Promise(r => setTimeout(r, 400));
      onProgress(analysis, i + 1, rawFeed.length);
    }
  }
}

window.PocketSpamFilter = new SMSSpamFilter();
