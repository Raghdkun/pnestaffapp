import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens and the runtime-swappable font system.
abstract final class AppTypography {
  /// Used when the user hasn't chosen a font.
  static const String defaultFontFamily = 'Inter';

  /// Font families offered in appearance settings (google_fonts names).
  static const List<String> availableFonts = <String>[
    'Inter',
    'Roboto',
    'Nunito Sans',
    'Manrope',
    'IBM Plex Sans',
  ];

  /// Builds a Material 3 [TextTheme] in [fontFamily] (via google_fonts),
  /// colored for [colorScheme]. Falls back to the Material baseline for the
  /// brightness. Swapping [fontFamily] restyles the whole app.
  static TextTheme textTheme(ColorScheme colorScheme, String fontFamily) {
    final base = Typography.material2021(
      platform: TargetPlatform.iOS,
    ).black.merge(ThemeData(brightness: colorScheme.brightness).textTheme);
    final themed = GoogleFonts.getTextTheme(fontFamily, base);
    // Tighten + weight the display/headline scale for a modern, confident feel.
    return themed
        .copyWith(
          displayLarge: themed.displayLarge?.copyWith(
            letterSpacing: -1,
            fontWeight: FontWeight.w700,
          ),
          displayMedium: themed.displayMedium?.copyWith(
            letterSpacing: -0.5,
            fontWeight: FontWeight.w700,
          ),
          displaySmall: themed.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          headlineLarge: themed.headlineLarge?.copyWith(
            letterSpacing: -0.5,
            fontWeight: FontWeight.w700,
          ),
          headlineMedium: themed.headlineMedium?.copyWith(
            letterSpacing: -0.4,
            fontWeight: FontWeight.w700,
          ),
          headlineSmall: themed.headlineSmall?.copyWith(
            letterSpacing: -0.3,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: themed.titleLarge?.copyWith(letterSpacing: -0.2),
        )
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        );
  }
}
