// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Try again';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get continueAction => 'Continue';

  @override
  String get back => 'Back';

  @override
  String get edit => 'Edit';

  @override
  String get navHome => 'Home';

  @override
  String get navSos => 'SOS';

  @override
  String get navSafetyCheck => 'Safety Check';

  @override
  String get navContacts => 'Contacts';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeGreeting => 'Guardian AI';

  @override
  String get homeStatusSafe => 'You are safe';

  @override
  String get homeStatusSafeDesc => 'Active monitoring enabled and ready';

  @override
  String get homeStatusWarning => 'Attention needed';

  @override
  String get homeStatusEmergency => 'EMERGENCY ACTIVE';

  @override
  String get homeQuickActions => 'Quick Safety Tools';

  @override
  String get homeSirenAction => 'Siren Alarm';

  @override
  String get homeStrobeAction => 'Strobe Light';

  @override
  String get homeCallPoliceAction => 'Call 113';

  @override
  String get homeSosHoldHint => 'Hold for 3 seconds to trigger SOS';

  @override
  String get sosTitle => 'Emergency SOS';

  @override
  String get sosActivate => 'ACTIVATE SOS';

  @override
  String get sosActiveTitle => 'SOS IS ACTIVE';

  @override
  String get sosActiveSubtitle =>
      'Sending live location and alerting emergency contacts';

  @override
  String get sosStop => 'STOP SOS';

  @override
  String get sosCallingHelp => 'Contacting emergency services...';

  @override
  String get sosSharingLocation => 'Live GPS sharing is active';

  @override
  String get sosStopConfirmTitle => 'Stop Emergency SOS?';

  @override
  String get sosStopConfirmDesc =>
      'Are you sure you want to stop the SOS alert? Your emergency contacts will be notified that you are safe.';

  @override
  String get sosEnterPinTitle => 'Enter PIN to cancel SOS';

  @override
  String get sosEnterPinDesc => 'Enter your 4-digit PIN to stop the alert';

  @override
  String get sosIncorrectPin => 'Incorrect PIN. Please try again.';

  @override
  String get safetyCheckTitle => 'Safety Check';

  @override
  String get safetyCheckSubtitle =>
      'Set a timer and check in before it expires. If missed, SOS will automatically trigger.';

  @override
  String get safetyCheckStart => 'Start Timer';

  @override
  String get safetyCheckSafeConfirm => 'I\'m Safe';

  @override
  String get safetyCheckExpiringSoon => 'Check-in Expiring Soon';

  @override
  String get safetyCheckMissedAlert => 'Check-in Missed - SOS Triggered';

  @override
  String get safetyCheckRemainingTime => 'Remaining Time';

  @override
  String safetyCheckMinutesRemaining(int minutes) {
    return '$minutes minutes remaining';
  }

  @override
  String get safetyCheckTemplatesTitle => 'Quick Templates';

  @override
  String get customDuration => 'Custom';

  @override
  String get customMinutesPrompt => 'Enter minutes';

  @override
  String get contactsTitle => 'Guardian Circle';

  @override
  String get contactsSubtitle =>
      'Up to 10 trusted contacts who receive instant alerts via App & Telegram';

  @override
  String get contactsAdd => 'Add Contact';

  @override
  String get contactsConfirmed => 'Confirmed';

  @override
  String get contactsPending => 'Pending Telegram link';

  @override
  String get contactsLimitReached => 'Maximum 10 emergency contacts reached';

  @override
  String get contactsRemoveConfirm =>
      'Remove this contact from your emergency circle?';

  @override
  String get profileTitle => 'Profile & Settings';

  @override
  String get medicalProfileTitle => 'Medical Profile';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageVi => 'Vietnamese';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsSystemTheme => 'System Theme';

  @override
  String get settingsLogout => 'Sign Out';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork =>
      'Network unavailable. Please check your connection.';

  @override
  String get errorLocationUnavailable =>
      'Unable to determine your GPS location.';

  @override
  String get errorPermissionRequired =>
      'Permission required to perform this action.';

  @override
  String get errorTryAgain => 'Try Again';

  @override
  String get profileLoading => 'Loading your profile...';

  @override
  String get profilePersonalTab => 'Personal';

  @override
  String get profileMedicalTab => 'Medical';

  @override
  String get profileSettingsTab => 'Settings';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get notUpdated => 'Not provided';

  @override
  String get profileTelegramPersonal => 'Personal Telegram Chat ID';

  @override
  String get profileTelegramUnlinked => 'Not linked';

  @override
  String get profileEditPersonal => 'Edit personal information';

  @override
  String get profileTestTelegramTitle => 'Test Telegram connection';

  @override
  String get profileTestTelegramDescription =>
      'Send a test alert to check that the Telegram bot can deliver emergency notifications.';

  @override
  String get profileTelegramBot => '🤖 Alert bot: @GuardianAINotiBot';

  @override
  String get profileTelegramSetupOne =>
      '1. Open @GuardianAINotiBot, tap START (or type /start), then send \"hello\" to connect.\n';

  @override
  String get profileTelegramSetupTwo =>
      '2. Use @userinfobot to find your and your contacts\' numeric Chat IDs.';

  @override
  String get profileTestTelegramAction => '🔔 Send a Telegram test alert';

  @override
  String get medicalLockedTitle => 'Medical profile is locked';

  @override
  String get medicalLockedDescription =>
      'Medical information is sensitive personal data under Vietnam\'s Decree 13/2023/ND-CP. Enter your account\'s 4-digit PIN to view or edit it.';

  @override
  String get medicalUnlockAction => '🔓 Unlock with your 4-digit PIN';

  @override
  String get medicalInitialHint =>
      'You can enter your initial medical information without unlocking. After saving, this section is automatically locked.';

  @override
  String get medicalLockNow => 'Lock now';

  @override
  String get medicalLockedSuccess => 'Medical profile locked';

  @override
  String get editInformation => 'Edit';

  @override
  String get enterInformation => 'Add information';

  @override
  String get medicalBloodType => 'Blood type';

  @override
  String get medicalAllergies => 'Allergies';

  @override
  String get medicalNotes => 'Medical notes and conditions';

  @override
  String get medicalSosHint =>
      'This medical information is included in SOS messages to your emergency contacts and responders.';

  @override
  String get settingsSafePinTitle => '4-digit PIN to stop SOS';

  @override
  String get settingsSafePinSet => 'Security PIN configured (4 digits)';

  @override
  String get notConfigured => 'Not configured';

  @override
  String get settingsChangePin => 'Change PIN';

  @override
  String get settingsDuressPinTitle => 'Duress PIN';

  @override
  String get settingsDuressPinSet => 'Duress PIN enabled (4 digits)';

  @override
  String get notEnabled => 'Not enabled';

  @override
  String get settingsChangeCode => 'Change code';

  @override
  String get settingsDuressDescription =>
      'If someone forces you to stop SOS, enter this code. The app silences the alarm while discreetly alerting your emergency contacts through Telegram.';

  @override
  String get settingsPasswordTitle => 'Account password';

  @override
  String get settingsPasswordSet => 'Account password configured';

  @override
  String get changeAction => 'Change';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLight => 'Light (default)';

  @override
  String get settingsDark => 'Dark';

  @override
  String get settingsLogoutAccount => 'Sign out';

  @override
  String get fullName => 'Full name';

  @override
  String get fullNameExample => 'Your full name';

  @override
  String get telegramNumericId => 'Telegram Chat ID (numeric)';

  @override
  String get telegramIdExample => 'Example: 628392102';

  @override
  String get telegramIdHint =>
      '💡 Get your numeric ID from @userinfobot on Telegram.';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get nameRequired => 'Please enter your full name';

  @override
  String get profileUpdateSuccess => 'Profile updated successfully';

  @override
  String get profileUpdateFailed => 'Update failed. Please try again';

  @override
  String get telegramTestOptions => 'Telegram test recipients';

  @override
  String get telegramTestChoose =>
      'Choose who receives a test alert from @GuardianAINotiBot:';

  @override
  String get telegramTestSelf => '🎯 Only my Telegram account';

  @override
  String get telegramNotConfigured => 'Telegram ID not configured';

  @override
  String get telegramTestEveryone => '👥 Me and all Guardian Circle contacts';

  @override
  String get telegramTestContacts => '🛡️ Only my emergency contacts';

  @override
  String get telegramChecking => 'Checking Telegram connection...';

  @override
  String get telegramSending => 'Sending through @GuardianAINotiBot...';

  @override
  String get telegramRecipientHint =>
      '💡 Recipients must first open @GuardianAINotiBot, tap /start and send \"hello\".';

  @override
  String get telegramChatNotConfigured => 'Telegram Chat ID not configured';

  @override
  String get sessionExpiredHint =>
      'Session error. Please sign out and sign in again';

  @override
  String get telegramNotStarted =>
      'Start a conversation with @GuardianAINotiBot first';

  @override
  String get medicalEditTitle => 'Edit emergency medical profile';

  @override
  String get medicalAllergiesExample => 'Penicillin, aspirin, pollen...';

  @override
  String get medicalNotesExample => 'Asthma, medication you carry...';

  @override
  String get medicalSave => 'Save medical profile';

  @override
  String get medicalSaveSuccess => 'Medical profile updated successfully';

  @override
  String get medicalUnlockTitle => 'Unlock medical profile';

  @override
  String get medicalEnterPin =>
      'Enter your current 4-digit safety PIN to view your medical information:';

  @override
  String get medicalUnlockedSuccess => '🔓 Medical profile unlocked';

  @override
  String get pinVerifyUnavailable => 'Unable to verify PIN';

  @override
  String get unlockAction => 'Unlock';

  @override
  String get pinChangeTitle => 'Change your 4-digit SOS PIN';

  @override
  String get pinCurrentHint => 'For your security, enter your current PIN:';

  @override
  String get pinCurrent => 'Current PIN';

  @override
  String get pinNew => 'New PIN';

  @override
  String get pinConfirmNew => 'Confirm new PIN';

  @override
  String get pinCurrentIncorrect => 'Current PIN is incorrect';

  @override
  String get pinFourDigits => 'PIN must contain exactly 4 digits';

  @override
  String get pinConfirmationMismatch => 'New PIN and confirmation do not match';

  @override
  String get pinMustDiffer => 'New PIN must differ from your current PIN';

  @override
  String get pinUpdateUnavailable => 'Unable to update PIN on the server';

  @override
  String get pinUpdateSuccess => 'SOS PIN changed successfully';

  @override
  String get pinSave => 'Save PIN';

  @override
  String get duressChangeTitle => 'Change duress PIN';

  @override
  String get duressChangeDescription =>
      'This code silences the alarm while discreetly sending an emergency alert to your contacts.\n\n';

  @override
  String get duressCurrentHint =>
      'For your security, enter your current duress PIN:';

  @override
  String get duressCurrent => 'Current duress PIN';

  @override
  String get duressNew => 'New duress PIN';

  @override
  String get duressConfirmNew => 'Confirm new duress PIN';

  @override
  String get duressCurrentIncorrect => 'Current duress PIN is incorrect';

  @override
  String get duressUpdateUnavailable =>
      'Unable to update duress PIN. Check your connection and try again.';

  @override
  String get duressUpdateSuccess => 'Duress PIN changed successfully';

  @override
  String get saveCode => 'Save code';

  @override
  String get passwordChangeTitle => 'Change account password';

  @override
  String get passwordCurrentHint =>
      'For your security, enter your current password:';

  @override
  String get passwordCurrent => 'Current password';

  @override
  String get passwordNew => 'New password';

  @override
  String get passwordRequirements =>
      'At least 6 characters, including letters and digits';

  @override
  String get passwordConfirm => 'Confirm new password';

  @override
  String get passwordRepeat => 'Re-enter new password';

  @override
  String get passwordCurrentRequired => 'Please enter your current password';

  @override
  String get passwordTooShort =>
      'New password must contain at least 6 characters';

  @override
  String get passwordLettersDigits =>
      'New password must include both letters and digits';

  @override
  String get passwordConfirmationMismatch =>
      'New password and confirmation do not match';

  @override
  String get passwordMustDiffer =>
      'New password must differ from your current password';

  @override
  String get passwordChange => 'Change password';

  @override
  String get logoutConfirmTitle => 'Confirm sign out';

  @override
  String get logoutConfirmDescription =>
      'Sign out of Guardian AI on this device?';

  @override
  String get mobileDevice => 'Mobile device';

  @override
  String get locationDeviceTitle => 'Emergency location and trusted device';

  @override
  String get locationAuthorized =>
      '🟢 Location authorized — ready for one-tap SOS';

  @override
  String get locationNotAuthorized => '🟠 Background location not authorized';

  @override
  String get locationDeviceLabel => 'Device:';

  @override
  String get locationOsLabel => 'Operating system:';

  @override
  String get locationLastKnown => 'Last checked location:';

  @override
  String get locationOpenMaps => '🗺️ Open in Google Maps';

  @override
  String get locationFinding => 'Getting your location...';

  @override
  String get locationUpdate => '🔄 Update and check location';

  @override
  String get locationAuthorize => '⚡ Authorize emergency location';

  @override
  String get locationAuthorizeHint =>
      'Authorize location access so SOS can share your location without asking again.';

  @override
  String get locationUnavailableDescription =>
      'Unable to get your location. Enable location services and allow access in your browser or device settings.';

  @override
  String get homeCountdownActive => 'SAFETY COUNTDOWN ACTIVE';

  @override
  String get runningStatus => 'Running';

  @override
  String get homeProtectionDescription =>
      'Your safety timer is running. View the countdown or confirm you are safe.';

  @override
  String get homeViewCountdown => 'View countdown';

  @override
  String get contactsEmptyTitle => 'No emergency contacts yet';

  @override
  String get contactsEmptyDescription =>
      'Add at least one trusted contact to receive emergency alerts.';

  @override
  String get contactsPriorityBadge => '#1 Priority contact';

  @override
  String get contactsTestCall => 'Test call';

  @override
  String get contactsSetPriority => 'Set as priority contact #1';

  @override
  String get contactsAddTitle => 'Add a Guardian Circle contact';

  @override
  String get contactsFullName => 'Contact name';

  @override
  String get contactsNameExample => 'Example: parent, partner, friend...';

  @override
  String get contactsTelegramLabel => 'Telegram Chat ID (required)';

  @override
  String get contactsTelegramSetupTitle => 'How to receive Telegram alerts:';

  @override
  String get contactsTelegramSetupOne =>
      '1. Ask your contact to open @GuardianAINotiBot on Telegram (t.me/GuardianAINotiBot).\n';

  @override
  String get contactsTelegramSetupTwo =>
      '2. Tap START (or type /start), then send a message such as \"hello\" to connect.\n';

  @override
  String get contactsTelegramSetupThree =>
      '3. Use @userinfobot to get your contact\'s numeric User ID and paste it into the Chat ID field above.';

  @override
  String get contactsTelegramNumericHint =>
      '💡 The bot requires a numeric Chat ID; a Telegram @username will not work.';

  @override
  String get contactRelationship => 'Relationship';

  @override
  String get relationshipParent => 'Parent';

  @override
  String get relationshipSpouse => 'Spouse';

  @override
  String get relationshipSibling => 'Sibling';

  @override
  String get relationshipChild => 'Child';

  @override
  String get relationshipFriend => 'Friend';

  @override
  String get relationshipColleague => 'Colleague';

  @override
  String get contactsOldPriorityHint =>
      'The previous priority contact will move down';

  @override
  String get contactsSave => 'Save contact';

  @override
  String get contactsNamePhoneRequired =>
      'Please enter a name and phone number';

  @override
  String get contactsInvalidPhone =>
      'Enter a valid 10-digit Vietnamese mobile number starting with 03, 05, 07, 08 or 09.';

  @override
  String get contactsInvalidTelegram =>
      'Enter a numeric Telegram Chat ID with 6 to 14 digits.';

  @override
  String get contactsDeleteTitle => 'Confirm removal';

  @override
  String get contactsPriorityMovedHint =>
      'The previous priority contact will move to a lower position.';

  @override
  String get contactsPriorityFailed => 'Unable to set priority contact';

  @override
  String get safetyExtendShort => '+15 min';

  @override
  String get safetyMicrophoneUnavailable =>
      'Microphone unavailable. Your safety timer is still running.';

  @override
  String get safetyExpiredDescription =>
      'Time is up. Please confirm you are safe';

  @override
  String get safetyMonitoring => 'Active safety monitoring';

  @override
  String get safetyGracePeriod => 'Grace period';

  @override
  String get safetyConfirmed => 'You have checked in safely';

  @override
  String get safetyExtendAction => 'Extend by 15 minutes';

  @override
  String get safetyExtended => 'Extended by 15 minutes';

  @override
  String get safetyCancelTitle => 'Cancel timer';

  @override
  String get safetyCancelDescription => 'End this safety timer?';

  @override
  String get safetyCancelConfirm => 'Stop timer';

  @override
  String get safetyChooseScenario => '1. Choose a scenario';

  @override
  String get safetyChooseDuration => '2. Choose a timer duration';

  @override
  String get safetyDurationLabel => 'Duration:';

  @override
  String get safetyNotesLabel => '3. Destination or companion notes (optional)';

  @override
  String get safetyNotesExample =>
      'Example: taxi plate 29A-12345, expected home by 22:30...';

  @override
  String get minutesUnit => 'min';

  @override
  String get sirenRunning => 'Siren on...';

  @override
  String get strobeRunning => 'Strobe on...';

  @override
  String get policeCallTitle => 'Call police on 113?';

  @override
  String get policeCallDescription =>
      'You are about to call Vietnam\'s police emergency number, 113.';

  @override
  String get callNow => 'Call now';

  @override
  String get languageSaveError =>
      'Unable to save your language. Please try again.';

  @override
  String get cancelShort => 'Cancel';

  @override
  String get contactsAlertDescription =>
      'When SOS is activated or a Safety Check is missed, the app alerts your contacts through @GuardianAINotiBot and includes your location when available.';

  @override
  String get relationshipOther => 'Other';

  @override
  String get sosNoRecipients =>
      'No contacts are ready to receive Telegram alerts';

  @override
  String get sosSessionActive => 'SOS is active';

  @override
  String get sosLocationMissing => 'Location unavailable';

  @override
  String get sirenOffAction => 'Turn siren off';

  @override
  String get sirenOnAction => 'Turn siren on';

  @override
  String get strobeOffAction => 'Turn strobe off';

  @override
  String get strobeOnAction => 'Turn strobe on';

  @override
  String get emergencyContacts => 'Emergency contacts';

  @override
  String get policeCallEmoji => '🚔 Call police 113';

  @override
  String get policeCallPhone => '📞 Call police 113';

  @override
  String get primaryContact => 'Priority contact #1';

  @override
  String get callNowUpper => 'CALL NOW';

  @override
  String get messageNowUpper => 'SEND MESSAGE';

  @override
  String get callAction => 'Call';

  @override
  String get messageAction => 'Message';

  @override
  String get sosCurrentPinHint => 'Enter your current 4-digit PIN to stop SOS';

  @override
  String get sosPinRequired => 'Please enter all 4 PIN digits';

  @override
  String get sosStoppedSuccess =>
      'SOS has stopped. Your contacts have been notified that you are safe.';

  @override
  String get sosConfirmationTitle => 'Confirm SOS';

  @override
  String get screamDetected => 'Screaming detected!';

  @override
  String get sosCancelling => 'Confirming cancellation…';

  @override
  String get sosSending => 'Sending SOS to your contacts…';

  @override
  String get sosSendFailed => 'SOS has not been sent yet';

  @override
  String get sosWaitingServer => 'Waiting for the server to process SOS…';

  @override
  String get sosFalseAlarm => 'FALSE ALARM';

  @override
  String get sosActivateNow => 'ACTIVATE SOS NOW';

  @override
  String get sosRetry => 'RETRY SOS';

  @override
  String get sosPreparingTitle => 'PREPARING TO SEND SOS';

  @override
  String get sosCountdownDescription =>
      'Your emergency contacts will receive an SOS alert and your available location after:';

  @override
  String get sosCancelNow => 'CANCEL ALERT NOW';

  @override
  String get sosCancelledSuccess => 'SOS activation cancelled';

  @override
  String get loginTagline => 'Proactive personal safety';

  @override
  String get loginTitle => 'Sign in to your account';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginAction => 'Sign in';

  @override
  String get loginRequired => 'Please enter your email and password';

  @override
  String get forgotPasswordLink => '🔑 Forgot password?';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get registerLink => 'Create an account';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordDescription =>
      'Enter your account email to receive a password reset link:';

  @override
  String get accountEmail => 'Account email';

  @override
  String get forgotPasswordSpamHint =>
      '💡 Check your spam folder if the email does not arrive.';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get emailInvalid => 'Invalid email address';

  @override
  String get sendRequest => 'Send request';

  @override
  String get registerTitle => 'Create an account';

  @override
  String get registerSubtitle => 'Start protecting your safety';

  @override
  String get registerName => 'Full name *';

  @override
  String get registerEmail => 'Email address *';

  @override
  String get registerPassword => 'Password *';

  @override
  String get registerPasswordHint => 'At least 6 characters';

  @override
  String get registerPasswordConfirm => 'Confirm password *';

  @override
  String get registerPasswordRepeat => 'Re-enter your password';

  @override
  String get registerConsent =>
      'I agree to Guardian AI\'s location and audio data privacy commitment under Vietnam\'s Decree 13/2023/ND-CP.';

  @override
  String get registerAction => 'Create account';

  @override
  String get registerRequired => 'Please complete all required fields (*)';

  @override
  String get registerInvalidEmail => 'Please enter a valid email address';

  @override
  String get registerPasswordShort =>
      'Password must contain at least 6 characters';

  @override
  String get registerPasswordMismatch =>
      'Passwords do not match. Please check them again';

  @override
  String get registerConsentRequired =>
      'Please accept the data privacy commitment';

  @override
  String get registerSuccess => 'Account created successfully!';

  @override
  String get registerFailed => 'Registration failed';

  @override
  String get registerHaveAccount => 'Already have an account? ';

  @override
  String get loginLink => 'Sign in';

  @override
  String contactsAddCount(int count) {
    return 'Add contact ($count/10)';
  }

  @override
  String contactsCount(int count) {
    return '$count/10 contacts';
  }

  @override
  String homeContactsReady(int count) {
    return '$count/10 contacts ready for Telegram alerts';
  }

  @override
  String homeSessionRemaining(String name, String remaining) {
    return 'Session \"$name\": $remaining remaining';
  }

  @override
  String minutesDuration(int minutes) {
    return '$minutes min';
  }

  @override
  String customMinutesDuration(int minutes) {
    return 'Custom: ${minutes}m';
  }

  @override
  String safetyStarted(int minutes) {
    return 'Your $minutes-minute safety timer has started';
  }

  @override
  String safetyExtensionCount(int count, int total) {
    return 'Extensions used: $count/$total';
  }

  @override
  String contactsAdded(String name) {
    return 'Added $name to Guardian Circle';
  }

  @override
  String contactsAddedPriority(String name) {
    return 'Added $name to Guardian Circle as priority contact #1';
  }

  @override
  String contactsRemoveNamed(String name) {
    return 'Remove $name from your emergency contacts?';
  }

  @override
  String contactsPriorityNamed(String name) {
    return 'Call $name first in an emergency?';
  }

  @override
  String contactsPrioritySuccess(String name) {
    return '$name is now priority contact #1';
  }

  @override
  String profileSelf(String name) {
    return 'You ($name)';
  }

  @override
  String profileTestEveryoneDetail(int count) {
    return 'Send to you and $count contacts with Telegram IDs';
  }

  @override
  String profileTestContactsDetail(int count) {
    return 'Send a test alert to $count emergency contacts';
  }

  @override
  String profileTestResults(int sent, int total) {
    return 'Result: $sent/$total recipients reached';
  }

  @override
  String profileTestMessage(String name) {
    return '🔔 [Guardian AI - Test] This is a safety alert connection test from $name. The connection is working.';
  }

  @override
  String profileTestDelivered(String id) {
    return 'Message delivered (ID: $id)';
  }

  @override
  String locationNetworkLabel(String coordinates) {
    return '$coordinates (network location)';
  }

  @override
  String locationGpsLabel(String coordinates, String accuracy) {
    return '$coordinates (GPS accuracy ~${accuracy}m)';
  }

  @override
  String locationNetworkSuccess(String device) {
    return 'Network location enabled and $device registered!';
  }

  @override
  String locationGpsSuccess(String device) {
    return 'GPS enabled and $device registered!';
  }

  @override
  String sosAutoActivateSeconds(int seconds) {
    return 'Automatically activates in ${seconds}s';
  }

  @override
  String sosDetectionType(String type, String confidence) {
    return 'Type: $type ($confidence%)';
  }

  @override
  String sosDeliveredCount(int sent, int total) {
    return 'Telegram accepted $sent/$total alerts';
  }

  @override
  String sosDeliveryFailedCount(int sent, int total, int failed) {
    return 'Sent $sent/$total; $failed failed';
  }

  @override
  String sosDeliveryPendingCount(int sent, int total) {
    return 'Sending to contacts: $sent/$total';
  }

  @override
  String get templateWalkHome => 'Walking home';

  @override
  String get templateWalkHomeDescription =>
      'Stay protected while walking on quiet streets or after dark.';

  @override
  String get templateLateRide => 'Taxi or ride-hailing';

  @override
  String get templateLateRideDescription =>
      'Monitor a taxi or ride-hailing trip after dark.';

  @override
  String get templateExercise => 'Running or exercise';

  @override
  String get templateExerciseDescription =>
      'Check in while running or exercising outdoors.';

  @override
  String get templateMeetup => 'Meeting or date';

  @override
  String get templateMeetupDescription =>
      'Stay safe when meeting someone new or visiting an unfamiliar place.';

  @override
  String get templateOvertime => 'Late work or night shift';

  @override
  String get templateOvertimeDescription =>
      'Check in while working late or travelling for work.';

  @override
  String get templateCommute => 'Commute or transit';

  @override
  String get templateCommuteDescription =>
      'Monitor a taxi, ride-hailing or public transit trip.';

  @override
  String get templateOutdoor => 'Outdoor adventure';

  @override
  String get templateOutdoorDescription =>
      'Stay safe while hiking, exploring or trail running.';

  @override
  String get templateAlone => 'Alone at home';

  @override
  String get templateAloneDescription =>
      'Check in while home alone or working at night.';

  @override
  String get templateStranger => 'Meeting someone new';

  @override
  String get templateStrangerDescription =>
      'Stay safe when meeting someone new, trading in person or interviewing.';

  @override
  String get profileSignedIn => 'Signed in';

  @override
  String get deviceWindowsPc => 'Windows PC';

  @override
  String get deviceAppleMac => 'Apple Mac';

  @override
  String get deviceAndroid => 'Android device';

  @override
  String get deviceWebBrowser => 'Web browser';

  @override
  String get deviceGuardian => 'Guardian AI device';

  @override
  String get deviceUser => 'User device';

  @override
  String get contactsActions => 'Contact actions';

  @override
  String get contactsEditTitle => 'Edit emergency contact';

  @override
  String get contactsInvalidName =>
      'Enter a name between 2 and 100 characters.';

  @override
  String get contactsTelegramRequiredHint =>
      'A Chat ID is required for this contact to receive Telegram alerts.';

  @override
  String get contactsUpdated => 'Contact updated successfully';

  @override
  String get contactsUpdateFailed =>
      'Unable to save changes. Please try again.';

  @override
  String get scenarioCreate => 'Create scenario';

  @override
  String get scenarioEdit => 'Edit scenario';

  @override
  String get scenarioName => 'Scenario name';

  @override
  String get scenarioDescription => 'Description (optional)';

  @override
  String get scenarioDuration => 'Default duration (minutes)';

  @override
  String get scenarioGrace => 'Check-in grace period (seconds)';

  @override
  String get scenarioGraceHint =>
      'Time to confirm you are safe after the timer ends.';

  @override
  String get scenarioPresets => 'Five duration presets (minutes)';

  @override
  String get scenarioPresetsHint =>
      'Separate values with commas, e.g. 15, 30, 45, 60, 90.';

  @override
  String get scenarioInvalidName =>
      'Enter a name between 2 and 100 characters.';

  @override
  String get scenarioInvalidDescription =>
      'Description must be at most 300 characters.';

  @override
  String get scenarioInvalidDuration =>
      'Enter a whole number from 1 to 1440 minutes.';

  @override
  String get scenarioInvalidGrace =>
      'Enter a whole number from 30 to 1800 seconds.';

  @override
  String get scenarioInvalidPresets =>
      'Enter five different whole numbers from 1 to 1440, separated by commas.';

  @override
  String get scenarioSaveFailed =>
      'Unable to save the scenario. Please try again.';

  @override
  String get scenarioSaved => 'Scenario saved';

  @override
  String get scenarioDeleted => 'Scenario deleted';

  @override
  String get scenarioDeleteTitle => 'Delete scenario?';

  @override
  String get scenarioDeleteConfirm =>
      'This scenario will be removed from your list. Other accounts keep their own scenarios.';

  @override
  String get scenarioEmpty =>
      'No scenarios yet. Create one to start a Safety Check.';

  @override
  String get scenarioActions => 'Scenario actions';

  @override
  String get registerNamePrompt => 'Enter your full name';

  @override
  String get registerEmailPrompt => 'Enter your email address';

  @override
  String get registerPhoneOptional => 'Phone number (optional)';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get flashlightSetupTitle => 'Camera and flashlight';

  @override
  String get flashlightSetupDescription =>
      'Allow camera access to use the emergency flashlight. The camera opens only for checks or flashlight use; images are not recorded or sent.';

  @override
  String get flashlightGrantAction => 'Allow camera';

  @override
  String get flashlightCheckAction => 'Check again';

  @override
  String get flashlightLaterAction => 'Later';

  @override
  String get flashlightCancelAction => 'Cancel check';

  @override
  String get flashlightChecking => 'Checking camera and flashlight…';

  @override
  String get flashlightReady =>
      'This camera supports the flashlight. Ready to use.';

  @override
  String get flashlightUnknown => 'Flashlight support has not been checked.';

  @override
  String get flashlightPermissionRequired =>
      'Allow camera access to use the flashlight.';

  @override
  String get flashlightPermissionDenied =>
      'Camera access was denied. Allow Camera in your browser’s website settings, then check again.';

  @override
  String get flashlightUnsupported =>
      'This camera or browser does not support flashlight control. Other SOS features remain available.';

  @override
  String get flashlightInsecure =>
      'Open Guardian AI over HTTPS to allow camera access and use the flashlight.';

  @override
  String get flashlightCameraMissing =>
      'No suitable camera was found on this device.';

  @override
  String get flashlightCameraBusy =>
      'The camera could not be opened. Close other apps using the camera and try again.';

  @override
  String get flashlightInterrupted =>
      'The flashlight stopped because the camera disconnected or you left the app. Turn it on to try again.';

  @override
  String get flashlightTimedOut =>
      'Camera permission was not received. You can keep using the app and check again later.';

  @override
  String get flashlightFailed =>
      'The flashlight could not be controlled. Please try again.';

  @override
  String get flashlightPermissionNote =>
      'Camera permission is managed by the browser on this device and may need to be granted again.';

  @override
  String get flashlightStopAction => 'Turn off flashlight';

  @override
  String get audioPreparing => 'Preparing audio recognition';

  @override
  String get audioLocalMode => 'Recognition on this device';

  @override
  String get audioServerMode => 'Recognition through the server';

  @override
  String get audioWaiting => 'Waiting for an audio window';

  @override
  String get audioAnalysisHealthy => 'Analysis is keeping up';

  @override
  String get audioAnalysisDelayed =>
      'Analysis is delayed; some audio may be skipped';

  @override
  String get audioAnalysisUnavailable => 'Audio analysis is unavailable';

  @override
  String get audioNetworkFailure => 'The server connection is interrupted.';

  @override
  String get audioAuthFailure => 'Sign in again to reconnect to the server.';

  @override
  String get audioModelFailure =>
      'The audio model is unavailable or could not run.';

  @override
  String get audioStaleFailure =>
      'The audio event expired or its Safety Check ended.';

  @override
  String get audioServerFailure => 'The server could not process the request.';

  @override
  String get audioMicrophoneActive => 'Microphone is recording';

  @override
  String get audioDeliveryRequiresNetwork =>
      'Sending an alert to the server requires a connection.';

  @override
  String get audioAlertSending =>
      'Sound detected. Sending the alert to the server…';

  @override
  String get audioAlertRetrying =>
      'Sound detected. Connection interrupted; retrying the alert…';

  @override
  String get audioAlertAccepted =>
      'The server accepted the alert. Delivery to contacts is tracked separately.';

  @override
  String get audioAlertFailed => 'The server has not acknowledged the alert.';

  @override
  String get audioAlertExpired =>
      'The detected event expired before server acknowledgement.';

  @override
  String get audioRecipientsSent =>
      'The alert was delivered to all selected contacts.';

  @override
  String get audioRecipientsMissing =>
      'There are no eligible contacts to receive this alert.';

  @override
  String get audioRecipientsFailed =>
      'Some alert deliveries failed. Check SOS delivery status.';
}
