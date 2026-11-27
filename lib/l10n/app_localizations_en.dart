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
}
