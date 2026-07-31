import 'package:flutter/material.dart';
import 'package:pnestaffapp/core/theme/extensions/app_colors_x.dart';
import 'package:pnestaffapp/core/theme/theme_presets.dart';
import 'package:pnestaffapp/core/theme/tokens/app_radii.dart';
import 'package:pnestaffapp/core/theme/tokens/app_spacing.dart';
import 'package:pnestaffapp/core/theme/tokens/app_typography.dart';

/// Assembles a [ThemeData] from design tokens + a [AppThemePreset] + a font.
/// Everything visual is derived here, so restyling the app is a matter of
/// changing tokens or emitting a new preset/font from the ThemeCubit.
abstract final class AppTheme {
  static ThemeData light(AppThemePreset preset, {String? fontFamily}) => _build(
    preset: preset,
    brightness: Brightness.light,
    fontFamily: fontFamily,
  );

  static ThemeData dark(AppThemePreset preset, {String? fontFamily}) => _build(
    preset: preset,
    brightness: Brightness.dark,
    fontFamily: fontFamily,
  );

  static ThemeData _build({
    required AppThemePreset preset,
    required Brightness brightness,
    String? fontFamily,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: preset.seed,
      brightness: brightness,
    );
    final font = fontFamily ?? AppTypography.defaultFontFamily;
    final textTheme = AppTypography.textTheme(colorScheme, font);
    final appColors = brightness == Brightness.dark
        ? AppColorsX.dark
        : AppColorsX.light;
    final isDark = brightness == Brightness.dark;

    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: AppRadii.brLg,
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[appColors],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.brLg,
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(
              alpha: isDark ? 0.5 : 0.9,
            ),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surfaceContainerLowest,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md + 2,
        ),
        border: inputBorder(colorScheme.outlineVariant),
        enabledBorder: inputBorder(colorScheme.outlineVariant),
        focusedBorder: inputBorder(colorScheme.primary, 1.8),
        errorBorder: inputBorder(colorScheme.error, 1.4),
        focusedErrorBorder: inputBorder(colorScheme.error, 1.8),
        prefixIconColor: colorScheme.onSurfaceVariant,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.brLg),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: colorScheme.outlineVariant),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.brLg),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.brSm),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        height: 68,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        selectedIconTheme: IconThemeData(
          color: colorScheme.onSecondaryContainer,
        ),
        useIndicator: true,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.brMd),
        insetPadding: EdgeInsets.all(AppSpacing.md),
      ),
      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brPill),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    );
  }
}
