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

  /// No description provided for @addSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addSheetTitle;

  /// No description provided for @editEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editEntryTitle;

  /// No description provided for @choosePersonLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose a person'**
  String get choosePersonLabel;

  /// No description provided for @validationChoosePerson.
  ///
  /// In en, this message translates to:
  /// **'Choose a person'**
  String get validationChoosePerson;

  /// No description provided for @validationAddAmount.
  ///
  /// In en, this message translates to:
  /// **'Add an amount'**
  String get validationAddAmount;

  /// No description provided for @validationAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get validationAddNote;

  /// No description provided for @validationAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a title'**
  String get validationAddTitle;

  /// No description provided for @validationPickFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get validationPickFile;

  /// No description provided for @suggestedLastCall.
  ///
  /// In en, this message translates to:
  /// **'Your last call'**
  String get suggestedLastCall;

  /// No description provided for @suggestedFollowUpAt.
  ///
  /// In en, this message translates to:
  /// **'Suggested from your {time} follow-up'**
  String suggestedFollowUpAt(String time);

  /// No description provided for @typeNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get typeNote;

  /// No description provided for @typeCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get typeCall;

  /// No description provided for @typeVisit.
  ///
  /// In en, this message translates to:
  /// **'Visit'**
  String get typeVisit;

  /// No description provided for @typeTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get typeTask;

  /// No description provided for @typePayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get typePayment;

  /// No description provided for @typeFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get typeFile;

  /// No description provided for @directionOutgoing.
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get directionOutgoing;

  /// No description provided for @directionIncoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get directionIncoming;

  /// No description provided for @outcomeQuestion.
  ///
  /// In en, this message translates to:
  /// **'How did it go?'**
  String get outcomeQuestion;

  /// No description provided for @outcomeSpoke.
  ///
  /// In en, this message translates to:
  /// **'Spoke'**
  String get outcomeSpoke;

  /// No description provided for @outcomeNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'No answer'**
  String get outcomeNoAnswer;

  /// No description provided for @outcomeLeftMessage.
  ///
  /// In en, this message translates to:
  /// **'Left a message'**
  String get outcomeLeftMessage;

  /// No description provided for @fieldTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get fieldTime;

  /// No description provided for @fieldDurationMin.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get fieldDurationMin;

  /// No description provided for @fieldPlace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get fieldPlace;

  /// No description provided for @currentLocationAction.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocationAction;

  /// No description provided for @locationAttached.
  ///
  /// In en, this message translates to:
  /// **'Location attached'**
  String get locationAttached;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get locationUnavailable;

  /// No description provided for @fieldPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get fieldPhotos;

  /// No description provided for @photoCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get photoCamera;

  /// No description provided for @photoGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get photoGallery;

  /// No description provided for @fieldAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get fieldAmount;

  /// No description provided for @fieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get fieldDescription;

  /// No description provided for @fieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fieldDate;

  /// No description provided for @chooseFileAction.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get chooseFileAction;

  /// No description provided for @followUpSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Follow up'**
  String get followUpSectionLabel;

  /// No description provided for @pickDateAction.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get pickDateAction;

  /// No description provided for @followUpDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow up with {firstName}'**
  String followUpDefaultTitle(String firstName);

  /// No description provided for @callBackDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Call {firstName} back'**
  String callBackDefaultTitle(String firstName);

  /// No description provided for @saveCallAction.
  ///
  /// In en, this message translates to:
  /// **'Save call'**
  String get saveCallAction;

  /// No description provided for @saveVisitAction.
  ///
  /// In en, this message translates to:
  /// **'Save visit'**
  String get saveVisitAction;

  /// No description provided for @saveTaskAction.
  ///
  /// In en, this message translates to:
  /// **'Save task'**
  String get saveTaskAction;

  /// No description provided for @savePaymentAction.
  ///
  /// In en, this message translates to:
  /// **'Save payment'**
  String get savePaymentAction;

  /// No description provided for @saveFileAction.
  ///
  /// In en, this message translates to:
  /// **'Save file'**
  String get saveFileAction;

  /// No description provided for @saveChangesAction.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChangesAction;

  /// No description provided for @savedMessage.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedMessage;

  /// No description provided for @callWithTitle.
  ///
  /// In en, this message translates to:
  /// **'Call with {name}'**
  String callWithTitle(String name);

  /// No description provided for @justNowLabel.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNowLabel;

  /// No description provided for @todaySearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search people'**
  String get todaySearchTooltip;

  /// No description provided for @todaySettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get todaySettingsTooltip;

  /// No description provided for @promptSpokeWith.
  ///
  /// In en, this message translates to:
  /// **'You spoke with {name}'**
  String promptSpokeWith(String name);

  /// No description provided for @promptAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get promptAddNote;

  /// No description provided for @promptFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow up'**
  String get promptFollowUp;

  /// No description provided for @promptSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get promptSkip;

  /// No description provided for @sectionNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get sectionNeedsAttention;

  /// No description provided for @sectionFollowUps.
  ///
  /// In en, this message translates to:
  /// **'Follow-ups'**
  String get sectionFollowUps;

  /// No description provided for @sectionReconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get sectionReconnect;

  /// No description provided for @sectionGoingOutToday.
  ///
  /// In en, this message translates to:
  /// **'Going out today'**
  String get sectionGoingOutToday;

  /// No description provided for @sectionComingUp.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get sectionComingUp;

  /// No description provided for @showAllAction.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAllAction;

  /// No description provided for @snoozeOneWeek.
  ///
  /// In en, this message translates to:
  /// **'Snooze 1 week'**
  String get snoozeOneWeek;

  /// No description provided for @changeHowOften.
  ///
  /// In en, this message translates to:
  /// **'Change how often'**
  String get changeHowOften;

  /// No description provided for @birthdayToday.
  ///
  /// In en, this message translates to:
  /// **'Birthday today'**
  String get birthdayToday;

  /// No description provided for @birthdayOnDay.
  ///
  /// In en, this message translates to:
  /// **'Birthday on {day}'**
  String birthdayOnDay(String day);

  /// No description provided for @allCaughtUpTitle.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get allCaughtUpTitle;

  /// No description provided for @allCaughtUpMessage.
  ///
  /// In en, this message translates to:
  /// **'Follow-ups and people to reconnect with will appear here.'**
  String get allCaughtUpMessage;

  /// No description provided for @choosePeopleToStayInTouch.
  ///
  /// In en, this message translates to:
  /// **'Choose people to stay in touch with'**
  String get choosePeopleToStayInTouch;

  /// No description provided for @retryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// No description provided for @notSentTo.
  ///
  /// In en, this message translates to:
  /// **'Not sent to {name}'**
  String notSentTo(String name);

  /// No description provided for @notifChannelFollowUps.
  ///
  /// In en, this message translates to:
  /// **'Follow-ups'**
  String get notifChannelFollowUps;

  /// No description provided for @notifChannelReconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get notifChannelReconnect;

  /// No description provided for @notifChannelAfterCalls.
  ///
  /// In en, this message translates to:
  /// **'After calls'**
  String get notifChannelAfterCalls;

  /// No description provided for @notifChannelMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get notifChannelMessages;

  /// No description provided for @notifChannelMorningSummary.
  ///
  /// In en, this message translates to:
  /// **'Morning summary'**
  String get notifChannelMorningSummary;

  /// No description provided for @notifActionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get notifActionDone;

  /// No description provided for @notifActionTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get notifActionTomorrow;

  /// No description provided for @morningSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'PocketCRM'**
  String get morningSummaryTitle;

  /// No description provided for @morningSummaryFollowUps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 follow-up today} other{{count} follow-ups today}}'**
  String morningSummaryFollowUps(int count);

  /// No description provided for @morningSummaryReconnect.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person to reconnect with} other{{count} people to reconnect with}}'**
  String morningSummaryReconnect(int count);

  /// No description provided for @notifPermissionRationale.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so PocketCRM can remind you about follow-ups and scheduled messages.'**
  String get notifPermissionRationale;

  /// No description provided for @messagePersonTitle.
  ///
  /// In en, this message translates to:
  /// **'Message {name}'**
  String messagePersonTitle(String name);

  /// No description provided for @messageFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message'**
  String get messageFieldHint;

  /// No description provided for @smsCounterLabel.
  ///
  /// In en, this message translates to:
  /// **'{units} / {limit} · {segments} SMS'**
  String smsCounterLabel(int units, int limit, int segments);

  /// No description provided for @sendNowOption.
  ///
  /// In en, this message translates to:
  /// **'Send now'**
  String get sendNowOption;

  /// No description provided for @scheduleOption.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleOption;

  /// No description provided for @sendNowAction.
  ///
  /// In en, this message translates to:
  /// **'Send now'**
  String get sendNowAction;

  /// No description provided for @scheduleMessageAction.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleMessageAction;

  /// No description provided for @openInSmsAppAction.
  ///
  /// In en, this message translates to:
  /// **'Open in your SMS app'**
  String get openInSmsAppAction;

  /// No description provided for @fromSimLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromSimLabel;

  /// No description provided for @mayBeMinutesLateNotice.
  ///
  /// In en, this message translates to:
  /// **'Exact alarms are off, so this message may go out a few minutes late.'**
  String get mayBeMinutesLateNotice;

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get statusMissed;

  /// No description provided for @missedMessageTo.
  ///
  /// In en, this message translates to:
  /// **'Missed message to {name}'**
  String missedMessageTo(String name);

  /// No description provided for @smsErrorNoService.
  ///
  /// In en, this message translates to:
  /// **'No service'**
  String get smsErrorNoService;

  /// No description provided for @smsErrorRadioOff.
  ///
  /// In en, this message translates to:
  /// **'Airplane mode or radio off'**
  String get smsErrorRadioOff;

  /// No description provided for @smsErrorLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Sending limit reached'**
  String get smsErrorLimitReached;

  /// No description provided for @smsErrorNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Not allowed by the network'**
  String get smsErrorNotAllowed;

  /// No description provided for @smsErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Not sent'**
  String get smsErrorGeneric;

  /// No description provided for @smsErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown error ({code})'**
  String smsErrorUnknown(int code);

  /// No description provided for @messageScheduledSnack.
  ///
  /// In en, this message translates to:
  /// **'Message scheduled'**
  String get messageScheduledSnack;

  /// No description provided for @messageQueuedSnack.
  ///
  /// In en, this message translates to:
  /// **'Sending message'**
  String get messageQueuedSnack;

  /// No description provided for @messagesViewOutbox.
  ///
  /// In en, this message translates to:
  /// **'Outbox'**
  String get messagesViewOutbox;

  /// No description provided for @messagesViewCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Campaigns'**
  String get messagesViewCampaigns;

  /// No description provided for @messagesViewTemplates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get messagesViewTemplates;

  /// No description provided for @messagesSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search messages'**
  String get messagesSearchTooltip;

  /// No description provided for @messagesSummaryScheduled.
  ///
  /// In en, this message translates to:
  /// **'{count} scheduled'**
  String messagesSummaryScheduled(int count);

  /// No description provided for @messagesSummaryAttention.
  ///
  /// In en, this message translates to:
  /// **'{count} needs attention'**
  String messagesSummaryAttention(int count);

  /// No description provided for @sectionTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get sectionTomorrow;

  /// No description provided for @sectionLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get sectionLater;

  /// No description provided for @sectionEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get sectionEarlier;

  /// No description provided for @sentThisWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Sent this week'**
  String get sentThisWeekLabel;

  /// No description provided for @campaignToNPeople.
  ///
  /// In en, this message translates to:
  /// **'{name} to {count} people'**
  String campaignToNPeople(String name, int count);

  /// No description provided for @emptyOutboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled'**
  String get emptyOutboxTitle;

  /// No description provided for @emptyOutboxMessage.
  ///
  /// In en, this message translates to:
  /// **'Messages you schedule will wait here until they are sent.'**
  String get emptyOutboxMessage;

  /// No description provided for @emptyCampaignsTitle.
  ///
  /// In en, this message translates to:
  /// **'No campaigns yet'**
  String get emptyCampaignsTitle;

  /// No description provided for @emptyCampaignsMessage.
  ///
  /// In en, this message translates to:
  /// **'Messages sent to a list or multiple people will appear here.'**
  String get emptyCampaignsMessage;

  /// No description provided for @emptyTemplatesTitle.
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
  String get emptyTemplatesTitle;

  /// No description provided for @emptyTemplatesMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a template to reuse personalised messages.'**
  String get emptyTemplatesMessage;

  /// No description provided for @newTemplateAction.
  ///
  /// In en, this message translates to:
  /// **'New template'**
  String get newTemplateAction;

  /// No description provided for @newMessageFabTooltip.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get newMessageFabTooltip;

  /// No description provided for @composerToLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get composerToLabel;

  /// No description provided for @composerAddPeople.
  ///
  /// In en, this message translates to:
  /// **'Add people'**
  String get composerAddPeople;

  /// No description provided for @composerMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get composerMessageLabel;

  /// No description provided for @composerPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get composerPreviewLabel;

  /// No description provided for @composerPreviewCounter.
  ///
  /// In en, this message translates to:
  /// **'{name} · {index} of {total}'**
  String composerPreviewCounter(String name, int index, int total);

  /// No description provided for @composerTemplatesAction.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get composerTemplatesAction;

  /// No description provided for @composerSendLabel.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get composerSendLabel;

  /// No description provided for @composerPaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get composerPaceLabel;

  /// No description provided for @composerSendWindowCaption.
  ///
  /// In en, this message translates to:
  /// **'Sends only between {start} and {end}'**
  String composerSendWindowCaption(String start, String end);

  /// No description provided for @composerScheduleNMessages.
  ///
  /// In en, this message translates to:
  /// **'Schedule {count, plural, =1{message} other{{count} messages}}'**
  String composerScheduleNMessages(int count);

  /// No description provided for @composerSendNMessages.
  ///
  /// In en, this message translates to:
  /// **'Send {count, plural, =1{now} other{{count} messages}}'**
  String composerSendNMessages(int count);

  /// No description provided for @composerCounterSingle.
  ///
  /// In en, this message translates to:
  /// **'{segments} SMS · {units} of {limit}'**
  String composerCounterSingle(int segments, int units, int limit);

  /// No description provided for @composerCounterRange.
  ///
  /// In en, this message translates to:
  /// **'{min} to {max} SMS each'**
  String composerCounterRange(int min, int max);

  /// No description provided for @mergeChipFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get mergeChipFirstName;

  /// No description provided for @mergeChipName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get mergeChipName;

  /// No description provided for @mergeChipCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get mergeChipCompany;

  /// No description provided for @mergeChipAmountDue.
  ///
  /// In en, this message translates to:
  /// **'Amount due'**
  String get mergeChipAmountDue;

  /// No description provided for @mergeChipMyName.
  ///
  /// In en, this message translates to:
  /// **'My name'**
  String get mergeChipMyName;

  /// No description provided for @skippedNoMobile.
  ///
  /// In en, this message translates to:
  /// **'{count} skipped: no mobile number'**
  String skippedNoMobile(int count);

  /// No description provided for @skippedOptedOut.
  ///
  /// In en, this message translates to:
  /// **'{count} skipped: asked not to be messaged'**
  String skippedOptedOut(int count);

  /// No description provided for @skippedDuplicate.
  ///
  /// In en, this message translates to:
  /// **'{count} skipped: duplicate number'**
  String skippedDuplicate(int count);

  /// No description provided for @unknownMergeFieldsWarning.
  ///
  /// In en, this message translates to:
  /// **'Unknown fields will be sent as typed: {fields}'**
  String unknownMergeFieldsWarning(String fields);

  /// No description provided for @checkTheseRecipients.
  ///
  /// In en, this message translates to:
  /// **'Check these ({count}): missing {fields}'**
  String checkTheseRecipients(int count, String fields);

  /// No description provided for @previewMissingFieldWarning.
  ///
  /// In en, this message translates to:
  /// **'Missing {fields} for this person'**
  String previewMissingFieldWarning(String fields);

  /// No description provided for @paceFastTitle.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get paceFastTitle;

  /// No description provided for @paceSteadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Steady'**
  String get paceSteadyTitle;

  /// No description provided for @paceCarefulTitle.
  ///
  /// In en, this message translates to:
  /// **'Careful'**
  String get paceCarefulTitle;

  /// No description provided for @paceEveryNSeconds.
  ///
  /// In en, this message translates to:
  /// **'1 every {seconds} s'**
  String paceEveryNSeconds(int seconds);

  /// No description provided for @paceOnePerMinute.
  ///
  /// In en, this message translates to:
  /// **'1 a minute'**
  String get paceOnePerMinute;

  /// No description provided for @paceWithEstimate.
  ///
  /// In en, this message translates to:
  /// **'{pace} · {estimate}'**
  String paceWithEstimate(String pace, String estimate);

  /// No description provided for @aboutSeconds.
  ///
  /// In en, this message translates to:
  /// **'about {seconds} s'**
  String aboutSeconds(int seconds);

  /// No description provided for @aboutMinutes.
  ///
  /// In en, this message translates to:
  /// **'about {minutes} min'**
  String aboutMinutes(int minutes);

  /// No description provided for @aboutSecondsLeft.
  ///
  /// In en, this message translates to:
  /// **'About {seconds} seconds left'**
  String aboutSecondsLeft(int seconds);

  /// No description provided for @aboutMinutesLeft.
  ///
  /// In en, this message translates to:
  /// **'About {minutes} min left'**
  String aboutMinutesLeft(int minutes);

  /// No description provided for @confirmBulkSendTitle.
  ///
  /// In en, this message translates to:
  /// **'Send {count} messages from {sim}?'**
  String confirmBulkSendTitle(int count, String sim);

  /// No description provided for @confirmBulkSendBody.
  ///
  /// In en, this message translates to:
  /// **'This takes {estimate} and uses your SMS plan.'**
  String confirmBulkSendBody(String estimate);

  /// No description provided for @sendAction.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendAction;

  /// No description provided for @discardDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this message?'**
  String get discardDraftTitle;

  /// No description provided for @discardDraftBody.
  ///
  /// In en, this message translates to:
  /// **'Your message will not be saved.'**
  String get discardDraftBody;

  /// No description provided for @discardAction.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardAction;

  /// No description provided for @keepEditingAction.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditingAction;

  /// No description provided for @defaultSimLabel.
  ///
  /// In en, this message translates to:
  /// **'your SIM'**
  String get defaultSimLabel;

  /// No description provided for @campaignStateScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled for {time}'**
  String campaignStateScheduled(String time);

  /// No description provided for @campaignStateSending.
  ///
  /// In en, this message translates to:
  /// **'Sending · {done} of {total}'**
  String campaignStateSending(int done, int total);

  /// No description provided for @campaignStatePaused.
  ///
  /// In en, this message translates to:
  /// **'Paused · {done} of {total}'**
  String campaignStatePaused(int done, int total);

  /// No description provided for @campaignStateDone.
  ///
  /// In en, this message translates to:
  /// **'Done · {sent} sent'**
  String campaignStateDone(int sent);

  /// No description provided for @campaignStateDoneWithFailed.
  ///
  /// In en, this message translates to:
  /// **'Done · {sent} sent · {failed} not sent'**
  String campaignStateDoneWithFailed(int sent, int failed);

  /// No description provided for @campaignStateStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped · {done} of {total}'**
  String campaignStateStopped(int done, int total);

  /// No description provided for @campaignPauseAction.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get campaignPauseAction;

  /// No description provided for @campaignResumeAction.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get campaignResumeAction;

  /// No description provided for @campaignStopAction.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get campaignStopAction;

  /// No description provided for @campaignStopConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop this campaign?'**
  String get campaignStopConfirmTitle;

  /// No description provided for @campaignStopConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Messages already sent cannot be undone. Waiting messages will be cancelled.'**
  String get campaignStopConfirmBody;

  /// No description provided for @campaignRetryNNotSent.
  ///
  /// In en, this message translates to:
  /// **'Retry {count} not sent'**
  String campaignRetryNNotSent(int count);

  /// No description provided for @campaignStatSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get campaignStatSent;

  /// No description provided for @campaignStatFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get campaignStatFailed;

  /// No description provided for @campaignStatSending.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get campaignStatSending;

  /// No description provided for @campaignStatWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get campaignStatWaiting;

  /// No description provided for @campaignSectionRecipients.
  ///
  /// In en, this message translates to:
  /// **'Recipients'**
  String get campaignSectionRecipients;

  /// No description provided for @campaignMenuDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get campaignMenuDuplicate;

  /// No description provided for @campaignMenuExport.
  ///
  /// In en, this message translates to:
  /// **'Export results'**
  String get campaignMenuExport;

  /// No description provided for @campaignMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get campaignMenuDelete;

  /// No description provided for @campaignExportedSnack.
  ///
  /// In en, this message translates to:
  /// **'Results ready to share'**
  String get campaignExportedSnack;

  /// No description provided for @statusSending.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get statusSending;

  /// No description provided for @statusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get statusWaiting;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get statusSkipped;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @tapToRetryMeta.
  ///
  /// In en, this message translates to:
  /// **'{reason} · tap to retry'**
  String tapToRetryMeta(String reason);

  /// No description provided for @sentFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get sentFilterAll;

  /// No description provided for @sentFilterDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get sentFilterDelivered;

  /// No description provided for @sentFilterSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sentFilterSent;

  /// No description provided for @sentFilterNotSent.
  ///
  /// In en, this message translates to:
  /// **'Not sent'**
  String get sentFilterNotSent;

  /// No description provided for @sentListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sent messages yet'**
  String get sentListEmpty;

  /// No description provided for @templateNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Template name'**
  String get templateNameLabel;

  /// No description provided for @templateNameHint.
  ///
  /// In en, this message translates to:
  /// **'Payment reminder'**
  String get templateNameHint;

  /// No description provided for @templateBodyLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get templateBodyLabel;

  /// No description provided for @templateSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save template'**
  String get templateSaveAction;

  /// No description provided for @templateDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete template'**
  String get templateDeleteAction;

  /// No description provided for @templateSamplePreview.
  ///
  /// In en, this message translates to:
  /// **'Sample preview'**
  String get templateSamplePreview;

  /// No description provided for @templateValidationName.
  ///
  /// In en, this message translates to:
  /// **'Add a template name'**
  String get templateValidationName;

  /// No description provided for @templateValidationBody.
  ///
  /// In en, this message translates to:
  /// **'Add a message'**
  String get templateValidationBody;

  /// No description provided for @recipientPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose recipients'**
  String get recipientPickerTitle;

  /// No description provided for @recipientPickerDone.
  ///
  /// In en, this message translates to:
  /// **'Done ({count})'**
  String recipientPickerDone(int count);

  /// No description provided for @setupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A few permissions let PocketCRM log your calls and send on time, even when the app is closed.'**
  String get setupSubtitle;

  /// No description provided for @setupRowContactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get setupRowContactsTitle;

  /// No description provided for @setupRowContactsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shows your people and matches calls to them'**
  String get setupRowContactsSubtitle;

  /// No description provided for @setupRowCallsSmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Calls and messages'**
  String get setupRowCallsSmsTitle;

  /// No description provided for @setupRowCallsSmsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Builds each person\'s history on this phone'**
  String get setupRowCallsSmsSubtitle;

  /// No description provided for @setupRowAlarmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alarms and reminders'**
  String get setupRowAlarmsTitle;

  /// No description provided for @setupRowAlarmsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sends scheduled messages at the exact time'**
  String get setupRowAlarmsSubtitle;

  /// No description provided for @setupRowAlarmsFallback.
  ///
  /// In en, this message translates to:
  /// **'Scheduled messages may be a few minutes late'**
  String get setupRowAlarmsFallback;

  /// No description provided for @setupRowBatteryTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get setupRowBatteryTitle;

  /// No description provided for @setupRowBatterySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stops Android pausing sends when the app is closed'**
  String get setupRowBatterySubtitle;

  /// No description provided for @setupRowNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get setupRowNotificationsTitle;

  /// No description provided for @setupRowNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow-up reminders and send results'**
  String get setupRowNotificationsSubtitle;

  /// No description provided for @setupAllowedLabel.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get setupAllowedLabel;

  /// No description provided for @setupAllowAction.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get setupAllowAction;

  /// No description provided for @setupOpenSettingsAction.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get setupOpenSettingsAction;

  /// No description provided for @setupPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on this phone. PocketCRM has no internet access.'**
  String get setupPrivacyNote;

  /// No description provided for @setupSyncingContacts.
  ///
  /// In en, this message translates to:
  /// **'Reading your contacts...'**
  String get setupSyncingContacts;

  /// No description provided for @setupSyncingHistory.
  ///
  /// In en, this message translates to:
  /// **'Reading your call and message history...'**
  String get setupSyncingHistory;

  /// No description provided for @setupSyncProgressCounts.
  ///
  /// In en, this message translates to:
  /// **'Synced {contacts} people · {calls} calls · {sms} messages'**
  String setupSyncProgressCounts(int contacts, int calls, int sms);

  /// No description provided for @restrictedSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow restricted settings'**
  String get restrictedSettingsTitle;

  /// No description provided for @restrictedSettingsStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Tap the three dots at the top right.'**
  String get restrictedSettingsStep1;

  /// No description provided for @restrictedSettingsStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Tap \"Allow restricted settings\" and confirm with your screen lock.'**
  String get restrictedSettingsStep2;

  /// No description provided for @restrictedSettingsStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Come back here and tap Allow again.'**
  String get restrictedSettingsStep3;

  /// No description provided for @restrictedSettingsFallback.
  ///
  /// In en, this message translates to:
  /// **'No such option? Open Permissions on that page and allow SMS and Call logs there.'**
  String get restrictedSettingsFallback;

  /// No description provided for @restrictedSettingsOpenAppInfo.
  ///
  /// In en, this message translates to:
  /// **'Open app info'**
  String get restrictedSettingsOpenAppInfo;

  /// No description provided for @oemBatteryXiaomi.
  ///
  /// In en, this message translates to:
  /// **'Turn on Autostart and set Battery saver to No restrictions'**
  String get oemBatteryXiaomi;

  /// No description provided for @oemBatteryOppo.
  ///
  /// In en, this message translates to:
  /// **'Allow background activity and Auto-launch'**
  String get oemBatteryOppo;

  /// No description provided for @oemBatteryVivo.
  ///
  /// In en, this message translates to:
  /// **'Allow High background power consumption and Autostart'**
  String get oemBatteryVivo;

  /// No description provided for @oemBatterySamsung.
  ///
  /// In en, this message translates to:
  /// **'Add PocketCRM to Never sleeping apps'**
  String get oemBatterySamsung;

  /// No description provided for @oemBatteryTecno.
  ///
  /// In en, this message translates to:
  /// **'Allow Auto-start in Phone Master'**
  String get oemBatteryTecno;

  /// No description provided for @oemBatteryHuawei.
  ///
  /// In en, this message translates to:
  /// **'Set App launch to Manage manually and allow all three switches'**
  String get oemBatteryHuawei;

  /// No description provided for @reliabilitySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Check reliability'**
  String get reliabilitySectionTitle;

  /// No description provided for @reliabilitySendTestAction.
  ///
  /// In en, this message translates to:
  /// **'Send a test message'**
  String get reliabilitySendTestAction;

  /// No description provided for @reliabilityPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Your phone number'**
  String get reliabilityPhoneLabel;

  /// No description provided for @reliabilityPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your own number'**
  String get reliabilityPhoneHint;

  /// No description provided for @reliabilityScheduledNotice.
  ///
  /// In en, this message translates to:
  /// **'Close the app and lock your phone. The message should arrive at {time}.'**
  String reliabilityScheduledNotice(String time);

  /// No description provided for @reliabilityTestMessageBody.
  ///
  /// In en, this message translates to:
  /// **'PocketCRM test, scheduled for {time}'**
  String reliabilityTestMessageBody(String time);

  /// No description provided for @reliabilityResultOnTime.
  ///
  /// In en, this message translates to:
  /// **'Arrived on time'**
  String get reliabilityResultOnTime;

  /// No description provided for @reliabilityResultLate.
  ///
  /// In en, this message translates to:
  /// **'Arrived {minutes} minutes late: allow Alarms and reminders, and check the Battery step'**
  String reliabilityResultLate(int minutes);

  /// No description provided for @reliabilityResultFailed.
  ///
  /// In en, this message translates to:
  /// **'Not sent: {reason}'**
  String reliabilityResultFailed(String reason);

  /// No description provided for @finishSetupBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get finishSetupBannerTitle;

  /// No description provided for @finishSetupBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow contacts, calls and messages to log history automatically'**
  String get finishSetupBannerSubtitle;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsSectionAfterCalls.
  ///
  /// In en, this message translates to:
  /// **'After calls'**
  String get settingsSectionAfterCalls;

  /// No description provided for @settingsSectionReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsSectionReminders;

  /// No description provided for @settingsSectionMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get settingsSectionMessages;

  /// No description provided for @settingsSectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsSectionData;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get settingsYourName;

  /// No description provided for @settingsNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get settingsNotSet;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @settingsPhoneRegion.
  ///
  /// In en, this message translates to:
  /// **'Region for phone numbers'**
  String get settingsPhoneRegion;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageBengali.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get settingsLanguageBengali;

  /// No description provided for @settingsAfterCallPrompt.
  ///
  /// In en, this message translates to:
  /// **'Ask for a note'**
  String get settingsAfterCallPrompt;

  /// No description provided for @settingsAfterCallAll.
  ///
  /// In en, this message translates to:
  /// **'All saved people'**
  String get settingsAfterCallAll;

  /// No description provided for @settingsAfterCallStarred.
  ///
  /// In en, this message translates to:
  /// **'Starred only'**
  String get settingsAfterCallStarred;

  /// No description provided for @settingsAfterCallNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get settingsAfterCallNever;

  /// No description provided for @settingsMorningSummary.
  ///
  /// In en, this message translates to:
  /// **'Morning summary'**
  String get settingsMorningSummary;

  /// No description provided for @settingsReconnectNudges.
  ///
  /// In en, this message translates to:
  /// **'Reconnect nudges'**
  String get settingsReconnectNudges;

  /// No description provided for @settingsOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settingsOn;

  /// No description provided for @settingsOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsOff;

  /// No description provided for @settingsDefaultPace.
  ///
  /// In en, this message translates to:
  /// **'Default pace'**
  String get settingsDefaultPace;

  /// No description provided for @settingsSendWindow.
  ///
  /// In en, this message translates to:
  /// **'Send window'**
  String get settingsSendWindow;

  /// No description provided for @settingsOptOutWords.
  ///
  /// In en, this message translates to:
  /// **'Opt-out words'**
  String get settingsOptOutWords;

  /// No description provided for @settingsSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get settingsSyncNow;

  /// No description provided for @settingsSyncNever.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get settingsSyncNever;

  /// No description provided for @settingsSyncComplete.
  ///
  /// In en, this message translates to:
  /// **'Sync complete'**
  String get settingsSyncComplete;

  /// No description provided for @settingsCheckSetup.
  ///
  /// In en, this message translates to:
  /// **'Check setup'**
  String get settingsCheckSetup;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsLicences.
  ///
  /// In en, this message translates to:
  /// **'Licences'**
  String get settingsLicences;

  /// No description provided for @settingsNoInternetStatement.
  ///
  /// In en, this message translates to:
  /// **'PocketCRM cannot connect to the internet.'**
  String get settingsNoInternetStatement;
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
