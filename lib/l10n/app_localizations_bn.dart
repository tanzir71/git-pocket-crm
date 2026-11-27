// ignore_for_file: deprecated_member_use

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'PocketCRM';

  @override
  String get navToday => 'আজ';

  @override
  String get navPeople => 'পরিচিতি';

  @override
  String get navMessages => 'বার্তা';

  @override
  String get tabTodayPlaceholder => 'আজ ট্যাব স্পেক ০৮-এ তৈরি হবে।';

  @override
  String get tabPeoplePlaceholder => 'পরিচিতি ট্যাব স্পেক ০৬-এ তৈরি হবে।';

  @override
  String get tabMessagesPlaceholder => 'বার্তা ট্যাব স্পেক ১০-এ তৈরি হবে।';

  @override
  String get placeholderTitle => 'ভি২-তে আসছে';

  @override
  String get setupTitle => 'সেটআপ সম্পন্ন করুন';

  @override
  String get setupPlaceholder => 'সেটআপ স্পেক ১১-এ তৈরি হবে।';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get settingsPlaceholder => 'সেটিংস পরবর্তী স্পেকগুলোতে তৈরি হবে।';

  @override
  String get backupTitle => 'ব্যাকআপ ও পুনরুদ্ধার';

  @override
  String get backupPlaceholder => 'ব্যাকআপ ও পুনরুদ্ধার স্পেক ১২-এ তৈরি হবে।';

  @override
  String get personTitle => 'ব্যক্তি';

  @override
  String get newMessageTitle => 'নতুন বার্তা';

  @override
  String get campaignTitle => 'ক্যাম্পেইন';

  @override
  String get sentMessagesTitle => 'পাঠানো বার্তা';

  @override
  String get templateTitle => 'টেমপ্লেট';

  @override
  String get continueLabel => 'চালিয়ে যান';

  @override
  String get doThisLater => 'পরে করব';

  @override
  String get peopleTitle => 'পরিচিতি';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count জন',
      one: '১ জন',
      zero: 'কেউ নেই',
    );
    return '$_temp0';
  }

  @override
  String get addPersonTooltip => 'ব্যক্তি যোগ করুন';

  @override
  String get searchPeopleHint => 'নাম, কোম্পানি, নম্বর বা নোট খুঁজুন';

  @override
  String get clearSearchTooltip => 'খোঁজা মুছুন';

  @override
  String get filterAll => 'সব';

  @override
  String get filterStarred => 'তারকাচিহ্নিত';

  @override
  String get filterDueToReconnect => 'যোগাযোগের সময় হয়েছে';

  @override
  String get filterOwesMe => 'আমার পাওনা';

  @override
  String get newListChip => 'নতুন তালিকা';

  @override
  String get sortRecentlyContacted => 'সাম্প্রতিক যোগাযোগ';

  @override
  String get sortName => 'নাম';

  @override
  String get sortLongestSinceContact => 'সবচেয়ে পুরোনো যোগাযোগ';

  @override
  String selectionCount(int count) {
    return '$countটি নির্বাচিত';
  }

  @override
  String get closeSelectionTooltip => 'নির্বাচন বন্ধ করুন';

  @override
  String get actionAddToList => 'তালিকায় যোগ করুন';

  @override
  String get actionSetReconnect => 'যোগাযোগের ব্যবধান';

  @override
  String get actionMessage => 'বার্তা';

  @override
  String get actionStar => 'তারকাচিহ্নিত করুন';

  @override
  String mergeSuggestionTitle(String firstName, String secondName) {
    return '$firstName এবং $secondName-এর একই নম্বর আছে';
  }

  @override
  String get mergeAction => 'একত্র করুন';

  @override
  String get keepSeparateAction => 'আলাদা রাখুন';

  @override
  String noMatchesTitle(String query) {
    return '\'$query\'-এর সাথে কোনো মিল নেই';
  }

  @override
  String addQueryAsPerson(String query) {
    return '\'$query\'-কে নতুন ব্যক্তি হিসেবে যোগ করুন';
  }

  @override
  String get noPeopleYetTitle => 'এখনও কোনো পরিচিতি নেই';

  @override
  String get noPeopleYetSubtitle =>
      'আপনার ফোনের পরিচিতি এবং আপনি যাদের যোগ করবেন তারা এখানে দেখা যাবে।';

  @override
  String get noPeopleInFilter => 'এই তালিকায় কেউ নেই';

  @override
  String get followUpOverdue => 'ফলো-আপ মেয়াদোত্তীর্ণ';

  @override
  String get noContactYet => 'এখনও যোগাযোগ হয়নি';

  @override
  String get calledToday => 'আজ কল করা হয়েছে';

  @override
  String get calledYesterday => 'গতকাল কল করা হয়েছে';

  @override
  String calledAgo(String age) {
    return '$age আগে কল করা হয়েছে';
  }

  @override
  String get messagedToday => 'আজ বার্তা পাঠানো হয়েছে';

  @override
  String get messagedYesterday => 'গতকাল বার্তা পাঠানো হয়েছে';

  @override
  String messagedAgo(String age) {
    return '$age আগে বার্তা পাঠানো হয়েছে';
  }

  @override
  String get visitedToday => 'আজ দেখা হয়েছে';

  @override
  String get visitedYesterday => 'গতকাল দেখা হয়েছে';

  @override
  String visitedAgo(String age) {
    return '$age আগে দেখা হয়েছে';
  }

  @override
  String get lastSpokeToday => 'আজ শেষ কথা হয়েছে';

  @override
  String get lastSpokeYesterday => 'গতকাল শেষ কথা হয়েছে';

  @override
  String lastSpokeAgo(String age) {
    return '$age আগে শেষ কথা হয়েছে';
  }

  @override
  String get ageNow => 'এখনই';

  @override
  String get listRename => 'নাম পরিবর্তন';

  @override
  String get listSetReconnect => 'যোগাযোগের ব্যবধান নির্ধারণ';

  @override
  String get listMessage => 'এই তালিকায় বার্তা পাঠান';

  @override
  String get listDelete => 'তালিকা মুছুন';

  @override
  String get listNameLabel => 'তালিকার নাম';

  @override
  String get createListTitle => 'নতুন তালিকা';

  @override
  String get renameListTitle => 'তালিকার নাম পরিবর্তন';

  @override
  String deleteListConfirm(String name) {
    return '\'$name\' মুছে ফেলবেন? এই তালিকার ব্যক্তিরা মুছে যাবে না।';
  }

  @override
  String get manageListsTitle => 'তালিকা';

  @override
  String get cadencePickerTitle => 'কতদিন পরপর যোগাযোগ করবেন';

  @override
  String get cadenceWeekly => 'প্রতি সপ্তাহে';

  @override
  String get cadenceBiweekly => 'প্রতি ২ সপ্তাহে';

  @override
  String get cadenceMonthly => 'প্রতি মাসে';

  @override
  String get cadenceQuarterly => 'প্রতি ৩ মাসে';

  @override
  String get cadenceHalfYearly => 'প্রতি ৬ মাসে';

  @override
  String get cadenceYearly => 'প্রতি বছরে';

  @override
  String get cadenceNever => 'কখনোই নয়';

  @override
  String cadenceEveryNDays(int days) {
    return 'প্রতি $days দিন পরপর';
  }

  @override
  String reconnectEvery(String cadence) {
    return 'যোগাযোগ: $cadence';
  }

  @override
  String get setReconnectChip => 'যোগাযোগের ব্যবধান';

  @override
  String cadenceListHint(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count জন',
      one: '১ জন',
    );
    return '$listName তালিকার $_temp0 ব্যক্তির ওপর প্রযোজ্য যাদের নিজস্ব সেটিং নেই।';
  }

  @override
  String get addPersonTitle => 'ব্যক্তি যোগ করুন';

  @override
  String get editPersonTitle => 'তথ্য সম্পাদনা';

  @override
  String get fieldName => 'নাম';

  @override
  String get fieldPhone => 'ফোন নম্বর';

  @override
  String get fieldAddPhone => 'আরেকটি নম্বর যোগ করুন';

  @override
  String get fieldPrimary => 'প্রাথমিক';

  @override
  String get fieldCompany => 'কোম্পানি';

  @override
  String get fieldRole => 'পদবি';

  @override
  String get fieldCity => 'শহর';

  @override
  String get fieldEmail => 'ইমেইল';

  @override
  String get fieldBirthday => 'জন্মদিন (YYYY-MM-DD)';

  @override
  String get fieldLinkedin => 'LinkedIn';

  @override
  String get fieldFacebook => 'Facebook';

  @override
  String get fieldAbout => 'পরিচিতি';

  @override
  String get phoneIncompleteWarning => 'এই নম্বরটি সম্পূর্ণ মনে হচ্ছে না';

  @override
  String duplicatePhoneNotice(String name) {
    return 'এই নম্বরটি ইতিমধ্যে $name-এর নামে আছে';
  }

  @override
  String openPersonAction(String name) {
    return '$name খুলুন';
  }

  @override
  String get saveAction => 'সংরক্ষণ';

  @override
  String get cancelAction => 'বাতিল';

  @override
  String get deleteAction => 'মুছুন';

  @override
  String get undoAction => 'পূর্বাবস্থায় ফেরান';

  @override
  String get doneAction => 'সম্পন্ন';

  @override
  String get okAction => 'ঠিক আছে';

  @override
  String get starTooltip => 'তারকাচিহ্ন দিন';

  @override
  String get unstarTooltip => 'তারকাচিহ্ন সরান';

  @override
  String get moreTooltip => 'আরও';

  @override
  String get backTooltip => 'পিছনে';

  @override
  String get doNotMessageLabel => 'বার্তা পাঠাবেন না';

  @override
  String get askedNotToBeMessaged => 'বার্তা না পাঠাতে অনুরোধ করেছেন';

  @override
  String get deletePersonMenu => 'ব্যক্তি মুছুন';

  @override
  String deletePersonTitle(String name) {
    return '$name-কে মুছে ফেলবেন?';
  }

  @override
  String deletePersonConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'এই ব্যক্তি এবং $countটি ইতিহাসের এন্ট্রি মুছে ফেলা হবে।',
      one: 'এই ব্যক্তি এবং ১টি ইতিহাসের এন্ট্রি মুছে ফেলা হবে।',
      zero: 'এই ব্যক্তিকে PocketCRM থেকে সরানো হবে।',
    );
    return '$_temp0';
  }

  @override
  String get actionCall => 'কল';

  @override
  String get actionWhatsApp => 'WhatsApp';

  @override
  String get actionNote => 'নোট';

  @override
  String get pickNumberTitle => 'একটি নম্বর বেছে নিন';

  @override
  String get sectionNext => 'পরবর্তী';

  @override
  String get sectionHistory => 'ইতিহাস';

  @override
  String owesYouAmount(String amount) {
    return 'আপনার পাওনা $amount';
  }

  @override
  String youOweAmount(String amount) {
    return 'আপনার দেনা $amount';
  }

  @override
  String get sendReminderAction => 'রিমাইন্ডার পাঠান';

  @override
  String get historyFilterTooltip => 'ইতিহাস ফিল্টার করুন';

  @override
  String get historyFilterAll => 'সব';

  @override
  String get historyFilterCalls => 'কল';

  @override
  String get historyFilterMessages => 'বার্তা';

  @override
  String get historyFilterNotes => 'নোট';

  @override
  String get historyFilterVisits => 'ভিজিট';

  @override
  String get historyFilterPayments => 'পেমেন্ট';

  @override
  String get historyFilterFiles => 'ফাইল';

  @override
  String get historyEmpty => 'এখনও কোনো ইতিহাস নেই';

  @override
  String get historyEmptyFiltered => 'এই ফিল্টারে কোনো তথ্য নেই';

  @override
  String get loadMoreAction => 'আরও দেখুন';

  @override
  String get callOutgoing => 'আউটগোয়িং কল';

  @override
  String get callIncoming => 'ইনকামিং কল';

  @override
  String get callMissed => 'মিসড কল';

  @override
  String get messageReceived => 'প্রাপ্ত বার্তা';

  @override
  String get messageSent => 'পাঠানো বার্তা';

  @override
  String get entryNote => 'নোট';

  @override
  String get entryVisit => 'ভিজিট';

  @override
  String entryVisitPlace(String place) {
    return 'ভিজিট · $place';
  }

  @override
  String paymentReceivedTitle(String amount) {
    return 'পেমেন্ট প্রাপ্ত · $amount';
  }

  @override
  String paymentPaidTitle(String amount) {
    return 'আপনি পরিশোধ করেছেন · $amount';
  }

  @override
  String paymentOwedToMeTitle(String amount) {
    return 'আপনার পাওনা · $amount';
  }

  @override
  String paymentIOweTitle(String amount) {
    return 'আপনার দেনা · $amount';
  }

  @override
  String suggestedPaymentTitle(String amount) {
    return 'সম্ভাব্য পেমেন্ট · $amount';
  }

  @override
  String get confirmAction => 'নিশ্চিত করুন';

  @override
  String get dismissAction => 'বাতিল করুন';

  @override
  String get confirmPaymentTitle => 'পেমেন্ট নিশ্চিত করুন';

  @override
  String get paymentStatusReceived => 'প্রাপ্ত';

  @override
  String get paymentStatusPaid => 'পরিশোধিত';

  @override
  String get paymentStatusOwesMe => 'আমার পাওনা';

  @override
  String get paymentStatusIOwe => 'আমার দেনা';

  @override
  String get deleteEntryAction => 'এন্ট্রি মুছুন';

  @override
  String get hideFromHistoryAction => 'ইতিহাস থেকে লুকান';

  @override
  String get addFollowUpAction => 'ফলো-আপ যোগ করুন';

  @override
  String get entryHiddenMessage => 'ইতিহাস থেকে লুকানো হয়েছে';

  @override
  String get entryDeletedMessage => 'এন্ট্রি মুছে ফেলা হয়েছে';

  @override
  String get followUpCompletedMessage => 'ফলো-আপ সম্পন্ন হয়েছে';

  @override
  String photoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ছবি',
      one: '১টি ছবি',
    );
    return '$_temp0';
  }

  @override
  String get statusScheduled => 'নির্ধারিত';

  @override
  String get statusDelivered => 'পৌঁছেছে';

  @override
  String get statusNotSent => 'পাঠানো যায়নি';

  @override
  String get statusSent => 'পাঠানো হয়েছে';

  @override
  String get quickNoteTitle => 'নোট যোগ করুন';

  @override
  String get quickNoteHint => 'একটি নোট লিখুন';

  @override
  String get saveNoteAction => 'নোট সংরক্ষণ';

  @override
  String get quickFollowUpTitle => 'ফলো-আপ যোগ করুন';

  @override
  String get followUpTitleHint => 'কী করতে হবে?';

  @override
  String get dueTomorrow => 'আগামীকাল';

  @override
  String get dueInThreeDays => '৩ দিন পর';

  @override
  String get dueNextWeek => 'আগামী সপ্তাহে';

  @override
  String get saveFollowUpAction => 'ফলো-আপ সংরক্ষণ';

  @override
  String get personPickerTitle => 'একজন ব্যক্তি বেছে নিন';

  @override
  String get personPickerRecent => 'সাম্প্রতিক';

  @override
  String get personPickerAll => 'সব পরিচিতি';

  @override
  String get personPickerLists => 'তালিকা';

  @override
  String get personNotFound => 'ব্যক্তি পাওয়া যায়নি';

  @override
  String durationMinutes(int minutes) {
    return '$minutes মিনিট';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds সে.';
  }

  @override
  String get todayLabel => 'আজ';

  @override
  String get yesterdayLabel => 'গতকাল';

  @override
  String overdueByDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days দিন বিলম্বিত',
      one: '১ দিন বিলম্বিত',
    );
    return '$_temp0';
  }

  @override
  String get addSheetTitle => 'যোগ করুন';

  @override
  String get editEntryTitle => 'এন্ট্রি সম্পাদনা';

  @override
  String get choosePersonLabel => 'একজন ব্যক্তি বেছে নিন';

  @override
  String get validationChoosePerson => 'একজন ব্যক্তি বেছে নিন';

  @override
  String get validationAddAmount => 'পরিমাণ লিখুন';

  @override
  String get validationAddNote => 'একটি নোট লিখুন';

  @override
  String get validationAddTitle => 'একটি শিরোনাম লিখুন';

  @override
  String get validationPickFile => 'একটি ফাইল বেছে নিন';

  @override
  String get suggestedLastCall => 'আপনার শেষ কল';

  @override
  String suggestedFollowUpAt(String time) {
    return 'আপনার $time-এর ফলো-আপ থেকে প্রস্তাবিত';
  }

  @override
  String get typeNote => 'নোট';

  @override
  String get typeCall => 'কল';

  @override
  String get typeVisit => 'ভিজিট';

  @override
  String get typeTask => 'কাজ';

  @override
  String get typePayment => 'পেমেন্ট';

  @override
  String get typeFile => 'ফাইল';

  @override
  String get directionOutgoing => 'আউটগোয়িং';

  @override
  String get directionIncoming => 'ইনকামিং';

  @override
  String get outcomeQuestion => 'কথোপকথন কেমন হলো?';

  @override
  String get outcomeSpoke => 'কথা হয়েছে';

  @override
  String get outcomeNoAnswer => 'উত্তর মেলেনি';

  @override
  String get outcomeLeftMessage => 'বার্তা রাখা হয়েছে';

  @override
  String get fieldTime => 'সময়';

  @override
  String get fieldDurationMin => 'সময়কাল (মিনিট)';

  @override
  String get fieldPlace => 'স্থান';

  @override
  String get currentLocationAction => 'বর্তমান অবস্থান';

  @override
  String get locationAttached => 'অবস্থান যুক্ত হয়েছে';

  @override
  String get locationUnavailable => 'অবস্থান পাওয়া যায়নি';

  @override
  String get fieldPhotos => 'ছবি';

  @override
  String get photoCamera => 'ক্যামেরা';

  @override
  String get photoGallery => 'গ্যালারি';

  @override
  String get fieldAmount => 'পরিমাণ';

  @override
  String get fieldDescription => 'বিবরণ';

  @override
  String get fieldDate => 'তারিখ';

  @override
  String get chooseFileAction => 'ফাইল বেছে নিন';

  @override
  String get followUpSectionLabel => 'ফলো-আপ';

  @override
  String get pickDateAction => 'তারিখ বাছুন';

  @override
  String followUpDefaultTitle(String firstName) {
    return '$firstName-এর সাথে ফলো-আপ';
  }

  @override
  String callBackDefaultTitle(String firstName) {
    return '$firstName-কে ফিরতি কল করুন';
  }

  @override
  String get saveCallAction => 'কল সংরক্ষণ';

  @override
  String get saveVisitAction => 'ভিজিট সংরক্ষণ';

  @override
  String get saveTaskAction => 'কাজ সংরক্ষণ';

  @override
  String get savePaymentAction => 'পেমেন্ট সংরক্ষণ';

  @override
  String get saveFileAction => 'ফাইল সংরক্ষণ';

  @override
  String get saveChangesAction => 'পরিবর্তন সংরক্ষণ';

  @override
  String get savedMessage => 'সংরক্ষিত হয়েছে';

  @override
  String callWithTitle(String name) {
    return '$name-এর সাথে কল';
  }

  @override
  String get justNowLabel => 'এইমাত্র';

  @override
  String get todaySearchTooltip => 'পরিচিতি খুঁজুন';

  @override
  String get todaySettingsTooltip => 'সেটিংস';

  @override
  String promptSpokeWith(String name) {
    return '$name-এর সাথে কথা বলেছেন';
  }

  @override
  String get promptAddNote => 'নোট যোগ করুন';

  @override
  String get promptFollowUp => 'ফলো-আপ';

  @override
  String get promptSkip => 'এড়িয়ে যান';

  @override
  String get sectionNeedsAttention => 'মনোযোগ প্রয়োজন';

  @override
  String get sectionFollowUps => 'ফলো-আপ';

  @override
  String get sectionReconnect => 'পুনরায় যোগাযোগ';

  @override
  String get sectionGoingOutToday => 'আজ পাঠানো হবে';

  @override
  String get sectionComingUp => 'আসন্ন';

  @override
  String get showAllAction => 'সব দেখুন';

  @override
  String get snoozeOneWeek => '১ সপ্তাহ পেছান';

  @override
  String get changeHowOften => 'ব্যবধান পরিবর্তন';

  @override
  String get birthdayToday => 'আজ জন্মদিন';

  @override
  String birthdayOnDay(String day) {
    return '$day-এ জন্মদিন';
  }

  @override
  String get allCaughtUpTitle => 'সব সম্পন্ন';

  @override
  String get allCaughtUpMessage =>
      'ফলো-আপ এবং যাদের সাথে যোগাযোগ করতে হবে তারা এখানে দেখা যাবে।';

  @override
  String get choosePeopleToStayInTouch =>
      'নিয়মিত যোগাযোগের জন্য পরিচিতি বেছে নিন';

  @override
  String get retryAction => 'আবার চেষ্টা';

  @override
  String notSentTo(String name) {
    return '$name-কে পাঠানো যায়নি';
  }

  @override
  String get notifChannelFollowUps => 'ফলো-আপ';

  @override
  String get notifChannelReconnect => 'পুনরায় যোগাযোগ';

  @override
  String get notifChannelAfterCalls => 'কলের পরে';

  @override
  String get notifChannelMessages => 'বার্তা';

  @override
  String get notifChannelMorningSummary => 'সকালের সারসংক্ষেপ';

  @override
  String get notifActionDone => 'সম্পন্ন';

  @override
  String get notifActionTomorrow => 'আগামীকাল';

  @override
  String get morningSummaryTitle => 'PocketCRM';

  @override
  String morningSummaryFollowUps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'আজ $countটি ফলো-আপ',
      one: 'আজ ১টি ফলো-আপ',
    );
    return '$_temp0';
  }

  @override
  String morningSummaryReconnect(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count জনের সাথে যোগাযোগের সময়',
      one: '১ জনের সাথে যোগাযোগের সময়',
    );
    return '$_temp0';
  }

  @override
  String get notifPermissionRationale =>
      'ফলো-আপ ও নির্ধারিত বার্তার রিমাইন্ডার পেতে নোটিফিকেশন অনুমোদন করুন।';

  @override
  String messagePersonTitle(String name) {
    return '$name-কে বার্তা';
  }

  @override
  String get messageFieldHint => 'বার্তা লিখুন';

  @override
  String smsCounterLabel(int units, int limit, int segments) {
    return '$units / $limit · $segments SMS';
  }

  @override
  String get sendNowOption => 'এখনই পাঠান';

  @override
  String get scheduleOption => 'সময় নির্ধারণ';

  @override
  String get sendNowAction => 'এখনই পাঠান';

  @override
  String get scheduleMessageAction => 'সময় নির্ধারণ';

  @override
  String get openInSmsAppAction => 'আপনার SMS অ্যাপে খুলুন';

  @override
  String get fromSimLabel => 'সিম';

  @override
  String get mayBeMinutesLateNotice =>
      'সঠিক সময়ের অ্যালার্ম বন্ধ আছে, তাই বার্তা কয়েক মিনিট দেরিতে যেতে পারে।';

  @override
  String get statusMissed => 'বাদ পড়েছে';

  @override
  String missedMessageTo(String name) {
    return '$name-এর নির্ধারিত বার্তা বাদ পড়েছে';
  }

  @override
  String get smsErrorNoService => 'নেটওয়ার্ক নেই';

  @override
  String get smsErrorRadioOff => 'বিমান মোড বা নেটওয়ার্ক বন্ধ';

  @override
  String get smsErrorLimitReached => 'বার্তা পাঠানোর সীমা পূর্ণ হয়েছে';

  @override
  String get smsErrorNotAllowed => 'নেটওয়ার্ক দ্বারা অনুমোদিত নয়';

  @override
  String get smsErrorGeneric => 'পাঠানো যায়নি';

  @override
  String smsErrorUnknown(int code) {
    return 'অজানা ত্রুটি ($code)';
  }

  @override
  String get messageScheduledSnack => 'বার্তার সময় নির্ধারিত হয়েছে';

  @override
  String get messageQueuedSnack => 'বার্তা পাঠানো হচ্ছে';

  @override
  String get messagesViewOutbox => 'আউটবক্স';

  @override
  String get messagesViewCampaigns => 'ক্যাম্পেইন';

  @override
  String get messagesViewTemplates => 'টেমপ্লেট';

  @override
  String get messagesSearchTooltip => 'বার্তা খুঁজুন';

  @override
  String messagesSummaryScheduled(int count) {
    return '$countটি নির্ধারিত';
  }

  @override
  String messagesSummaryAttention(int count) {
    return '$countটিতে মনোযোগ প্রয়োজন';
  }

  @override
  String get sectionTomorrow => 'আগামীকাল';

  @override
  String get sectionLater => 'পরে';

  @override
  String get sectionEarlier => 'আগে';

  @override
  String get sentThisWeekLabel => 'এই সপ্তাহে পাঠানো হয়েছে';

  @override
  String campaignToNPeople(String name, int count) {
    return '$name · $count জন';
  }

  @override
  String get emptyOutboxTitle => 'কোনো নির্ধারিত বার্তা নেই';

  @override
  String get emptyOutboxMessage =>
      'আপনার নির্ধারিত বার্তাগুলো পাঠানোর আগ পর্যন্ত এখানে অপেক্ষা করবে।';

  @override
  String get emptyCampaignsTitle => 'এখনও কোনো ক্যাম্পেইন নেই';

  @override
  String get emptyCampaignsMessage =>
      'তালিকা বা একাধিক ব্যক্তিকে পাঠানো বার্তা এখানে দেখা যাবে।';

  @override
  String get emptyTemplatesTitle => 'এখনও কোনো টেমপ্লেট নেই';

  @override
  String get emptyTemplatesMessage =>
      'ব্যক্তিগত বার্তা বারবার ব্যবহার করতে টেমপ্লেট তৈরি করুন।';

  @override
  String get newTemplateAction => 'নতুন টেমপ্লেট';

  @override
  String get newMessageFabTooltip => 'নতুন বার্তা';

  @override
  String get composerToLabel => 'প্রাপক';

  @override
  String get composerAddPeople => 'ব্যক্তি যোগ করুন';

  @override
  String get composerMessageLabel => 'বার্তা';

  @override
  String get composerPreviewLabel => 'প্রিভিউ';

  @override
  String composerPreviewCounter(String name, int index, int total) {
    return '$name · $total-এর $index';
  }

  @override
  String get composerTemplatesAction => 'টেমপ্লেট';

  @override
  String get composerSendLabel => 'পাঠান';

  @override
  String get composerPaceLabel => 'গতি';

  @override
  String composerSendWindowCaption(String start, String end) {
    return 'শুধু $start থেকে $end-এর মধ্যে পাঠানো হয়';
  }

  @override
  String composerScheduleNMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বার্তা নির্ধারণ করুন',
      one: 'বার্তা নির্ধারণ করুন',
    );
    return '$_temp0';
  }

  @override
  String composerSendNMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বার্তা পাঠান',
      one: 'এখনই পাঠান',
    );
    return '$_temp0';
  }

  @override
  String composerCounterSingle(int segments, int units, int limit) {
    return '$segments SMS · $limit-এর $units';
  }

  @override
  String composerCounterRange(int min, int max) {
    return 'প্রতিটি $min থেকে $max SMS';
  }

  @override
  String get mergeChipFirstName => 'প্রথম নাম';

  @override
  String get mergeChipName => 'পুরো নাম';

  @override
  String get mergeChipCompany => 'কোম্পানি';

  @override
  String get mergeChipAmountDue => 'বকেয়া পরিমাণ';

  @override
  String get mergeChipMyName => 'আমার নাম';

  @override
  String skippedNoMobile(int count) {
    return '$count জন বাদ: মোবাইল নম্বর নেই';
  }

  @override
  String skippedOptedOut(int count) {
    return '$count জন বাদ: বার্তা না পাঠাতে বলেছেন';
  }

  @override
  String skippedDuplicate(int count) {
    return '$count জন বাদ: একই নম্বর';
  }

  @override
  String unknownMergeFieldsWarning(String fields) {
    return 'অজানা ফিল্ড যেমন আছে তেমনই পাঠানো হবে: $fields';
  }

  @override
  String checkTheseRecipients(int count, String fields) {
    return 'এগুলো যাচাই করুন ($count): $fields নেই';
  }

  @override
  String previewMissingFieldWarning(String fields) {
    return 'এই ব্যক্তির জন্য $fields নেই';
  }

  @override
  String get paceFastTitle => 'দ্রুত';

  @override
  String get paceSteadyTitle => 'মাঝারি';

  @override
  String get paceCarefulTitle => 'সতর্ক';

  @override
  String paceEveryNSeconds(int seconds) {
    return 'প্রতি $seconds সেকেন্ডে ১টি';
  }

  @override
  String get paceOnePerMinute => 'প্রতি মিনিটে ১টি';

  @override
  String paceWithEstimate(String pace, String estimate) {
    return '$pace · $estimate';
  }

  @override
  String aboutSeconds(int seconds) {
    return 'প্রায় $seconds সে.';
  }

  @override
  String aboutMinutes(int minutes) {
    return 'প্রায় $minutes মিনিট';
  }

  @override
  String aboutSecondsLeft(int seconds) {
    return 'প্রায় $seconds সেকেন্ড বাকি';
  }

  @override
  String aboutMinutesLeft(int minutes) {
    return 'প্রায় $minutes মিনিট বাকি';
  }

  @override
  String confirmBulkSendTitle(int count, String sim) {
    return '$sim থেকে $countটি বার্তা পাঠাবেন?';
  }

  @override
  String confirmBulkSendBody(String estimate) {
    return 'এতে $estimate সময় লাগবে এবং আপনার SMS প্ল্যান ব্যবহৃত হবে।';
  }

  @override
  String get sendAction => 'পাঠান';

  @override
  String get discardDraftTitle => 'এই বার্তাটি বাতিল করবেন?';

  @override
  String get discardDraftBody => 'আপনার বার্তাটি সংরক্ষিত হবে না।';

  @override
  String get discardAction => 'বাতিল করুন';

  @override
  String get keepEditingAction => 'সম্পাদনা চালিয়ে যান';

  @override
  String get defaultSimLabel => 'আপনার সিম';

  @override
  String campaignStateScheduled(String time) {
    return '$time-এর জন্য নির্ধারিত';
  }

  @override
  String campaignStateSending(int done, int total) {
    return 'পাঠানো হচ্ছে · $total-এর $done';
  }

  @override
  String campaignStatePaused(int done, int total) {
    return 'বিরতি · $total-এর $done';
  }

  @override
  String campaignStateDone(int sent) {
    return 'সম্পন্ন · $sentটি পাঠানো হয়েছে';
  }

  @override
  String campaignStateDoneWithFailed(int sent, int failed) {
    return 'সম্পন্ন · $sentটি পাঠানো হয়েছে · $failedটি ব্যর্থ';
  }

  @override
  String campaignStateStopped(int done, int total) {
    return 'বন্ধ · $total-এর $done';
  }

  @override
  String get campaignPauseAction => 'বিরতি';

  @override
  String get campaignResumeAction => 'চালু করুন';

  @override
  String get campaignStopAction => 'বন্ধ করুন';

  @override
  String get campaignStopConfirmTitle => 'এই ক্যাম্পেইন বন্ধ করবেন?';

  @override
  String get campaignStopConfirmBody =>
      'ইতিমধ্যে পাঠানো বার্তা ফেরানো যাবে না। অপেক্ষমাণ বার্তাগুলো বাতিল হবে।';

  @override
  String campaignRetryNNotSent(int count) {
    return 'ব্যর্থ $countটি আবার চেষ্টা করুন';
  }

  @override
  String get campaignStatSent => 'পাঠানো হয়েছে';

  @override
  String get campaignStatFailed => 'ব্যর্থ';

  @override
  String get campaignStatSending => 'পাঠানো হচ্ছে';

  @override
  String get campaignStatWaiting => 'অপেক্ষমাণ';

  @override
  String get campaignSectionRecipients => 'প্রাপক';

  @override
  String get campaignMenuDuplicate => 'অনুলিপি তৈরি';

  @override
  String get campaignMenuExport => 'ফলাফল রপ্তানি';

  @override
  String get campaignMenuDelete => 'মুছুন';

  @override
  String get campaignExportedSnack => 'ফলাফল শেয়ার করার জন্য প্রস্তুত';

  @override
  String get statusSending => 'পাঠানো হচ্ছে';

  @override
  String get statusWaiting => 'অপেক্ষমাণ';

  @override
  String get statusFailed => 'ব্যর্থ';

  @override
  String get statusSkipped => 'বাদ দেওয়া হয়েছে';

  @override
  String get statusCancelled => 'বাতিল';

  @override
  String tapToRetryMeta(String reason) {
    return '$reason · আবার চেষ্টা করতে ট্যাপ করুন';
  }

  @override
  String get sentFilterAll => 'সব';

  @override
  String get sentFilterDelivered => 'পৌঁছেছে';

  @override
  String get sentFilterSent => 'পাঠানো হয়েছে';

  @override
  String get sentFilterNotSent => 'পাঠানো যায়নি';

  @override
  String get sentListEmpty => 'এখনও কোনো পাঠানো বার্তা নেই';

  @override
  String get templateNameLabel => 'টেমপ্লেটের নাম';

  @override
  String get templateNameHint => 'পেমেন্ট রিমাইন্ডার';

  @override
  String get templateBodyLabel => 'বার্তা';

  @override
  String get templateSaveAction => 'টেমপ্লেট সংরক্ষণ';

  @override
  String get templateDeleteAction => 'টেমপ্লেট মুছুন';

  @override
  String get templateSamplePreview => 'নমুনা প্রিভিউ';

  @override
  String get templateValidationName => 'টেমপ্লেটের নাম লিখুন';

  @override
  String get templateValidationBody => 'বার্তা লিখুন';

  @override
  String get recipientPickerTitle => 'প্রাপক বেছে নিন';

  @override
  String recipientPickerDone(int count) {
    return 'সম্পন্ন ($count)';
  }

  @override
  String get setupSubtitle =>
      'কয়েকটি অনুমতি দিলে PocketCRM অ্যাপ বন্ধ থাকলেও আপনার কল লগ করতে এবং সময়মতো বার্তা পাঠাতে পারবে।';

  @override
  String get setupRowContactsTitle => 'পরিচিতি';

  @override
  String get setupRowContactsSubtitle => 'আপনার পরিচিতি দেখায় এবং কল মেলায়';

  @override
  String get setupRowCallsSmsTitle => 'কল ও বার্তা';

  @override
  String get setupRowCallsSmsSubtitle =>
      'এই ফোনেই প্রতিটি ব্যক্তির ইতিহাস তৈরি করে';

  @override
  String get setupRowAlarmsTitle => 'অ্যালার্ম ও রিমাইন্ডার';

  @override
  String get setupRowAlarmsSubtitle => 'নির্ধারিত বার্তা ঠিক সময়ে পাঠায়';

  @override
  String get setupRowAlarmsFallback =>
      'নির্ধারিত বার্তা কয়েক মিনিট দেরি হতে পারে';

  @override
  String get setupRowBatteryTitle => 'ব্যাটারি';

  @override
  String get setupRowBatterySubtitle =>
      'অ্যাপ বন্ধ থাকলে Android-কে বার্তা থামানো থেকে বিরত রাখে';

  @override
  String get setupRowNotificationsTitle => 'নোটিফিকেশন';

  @override
  String get setupRowNotificationsSubtitle =>
      'ফলো-আপ রিমাইন্ডার এবং বার্তা পাঠানোর ফলাফল';

  @override
  String get setupAllowedLabel => 'অনুমোদিত';

  @override
  String get setupAllowAction => 'অনুমতি দিন';

  @override
  String get setupOpenSettingsAction => 'সেটিংস খুলুন';

  @override
  String get setupPrivacyNote =>
      'সবকিছু এই ফোনেই থাকে। PocketCRM-এর কোনো ইন্টারনেট অ্যাক্সেস নেই।';

  @override
  String get setupSyncingContacts => 'আপনার পরিচিতি পড়া হচ্ছে...';

  @override
  String get setupSyncingHistory => 'আপনার কল ও বার্তার ইতিহাস পড়া হচ্ছে...';

  @override
  String setupSyncProgressCounts(int contacts, int calls, int sms) {
    return 'সিঙ্ক সম্পন্ন: $contacts পরিচিতি · $calls কল · $sms বার্তা';
  }

  @override
  String get restrictedSettingsTitle => 'সীমাবদ্ধ সেটিংস অনুমোদন করুন';

  @override
  String get restrictedSettingsStep1 =>
      '১. উপরের ডানদিকে তিনটি বিন্দুতে ট্যাপ করুন।';

  @override
  String get restrictedSettingsStep2 =>
      '২. \"Allow restricted settings\"-এ ট্যাপ করুন এবং স্ক্রিন লক দিয়ে নিশ্চিত করুন।';

  @override
  String get restrictedSettingsStep3 =>
      '৩. এখানে ফিরে আসুন এবং আবার অনুমতি দিন-এ ট্যাপ করুন।';

  @override
  String get restrictedSettingsFallback =>
      'অপশনটি নেই? সেই পেজে Permissions খুলে SMS এবং Call logs অনুমোদন করুন।';

  @override
  String get restrictedSettingsOpenAppInfo => 'অ্যাপ তথ্য খুলুন';

  @override
  String get oemBatteryXiaomi =>
      'Autostart চালু করুন এবং Battery saver-এ No restrictions দিন';

  @override
  String get oemBatteryOppo =>
      'Background activity এবং Auto-launch অনুমোদন করুন';

  @override
  String get oemBatteryVivo =>
      'High background power consumption এবং Autostart অনুমোদন করুন';

  @override
  String get oemBatterySamsung =>
      'Never sleeping apps তালিকায় PocketCRM যোগ করুন';

  @override
  String get oemBatteryTecno => 'Phone Master-এ Auto-start অনুমোদন করুন';

  @override
  String get oemBatteryHuawei =>
      'App launch-এ Manage manually নির্বাচন করে তিনটি সুইচই চালু করুন';

  @override
  String get reliabilitySectionTitle => 'নির্ভরযোগ্যতা যাচাই';

  @override
  String get reliabilitySendTestAction => 'পরীক্ষামূলক বার্তা পাঠান';

  @override
  String get reliabilityPhoneLabel => 'আপনার ফোন নম্বর';

  @override
  String get reliabilityPhoneHint => 'আপনার নিজের নম্বর লিখুন';

  @override
  String reliabilityScheduledNotice(String time) {
    return 'অ্যাপ বন্ধ করুন এবং ফোন লক করুন। বার্তাটি $time-এ পৌঁছানো উচিত।';
  }

  @override
  String reliabilityTestMessageBody(String time) {
    return 'PocketCRM পরীক্ষা, $time-এর জন্য নির্ধারিত';
  }

  @override
  String get reliabilityResultOnTime => 'ঠিক সময়ে পৌঁছেছে';

  @override
  String reliabilityResultLate(int minutes) {
    return '$minutes মিনিট দেরিতে পৌঁছেছে: অ্যালার্ম ও রিমাইন্ডার অনুমোদন করুন এবং ব্যাটারি ধাপটি যাচাই করুন';
  }

  @override
  String reliabilityResultFailed(String reason) {
    return 'পাঠানো যায়নি: $reason';
  }

  @override
  String get finishSetupBannerTitle => 'সেটআপ সম্পন্ন করুন';

  @override
  String get finishSetupBannerSubtitle =>
      'স্বয়ংক্রিয় ইতিহাস তৈরি করতে পরিচিতি, কল ও বার্তার অনুমতি দিন';

  @override
  String get settingsSectionGeneral => 'সাধারণ';

  @override
  String get settingsSectionAfterCalls => 'কলের পরে';

  @override
  String get settingsSectionReminders => 'রিমাইন্ডার';

  @override
  String get settingsSectionMessages => 'বার্তা';

  @override
  String get settingsSectionData => 'ডেটা';

  @override
  String get settingsSectionAbout => 'সম্পর্কে';

  @override
  String get settingsYourName => 'আপনার নাম';

  @override
  String get settingsNotSet => 'নির্ধারিত নয়';

  @override
  String get settingsCurrency => 'মুদ্রা';

  @override
  String get settingsCurrencySearchHint => 'মুদ্রার কোড বা চিহ্ন খুঁজুন';

  @override
  String get settingsPhoneRegion => 'ফোন নম্বরের অঞ্চল';

  @override
  String get settingsTheme => 'থিম';

  @override
  String get settingsThemeSystem => 'সিস্টেম';

  @override
  String get settingsThemeLight => 'হালকা';

  @override
  String get settingsThemeDark => 'গাঢ়';

  @override
  String get settingsLanguage => 'ভাষা';

  @override
  String get settingsLanguageSystem => 'সিস্টেম ডিফল্ট';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageBengali => 'বাংলা';

  @override
  String get settingsAfterCallPrompt => 'নোটের জন্য জিজ্ঞাসা করুন';

  @override
  String get settingsAfterCallAll => 'সব সংরক্ষিত পরিচিতি';

  @override
  String get settingsAfterCallStarred => 'শুধু তারকাচিহ্নিত';

  @override
  String get settingsAfterCallNever => 'কখনোই নয়';

  @override
  String get settingsMorningSummary => 'সকালের সারসংক্ষেপ';

  @override
  String get settingsReconnectNudges => 'যোগাযোগের রিমাইন্ডার';

  @override
  String get settingsOn => 'চালু';

  @override
  String get settingsOff => 'বন্ধ';

  @override
  String get settingsDefaultPace => 'ডিফল্ট গতি';

  @override
  String get settingsSendWindow => 'পাঠানোর সময়সীমা';

  @override
  String get settingsOptOutWords => 'বার্তা বন্ধের শব্দ';

  @override
  String get settingsSyncNow => 'এখনই সিঙ্ক করুন';

  @override
  String get settingsSyncNever => 'এখনও সিঙ্ক হয়নি';

  @override
  String get settingsSyncComplete => 'সিঙ্ক সম্পন্ন হয়েছে';

  @override
  String get settingsCheckSetup => 'সেটআপ যাচাই করুন';

  @override
  String get settingsVersion => 'সংস্করণ';

  @override
  String get settingsLicences => 'লাইসেন্স';

  @override
  String get settingsNoInternetStatement =>
      'PocketCRM ইন্টারনেটের সাথে সংযোগ করতে পারে না।';

  @override
  String get settingsExportPeopleCsv => 'পরিচিতি CSV হিসেবে';

  @override
  String get settingsExportPeopleVcard => 'পরিচিতি vCard হিসেবে';

  @override
  String get exportHistoryCsvMenu => 'ইতিহাস CSV হিসেবে রপ্তানি';

  @override
  String get exportSavedSnack => 'রপ্তানি সংরক্ষিত হয়েছে';

  @override
  String get exportFailedSnack => 'রপ্তানি সংরক্ষণ করা যায়নি';

  @override
  String get backupLastTime => 'শেষ ব্যাকআপ';

  @override
  String get backupNever => 'কখনোই নয়';

  @override
  String get backupNowAction => 'এখনই ব্যাকআপ নিন';

  @override
  String get backupIncludeFiles => 'ছবি ও ফাইল অন্তর্ভুক্ত করুন';

  @override
  String get backupProtectPassphrase => 'পাসফ্রেজ দিয়ে সুরক্ষিত করুন';

  @override
  String get backupPassphraseHint => 'পাসফ্রেজ';

  @override
  String get backupPassphraseConfirmHint => 'পাসফ্রেজ নিশ্চিত করুন';

  @override
  String get backupPassphraseWarning =>
      'আপনি এই পাসফ্রেজ ভুলে গেলে ব্যাকআপ আর খোলা যাবে না।';

  @override
  String get backupPassphraseMismatch => 'পাসফ্রেজ মেলেনি';

  @override
  String get backupPassphraseRequired => 'একটি পাসফ্রেজ লিখুন';

  @override
  String get backupRestoreAction => 'ব্যাকআপ থেকে পুনরুদ্ধার';

  @override
  String get backupAutoTitle => 'স্বয়ংক্রিয় ব্যাকআপ';

  @override
  String get backupAutoSubtitle =>
      'সাপ্তাহিক সাধারণ ব্যাকআপ, শেষ ৪টি সংরক্ষিত থাকে';

  @override
  String get backupAutoExplanation =>
      'এই ফোনেই সংরক্ষিত থাকে এবং অ্যাপ আনইনস্টল করলে মুছে যায়। মাঝে মাঝে অন্যত্র একটি ব্যাকআপ সংরক্ষণ করুন।';

  @override
  String backupAutoCount(int count) {
    return 'এই ফোনে $countটি আছে';
  }

  @override
  String get backupStagePreparing => 'ডেটাবেস প্রস্তুত করা হচ্ছে...';

  @override
  String get backupStageReadingOutbox => 'নির্ধারিত বার্তা পড়া হচ্ছে...';

  @override
  String get backupStagePacking => 'ফাইল প্যাক করা হচ্ছে...';

  @override
  String get backupStageEncrypting => 'ব্যাকআপ এনক্রিপ্ট করা হচ্ছে...';

  @override
  String get backupStageSaving => 'ব্যাকআপ সংরক্ষণ করা হচ্ছে...';

  @override
  String get backupStageDecrypting => 'ব্যাকআপ ডিক্রিপ্ট করা হচ্ছে...';

  @override
  String get backupStageVerifying => 'ব্যাকআপ যাচাই করা হচ্ছে...';

  @override
  String get backupStageRestoring => 'ডেটা পুনরুদ্ধার করা হচ্ছে...';

  @override
  String get backupSavedSnack => 'ব্যাকআপ সংরক্ষিত হয়েছে';

  @override
  String get backupWrongPassphrase =>
      'এই পাসফ্রেজ দিয়ে ব্যাকআপটি খোলা যাচ্ছে না';

  @override
  String get backupCorruptError => 'এই ফাইলটি বৈধ PocketCRM ব্যাকআপ নয়';

  @override
  String backupManifestSummary(
    String people,
    String history,
    String files,
    String date,
  ) {
    return '$people পরিচিতি, $history ইতিহাস, $files ফাইল, তারিখ $date';
  }

  @override
  String backupV1Summary(String people, String history, String tasks) {
    return 'পুরোনো ব্যাকআপ: $people পরিচিতি, $history ইতিহাস, $tasks ফলো-আপ';
  }

  @override
  String get backupReplaceConfirmTitle =>
      'এই ফোনের সব ডেটা এই ব্যাকআপ দিয়ে প্রতিস্থাপন করবেন?';

  @override
  String get backupReplaceConfirmAction => 'প্রতিস্থাপন';

  @override
  String get backupMergeV1ConfirmTitle =>
      'এই পুরোনো ব্যাকআপটি PocketCRM-এ ইম্পোর্ট করবেন?';

  @override
  String get backupMergeV1ConfirmAction => 'ইম্পোর্ট';

  @override
  String get backupEnterPassphraseTitle => 'ব্যাকআপ পাসফ্রেজ লিখুন';

  @override
  String get backupOpenAction => 'ব্যাকআপ খুলুন';

  @override
  String get backupRestoredSnack => 'ব্যাকআপ পুনরুদ্ধার হয়েছে';

  @override
  String backupV1ImportedSnack(int people, int history) {
    return '$people জন পরিচিতি এবং $historyটি ইতিহাস ইম্পোর্ট হয়েছে';
  }
}
