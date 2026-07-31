import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/theme/cubit/theme_state.dart';
import 'package:pnestaffapp/core/theme/theme_presets.dart';

/// Holds and persists the appearance settings. Registered as a global singleton
/// so any screen (e.g. appearance settings) can drive the app's look.
@lazySingleton
class ThemeCubit extends HydratedCubit<ThemeState> {
  ThemeCubit() : super(const ThemeState());

  /// Text-scale bounds (accessibility-safe).
  static const double minTextScale = 0.8;
  static const double maxTextScale = 1.6;

  void setThemeMode(ThemeMode mode) => emit(state.copyWith(themeMode: mode));

  void setPreset(AppThemePreset preset) => emit(state.copyWith(preset: preset));

  /// Pass `null` to fall back to the default font.
  void setFontFamily(String? fontFamily) =>
      emit(state.copyWith(fontFamily: fontFamily));

  void setTextScale(double scale) => emit(
    state.copyWith(
      textScale: scale.clamp(minTextScale, maxTextScale),
    ),
  );

  void reset() => emit(const ThemeState());

  @override
  ThemeState? fromJson(Map<String, dynamic> json) => ThemeState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(ThemeState state) => state.toJson();
}
