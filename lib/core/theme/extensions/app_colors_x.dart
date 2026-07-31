import 'package:flutter/material.dart';

/// Semantic brand colors that live *outside* Material's [ColorScheme]
/// (success/warning/info + a brand accent). Registered into `ThemeData.extensions`
/// so they animate on theme change and are available anywhere `Theme.of` works.
///
/// Read via `context.colors` (see the extension at the bottom of this file).
@immutable
class AppColorsX extends ThemeExtension<AppColorsX> {
  const AppColorsX({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
    required this.brandAccent,
    required this.neutralSurface,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;
  final Color brandAccent;
  final Color neutralSurface;

  static const AppColorsX light = AppColorsX(
    success: Color(0xFF2E7D32),
    onSuccess: Color(0xFFFFFFFF),
    warning: Color(0xFFED6C02),
    onWarning: Color(0xFFFFFFFF),
    info: Color(0xFF0277BD),
    onInfo: Color(0xFFFFFFFF),
    brandAccent: Color(0xFF00A19A),
    neutralSurface: Color(0xFFF3F5F7),
  );

  static const AppColorsX dark = AppColorsX(
    success: Color(0xFF81C784),
    onSuccess: Color(0xFF00320A),
    warning: Color(0xFFFFB74D),
    onWarning: Color(0xFF3B2400),
    info: Color(0xFF4FC3F7),
    onInfo: Color(0xFF00293A),
    brandAccent: Color(0xFF26D0C7),
    neutralSurface: Color(0xFF1A1C1E),
  );

  @override
  AppColorsX copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
    Color? brandAccent,
    Color? neutralSurface,
  }) {
    return AppColorsX(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      brandAccent: brandAccent ?? this.brandAccent,
      neutralSurface: neutralSurface ?? this.neutralSurface,
    );
  }

  @override
  AppColorsX lerp(ThemeExtension<AppColorsX>? other, double t) {
    if (other is! AppColorsX) return this;
    return AppColorsX(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      brandAccent: Color.lerp(brandAccent, other.brandAccent, t)!,
      neutralSurface: Color.lerp(neutralSurface, other.neutralSurface, t)!,
    );
  }
}

/// `context.colors.success`, `context.colors.brandAccent`, …
extension AppColorsContextX on BuildContext {
  AppColorsX get colors =>
      Theme.of(this).extension<AppColorsX>() ?? AppColorsX.light;
}
