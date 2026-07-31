import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pnestaffapp/core/theme/theme_presets.dart';

/// Persisted appearance settings. Any change emits a new state, which rebuilds
/// `MaterialApp` with fresh `ThemeData` — restyling the whole app live.
class ThemeState extends Equatable {
  const ThemeState({
    this.themeMode = ThemeMode.system,
    this.preset = AppThemePreset.pne,
    this.fontFamily,
    this.textScale = 1.0,
  });

  factory ThemeState.fromJson(Map<String, dynamic> json) {
    return ThemeState(
      themeMode:
          ThemeMode.values.asNameMap()[json['themeMode']] ?? ThemeMode.system,
      preset:
          AppThemePreset.values.asNameMap()[json['preset']] ??
          AppThemePreset.pne,
      fontFamily: json['fontFamily'] as String?,
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
    );
  }

  final ThemeMode themeMode;
  final AppThemePreset preset;
  final String? fontFamily;
  final double textScale;

  static const Object _unset = Object();

  ThemeState copyWith({
    ThemeMode? themeMode,
    AppThemePreset? preset,
    Object? fontFamily = _unset,
    double? textScale,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      preset: preset ?? this.preset,
      fontFamily: identical(fontFamily, _unset)
          ? this.fontFamily
          : fontFamily as String?,
      textScale: textScale ?? this.textScale,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'themeMode': themeMode.name,
    'preset': preset.name,
    'fontFamily': fontFamily,
    'textScale': textScale,
  };

  @override
  List<Object?> get props => [themeMode, preset, fontFamily, textScale];
}
