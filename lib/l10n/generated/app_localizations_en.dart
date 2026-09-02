// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PNE Staff';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get welcomeSubtitle => 'Sign in to continue to PNE Staff.';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'you@pneunited.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get logoutButton => 'Sign out';

  @override
  String get homeTitle => 'Home';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get profileTitle => 'Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get themeModeLabel => 'Theme mode';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themePresetLabel => 'Theme';

  @override
  String get fontLabel => 'Font';

  @override
  String get textScaleLabel => 'Text size';

  @override
  String get languageLabel => 'Language';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String greeting(String name) {
    return 'Hello, $name!';
  }

  @override
  String get genericErrorMessage => 'Something went wrong. Please try again.';

  @override
  String get networkErrorMessage =>
      'No internet connection. Check your network and retry.';

  @override
  String get serverErrorMessage =>
      'Our servers had a problem. Please try again shortly.';

  @override
  String get authErrorMessage =>
      'Your session has expired. Please sign in again.';

  @override
  String get fieldRequired => 'This field is required.';

  @override
  String get invalidEmail => 'Enter a valid email address.';

  @override
  String passwordTooShort(int min) {
    return 'Password must be at least $min characters.';
  }

  @override
  String get emptyNotifications => 'You\'re all caught up.';

  @override
  String get sendTestNotification => 'Send a test notification';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordEmailPrompt =>
      'Enter your email and we\'ll send you a verification code.';

  @override
  String get sendCode => 'Send code';

  @override
  String get otpTitle => 'Enter code';

  @override
  String otpPrompt(String email) {
    return 'We sent a verification code to $email. Enter it below.';
  }

  @override
  String get otpLabel => 'Verification code';

  @override
  String get verifyCode => 'Verify';

  @override
  String get resendCode => 'Resend code';

  @override
  String get newPasswordTitle => 'New password';

  @override
  String get newPasswordPrompt => 'Choose a new password for your account.';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get resetPasswordButton => 'Reset password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get passwordResetDoneTitle => 'Password updated';

  @override
  String get passwordResetDoneSubtitle =>
      'You can now sign in with your new password.';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get nameLabel => 'Name';

  @override
  String get saveButton => 'Save';

  @override
  String get changePasswordSection => 'Change password (optional)';

  @override
  String get newPasswordOptionalLabel => 'New password';

  @override
  String get removeAvatar => 'Remove profile photo';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get rolesLabel => 'Roles';

  @override
  String get emailVerified => 'Email verified';

  @override
  String get employeeIdLabel => 'Employee ID';

  @override
  String get employeeIdHint => 'e.g. 1024';

  @override
  String get invalidEmployeeId => 'Enter a valid employee ID.';

  @override
  String get activeLabel => 'Active';

  @override
  String get inactiveLabel => 'Inactive';

  @override
  String get storesLabel => 'Stores';

  @override
  String get noStores => 'No store assignments.';

  @override
  String signingInTo(String domain) {
    return 'Signing in to $domain';
  }

  @override
  String get notYourCompany => 'Not your company?';

  @override
  String get enterDomainTitle => 'Company portal';

  @override
  String get enterDomainPrompt =>
      'Enter your company\'s portal domain to continue.';

  @override
  String get domainLabel => 'Company domain';

  @override
  String get domainHint => 'e.g. bmwgate.ai';

  @override
  String get invalidDomain => 'Enter a valid domain.';

  @override
  String get continueButton => 'Continue';

  @override
  String get domainNotRecognized =>
      'We don\'t recognize that company domain. Contact your administrator.';

  @override
  String get domainCheckFailed =>
      'Couldn\'t verify that domain. Check your connection and try again.';
}
