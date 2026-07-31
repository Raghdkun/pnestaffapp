import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:pnestaffapp/core/extensions/context_extensions.dart';
import 'package:pnestaffapp/core/theme/cubit/theme_cubit.dart';
import 'package:pnestaffapp/core/theme/cubit/theme_state.dart';
import 'package:pnestaffapp/core/theme/theme_presets.dart';
import 'package:pnestaffapp/core/theme/tokens/app_spacing.dart';
import 'package:pnestaffapp/core/theme/tokens/app_typography.dart';

/// Live theming controls. Every change goes through [ThemeCubit], which persists
/// it (HydratedBloc) and rebuilds `MaterialApp` with fresh `ThemeData`.
class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ThemeCubit>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appearanceTitle)),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _SectionLabel(l10n.themeModeLabel),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(l10n.themeModeSystem),
                    icon: const Icon(Icons.brightness_auto_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(l10n.themeModeLight),
                    icon: const Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(l10n.themeModeDark),
                    icon: const Icon(Icons.dark_mode_outlined),
                  ),
                ],
                selected: {state.themeMode},
                onSelectionChanged: (selection) =>
                    cubit.setThemeMode(selection.first),
              ),
              const Gap(AppSpacing.lg),
              _SectionLabel(l10n.themePresetLabel),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final preset in AppThemePreset.values)
                    ChoiceChip(
                      label: Text(preset.label),
                      selected: state.preset == preset,
                      avatar: CircleAvatar(
                        backgroundColor: preset.seed,
                        radius: 8,
                      ),
                      onSelected: (_) => cubit.setPreset(preset),
                    ),
                ],
              ),
              const Gap(AppSpacing.lg),
              _SectionLabel(l10n.fontLabel),
              DropdownButtonFormField<String>(
                initialValue:
                    state.fontFamily ?? AppTypography.defaultFontFamily,
                items: [
                  for (final font in AppTypography.availableFonts)
                    DropdownMenuItem(value: font, child: Text(font)),
                ],
                onChanged: cubit.setFontFamily,
              ),
              const Gap(AppSpacing.lg),
              _SectionLabel(l10n.textScaleLabel),
              Slider(
                value: state.textScale,
                min: ThemeCubit.minTextScale,
                max: ThemeCubit.maxTextScale,
                divisions: 8,
                label: '${(state.textScale * 100).round()}%',
                onChanged: cubit.setTextScale,
              ),
              Center(
                child: Text(
                  'The quick brown fox',
                  style: context.textTheme.titleMedium,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text.toUpperCase(),
        style: context.textTheme.labelMedium?.copyWith(
          color: context.colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
