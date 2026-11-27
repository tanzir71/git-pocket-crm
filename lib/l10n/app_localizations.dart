// ignore_for_file: deprecated_member_use
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PocketCRM'**
  String get appTitle;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get navPeople;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @tabTodayPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Today will be built in spec 08.'**
  String get tabTodayPlaceholder;

  /// No description provided for @tabPeoplePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'People will be built in spec 06.'**
  String get tabPeoplePlaceholder;

  /// No description provided for @tabMessagesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Messages will be built in spec 10.'**
  String get tabMessagesPlaceholder;

  /// No description provided for @placeholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming in v2'**
  String get placeholderTitle;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get setupTitle;

  /// No description provided for @setupPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Setup will be built in spec 11.'**
  String get setupPlaceholder;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Settings will be built in upcoming specs.'**
  String get settingsPlaceholder;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup and restore'**
  String get backupTitle;

  /// No description provided for @backupPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Backup and restore will be built in spec 12.'**
  String get backupPlaceholder;

  /// No description provided for @personTitle.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get personTitle;

  /// No description provided for @newMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get newMessageTitle;

  /// No description provided for @campaignTitle.
  ///
  /// In en, this message translates to:
  /// **'Campaign'**
  String get campaignTitle;

  /// No description provided for @sentMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sent messages'**
  String get sentMessagesTitle;

  /// No description provided for @templateTitle.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get templateTitle;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @doThisLater.
  ///
  /// In en, this message translates to:
  /// **'Do this later'**
  String get doThisLater;

  /// No description provided for @peopleTitle.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get peopleTitle;

  /// No description provided for @peopleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No people} =1{1 person} other{{count} people}}'**
  String peopleCount(int count);

  /// No description provided for @addPersonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get addPersonTooltip;

  /// No description provided for @searchPeopleHint.
  ///
  /// In en, this message translates to:
  /// **'Search people, companies, numbers, notes'**
  String get searchPeopleHint;

  /// No description provided for @clearSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearchTooltip;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterStarred.
  ///
  /// In en, this message translates to:
  /// **'Starred'**
  String get filterStarred;

  /// No description provided for @filterDueToReconnect.
  ///
  /// In en, this message translates to:
  /// **'Due to reconnect'**
  String get filterDueToReconnect;

  /// No description provided for @filterOwesMe.
  ///
  /// In en, this message translates to:
  /// **'Owes me'**
  String get filterOwesMe;

  /// No description provided for @newListChip.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get newListChip;

  /// No description provided for @sortRecentlyContacted.
  ///
  /// In en, this message translates to:
  /// **'Recently contacted'**
  String get sortRecentlyContacted;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @sortLongestSinceContact.
  ///
  /// In en, this message translates to:
  /// **'Longest since contact'**
  String get sortLongestSinceContact;

  /// No description provided for @selectionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectionCount(int count);

  /// No description provided for @closeSelectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Exit selection'**
  String get closeSelectionTooltip;

  /// No description provided for @actionAddToList.
  ///
  /// In en, this message translates to:
  /// **'Add to list'**
  String get actionAddToList;

  /// No description provided for @actionSetReconnect.
  ///
  /// In en, this message translates to:
  /// **'Set reconnect'**
  String get actionSetReconnect;

  /// No description provided for @actionMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get actionMessage;

  /// No description provided for @actionStar.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get actionStar;

  /// No description provided for @mergeSuggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'{firstName} and {secondName} share a number'**
  String mergeSuggestionTitle(String firstName, String secondName);

  /// No description provided for @mergeAction.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get mergeAction;

  /// No description provided for @keepSeparateAction.
  ///
  /// In en, this message translates to:
  /// **'Keep separate'**
  String get keepSeparateAction;

  /// No description provided for @noMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No one matches \'{query}\''**
  String noMatchesTitle(String query);

  /// No description provided for @addQueryAsPerson.
  ///
  /// In en, this message translates to:
  /// **'Add \'{query}\' as a new person'**
  String addQueryAsPerson(String query);

  /// No description provided for @noPeopleYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No people yet'**
  String get noPeopleYetTitle;

  /// No description provided for @noPeopleYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'People from your phone and people you add will appear here.'**
  String get noPeopleYetSubtitle;

  /// No description provided for @noPeopleInFilter.
  ///
  /// In en, this message translates to:
  /// **'No people in this view'**
  String get noPeopleInFilter;

  /// No description provided for @followUpOverdue.
  ///
  /// In en, this message translates to:
  /// **'follow-up overdue'**
  String get followUpOverdue;

  /// No description provided for @noContactYet.
  ///
  /// In en, this message translates to:
  /// **'no contact yet'**
  String get noContactYet;

  /// No description provided for @calledToday.
  ///
  /// In en, this message translates to:
  /// **'called today'**
  String get calledToday;

  /// No description provided for @calledYesterday.
  ///
  /// In en, this message translates to:
  /// **'called yesterday'**
  String get calledYesterday;

  /// No description provided for @calledAgo.
  ///
  /// In en, this message translates to:
  /// **'called {age} ago'**
  String calledAgo(String age);

  /// No description provided for @messagedToday.
  ///
  /// In en, this message translates to:
  /// **'messaged today'**
  String get messagedToday;

  /// No description provided for @messagedYesterday.
  ///
  /// In en, this message translates to:
  /// **'messaged yesterday'**
  String get messagedYesterday;

  /// No description provided for @messagedAgo.
  ///
  /// In en, this message translates to:
  /// **'messaged {age} ago'**
  String messagedAgo(String age);

  /// No description provided for @visitedToday.
  ///
  /// In en, this message translates to:
  /// **'visited today'**
  String get visitedToday;

  /// No description provided for @visitedYesterday.
  ///
  /// In en, this message translates to:
  /// **'visited yesterday'**
  String get visitedYesterday;

  /// No description provided for @visitedAgo.
  ///
  /// In en, this message translates to:
  /// **'visited {age} ago'**
  String visitedAgo(String age);

  /// No description provided for @lastSpokeToday.
  ///
  /// In en, this message translates to:
  /// **'last spoke today'**
  String get lastSpokeToday;

  /// No description provided for @lastSpokeYesterday.
  ///
  /// In en, this message translates to:
  /// **'last spoke yesterday'**
  String get lastSpokeYesterday;

  /// No description provided for @lastSpokeAgo.
  ///
  /// In en, this message translates to:
  /// **'last spoke {age} ago'**
  String lastSpokeAgo(String age);

  /// No description provided for @ageNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get ageNow;

  /// No description provided for @listRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get listRename;

  /// No description provided for @listSetReconnect.
  ///
  /// In en, this message translates to:
  /// **'Set how often to reconnect'**
  String get listSetReconnect;

  /// No description provided for @listMessage.
  ///
  /// In en, this message translates to:
  /// **'Message this list'**
  String get listMessage;

  /// No description provided for @listDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete list'**
  String get listDelete;

  /// No description provided for @listNameLabel.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get listNameLabel;

  /// No description provided for @createListTitle.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get createListTitle;

  /// No description provided for @renameListTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename list'**
  String get renameListTitle;

  /// No description provided for @deleteListConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \'{name}\'? People in this list will not be deleted.'**
  String deleteListConfirm(String name);

  /// No description provided for @manageListsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get manageListsTitle;

  /// No description provided for @cadencePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'How often to reconnect'**
  String get cadencePickerTitle;

  /// No description provided for @cadenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get cadenceWeekly;

  /// No description provided for @cadenceBiweekly.
  ///
  /// In en, this message translates to:
  /// **'Every 2 weeks'**
  String get cadenceBiweekly;

  /// No description provided for @cadenceMonthly.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get cadenceMonthly;

  /// No description provided for @cadenceQuarterly.
  ///
  /// In en, this message translates to:
  /// **'Every 3 months'**
  String get cadenceQuarterly;

  /// No description provided for @cadenceHalfYearly.
  ///
  /// In en, this message translates to:
  /// **'Every 6 months'**
  String get cadenceHalfYearly;

  /// No description provided for @cadenceYearly.
  ///
  /// In en, this message translates to:
  /// **'Every year'**
  String get cadenceYearly;

  /// No description provided for @cadenceNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get cadenceNever;

  /// No description provided for @cadenceEveryNDays.
  ///
  /// In en, this message translates to:
  /// **'Every {days} days'**
  String cadenceEveryNDays(int days);

  /// No description provided for @reconnectEvery.
  ///
  /// In en, this message translates to:
  /// **'Reconnect {cadence}'**
  String reconnectEvery(String cadence);

  /// No description provided for @setReconnectChip.
  ///
  /// In en, this message translates to:
  /// **'Set reconnect'**
  String get setReconnectChip;

  /// No description provided for @cadenceListHint.
  ///
  /// In en, this message translates to:
  /// **'Applies to the {count, plural, =1{1 person} other{{count} people}} in {listName} who have no setting of their own.'**
  String cadenceListHint(int count, String listName);

  /// No description provided for @addPersonTitle.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get addPersonTitle;

  /// No description provided for @editPersonTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit details'**
  String get editPersonTitle;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get fieldPhone;

  /// No description provided for @fieldAddPhone.
  ///
  /// In en, this message translates to:
  /// **'Add another number'**
  String get fieldAddPhone;

  /// No description provided for @fieldPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get fieldPrimary;

  /// No description provided for @fieldCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get fieldCompany;

  /// No description provided for @fieldRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get fieldRole;

  /// No description provided for @fieldCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get fieldCity;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday (YYYY-MM-DD)'**
  String get fieldBirthday;

  /// No description provided for @fieldLinkedin.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get fieldLinkedin;

  /// No description provided for @fieldFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get fieldFacebook;

  /// No description provided for @fieldAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get fieldAbout;

  /// No description provided for @phoneIncompleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This number does not look complete'**
  String get phoneIncompleteWarning;

  /// No description provided for @duplicatePhoneNotice.
  ///
  /// In en, this message translates to:
  /// **'This number already belongs to {name}'**
  String duplicatePhoneNotice(String name);

  /// No description provided for @openPersonAction.
  ///
  /// In en, this message translates to:
  /// **'Open {name}'**
  String openPersonAction(String name);

  /// No description provided for @saveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @undoAction.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoAction;

  /// No description provided for @doneAction.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneAction;

  /// No description provided for @okAction.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okAction;

  /// No description provided for @starTooltip.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get starTooltip;

  /// No description provided for @unstarTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove star'**
  String get unstarTooltip;

  /// No description provided for @moreTooltip.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTooltip;

  /// No description provided for @backTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backTooltip;

  /// No description provided for @doNotMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Do not message'**
  String get doNotMessageLabel;

  /// No description provided for @askedNotToBeMessaged.
  ///
  /// In en, this message translates to:
  /// **'Asked not to be messaged'**
  String get askedNotToBeMessaged;

  /// No description provided for @deletePersonMenu.
  ///
  /// In en, this message translates to:
  /// **'Delete person'**
  String get deletePersonMenu;

  /// No description provided for @deletePersonTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deletePersonTitle(String name);

  /// No description provided for @deletePersonConfirm.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{This person will be removed from PocketCRM.} =1{This person and 1 history entry will be removed.} other{This person and {count} history entries will be removed.}}'**
  String deletePersonConfirm(int count);

  /// No description provided for @actionCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get actionCall;

  /// No description provided for @actionWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get actionWhatsApp;

  /// No description provided for @actionNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get actionNote;

  /// No description provided for @pickNumberTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a number'**
  String get pickNumberTitle;

  /// No description provided for @sectionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get sectionNext;

  /// No description provided for @sectionHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get sectionHistory;

  /// No description provided for @owesYouAmount.
  ///
  /// In en, this message translates to:
  /// **'Owes you {amount}'**
  String owesYouAmount(String amount);

  /// No description provided for @youOweAmount.
  ///
  /// In en, this message translates to:
  /// **'You owe {amount}'**
  String youOweAmount(String amount);

  /// No description provided for @sendReminderAction.
  ///
  /// In en, this message translates to:
  /// **'Send a reminder'**
  String get sendReminderAction;

  /// No description provided for @historyFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter history'**
  String get historyFilterTooltip;

  /// No description provided for @historyFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get historyFilterAll;

  /// No description provided for @historyFilterCalls.
  ///
  /// In en, this message translates to:
  /// **'Calls'**
  String get historyFilterCalls;

  /// No description provided for @historyFilterMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get historyFilterMessages;

  /// No description provided for @historyFilterNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get historyFilterNotes;

  /// No description provided for @historyFilterVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get historyFilterVisits;

  /// No description provided for @historyFilterPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get historyFilterPayments;

  /// No description provided for @historyFilterFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get historyFilterFiles;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get historyEmpty;

  /// No description provided for @historyEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'No entries in this filter'**
  String get historyEmptyFiltered;

  /// No description provided for @loadMoreAction.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get loadMoreAction;

  /// No description provided for @callOutgoing.
  ///
  /// In en, this message translates to:
  /// **'Outgoing call'**
  String get callOutgoing;

  /// No description provided for @callIncoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming call'**
  String get callIncoming;

  /// No description provided for @callMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed call'**
  String get callMissed;

  /// No description provided for @messageReceived.
  ///
  /// In en, this message translates to:
  /// **'Message received'**
  String get messageReceived;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent'**
  String get messageSent;

  /// No description provided for @entryNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get entryNote;

  /// No description provided for @entryVisit.
  ///
  /// In en, this message translates to:
  /// **'Visit'**
  String get entryVisit;

  /// No description provided for @entryVisitPlace.
  ///
  /// In en, this message translates to:
  /// **'Visit · {place}'**
  String entryVisitPlace(String place);

  /// No description provided for @paymentReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment received · {amount}'**
  String paymentReceivedTitle(String amount);

  /// No description provided for @paymentPaidTitle.
  ///
  /// In en, this message translates to:
  /// **'You paid · {amount}'**
  String paymentPaidTitle(String amount);

  /// No description provided for @paymentOwedToMeTitle.
  ///
  /// In en, this message translates to:
  /// **'Owes you · {amount}'**
  String paymentOwedToMeTitle(String amount);

  /// No description provided for @paymentIOweTitle.
  ///
  /// In en, this message translates to:
  /// **'You owe · {amount}'**
  String paymentIOweTitle(String amount);

  /// No description provided for @suggestedPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Looks like a payment · {amount}'**
  String suggestedPaymentTitle(String amount);

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmAction;

  /// No description provided for @dismissAction.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissAction;

  /// No description provided for @confirmPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm payment'**
  String get confirmPaymentTitle;

  /// No description provided for @paymentStatusReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get paymentStatusReceived;

  /// No description provided for @paymentStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paymentStatusPaid;

  /// No description provided for @paymentStatusOwesMe.
  ///
  /// In en, this message translates to:
  /// **'Owes me'**
  String get paymentStatusOwesMe;

  /// No description provided for @paymentStatusIOwe.
  ///
  /// In en, this message translates to:
  /// **'I owe'**
  String get paymentStatusIOwe;

  /// No description provided for @deleteEntryAction.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get deleteEntryAction;

  /// No description provided for @hideFromHistoryAction.
  ///
  /// In en, this message translates to:
  /// **'Hide from history'**
  String get hideFromHistoryAction;

  /// No description provided for @addFollowUpAction.
  ///
  /// In en, this message translates to:
  /// **'Add follow-up'**
  String get addFollowUpAction;

  /// No description provided for @entryHiddenMessage.
  ///
  /// In en, this message translates to:
  /// **'Hidden from history'**
  String get entryHiddenMessage;

  /// No description provided for @entryDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get entryDeletedMessage;

  /// No description provided for @followUpCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Follow-up completed'**
  String get followUpCompletedMessage;

  /// No description provided for @photoCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo} other{{count} photos}}'**
  String photoCount(int count);

  /// No description provided for @statusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get statusScheduled;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusNotSent.
  ///
  /// In en, this message translates to:
  /// **'Not sent'**
  String get statusNotSent;

  /// No description provided for @statusSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get statusSent;

  /// No description provided for @quickNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get quickNoteTitle;

  /// No description provided for @quickNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Write a note'**
  String get quickNoteHint;

  /// No description provided for @saveNoteAction.
  ///
  /// In en, this message translates to:
  /// **'Save note'**
  String get saveNoteAction;

  /// No description provided for @quickFollowUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Add follow-up'**
  String get quickFollowUpTitle;

  /// No description provided for @followUpTitleHint.
  ///
  /// In en, this message translates to:
  /// **'What needs to happen?'**
  String get followUpTitleHint;

  /// No description provided for @dueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dueTomorrow;

  /// No description provided for @dueInThreeDays.
  ///
  /// In en, this message translates to:
  /// **'In 3 days'**
  String get dueInThreeDays;

  /// No description provided for @dueNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get dueNextWeek;

  /// No description provided for @saveFollowUpAction.
  ///
  /// In en, this message translates to:
  /// **'Save follow-up'**
  String get saveFollowUpAction;

  /// No description provided for @personPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a person'**
  String get personPickerTitle;

  /// No description provided for @personPickerRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get personPickerRecent;

  /// No description provided for @personPickerAll.
  ///
  /// In en, this message translates to:
  /// **'All people'**
  String get personPickerAll;

  /// No description provided for @personPickerLists.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get personPickerLists;

  /// No description provided for @personNotFound.
  ///
  /// In en, this message translates to:
  /// **'Person not found'**
  String get personNotFound;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @durationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String durationSeconds(int seconds);

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @yesterdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdayLabel;

  /// No description provided for @overdueByDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{overdue by 1 day} other{overdue by {days} days}}'**
  String overdueByDays(int days);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
