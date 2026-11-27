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

  @override
  String get todaySearchTooltip => 'Search people';

  @override
  String get todaySettingsTooltip => 'Settings';

  @override
  String promptSpokeWith(String name) {
    return 'You spoke with $name';
  }

  @override
  String get promptAddNote => 'Add note';

  @override
  String get promptFollowUp => 'Follow up';

  @override
  String get promptSkip => 'Skip';

  @override
  String get sectionNeedsAttention => 'Needs attention';

  @override
  String get sectionFollowUps => 'Follow-ups';

  @override
  String get sectionReconnect => 'Reconnect';

  @override
  String get sectionGoingOutToday => 'Going out today';

  @override
  String get sectionComingUp => 'Coming up';

  @override
  String get showAllAction => 'Show all';

  @override
  String get snoozeOneWeek => 'Snooze 1 week';

  @override
  String get changeHowOften => 'Change how often';

  @override
  String get birthdayToday => 'Birthday today';

  @override
  String birthdayOnDay(String day) {
    return 'Birthday on $day';
  }

  @override
  String get allCaughtUpTitle => 'All caught up';

  @override
  String get allCaughtUpMessage =>
      'Follow-ups and people to reconnect with will appear here.';

  @override
  String get choosePeopleToStayInTouch => 'Choose people to stay in touch with';

  @override
  String get retryAction => 'Retry';

  @override
  String notSentTo(String name) {
    return 'Not sent to $name';
  }

  @override
  String get notifChannelFollowUps => 'Follow-ups';

  @override
  String get notifChannelReconnect => 'Reconnect';

  @override
  String get notifChannelAfterCalls => 'After calls';

  @override
  String get notifChannelMessages => 'Messages';

  @override
  String get notifChannelMorningSummary => 'Morning summary';

  @override
  String get notifActionDone => 'Done';

  @override
  String get notifActionTomorrow => 'Tomorrow';

  @override
  String get morningSummaryTitle => 'PocketCRM';

  @override
  String morningSummaryFollowUps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count follow-ups today',
      one: '1 follow-up today',
    );
    return '$_temp0';
  }

  @override
  String morningSummaryReconnect(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people to reconnect with',
      one: '1 person to reconnect with',
    );
    return '$_temp0';
  }

  @override
  String get notifPermissionRationale =>
      'Allow notifications so PocketCRM can remind you about follow-ups and scheduled messages.';

  @override
  String messagePersonTitle(String name) {
    return 'Message $name';
  }

  @override
  String get messageFieldHint => 'Write a message';

  @override
  String smsCounterLabel(int units, int limit, int segments) {
    return '$units / $limit · $segments SMS';
  }

  @override
  String get sendNowOption => 'Send now';

  @override
  String get scheduleOption => 'Schedule';

  @override
  String get sendNowAction => 'Send now';

  @override
  String get scheduleMessageAction => 'Schedule';

  @override
  String get openInSmsAppAction => 'Open in your SMS app';

  @override
  String get fromSimLabel => 'From';

  @override
  String get mayBeMinutesLateNotice =>
      'Exact alarms are off, so this message may go out a few minutes late.';

  @override
  String get statusMissed => 'Missed';

  @override
  String missedMessageTo(String name) {
    return 'Missed message to $name';
  }

  @override
  String get smsErrorNoService => 'No service';

  @override
  String get smsErrorRadioOff => 'Airplane mode or radio off';

  @override
  String get smsErrorLimitReached => 'Sending limit reached';

  @override
  String get smsErrorNotAllowed => 'Not allowed by the network';

  @override
  String get smsErrorGeneric => 'Not sent';

  @override
  String smsErrorUnknown(int code) {
    return 'Unknown error ($code)';
  }

  @override
  String get messageScheduledSnack => 'Message scheduled';

  @override
  String get messageQueuedSnack => 'Sending message';

  @override
  String get messagesViewOutbox => 'Outbox';

  @override
  String get messagesViewCampaigns => 'Campaigns';

  @override
  String get messagesViewTemplates => 'Templates';

  @override
  String get messagesSearchTooltip => 'Search messages';

  @override
  String messagesSummaryScheduled(int count) {
    return '$count scheduled';
  }

  @override
  String messagesSummaryAttention(int count) {
    return '$count needs attention';
  }

  @override
  String get sectionTomorrow => 'Tomorrow';

  @override
  String get sectionLater => 'Later';

  @override
  String get sectionEarlier => 'Earlier';

  @override
  String get sentThisWeekLabel => 'Sent this week';

  @override
  String campaignToNPeople(String name, int count) {
    return '$name to $count people';
  }

  @override
  String get emptyOutboxTitle => 'Nothing scheduled';

  @override
  String get emptyOutboxMessage =>
      'Messages you schedule will wait here until they are sent.';

  @override
  String get emptyCampaignsTitle => 'No campaigns yet';

  @override
  String get emptyCampaignsMessage =>
      'Messages sent to a list or multiple people will appear here.';

  @override
  String get emptyTemplatesTitle => 'No templates yet';

  @override
  String get emptyTemplatesMessage =>
      'Create a template to reuse personalised messages.';

  @override
  String get newTemplateAction => 'New template';

  @override
  String get newMessageFabTooltip => 'New message';

  @override
  String get composerToLabel => 'To';

  @override
  String get composerAddPeople => 'Add people';

  @override
  String get composerMessageLabel => 'Message';

  @override
  String get composerPreviewLabel => 'Preview';

  @override
  String composerPreviewCounter(String name, int index, int total) {
    return '$name · $index of $total';
  }

  @override
  String get composerTemplatesAction => 'Templates';

  @override
  String get composerSendLabel => 'Send';

  @override
  String get composerPaceLabel => 'Pace';

  @override
  String composerSendWindowCaption(String start, String end) {
    return 'Sends only between $start and $end';
  }

  @override
  String composerScheduleNMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages',
      one: 'message',
    );
    return 'Schedule $_temp0';
  }

  @override
  String composerSendNMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages',
      one: 'now',
    );
    return 'Send $_temp0';
  }

  @override
  String composerCounterSingle(int segments, int units, int limit) {
    return '$segments SMS · $units of $limit';
  }

  @override
  String composerCounterRange(int min, int max) {
    return '$min to $max SMS each';
  }

  @override
  String get mergeChipFirstName => 'First name';

  @override
  String get mergeChipName => 'Name';

  @override
  String get mergeChipCompany => 'Company';

  @override
  String get mergeChipAmountDue => 'Amount due';

  @override
  String get mergeChipMyName => 'My name';

  @override
  String skippedNoMobile(int count) {
    return '$count skipped: no mobile number';
  }

  @override
  String skippedOptedOut(int count) {
    return '$count skipped: asked not to be messaged';
  }

  @override
  String skippedDuplicate(int count) {
    return '$count skipped: duplicate number';
  }

  @override
  String unknownMergeFieldsWarning(String fields) {
    return 'Unknown fields will be sent as typed: $fields';
  }

  @override
  String checkTheseRecipients(int count, String fields) {
    return 'Check these ($count): missing $fields';
  }

  @override
  String previewMissingFieldWarning(String fields) {
    return 'Missing $fields for this person';
  }

  @override
  String get paceFastTitle => 'Fast';

  @override
  String get paceSteadyTitle => 'Steady';

  @override
  String get paceCarefulTitle => 'Careful';

  @override
  String paceEveryNSeconds(int seconds) {
    return '1 every $seconds s';
  }

  @override
  String get paceOnePerMinute => '1 a minute';

  @override
  String paceWithEstimate(String pace, String estimate) {
    return '$pace · $estimate';
  }

  @override
  String aboutSeconds(int seconds) {
    return 'about $seconds s';
  }

  @override
  String aboutMinutes(int minutes) {
    return 'about $minutes min';
  }

  @override
  String aboutSecondsLeft(int seconds) {
    return 'About $seconds seconds left';
  }

  @override
  String aboutMinutesLeft(int minutes) {
    return 'About $minutes min left';
  }

  @override
  String confirmBulkSendTitle(int count, String sim) {
    return 'Send $count messages from $sim?';
  }

  @override
  String confirmBulkSendBody(String estimate) {
    return 'This takes $estimate and uses your SMS plan.';
  }

  @override
  String get sendAction => 'Send';

  @override
  String get discardDraftTitle => 'Discard this message?';

  @override
  String get discardDraftBody => 'Your message will not be saved.';

  @override
  String get discardAction => 'Discard';

  @override
  String get keepEditingAction => 'Keep editing';

  @override
  String get defaultSimLabel => 'your SIM';

  @override
  String campaignStateScheduled(String time) {
    return 'Scheduled for $time';
  }

  @override
  String campaignStateSending(int done, int total) {
    return 'Sending · $done of $total';
  }

  @override
  String campaignStatePaused(int done, int total) {
    return 'Paused · $done of $total';
  }

  @override
  String campaignStateDone(int sent) {
    return 'Done · $sent sent';
  }

  @override
  String campaignStateDoneWithFailed(int sent, int failed) {
    return 'Done · $sent sent · $failed not sent';
  }

  @override
  String campaignStateStopped(int done, int total) {
    return 'Stopped · $done of $total';
  }

  @override
  String get campaignPauseAction => 'Pause';

  @override
  String get campaignResumeAction => 'Resume';

  @override
  String get campaignStopAction => 'Stop';

  @override
  String get campaignStopConfirmTitle => 'Stop this campaign?';

  @override
  String get campaignStopConfirmBody =>
      'Messages already sent cannot be undone. Waiting messages will be cancelled.';

  @override
  String campaignRetryNNotSent(int count) {
    return 'Retry $count not sent';
  }

  @override
  String get campaignStatSent => 'Sent';

  @override
  String get campaignStatFailed => 'Failed';

  @override
  String get campaignStatSending => 'Sending';

  @override
  String get campaignStatWaiting => 'Waiting';

  @override
  String get campaignSectionRecipients => 'Recipients';

  @override
  String get campaignMenuDuplicate => 'Duplicate';

  @override
  String get campaignMenuExport => 'Export results';

  @override
  String get campaignMenuDelete => 'Delete';

  @override
  String get campaignExportedSnack => 'Results ready to share';

  @override
  String get statusSending => 'Sending';

  @override
  String get statusWaiting => 'Waiting';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusSkipped => 'Skipped';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String tapToRetryMeta(String reason) {
    return '$reason · tap to retry';
  }

  @override
  String get sentFilterAll => 'All';

  @override
  String get sentFilterDelivered => 'Delivered';

  @override
  String get sentFilterSent => 'Sent';

  @override
  String get sentFilterNotSent => 'Not sent';

  @override
  String get sentListEmpty => 'No sent messages yet';

  @override
  String get templateNameLabel => 'Template name';

  @override
  String get templateNameHint => 'Payment reminder';

  @override
  String get templateBodyLabel => 'Message';

  @override
  String get templateSaveAction => 'Save template';

  @override
  String get templateDeleteAction => 'Delete template';

  @override
  String get templateSamplePreview => 'Sample preview';

  @override
  String get templateValidationName => 'Add a template name';

  @override
  String get templateValidationBody => 'Add a message';

  @override
  String get recipientPickerTitle => 'Choose recipients';

  @override
  String recipientPickerDone(int count) {
    return 'Done ($count)';
  }

  @override
  String get setupSubtitle =>
      'A few permissions let PocketCRM log your calls and send on time, even when the app is closed.';

  @override
  String get setupRowContactsTitle => 'Contacts';

  @override
  String get setupRowContactsSubtitle =>
      'Shows your people and matches calls to them';

  @override
  String get setupRowCallsSmsTitle => 'Calls and messages';

  @override
  String get setupRowCallsSmsSubtitle =>
      'Builds each person\'s history on this phone';

  @override
  String get setupRowAlarmsTitle => 'Alarms and reminders';

  @override
  String get setupRowAlarmsSubtitle =>
      'Sends scheduled messages at the exact time';

  @override
  String get setupRowAlarmsFallback =>
      'Scheduled messages may be a few minutes late';

  @override
  String get setupRowBatteryTitle => 'Battery';

  @override
  String get setupRowBatterySubtitle =>
      'Stops Android pausing sends when the app is closed';

  @override
  String get setupRowNotificationsTitle => 'Notifications';

  @override
  String get setupRowNotificationsSubtitle =>
      'Follow-up reminders and send results';

  @override
  String get setupAllowedLabel => 'Allowed';

  @override
  String get setupAllowAction => 'Allow';

  @override
  String get setupOpenSettingsAction => 'Open settings';

  @override
  String get setupPrivacyNote =>
      'Everything stays on this phone. PocketCRM has no internet access.';

  @override
  String get setupSyncingContacts => 'Reading your contacts...';

  @override
  String get setupSyncingHistory => 'Reading your call and message history...';

  @override
  String setupSyncProgressCounts(int contacts, int calls, int sms) {
    return 'Synced $contacts people · $calls calls · $sms messages';
  }

  @override
  String get restrictedSettingsTitle => 'Allow restricted settings';

  @override
  String get restrictedSettingsStep1 =>
      '1. Tap the three dots at the top right.';

  @override
  String get restrictedSettingsStep2 =>
      '2. Tap \"Allow restricted settings\" and confirm with your screen lock.';

  @override
  String get restrictedSettingsStep3 =>
      '3. Come back here and tap Allow again.';

  @override
  String get restrictedSettingsFallback =>
      'No such option? Open Permissions on that page and allow SMS and Call logs there.';

  @override
  String get restrictedSettingsOpenAppInfo => 'Open app info';

  @override
  String get oemBatteryXiaomi =>
      'Turn on Autostart and set Battery saver to No restrictions';

  @override
  String get oemBatteryOppo => 'Allow background activity and Auto-launch';

  @override
  String get oemBatteryVivo =>
      'Allow High background power consumption and Autostart';

  @override
  String get oemBatterySamsung => 'Add PocketCRM to Never sleeping apps';

  @override
  String get oemBatteryTecno => 'Allow Auto-start in Phone Master';

  @override
  String get oemBatteryHuawei =>
      'Set App launch to Manage manually and allow all three switches';

  @override
  String get reliabilitySectionTitle => 'Check reliability';

  @override
  String get reliabilitySendTestAction => 'Send a test message';

  @override
  String get reliabilityPhoneLabel => 'Your phone number';

  @override
  String get reliabilityPhoneHint => 'Enter your own number';

  @override
  String reliabilityScheduledNotice(String time) {
    return 'Close the app and lock your phone. The message should arrive at $time.';
  }

  @override
  String reliabilityTestMessageBody(String time) {
    return 'PocketCRM test, scheduled for $time';
  }

  @override
  String get reliabilityResultOnTime => 'Arrived on time';

  @override
  String reliabilityResultLate(int minutes) {
    return 'Arrived $minutes minutes late: allow Alarms and reminders, and check the Battery step';
  }

  @override
  String reliabilityResultFailed(String reason) {
    return 'Not sent: $reason';
  }

  @override
  String get finishSetupBannerTitle => 'Finish setup';

  @override
  String get finishSetupBannerSubtitle =>
      'Allow contacts, calls and messages to log history automatically';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionAfterCalls => 'After calls';

  @override
  String get settingsSectionReminders => 'Reminders';

  @override
  String get settingsSectionMessages => 'Messages';

  @override
  String get settingsSectionData => 'Data';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsYourName => 'Your name';

  @override
  String get settingsNotSet => 'Not set';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsPhoneRegion => 'Region for phone numbers';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageBengali => 'বাংলা';

  @override
  String get settingsAfterCallPrompt => 'Ask for a note';

  @override
  String get settingsAfterCallAll => 'All saved people';

  @override
  String get settingsAfterCallStarred => 'Starred only';

  @override
  String get settingsAfterCallNever => 'Never';

  @override
  String get settingsMorningSummary => 'Morning summary';

  @override
  String get settingsReconnectNudges => 'Reconnect nudges';

  @override
  String get settingsOn => 'On';

  @override
  String get settingsOff => 'Off';

  @override
  String get settingsDefaultPace => 'Default pace';

  @override
  String get settingsSendWindow => 'Send window';

  @override
  String get settingsOptOutWords => 'Opt-out words';

  @override
  String get settingsSyncNow => 'Sync now';

  @override
  String get settingsSyncNever => 'Not synced yet';

  @override
  String get settingsSyncComplete => 'Sync complete';

  @override
  String get settingsCheckSetup => 'Check setup';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsLicences => 'Licences';

  @override
  String get settingsNoInternetStatement =>
      'PocketCRM cannot connect to the internet.';

  @override
  String get settingsExportPeopleCsv => 'People as CSV';

  @override
  String get settingsExportPeopleVcard => 'People as vCard';

  @override
  String get exportHistoryCsvMenu => 'Export history as CSV';

  @override
  String get exportSavedSnack => 'Export saved';

  @override
  String get exportFailedSnack => 'Could not save export';

  @override
  String get backupLastTime => 'Last backup';

  @override
  String get backupNever => 'Never';

  @override
  String get backupNowAction => 'Back up now';

  @override
  String get backupIncludeFiles => 'Include photos and files';

  @override
  String get backupProtectPassphrase => 'Protect with a passphrase';

  @override
  String get backupPassphraseHint => 'Passphrase';

  @override
  String get backupPassphraseConfirmHint => 'Confirm passphrase';

  @override
  String get backupPassphraseWarning =>
      'If you forget this passphrase the backup cannot be opened.';

  @override
  String get backupPassphraseMismatch => 'Passphrases do not match';

  @override
  String get backupPassphraseRequired => 'Enter a passphrase';

  @override
  String get backupRestoreAction => 'Restore from a backup';

  @override
  String get backupAutoTitle => 'Automatic backups';

  @override
  String get backupAutoSubtitle => 'Weekly plain backup, keeps last 4';

  @override
  String get backupAutoExplanation =>
      'Kept on this phone and removed if the app is uninstalled. Save a backup elsewhere now and then.';

  @override
  String backupAutoCount(int count) {
    return '$count on this phone';
  }

  @override
  String get backupStagePreparing => 'Preparing database...';

  @override
  String get backupStageReadingOutbox => 'Reading scheduled messages...';

  @override
  String get backupStagePacking => 'Packing files...';

  @override
  String get backupStageEncrypting => 'Encrypting backup...';

  @override
  String get backupStageSaving => 'Saving backup...';

  @override
  String get backupStageDecrypting => 'Decrypting backup...';

  @override
  String get backupStageVerifying => 'Checking backup...';

  @override
  String get backupStageRestoring => 'Restoring data...';

  @override
  String get backupSavedSnack => 'Backup saved';

  @override
  String get backupWrongPassphrase =>
      'That passphrase does not open this backup';

  @override
  String get backupCorruptError => 'This file is not a valid PocketCRM backup';

  @override
  String backupManifestSummary(
    String people,
    String history,
    String files,
    String date,
  ) {
    return '$people people, $history history entries, $files files, from $date';
  }

  @override
  String backupV1Summary(String people, String history, String tasks) {
    return 'Old backup: $people people, $history history entries, $tasks follow-ups';
  }

  @override
  String get backupReplaceConfirmTitle =>
      'Replace everything on this phone with this backup?';

  @override
  String get backupReplaceConfirmAction => 'Replace';

  @override
  String get backupMergeV1ConfirmTitle =>
      'Import this old backup into PocketCRM?';

  @override
  String get backupMergeV1ConfirmAction => 'Import';

  @override
  String get backupEnterPassphraseTitle => 'Enter backup passphrase';

  @override
  String get backupOpenAction => 'Open backup';

  @override
  String get backupRestoredSnack => 'Backup restored';

  @override
  String backupV1ImportedSnack(int people, int history) {
    return 'Imported $people people and $history history entries';
  }
}
