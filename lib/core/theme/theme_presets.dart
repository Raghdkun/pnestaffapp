import 'package:flutter/material.dart';

/// Named theme presets. Each maps to a seed color from which a full Material 3
/// [ColorScheme] is derived (light + dark). Add a case here to add a theme;
/// the appearance settings screen picks these up automatically.
///
/// `pne` is the default placeholder brand palette — swap [seed] (and the
/// accent in [AppColorsX]) for real PNE brand values.
enum AppThemePreset {
  pne(label: 'PNE', seed: Color(0xFF00695C)),
  ocean(label: 'Ocean', seed: Color(0xFF1565C0)),
  sunset(label: 'Sunset', seed: Color(0xFFE65100)),
  grape(label: 'Grape', seed: Color(0xFF6A1B9A)),
  slate(label: 'Slate', seed: Color(0xFF37474F));

  const AppThemePreset({required this.label, required this.seed});

  final String label;
  final Color seed;
}
