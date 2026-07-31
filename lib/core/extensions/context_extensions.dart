import 'package:flutter/material.dart';
import 'package:pnestaffapp/l10n/generated/app_localizations.dart';

/// Common `Theme`/`MediaQuery`/l10n accessors so widgets read
/// `context.textTheme`, `context.l10n`, etc. instead of verbose lookups.
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  AppLocalizations get l10n => AppLocalizations.of(this);

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  void showSnack(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
