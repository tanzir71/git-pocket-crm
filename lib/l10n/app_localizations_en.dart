// ignore_for_file: deprecated_member_use

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PocketCRM';

  @override
  String get navToday => 'Today';

  @override
  String get navPeople => 'People';

  @override
  String get navMessages => 'Messages';

  @override
  String get tabTodayPlaceholder => 'Today will be built in spec 08.';

  @override
  String get tabPeoplePlaceholder => 'People will be built in spec 06.';

  @override
  String get tabMessagesPlaceholder => 'Messages will be built in spec 10.';

  @override
  String get placeholderTitle => 'Coming in v2';

  @override
  String get setupTitle => 'Finish setup';

  @override
  String get setupPlaceholder => 'Setup will be built in spec 11.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPlaceholder => 'Settings will be built in upcoming specs.';

  @override
  String get backupTitle => 'Backup and restore';

  @override
  String get backupPlaceholder =>
      'Backup and restore will be built in spec 12.';

  @override
  String get personTitle => 'Person';

  @override
  String get newMessageTitle => 'New message';

  @override
  String get campaignTitle => 'Campaign';

  @override
  String get sentMessagesTitle => 'Sent messages';

  @override
  String get templateTitle => 'Template';

  @override
  String get continueLabel => 'Continue';

  @override
  String get doThisLater => 'Do this later';

  @override
  String get peopleTitle => 'People';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
      zero: 'No people',
    );
    return '$_temp0';
  }

  @override
  String get addPersonTooltip => 'Add person';

  @override
  String get searchPeopleHint => 'Search people, companies, numbers, notes';

  @override
  String get clearSearchTooltip => 'Clear search';

  @override
  String get filterAll => 'All';

  @override
  String get filterStarred => 'Starred';

  @override
  String get filterDueToReconnect => 'Due to reconnect';

  @override
  String get filterOwesMe => 'Owes me';

  @override
  String get newListChip => 'New list';

  @override
  String get sortRecentlyContacted => 'Recently contacted';

  @override
  String get sortName => 'Name';

  @override
  String get sortLongestSinceContact => 'Longest since contact';

  @override
  String selectionCount(int count) {
    return '$count selected';
  }

  @override
  String get closeSelectionTooltip => 'Exit selection';

  @override
  String get actionAddToList => 'Add to list';

  @override
  String get actionSetReconnect => 'Set reconnect';

  @override
  String get actionMessage => 'Message';

  @override
  String get actionStar => 'Star';

  @override
  String mergeSuggestionTitle(String firstName, String secondName) {
    return '$firstName and $secondName share a number';
  }

  @override
  String get mergeAction => 'Merge';

  @override
  String get keepSeparateAction => 'Keep separate';

  @override
  String noMatchesTitle(String query) {
    return 'No one matches \'$query\'';
  }

  @override
  String addQueryAsPerson(String query) {
    return 'Add \'$query\' as a new person';
  }

  @override
  String get noPeopleYetTitle => 'No people yet';

  @override
  String get noPeopleYetSubtitle =>
      'People from your phone and people you add will appear here.';

  @override
  String get noPeopleInFilter => 'No people in this view';

  @override
  String get followUpOverdue => 'follow-up overdue';

  @override
  String get noContactYet => 'no contact yet';

  @override
  String get calledToday => 'called today';

  @override
  String get calledYesterday => 'called yesterday';

  @override
  String calledAgo(String age) {
    return 'called $age ago';
  }

  @override
  String get messagedToday => 'messaged today';

  @override
  String get messagedYesterday => 'messaged yesterday';

  @override
  String messagedAgo(String age) {
    return 'messaged $age ago';
  }

  @override
  String get visitedToday => 'visited today';

  @override
  String get visitedYesterday => 'visited yesterday';

  @override
  String visitedAgo(String age) {
    return 'visited $age ago';
  }

  @override
  String get lastSpokeToday => 'last spoke today';

  @override
  String get lastSpokeYesterday => 'last spoke yesterday';

  @override
  String lastSpokeAgo(String age) {
    return 'last spoke $age ago';
  }

  @override
  String get ageNow => 'Now';

  @override
  String get listRename => 'Rename';

  @override
  String get listSetReconnect => 'Set how often to reconnect';

  @override
  String get listMessage => 'Message this list';

  @override
  String get listDelete => 'Delete list';

  @override
  String get listNameLabel => 'List name';

  @override
  String get createListTitle => 'New list';

  @override
  String get renameListTitle => 'Rename list';

  @override
  String deleteListConfirm(String name) {
    return 'Delete \'$name\'? People in this list will not be deleted.';
  }

  @override
  String get manageListsTitle => 'Lists';

  @override
  String get cadencePickerTitle => 'How often to reconnect';

  @override
  String get cadenceWeekly => 'Every week';

  @override
  String get cadenceBiweekly => 'Every 2 weeks';

  @override
  String get cadenceMonthly => 'Every month';

  @override
  String get cadenceQuarterly => 'Every 3 months';

  @override
  String get cadenceHalfYearly => 'Every 6 months';

  @override
  String get cadenceYearly => 'Every year';

  @override
  String get cadenceNever => 'Never';

  @override
  String cadenceEveryNDays(int days) {
    return 'Every $days days';
  }

  @override
  String reconnectEvery(String cadence) {
    return 'Reconnect $cadence';
  }

  @override
  String get setReconnectChip => 'Set reconnect';

  @override
  String cadenceListHint(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return 'Applies to the $_temp0 in $listName who have no setting of their own.';
  }

  @override
  String get addPersonTitle => 'Add person';

  @override
  String get editPersonTitle => 'Edit details';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldPhone => 'Phone number';

  @override
  String get fieldAddPhone => 'Add another number';

  @override
  String get fieldPrimary => 'Primary';

  @override
  String get fieldCompany => 'Company';

  @override
  String get fieldRole => 'Role';

  @override
  String get fieldCity => 'City';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldBirthday => 'Birthday (YYYY-MM-DD)';

  @override
  String get fieldLinkedin => 'LinkedIn';

  @override
  String get fieldFacebook => 'Facebook';

  @override
  String get fieldAbout => 'About';

  @override
  String get phoneIncompleteWarning => 'This number does not look complete';

  @override
  String duplicatePhoneNotice(String name) {
    return 'This number already belongs to $name';
  }

  @override
  String openPersonAction(String name) {
    return 'Open $name';
  }

  @override
  String get saveAction => 'Save';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get deleteAction => 'Delete';

  @override
  String get undoAction => 'Undo';

  @override
  String get doneAction => 'Done';

  @override
  String get okAction => 'OK';

  @override
  String get starTooltip => 'Star';

  @override
  String get unstarTooltip => 'Remove star';

  @override
  String get moreTooltip => 'More';

  @override
  String get backTooltip => 'Back';

  @override
  String get doNotMessageLabel => 'Do not message';

  @override
  String get askedNotToBeMessaged => 'Asked not to be messaged';

  @override
  String get deletePersonMenu => 'Delete person';

  @override
  String deletePersonTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String deletePersonConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This person and $count history entries will be removed.',
      one: 'This person and 1 history entry will be removed.',
      zero: 'This person will be removed from PocketCRM.',
    );
    return '$_temp0';
  }

  @override
  String get actionCall => 'Call';

  @override
  String get actionWhatsApp => 'WhatsApp';

  @override
  String get actionNote => 'Note';

  @override
  String get pickNumberTitle => 'Choose a number';

  @override
  String get sectionNext => 'Next';

  @override
  String get sectionHistory => 'History';

  @override
  String owesYouAmount(String amount) {
    return 'Owes you $amount';
  }

  @override
  String youOweAmount(String amount) {
    return 'You owe $amount';
  }

  @override
  String get sendReminderAction => 'Send a reminder';

  @override
  String get historyFilterTooltip => 'Filter history';

  @override
  String get historyFilterAll => 'All';

  @override
  String get historyFilterCalls => 'Calls';

  @override
  String get historyFilterMessages => 'Messages';

  @override
  String get historyFilterNotes => 'Notes';

  @override
  String get historyFilterVisits => 'Visits';

  @override
  String get historyFilterPayments => 'Payments';

  @override
  String get historyFilterFiles => 'Files';

  @override
  String get historyEmpty => 'No history yet';

  @override
  String get historyEmptyFiltered => 'No entries in this filter';

  @override
  String get loadMoreAction => 'Show more';

  @override
  String get callOutgoing => 'Outgoing call';

  @override
  String get callIncoming => 'Incoming call';

  @override
  String get callMissed => 'Missed call';

  @override
  String get messageReceived => 'Message received';

  @override
  String get messageSent => 'Message sent';

  @override
  String get entryNote => 'Note';

  @override
  String get entryVisit => 'Visit';

  @override
  String entryVisitPlace(String place) {
    return 'Visit · $place';
  }

  @override
  String paymentReceivedTitle(String amount) {
    return 'Payment received · $amount';
  }

  @override
  String paymentPaidTitle(String amount) {
    return 'You paid · $amount';
  }

  @override
  String paymentOwedToMeTitle(String amount) {
    return 'Owes you · $amount';
  }

  @override
  String paymentIOweTitle(String amount) {
    return 'You owe · $amount';
  }

  @override
  String suggestedPaymentTitle(String amount) {
    return 'Looks like a payment · $amount';
  }

  @override
  String get confirmAction => 'Confirm';

  @override
  String get dismissAction => 'Dismiss';

  @override
  String get confirmPaymentTitle => 'Confirm payment';

  @override
  String get paymentStatusReceived => 'Received';

  @override
  String get paymentStatusPaid => 'Paid';

  @override
  String get paymentStatusOwesMe => 'Owes me';

  @override
  String get paymentStatusIOwe => 'I owe';

  @override
  String get deleteEntryAction => 'Delete entry';

  @override
  String get hideFromHistoryAction => 'Hide from history';

  @override
  String get addFollowUpAction => 'Add follow-up';

  @override
  String get entryHiddenMessage => 'Hidden from history';

  @override
  String get entryDeletedMessage => 'Entry deleted';

  @override
  String get followUpCompletedMessage => 'Follow-up completed';

  @override
  String photoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String get statusScheduled => 'Scheduled';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusNotSent => 'Not sent';

  @override
  String get statusSent => 'Sent';

  @override
  String get quickNoteTitle => 'Add note';

  @override
  String get quickNoteHint => 'Write a note';

  @override
  String get saveNoteAction => 'Save note';

  @override
  String get quickFollowUpTitle => 'Add follow-up';

  @override
  String get followUpTitleHint => 'What needs to happen?';

  @override
  String get dueTomorrow => 'Tomorrow';

  @override
  String get dueInThreeDays => 'In 3 days';

  @override
  String get dueNextWeek => 'Next week';

  @override
  String get saveFollowUpAction => 'Save follow-up';

  @override
  String get personPickerTitle => 'Choose a person';

  @override
  String get personPickerRecent => 'Recent';

  @override
  String get personPickerAll => 'All people';

  @override
  String get personPickerLists => 'Lists';

  @override
  String get personNotFound => 'Person not found';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds s';
  }

  @override
  String get todayLabel => 'Today';

  @override
  String get yesterdayLabel => 'Yesterday';

  @override
  String overdueByDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'overdue by $days days',
      one: 'overdue by 1 day',
    );
    return '$_temp0';
  }

  @override
  String get addSheetTitle => 'Add';

  @override
  String get editEntryTitle => 'Edit entry';

  @override
  String get choosePersonLabel => 'Choose a person';

  @override
  String get validationChoosePerson => 'Choose a person';

  @override
  String get validationAddAmount => 'Add an amount';

  @override
  String get validationAddNote => 'Add a note';

  @override
  String get validationAddTitle => 'Add a title';

  @override
  String get validationPickFile => 'Choose a file';

  @override
  String get suggestedLastCall => 'Your last call';

  @override
  String suggestedFollowUpAt(String time) {
    return 'Suggested from your $time follow-up';
  }

  @override
  String get typeNote => 'Note';

  @override
  String get typeCall => 'Call';

  @override
  String get typeVisit => 'Visit';

  @override
  String get typeTask => 'Task';

  @override
  String get typePayment => 'Payment';

  @override
  String get typeFile => 'File';

  @override
  String get directionOutgoing => 'Outgoing';

  @override
  String get directionIncoming => 'Incoming';

  @override
  String get outcomeQuestion => 'How did it go?';

  @override
  String get outcomeSpoke => 'Spoke';

  @override
  String get outcomeNoAnswer => 'No answer';

  @override
  String get outcomeLeftMessage => 'Left a message';

  @override
  String get fieldTime => 'Time';

  @override
  String get fieldDurationMin => 'Duration (minutes)';

  @override
  String get fieldPlace => 'Place';

  @override
  String get currentLocationAction => 'Current location';

  @override
  String get locationAttached => 'Location attached';

  @override
  String get locationUnavailable => 'Location unavailable';

  @override
  String get fieldPhotos => 'Photos';

  @override
  String get photoCamera => 'Camera';

  @override
  String get photoGallery => 'Gallery';

  @override
  String get fieldAmount => 'Amount';

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldDate => 'Date';

  @override
  String get chooseFileAction => 'Choose file';

  @override
  String get followUpSectionLabel => 'Follow up';

  @override
  String get pickDateAction => 'Pick date';

  @override
  String followUpDefaultTitle(String firstName) {
    return 'Follow up with $firstName';
  }

  @override
  String callBackDefaultTitle(String firstName) {
    return 'Call $firstName back';
  }

  @override
  String get saveCallAction => 'Save call';

  @override
  String get saveVisitAction => 'Save visit';

  @override
  String get saveTaskAction => 'Save task';

  @override
  String get savePaymentAction => 'Save payment';

  @override
  String get saveFileAction => 'Save file';

  @override
  String get saveChangesAction => 'Save changes';

  @override
  String get savedMessage => 'Saved';

  @override
  String callWithTitle(String name) {
    return 'Call with $name';
  }

  @override
  String get justNowLabel => 'just now';
}
