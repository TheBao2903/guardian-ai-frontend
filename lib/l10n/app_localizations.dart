import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// Generic cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic confirm button label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Generic save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Generic retry button label
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// Generic delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Generic close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Generic continue button label
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// Generic back button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Generic edit button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Bottom nav Home label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav SOS label
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get navSos;

  /// Bottom nav Safety Check label
  ///
  /// In en, this message translates to:
  /// **'Safety Check'**
  String get navSafetyCheck;

  /// Bottom nav Contacts label
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get navContacts;

  /// Bottom nav Profile label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Guardian AI'**
  String get homeGreeting;

  /// No description provided for @homeStatusSafe.
  ///
  /// In en, this message translates to:
  /// **'You are safe'**
  String get homeStatusSafe;

  /// No description provided for @homeStatusSafeDesc.
  ///
  /// In en, this message translates to:
  /// **'Active monitoring enabled and ready'**
  String get homeStatusSafeDesc;

  /// No description provided for @homeStatusWarning.
  ///
  /// In en, this message translates to:
  /// **'Attention needed'**
  String get homeStatusWarning;

  /// No description provided for @homeStatusEmergency.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY ACTIVE'**
  String get homeStatusEmergency;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Safety Tools'**
  String get homeQuickActions;

  /// No description provided for @homeSirenAction.
  ///
  /// In en, this message translates to:
  /// **'Siren Alarm'**
  String get homeSirenAction;

  /// No description provided for @homeStrobeAction.
  ///
  /// In en, this message translates to:
  /// **'Strobe Light'**
  String get homeStrobeAction;

  /// No description provided for @homeCallPoliceAction.
  ///
  /// In en, this message translates to:
  /// **'Call 113'**
  String get homeCallPoliceAction;

  /// No description provided for @homeSosHoldHint.
  ///
  /// In en, this message translates to:
  /// **'Hold for 3 seconds to trigger SOS'**
  String get homeSosHoldHint;

  /// No description provided for @sosTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency SOS'**
  String get sosTitle;

  /// No description provided for @sosActivate.
  ///
  /// In en, this message translates to:
  /// **'ACTIVATE SOS'**
  String get sosActivate;

  /// No description provided for @sosActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'SOS IS ACTIVE'**
  String get sosActiveTitle;

  /// No description provided for @sosActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sending live location and alerting emergency contacts'**
  String get sosActiveSubtitle;

  /// No description provided for @sosStop.
  ///
  /// In en, this message translates to:
  /// **'STOP SOS'**
  String get sosStop;

  /// No description provided for @sosCallingHelp.
  ///
  /// In en, this message translates to:
  /// **'Contacting emergency services...'**
  String get sosCallingHelp;

  /// No description provided for @sosSharingLocation.
  ///
  /// In en, this message translates to:
  /// **'Live GPS sharing is active'**
  String get sosSharingLocation;

  /// No description provided for @sosStopConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop Emergency SOS?'**
  String get sosStopConfirmTitle;

  /// No description provided for @sosStopConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to stop the SOS alert? Your emergency contacts will be notified that you are safe.'**
  String get sosStopConfirmDesc;

  /// No description provided for @sosEnterPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN to cancel SOS'**
  String get sosEnterPinTitle;

  /// No description provided for @sosEnterPinDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your 4-digit PIN to stop the alert'**
  String get sosEnterPinDesc;

  /// No description provided for @sosIncorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Please try again.'**
  String get sosIncorrectPin;

  /// No description provided for @safetyCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety Check'**
  String get safetyCheckTitle;

  /// No description provided for @safetyCheckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a timer and check in before it expires. If missed, SOS will automatically trigger.'**
  String get safetyCheckSubtitle;

  /// No description provided for @safetyCheckStart.
  ///
  /// In en, this message translates to:
  /// **'Start Timer'**
  String get safetyCheckStart;

  /// No description provided for @safetyCheckSafeConfirm.
  ///
  /// In en, this message translates to:
  /// **'I\'m Safe'**
  String get safetyCheckSafeConfirm;

  /// No description provided for @safetyCheckExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Check-in Expiring Soon'**
  String get safetyCheckExpiringSoon;

  /// No description provided for @safetyCheckMissedAlert.
  ///
  /// In en, this message translates to:
  /// **'Check-in Missed - SOS Triggered'**
  String get safetyCheckMissedAlert;

  /// No description provided for @safetyCheckRemainingTime.
  ///
  /// In en, this message translates to:
  /// **'Remaining Time'**
  String get safetyCheckRemainingTime;

  /// Remaining minutes for safety check countdown
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes remaining'**
  String safetyCheckMinutesRemaining(int minutes);

  /// No description provided for @safetyCheckTemplatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Templates'**
  String get safetyCheckTemplatesTitle;

  /// No description provided for @customDuration.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customDuration;

  /// No description provided for @customMinutesPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter minutes'**
  String get customMinutesPrompt;

  /// No description provided for @contactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Guardian Circle'**
  String get contactsTitle;

  /// No description provided for @contactsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Up to 10 trusted contacts who receive instant alerts via App & Telegram'**
  String get contactsSubtitle;

  /// No description provided for @contactsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get contactsAdd;

  /// No description provided for @contactsConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get contactsConfirmed;

  /// No description provided for @contactsPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Telegram link'**
  String get contactsPending;

  /// No description provided for @contactsLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum 10 emergency contacts reached'**
  String get contactsLimitReached;

  /// No description provided for @contactsRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this contact from your emergency circle?'**
  String get contactsRemoveConfirm;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileTitle;

  /// No description provided for @medicalProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical Profile'**
  String get medicalProfileTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageVi.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get settingsLanguageVi;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsSystemTheme.
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get settingsSystemTheme;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsLogout;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network unavailable. Please check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to determine your GPS location.'**
  String get errorLocationUnavailable;

  /// No description provided for @errorPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission required to perform this action.'**
  String get errorPermissionRequired;

  /// No description provided for @errorTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get errorTryAgain;

  /// No description provided for @profileLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your profile...'**
  String get profileLoading;

  /// No description provided for @profilePersonalTab.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get profilePersonalTab;

  /// No description provided for @profileMedicalTab.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get profileMedicalTab;

  /// No description provided for @profileSettingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettingsTab;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @notUpdated.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notUpdated;

  /// No description provided for @profileTelegramPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal Telegram Chat ID'**
  String get profileTelegramPersonal;

  /// No description provided for @profileTelegramUnlinked.
  ///
  /// In en, this message translates to:
  /// **'Not linked'**
  String get profileTelegramUnlinked;

  /// No description provided for @profileEditPersonal.
  ///
  /// In en, this message translates to:
  /// **'Edit personal information'**
  String get profileEditPersonal;

  /// No description provided for @profileTestTelegramTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Telegram connection'**
  String get profileTestTelegramTitle;

  /// No description provided for @profileTestTelegramDescription.
  ///
  /// In en, this message translates to:
  /// **'Send a test alert to check that the Telegram bot can deliver emergency notifications.'**
  String get profileTestTelegramDescription;

  /// No description provided for @profileTelegramBot.
  ///
  /// In en, this message translates to:
  /// **'🤖 Alert bot: @GuardianAINotiBot'**
  String get profileTelegramBot;

  /// No description provided for @profileTelegramSetupOne.
  ///
  /// In en, this message translates to:
  /// **'1. Open @GuardianAINotiBot, tap START (or type /start), then send \"hello\" to connect.\n'**
  String get profileTelegramSetupOne;

  /// No description provided for @profileTelegramSetupTwo.
  ///
  /// In en, this message translates to:
  /// **'2. Use @userinfobot to find your and your contacts\' numeric Chat IDs.'**
  String get profileTelegramSetupTwo;

  /// No description provided for @profileTestTelegramAction.
  ///
  /// In en, this message translates to:
  /// **'🔔 Send a Telegram test alert'**
  String get profileTestTelegramAction;

  /// No description provided for @medicalLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical profile is locked'**
  String get medicalLockedTitle;

  /// No description provided for @medicalLockedDescription.
  ///
  /// In en, this message translates to:
  /// **'Medical information is sensitive personal data under Vietnam\'s Decree 13/2023/ND-CP. Enter your account\'s 4-digit PIN to view or edit it.'**
  String get medicalLockedDescription;

  /// No description provided for @medicalUnlockAction.
  ///
  /// In en, this message translates to:
  /// **'🔓 Unlock with your 4-digit PIN'**
  String get medicalUnlockAction;

  /// No description provided for @medicalInitialHint.
  ///
  /// In en, this message translates to:
  /// **'You can enter your initial medical information without unlocking. After saving, this section is automatically locked.'**
  String get medicalInitialHint;

  /// No description provided for @medicalLockNow.
  ///
  /// In en, this message translates to:
  /// **'Lock now'**
  String get medicalLockNow;

  /// No description provided for @medicalLockedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Medical profile locked'**
  String get medicalLockedSuccess;

  /// No description provided for @editInformation.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editInformation;

  /// No description provided for @enterInformation.
  ///
  /// In en, this message translates to:
  /// **'Add information'**
  String get enterInformation;

  /// No description provided for @medicalBloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood type'**
  String get medicalBloodType;

  /// No description provided for @medicalAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get medicalAllergies;

  /// No description provided for @medicalNotes.
  ///
  /// In en, this message translates to:
  /// **'Medical notes and conditions'**
  String get medicalNotes;

  /// No description provided for @medicalSosHint.
  ///
  /// In en, this message translates to:
  /// **'This medical information is included in SOS messages to your emergency contacts and responders.'**
  String get medicalSosHint;

  /// No description provided for @settingsSafePinTitle.
  ///
  /// In en, this message translates to:
  /// **'4-digit PIN to stop SOS'**
  String get settingsSafePinTitle;

  /// No description provided for @settingsSafePinSet.
  ///
  /// In en, this message translates to:
  /// **'Security PIN configured (4 digits)'**
  String get settingsSafePinSet;

  /// No description provided for @notConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get notConfigured;

  /// No description provided for @settingsChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get settingsChangePin;

  /// No description provided for @settingsDuressPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Duress PIN'**
  String get settingsDuressPinTitle;

  /// No description provided for @settingsDuressPinSet.
  ///
  /// In en, this message translates to:
  /// **'Duress PIN enabled (4 digits)'**
  String get settingsDuressPinSet;

  /// No description provided for @notEnabled.
  ///
  /// In en, this message translates to:
  /// **'Not enabled'**
  String get notEnabled;

  /// No description provided for @settingsChangeCode.
  ///
  /// In en, this message translates to:
  /// **'Change code'**
  String get settingsChangeCode;

  /// No description provided for @settingsDuressDescription.
  ///
  /// In en, this message translates to:
  /// **'If someone forces you to stop SOS, enter this code. The app silences the alarm while discreetly alerting your emergency contacts through Telegram.'**
  String get settingsDuressDescription;

  /// No description provided for @settingsPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Account password'**
  String get settingsPasswordTitle;

  /// No description provided for @settingsPasswordSet.
  ///
  /// In en, this message translates to:
  /// **'Account password configured'**
  String get settingsPasswordSet;

  /// No description provided for @changeAction.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeAction;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsLight.
  ///
  /// In en, this message translates to:
  /// **'Light (default)'**
  String get settingsLight;

  /// No description provided for @settingsDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsDark;

  /// No description provided for @settingsLogoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsLogoutAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @fullNameExample.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get fullNameExample;

  /// No description provided for @telegramNumericId.
  ///
  /// In en, this message translates to:
  /// **'Telegram Chat ID (numeric)'**
  String get telegramNumericId;

  /// No description provided for @telegramIdExample.
  ///
  /// In en, this message translates to:
  /// **'Example: 628392102'**
  String get telegramIdExample;

  /// No description provided for @telegramIdHint.
  ///
  /// In en, this message translates to:
  /// **'💡 Get your numeric ID from @userinfobot on Telegram.'**
  String get telegramIdHint;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get nameRequired;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdateSuccess;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed. Please try again'**
  String get profileUpdateFailed;

  /// No description provided for @telegramTestOptions.
  ///
  /// In en, this message translates to:
  /// **'Telegram test recipients'**
  String get telegramTestOptions;

  /// No description provided for @telegramTestChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose who receives a test alert from @GuardianAINotiBot:'**
  String get telegramTestChoose;

  /// No description provided for @telegramTestSelf.
  ///
  /// In en, this message translates to:
  /// **'🎯 Only my Telegram account'**
  String get telegramTestSelf;

  /// No description provided for @telegramNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Telegram ID not configured'**
  String get telegramNotConfigured;

  /// No description provided for @telegramTestEveryone.
  ///
  /// In en, this message translates to:
  /// **'👥 Me and all Guardian Circle contacts'**
  String get telegramTestEveryone;

  /// No description provided for @telegramTestContacts.
  ///
  /// In en, this message translates to:
  /// **'🛡️ Only my emergency contacts'**
  String get telegramTestContacts;

  /// No description provided for @telegramChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking Telegram connection...'**
  String get telegramChecking;

  /// No description provided for @telegramSending.
  ///
  /// In en, this message translates to:
  /// **'Sending through @GuardianAINotiBot...'**
  String get telegramSending;

  /// No description provided for @telegramRecipientHint.
  ///
  /// In en, this message translates to:
  /// **'💡 Recipients must first open @GuardianAINotiBot, tap /start and send \"hello\".'**
  String get telegramRecipientHint;

  /// No description provided for @telegramChatNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Telegram Chat ID not configured'**
  String get telegramChatNotConfigured;

  /// No description provided for @sessionExpiredHint.
  ///
  /// In en, this message translates to:
  /// **'Session error. Please sign out and sign in again'**
  String get sessionExpiredHint;

  /// No description provided for @telegramNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with @GuardianAINotiBot first'**
  String get telegramNotStarted;

  /// No description provided for @medicalEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit emergency medical profile'**
  String get medicalEditTitle;

  /// No description provided for @medicalAllergiesExample.
  ///
  /// In en, this message translates to:
  /// **'Penicillin, aspirin, pollen...'**
  String get medicalAllergiesExample;

  /// No description provided for @medicalNotesExample.
  ///
  /// In en, this message translates to:
  /// **'Asthma, medication you carry...'**
  String get medicalNotesExample;

  /// No description provided for @medicalSave.
  ///
  /// In en, this message translates to:
  /// **'Save medical profile'**
  String get medicalSave;

  /// No description provided for @medicalSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Medical profile updated successfully'**
  String get medicalSaveSuccess;

  /// No description provided for @medicalUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock medical profile'**
  String get medicalUnlockTitle;

  /// No description provided for @medicalEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your current 4-digit safety PIN to view your medical information:'**
  String get medicalEnterPin;

  /// No description provided for @medicalUnlockedSuccess.
  ///
  /// In en, this message translates to:
  /// **'🔓 Medical profile unlocked'**
  String get medicalUnlockedSuccess;

  /// No description provided for @pinVerifyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify PIN'**
  String get pinVerifyUnavailable;

  /// No description provided for @unlockAction.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockAction;

  /// No description provided for @pinChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change your 4-digit SOS PIN'**
  String get pinChangeTitle;

  /// No description provided for @pinCurrentHint.
  ///
  /// In en, this message translates to:
  /// **'For your security, enter your current PIN:'**
  String get pinCurrentHint;

  /// No description provided for @pinCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current PIN'**
  String get pinCurrent;

  /// No description provided for @pinNew.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get pinNew;

  /// No description provided for @pinConfirmNew.
  ///
  /// In en, this message translates to:
  /// **'Confirm new PIN'**
  String get pinConfirmNew;

  /// No description provided for @pinCurrentIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current PIN is incorrect'**
  String get pinCurrentIncorrect;

  /// No description provided for @pinFourDigits.
  ///
  /// In en, this message translates to:
  /// **'PIN must contain exactly 4 digits'**
  String get pinFourDigits;

  /// No description provided for @pinConfirmationMismatch.
  ///
  /// In en, this message translates to:
  /// **'New PIN and confirmation do not match'**
  String get pinConfirmationMismatch;

  /// No description provided for @pinMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'New PIN must differ from your current PIN'**
  String get pinMustDiffer;

  /// No description provided for @pinUpdateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to update PIN on the server'**
  String get pinUpdateUnavailable;

  /// No description provided for @pinUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'SOS PIN changed successfully'**
  String get pinUpdateSuccess;

  /// No description provided for @pinSave.
  ///
  /// In en, this message translates to:
  /// **'Save PIN'**
  String get pinSave;

  /// No description provided for @duressChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change duress PIN'**
  String get duressChangeTitle;

  /// No description provided for @duressChangeDescription.
  ///
  /// In en, this message translates to:
  /// **'This code silences the alarm while discreetly sending an emergency alert to your contacts.\n\n'**
  String get duressChangeDescription;

  /// No description provided for @duressCurrentHint.
  ///
  /// In en, this message translates to:
  /// **'For your security, enter your current duress PIN:'**
  String get duressCurrentHint;

  /// No description provided for @duressCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current duress PIN'**
  String get duressCurrent;

  /// No description provided for @duressNew.
  ///
  /// In en, this message translates to:
  /// **'New duress PIN'**
  String get duressNew;

  /// No description provided for @duressConfirmNew.
  ///
  /// In en, this message translates to:
  /// **'Confirm new duress PIN'**
  String get duressConfirmNew;

  /// No description provided for @duressCurrentIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current duress PIN is incorrect'**
  String get duressCurrentIncorrect;

  /// No description provided for @duressUpdateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to update duress PIN. Check your connection and try again.'**
  String get duressUpdateUnavailable;

  /// No description provided for @duressUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Duress PIN changed successfully'**
  String get duressUpdateSuccess;

  /// No description provided for @saveCode.
  ///
  /// In en, this message translates to:
  /// **'Save code'**
  String get saveCode;

  /// No description provided for @passwordChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change account password'**
  String get passwordChangeTitle;

  /// No description provided for @passwordCurrentHint.
  ///
  /// In en, this message translates to:
  /// **'For your security, enter your current password:'**
  String get passwordCurrentHint;

  /// No description provided for @passwordCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get passwordCurrent;

  /// No description provided for @passwordNew.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get passwordNew;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters, including letters and digits'**
  String get passwordRequirements;

  /// No description provided for @passwordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get passwordConfirm;

  /// No description provided for @passwordRepeat.
  ///
  /// In en, this message translates to:
  /// **'Re-enter new password'**
  String get passwordRepeat;

  /// No description provided for @passwordCurrentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get passwordCurrentRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'New password must contain at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordLettersDigits.
  ///
  /// In en, this message translates to:
  /// **'New password must include both letters and digits'**
  String get passwordLettersDigits;

  /// No description provided for @passwordConfirmationMismatch.
  ///
  /// In en, this message translates to:
  /// **'New password and confirmation do not match'**
  String get passwordConfirmationMismatch;

  /// No description provided for @passwordMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'New password must differ from your current password'**
  String get passwordMustDiffer;

  /// No description provided for @passwordChange.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get passwordChange;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm sign out'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign out of Guardian AI on this device?'**
  String get logoutConfirmDescription;

  /// No description provided for @mobileDevice.
  ///
  /// In en, this message translates to:
  /// **'Mobile device'**
  String get mobileDevice;

  /// No description provided for @locationDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency location and trusted device'**
  String get locationDeviceTitle;

  /// No description provided for @locationAuthorized.
  ///
  /// In en, this message translates to:
  /// **'🟢 Location authorized — ready for one-tap SOS'**
  String get locationAuthorized;

  /// No description provided for @locationNotAuthorized.
  ///
  /// In en, this message translates to:
  /// **'🟠 Background location not authorized'**
  String get locationNotAuthorized;

  /// No description provided for @locationDeviceLabel.
  ///
  /// In en, this message translates to:
  /// **'Device:'**
  String get locationDeviceLabel;

  /// No description provided for @locationOsLabel.
  ///
  /// In en, this message translates to:
  /// **'Operating system:'**
  String get locationOsLabel;

  /// No description provided for @locationLastKnown.
  ///
  /// In en, this message translates to:
  /// **'Last checked location:'**
  String get locationLastKnown;

  /// No description provided for @locationOpenMaps.
  ///
  /// In en, this message translates to:
  /// **'🗺️ Open in Google Maps'**
  String get locationOpenMaps;

  /// No description provided for @locationFinding.
  ///
  /// In en, this message translates to:
  /// **'Getting your location...'**
  String get locationFinding;

  /// No description provided for @locationUpdate.
  ///
  /// In en, this message translates to:
  /// **'🔄 Update and check location'**
  String get locationUpdate;

  /// No description provided for @locationAuthorize.
  ///
  /// In en, this message translates to:
  /// **'⚡ Authorize emergency location'**
  String get locationAuthorize;

  /// No description provided for @locationAuthorizeHint.
  ///
  /// In en, this message translates to:
  /// **'Authorize location access so SOS can share your location without asking again.'**
  String get locationAuthorizeHint;

  /// No description provided for @locationUnavailableDescription.
  ///
  /// In en, this message translates to:
  /// **'Unable to get your location. Enable location services and allow access in your browser or device settings.'**
  String get locationUnavailableDescription;

  /// No description provided for @homeCountdownActive.
  ///
  /// In en, this message translates to:
  /// **'SAFETY COUNTDOWN ACTIVE'**
  String get homeCountdownActive;

  /// No description provided for @runningStatus.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get runningStatus;

  /// No description provided for @homeProtectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Your safety timer is running. View the countdown or confirm you are safe.'**
  String get homeProtectionDescription;

  /// No description provided for @homeViewCountdown.
  ///
  /// In en, this message translates to:
  /// **'View countdown'**
  String get homeViewCountdown;

  /// No description provided for @contactsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No emergency contacts yet'**
  String get contactsEmptyTitle;

  /// No description provided for @contactsEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Add at least one trusted contact to receive emergency alerts.'**
  String get contactsEmptyDescription;

  /// No description provided for @contactsPriorityBadge.
  ///
  /// In en, this message translates to:
  /// **'#1 Priority contact'**
  String get contactsPriorityBadge;

  /// No description provided for @contactsTestCall.
  ///
  /// In en, this message translates to:
  /// **'Test call'**
  String get contactsTestCall;

  /// No description provided for @contactsSetPriority.
  ///
  /// In en, this message translates to:
  /// **'Set as priority contact #1'**
  String get contactsSetPriority;

  /// No description provided for @contactsAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a Guardian Circle contact'**
  String get contactsAddTitle;

  /// No description provided for @contactsFullName.
  ///
  /// In en, this message translates to:
  /// **'Contact name'**
  String get contactsFullName;

  /// No description provided for @contactsNameExample.
  ///
  /// In en, this message translates to:
  /// **'Example: parent, partner, friend...'**
  String get contactsNameExample;

  /// No description provided for @contactsTelegramLabel.
  ///
  /// In en, this message translates to:
  /// **'Telegram Chat ID (required)'**
  String get contactsTelegramLabel;

  /// No description provided for @contactsTelegramSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'How to receive Telegram alerts:'**
  String get contactsTelegramSetupTitle;

  /// No description provided for @contactsTelegramSetupOne.
  ///
  /// In en, this message translates to:
  /// **'1. Ask your contact to open @GuardianAINotiBot on Telegram (t.me/GuardianAINotiBot).\n'**
  String get contactsTelegramSetupOne;

  /// No description provided for @contactsTelegramSetupTwo.
  ///
  /// In en, this message translates to:
  /// **'2. Tap START (or type /start), then send a message such as \"hello\" to connect.\n'**
  String get contactsTelegramSetupTwo;

  /// No description provided for @contactsTelegramSetupThree.
  ///
  /// In en, this message translates to:
  /// **'3. Use @userinfobot to get your contact\'s numeric User ID and paste it into the Chat ID field above.'**
  String get contactsTelegramSetupThree;

  /// No description provided for @contactsTelegramNumericHint.
  ///
  /// In en, this message translates to:
  /// **'💡 The bot requires a numeric Chat ID; a Telegram @username will not work.'**
  String get contactsTelegramNumericHint;

  /// No description provided for @contactRelationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get contactRelationship;

  /// No description provided for @relationshipParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get relationshipParent;

  /// No description provided for @relationshipSpouse.
  ///
  /// In en, this message translates to:
  /// **'Spouse'**
  String get relationshipSpouse;

  /// No description provided for @relationshipSibling.
  ///
  /// In en, this message translates to:
  /// **'Sibling'**
  String get relationshipSibling;

  /// No description provided for @relationshipChild.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get relationshipChild;

  /// No description provided for @relationshipFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get relationshipFriend;

  /// No description provided for @relationshipColleague.
  ///
  /// In en, this message translates to:
  /// **'Colleague'**
  String get relationshipColleague;

  /// No description provided for @contactsOldPriorityHint.
  ///
  /// In en, this message translates to:
  /// **'The previous priority contact will move down'**
  String get contactsOldPriorityHint;

  /// No description provided for @contactsSave.
  ///
  /// In en, this message translates to:
  /// **'Save contact'**
  String get contactsSave;

  /// No description provided for @contactsNamePhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name and phone number'**
  String get contactsNamePhoneRequired;

  /// No description provided for @contactsInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit Vietnamese mobile number starting with 03, 05, 07, 08 or 09.'**
  String get contactsInvalidPhone;

  /// No description provided for @contactsInvalidTelegram.
  ///
  /// In en, this message translates to:
  /// **'Enter a numeric Telegram Chat ID with 6 to 14 digits.'**
  String get contactsInvalidTelegram;

  /// No description provided for @contactsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm removal'**
  String get contactsDeleteTitle;

  /// No description provided for @contactsPriorityMovedHint.
  ///
  /// In en, this message translates to:
  /// **'The previous priority contact will move to a lower position.'**
  String get contactsPriorityMovedHint;

  /// No description provided for @contactsPriorityFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to set priority contact'**
  String get contactsPriorityFailed;

  /// No description provided for @safetyExtendShort.
  ///
  /// In en, this message translates to:
  /// **'+15 min'**
  String get safetyExtendShort;

  /// No description provided for @safetyMicrophoneUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Microphone unavailable. Your safety timer is still running.'**
  String get safetyMicrophoneUnavailable;

  /// No description provided for @safetyExpiredDescription.
  ///
  /// In en, this message translates to:
  /// **'Time is up. Please confirm you are safe'**
  String get safetyExpiredDescription;

  /// No description provided for @safetyMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Active safety monitoring'**
  String get safetyMonitoring;

  /// No description provided for @safetyGracePeriod.
  ///
  /// In en, this message translates to:
  /// **'Grace period'**
  String get safetyGracePeriod;

  /// No description provided for @safetyConfirmed.
  ///
  /// In en, this message translates to:
  /// **'You have checked in safely'**
  String get safetyConfirmed;

  /// No description provided for @safetyExtendAction.
  ///
  /// In en, this message translates to:
  /// **'Extend by 15 minutes'**
  String get safetyExtendAction;

  /// No description provided for @safetyExtended.
  ///
  /// In en, this message translates to:
  /// **'Extended by 15 minutes'**
  String get safetyExtended;

  /// No description provided for @safetyCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel timer'**
  String get safetyCancelTitle;

  /// No description provided for @safetyCancelDescription.
  ///
  /// In en, this message translates to:
  /// **'End this safety timer?'**
  String get safetyCancelDescription;

  /// No description provided for @safetyCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Stop timer'**
  String get safetyCancelConfirm;

  /// No description provided for @safetyChooseScenario.
  ///
  /// In en, this message translates to:
  /// **'1. Choose a scenario'**
  String get safetyChooseScenario;

  /// No description provided for @safetyChooseDuration.
  ///
  /// In en, this message translates to:
  /// **'2. Choose a timer duration'**
  String get safetyChooseDuration;

  /// No description provided for @safetyDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration:'**
  String get safetyDurationLabel;

  /// No description provided for @safetyNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'3. Destination or companion notes (optional)'**
  String get safetyNotesLabel;

  /// No description provided for @safetyNotesExample.
  ///
  /// In en, this message translates to:
  /// **'Example: taxi plate 29A-12345, expected home by 22:30...'**
  String get safetyNotesExample;

  /// No description provided for @minutesUnit.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesUnit;

  /// No description provided for @sirenRunning.
  ///
  /// In en, this message translates to:
  /// **'Siren on...'**
  String get sirenRunning;

  /// No description provided for @strobeRunning.
  ///
  /// In en, this message translates to:
  /// **'Strobe on...'**
  String get strobeRunning;

  /// No description provided for @policeCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Call police on 113?'**
  String get policeCallTitle;

  /// No description provided for @policeCallDescription.
  ///
  /// In en, this message translates to:
  /// **'You are about to call Vietnam\'s police emergency number, 113.'**
  String get policeCallDescription;

  /// No description provided for @callNow.
  ///
  /// In en, this message translates to:
  /// **'Call now'**
  String get callNow;

  /// No description provided for @languageSaveError.
  ///
  /// In en, this message translates to:
  /// **'Unable to save your language. Please try again.'**
  String get languageSaveError;

  /// No description provided for @cancelShort.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelShort;

  /// No description provided for @contactsAlertDescription.
  ///
  /// In en, this message translates to:
  /// **'When SOS is activated or a Safety Check is missed, the app alerts your contacts through @GuardianAINotiBot and includes your location when available.'**
  String get contactsAlertDescription;

  /// No description provided for @relationshipOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get relationshipOther;

  /// No description provided for @sosNoRecipients.
  ///
  /// In en, this message translates to:
  /// **'No contacts are ready to receive Telegram alerts'**
  String get sosNoRecipients;

  /// No description provided for @sosSessionActive.
  ///
  /// In en, this message translates to:
  /// **'SOS is active'**
  String get sosSessionActive;

  /// No description provided for @sosLocationMissing.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get sosLocationMissing;

  /// No description provided for @sirenOffAction.
  ///
  /// In en, this message translates to:
  /// **'Turn siren off'**
  String get sirenOffAction;

  /// No description provided for @sirenOnAction.
  ///
  /// In en, this message translates to:
  /// **'Turn siren on'**
  String get sirenOnAction;

  /// No description provided for @strobeOffAction.
  ///
  /// In en, this message translates to:
  /// **'Turn strobe off'**
  String get strobeOffAction;

  /// No description provided for @strobeOnAction.
  ///
  /// In en, this message translates to:
  /// **'Turn strobe on'**
  String get strobeOnAction;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency contacts'**
  String get emergencyContacts;

  /// No description provided for @policeCallEmoji.
  ///
  /// In en, this message translates to:
  /// **'🚔 Call police 113'**
  String get policeCallEmoji;

  /// No description provided for @policeCallPhone.
  ///
  /// In en, this message translates to:
  /// **'📞 Call police 113'**
  String get policeCallPhone;

  /// No description provided for @primaryContact.
  ///
  /// In en, this message translates to:
  /// **'Priority contact #1'**
  String get primaryContact;

  /// No description provided for @callNowUpper.
  ///
  /// In en, this message translates to:
  /// **'CALL NOW'**
  String get callNowUpper;

  /// No description provided for @messageNowUpper.
  ///
  /// In en, this message translates to:
  /// **'SEND MESSAGE'**
  String get messageNowUpper;

  /// No description provided for @callAction.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callAction;

  /// No description provided for @messageAction.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageAction;

  /// No description provided for @sosCurrentPinHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your current 4-digit PIN to stop SOS'**
  String get sosCurrentPinHint;

  /// No description provided for @sosPinRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter all 4 PIN digits'**
  String get sosPinRequired;

  /// No description provided for @sosStoppedSuccess.
  ///
  /// In en, this message translates to:
  /// **'SOS has stopped. Your contacts have been notified that you are safe.'**
  String get sosStoppedSuccess;

  /// No description provided for @sosConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm SOS'**
  String get sosConfirmationTitle;

  /// No description provided for @screamDetected.
  ///
  /// In en, this message translates to:
  /// **'Screaming detected!'**
  String get screamDetected;

  /// No description provided for @sosCancelling.
  ///
  /// In en, this message translates to:
  /// **'Confirming cancellation…'**
  String get sosCancelling;

  /// No description provided for @sosSending.
  ///
  /// In en, this message translates to:
  /// **'Sending SOS to your contacts…'**
  String get sosSending;

  /// No description provided for @sosSendFailed.
  ///
  /// In en, this message translates to:
  /// **'SOS has not been sent yet'**
  String get sosSendFailed;

  /// No description provided for @sosWaitingServer.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the server to process SOS…'**
  String get sosWaitingServer;

  /// No description provided for @sosFalseAlarm.
  ///
  /// In en, this message translates to:
  /// **'FALSE ALARM'**
  String get sosFalseAlarm;

  /// No description provided for @sosActivateNow.
  ///
  /// In en, this message translates to:
  /// **'ACTIVATE SOS NOW'**
  String get sosActivateNow;

  /// No description provided for @sosRetry.
  ///
  /// In en, this message translates to:
  /// **'RETRY SOS'**
  String get sosRetry;

  /// No description provided for @sosPreparingTitle.
  ///
  /// In en, this message translates to:
  /// **'PREPARING TO SEND SOS'**
  String get sosPreparingTitle;

  /// No description provided for @sosCountdownDescription.
  ///
  /// In en, this message translates to:
  /// **'Your emergency contacts will receive an SOS alert and your available location after:'**
  String get sosCountdownDescription;

  /// No description provided for @sosCancelNow.
  ///
  /// In en, this message translates to:
  /// **'CANCEL ALERT NOW'**
  String get sosCancelNow;

  /// No description provided for @sosCancelledSuccess.
  ///
  /// In en, this message translates to:
  /// **'SOS activation cancelled'**
  String get sosCancelledSuccess;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'Proactive personal safety'**
  String get loginTagline;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get loginTitle;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginAction;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and password'**
  String get loginRequired;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'🔑 Forgot password?'**
  String get forgotPasswordLink;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginNoAccount;

  /// No description provided for @registerLink.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get registerLink;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your account email to receive a password reset link:'**
  String get forgotPasswordDescription;

  /// No description provided for @accountEmail.
  ///
  /// In en, this message translates to:
  /// **'Account email'**
  String get accountEmail;

  /// No description provided for @forgotPasswordSpamHint.
  ///
  /// In en, this message translates to:
  /// **'💡 Check your spam folder if the email does not arrive.'**
  String get forgotPasswordSpamHint;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get emailInvalid;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendRequest;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start protecting your safety'**
  String get registerSubtitle;

  /// No description provided for @registerName.
  ///
  /// In en, this message translates to:
  /// **'Full name *'**
  String get registerName;

  /// No description provided for @registerEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address *'**
  String get registerEmail;

  /// No description provided for @registerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password *'**
  String get registerPassword;

  /// No description provided for @registerPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get registerPasswordHint;

  /// No description provided for @registerPasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm password *'**
  String get registerPasswordConfirm;

  /// No description provided for @registerPasswordRepeat.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get registerPasswordRepeat;

  /// No description provided for @registerConsent.
  ///
  /// In en, this message translates to:
  /// **'I agree to Guardian AI\'s location and audio data privacy commitment under Vietnam\'s Decree 13/2023/ND-CP.'**
  String get registerConsent;

  /// No description provided for @registerAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerAction;

  /// No description provided for @registerRequired.
  ///
  /// In en, this message translates to:
  /// **'Please complete all required fields (*)'**
  String get registerRequired;

  /// No description provided for @registerInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get registerInvalidEmail;

  /// No description provided for @registerPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least 6 characters'**
  String get registerPasswordShort;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match. Please check them again'**
  String get registerPasswordMismatch;

  /// No description provided for @registerConsentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept the data privacy commitment'**
  String get registerConsentRequired;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get registerSuccess;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registerFailed;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerHaveAccount;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginLink;

  /// No description provided for @contactsAddCount.
  ///
  /// In en, this message translates to:
  /// **'Add contact ({count}/10)'**
  String contactsAddCount(int count);

  /// No description provided for @contactsCount.
  ///
  /// In en, this message translates to:
  /// **'{count}/10 contacts'**
  String contactsCount(int count);

  /// No description provided for @homeContactsReady.
  ///
  /// In en, this message translates to:
  /// **'{count}/10 contacts ready for Telegram alerts'**
  String homeContactsReady(int count);

  /// No description provided for @homeSessionRemaining.
  ///
  /// In en, this message translates to:
  /// **'Session \"{name}\": {remaining} remaining'**
  String homeSessionRemaining(String name, String remaining);

  /// No description provided for @minutesDuration.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesDuration(int minutes);

  /// No description provided for @customMinutesDuration.
  ///
  /// In en, this message translates to:
  /// **'Custom: {minutes}m'**
  String customMinutesDuration(int minutes);

  /// No description provided for @safetyStarted.
  ///
  /// In en, this message translates to:
  /// **'Your {minutes}-minute safety timer has started'**
  String safetyStarted(int minutes);

  /// No description provided for @safetyExtensionCount.
  ///
  /// In en, this message translates to:
  /// **'Extensions used: {count}/{total}'**
  String safetyExtensionCount(int count, int total);

  /// No description provided for @contactsAdded.
  ///
  /// In en, this message translates to:
  /// **'Added {name} to Guardian Circle'**
  String contactsAdded(String name);

  /// No description provided for @contactsAddedPriority.
  ///
  /// In en, this message translates to:
  /// **'Added {name} to Guardian Circle as priority contact #1'**
  String contactsAddedPriority(String name);

  /// No description provided for @contactsRemoveNamed.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from your emergency contacts?'**
  String contactsRemoveNamed(String name);

  /// No description provided for @contactsPriorityNamed.
  ///
  /// In en, this message translates to:
  /// **'Call {name} first in an emergency?'**
  String contactsPriorityNamed(String name);

  /// No description provided for @contactsPrioritySuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} is now priority contact #1'**
  String contactsPrioritySuccess(String name);

  /// No description provided for @profileSelf.
  ///
  /// In en, this message translates to:
  /// **'You ({name})'**
  String profileSelf(String name);

  /// No description provided for @profileTestEveryoneDetail.
  ///
  /// In en, this message translates to:
  /// **'Send to you and {count} contacts with Telegram IDs'**
  String profileTestEveryoneDetail(int count);

  /// No description provided for @profileTestContactsDetail.
  ///
  /// In en, this message translates to:
  /// **'Send a test alert to {count} emergency contacts'**
  String profileTestContactsDetail(int count);

  /// No description provided for @profileTestResults.
  ///
  /// In en, this message translates to:
  /// **'Result: {sent}/{total} recipients reached'**
  String profileTestResults(int sent, int total);

  /// No description provided for @profileTestMessage.
  ///
  /// In en, this message translates to:
  /// **'🔔 [Guardian AI - Test] This is a safety alert connection test from {name}. The connection is working.'**
  String profileTestMessage(String name);

  /// No description provided for @profileTestDelivered.
  ///
  /// In en, this message translates to:
  /// **'Message delivered (ID: {id})'**
  String profileTestDelivered(String id);

  /// No description provided for @locationNetworkLabel.
  ///
  /// In en, this message translates to:
  /// **'{coordinates} (network location)'**
  String locationNetworkLabel(String coordinates);

  /// No description provided for @locationGpsLabel.
  ///
  /// In en, this message translates to:
  /// **'{coordinates} (GPS accuracy ~{accuracy}m)'**
  String locationGpsLabel(String coordinates, String accuracy);

  /// No description provided for @locationNetworkSuccess.
  ///
  /// In en, this message translates to:
  /// **'Network location enabled and {device} registered!'**
  String locationNetworkSuccess(String device);

  /// No description provided for @locationGpsSuccess.
  ///
  /// In en, this message translates to:
  /// **'GPS enabled and {device} registered!'**
  String locationGpsSuccess(String device);

  /// No description provided for @sosAutoActivateSeconds.
  ///
  /// In en, this message translates to:
  /// **'Automatically activates in {seconds}s'**
  String sosAutoActivateSeconds(int seconds);

  /// No description provided for @sosDetectionType.
  ///
  /// In en, this message translates to:
  /// **'Type: {type} ({confidence}%)'**
  String sosDetectionType(String type, String confidence);

  /// No description provided for @sosDeliveredCount.
  ///
  /// In en, this message translates to:
  /// **'Telegram accepted {sent}/{total} alerts'**
  String sosDeliveredCount(int sent, int total);

  /// No description provided for @sosDeliveryFailedCount.
  ///
  /// In en, this message translates to:
  /// **'Sent {sent}/{total}; {failed} failed'**
  String sosDeliveryFailedCount(int sent, int total, int failed);

  /// No description provided for @sosDeliveryPendingCount.
  ///
  /// In en, this message translates to:
  /// **'Sending to contacts: {sent}/{total}'**
  String sosDeliveryPendingCount(int sent, int total);

  /// No description provided for @templateWalkHome.
  ///
  /// In en, this message translates to:
  /// **'Walking home'**
  String get templateWalkHome;

  /// No description provided for @templateWalkHomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Stay protected while walking on quiet streets or after dark.'**
  String get templateWalkHomeDescription;

  /// No description provided for @templateLateRide.
  ///
  /// In en, this message translates to:
  /// **'Taxi or ride-hailing'**
  String get templateLateRide;

  /// No description provided for @templateLateRideDescription.
  ///
  /// In en, this message translates to:
  /// **'Monitor a taxi or ride-hailing trip after dark.'**
  String get templateLateRideDescription;

  /// No description provided for @templateExercise.
  ///
  /// In en, this message translates to:
  /// **'Running or exercise'**
  String get templateExercise;

  /// No description provided for @templateExerciseDescription.
  ///
  /// In en, this message translates to:
  /// **'Check in while running or exercising outdoors.'**
  String get templateExerciseDescription;

  /// No description provided for @templateMeetup.
  ///
  /// In en, this message translates to:
  /// **'Meeting or date'**
  String get templateMeetup;

  /// No description provided for @templateMeetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Stay safe when meeting someone new or visiting an unfamiliar place.'**
  String get templateMeetupDescription;

  /// No description provided for @templateOvertime.
  ///
  /// In en, this message translates to:
  /// **'Late work or night shift'**
  String get templateOvertime;

  /// No description provided for @templateOvertimeDescription.
  ///
  /// In en, this message translates to:
  /// **'Check in while working late or travelling for work.'**
  String get templateOvertimeDescription;

  /// No description provided for @templateCommute.
  ///
  /// In en, this message translates to:
  /// **'Commute or transit'**
  String get templateCommute;

  /// No description provided for @templateCommuteDescription.
  ///
  /// In en, this message translates to:
  /// **'Monitor a taxi, ride-hailing or public transit trip.'**
  String get templateCommuteDescription;

  /// No description provided for @templateOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor adventure'**
  String get templateOutdoor;

  /// No description provided for @templateOutdoorDescription.
  ///
  /// In en, this message translates to:
  /// **'Stay safe while hiking, exploring or trail running.'**
  String get templateOutdoorDescription;

  /// No description provided for @templateAlone.
  ///
  /// In en, this message translates to:
  /// **'Alone at home'**
  String get templateAlone;

  /// No description provided for @templateAloneDescription.
  ///
  /// In en, this message translates to:
  /// **'Check in while home alone or working at night.'**
  String get templateAloneDescription;

  /// No description provided for @templateStranger.
  ///
  /// In en, this message translates to:
  /// **'Meeting someone new'**
  String get templateStranger;

  /// No description provided for @templateStrangerDescription.
  ///
  /// In en, this message translates to:
  /// **'Stay safe when meeting someone new, trading in person or interviewing.'**
  String get templateStrangerDescription;

  /// No description provided for @profileSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get profileSignedIn;

  /// No description provided for @deviceWindowsPc.
  ///
  /// In en, this message translates to:
  /// **'Windows PC'**
  String get deviceWindowsPc;

  /// No description provided for @deviceAppleMac.
  ///
  /// In en, this message translates to:
  /// **'Apple Mac'**
  String get deviceAppleMac;

  /// No description provided for @deviceAndroid.
  ///
  /// In en, this message translates to:
  /// **'Android device'**
  String get deviceAndroid;

  /// No description provided for @deviceWebBrowser.
  ///
  /// In en, this message translates to:
  /// **'Web browser'**
  String get deviceWebBrowser;

  /// No description provided for @deviceGuardian.
  ///
  /// In en, this message translates to:
  /// **'Guardian AI device'**
  String get deviceGuardian;

  /// No description provided for @deviceUser.
  ///
  /// In en, this message translates to:
  /// **'User device'**
  String get deviceUser;

  /// No description provided for @contactsActions.
  ///
  /// In en, this message translates to:
  /// **'Contact actions'**
  String get contactsActions;

  /// No description provided for @contactsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit emergency contact'**
  String get contactsEditTitle;

  /// No description provided for @contactsInvalidName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name between 2 and 100 characters.'**
  String get contactsInvalidName;

  /// No description provided for @contactsTelegramRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'A Chat ID is required for this contact to receive Telegram alerts.'**
  String get contactsTelegramRequiredHint;

  /// No description provided for @contactsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Contact updated successfully'**
  String get contactsUpdated;

  /// No description provided for @contactsUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save changes. Please try again.'**
  String get contactsUpdateFailed;

  /// No description provided for @scenarioCreate.
  ///
  /// In en, this message translates to:
  /// **'Create scenario'**
  String get scenarioCreate;

  /// No description provided for @scenarioEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit scenario'**
  String get scenarioEdit;

  /// No description provided for @scenarioName.
  ///
  /// In en, this message translates to:
  /// **'Scenario name'**
  String get scenarioName;

  /// No description provided for @scenarioDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get scenarioDescription;

  /// No description provided for @scenarioDuration.
  ///
  /// In en, this message translates to:
  /// **'Default duration (minutes)'**
  String get scenarioDuration;

  /// No description provided for @scenarioGrace.
  ///
  /// In en, this message translates to:
  /// **'Check-in grace period (seconds)'**
  String get scenarioGrace;

  /// No description provided for @scenarioGraceHint.
  ///
  /// In en, this message translates to:
  /// **'Time to confirm you are safe after the timer ends.'**
  String get scenarioGraceHint;

  /// No description provided for @scenarioPresets.
  ///
  /// In en, this message translates to:
  /// **'Five duration presets (minutes)'**
  String get scenarioPresets;

  /// No description provided for @scenarioPresetsHint.
  ///
  /// In en, this message translates to:
  /// **'Separate values with commas, e.g. 15, 30, 45, 60, 90.'**
  String get scenarioPresetsHint;

  /// No description provided for @scenarioInvalidName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name between 2 and 100 characters.'**
  String get scenarioInvalidName;

  /// No description provided for @scenarioInvalidDescription.
  ///
  /// In en, this message translates to:
  /// **'Description must be at most 300 characters.'**
  String get scenarioInvalidDescription;

  /// No description provided for @scenarioInvalidDuration.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number from 1 to 1440 minutes.'**
  String get scenarioInvalidDuration;

  /// No description provided for @scenarioInvalidGrace.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number from 30 to 1800 seconds.'**
  String get scenarioInvalidGrace;

  /// No description provided for @scenarioInvalidPresets.
  ///
  /// In en, this message translates to:
  /// **'Enter five different whole numbers from 1 to 1440, separated by commas.'**
  String get scenarioInvalidPresets;

  /// No description provided for @scenarioSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save the scenario. Please try again.'**
  String get scenarioSaveFailed;

  /// No description provided for @scenarioSaved.
  ///
  /// In en, this message translates to:
  /// **'Scenario saved'**
  String get scenarioSaved;

  /// No description provided for @scenarioDeleted.
  ///
  /// In en, this message translates to:
  /// **'Scenario deleted'**
  String get scenarioDeleted;

  /// No description provided for @scenarioDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete scenario?'**
  String get scenarioDeleteTitle;

  /// No description provided for @scenarioDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'This scenario will be removed from your list. Other accounts keep their own scenarios.'**
  String get scenarioDeleteConfirm;

  /// No description provided for @scenarioEmpty.
  ///
  /// In en, this message translates to:
  /// **'No scenarios yet. Create one to start a Safety Check.'**
  String get scenarioEmpty;

  /// No description provided for @scenarioActions.
  ///
  /// In en, this message translates to:
  /// **'Scenario actions'**
  String get scenarioActions;

  /// No description provided for @registerNamePrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get registerNamePrompt;

  /// No description provided for @registerEmailPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get registerEmailPrompt;

  /// No description provided for @registerPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone number (optional)'**
  String get registerPhoneOptional;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
