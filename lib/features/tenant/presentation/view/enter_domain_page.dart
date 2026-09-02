import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:pnestaffapp/core/di/injection.dart';
import 'package:pnestaffapp/core/extensions/context_extensions.dart';
import 'package:pnestaffapp/core/router/app_routes.dart';
import 'package:pnestaffapp/core/theme/tokens/app_spacing.dart';
import 'package:pnestaffapp/core/widgets/app_text_field.dart';
import 'package:pnestaffapp/core/widgets/primary_button.dart';
import 'package:pnestaffapp/features/tenant/presentation/cubit/tenant_cubit.dart';
import 'package:pnestaffapp/features/tenant/presentation/cubit/tenant_state.dart';

/// Manual "join/change company" screen — reached either by the user tapping
/// "not your company?" on the login screen, or by a deep link tapped while
/// the app is already running (which prefills [prefillDomain] rather than
/// applying the switch directly, so an active session goes through
/// [TenantCubit.switchDomain]'s logout-first confirmation instead of being
/// silently dropped).
class EnterDomainPage extends StatelessWidget {
  const EnterDomainPage({this.prefillDomain, super.key});

  final String? prefillDomain;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<TenantCubit>(),
      child: _EnterDomainView(prefillDomain: prefillDomain),
    );
  }
}

class _EnterDomainView extends StatefulWidget {
  const _EnterDomainView({this.prefillDomain});

  final String? prefillDomain;

  @override
  State<_EnterDomainView> createState() => _EnterDomainViewState();
}

class _EnterDomainViewState extends State<_EnterDomainView> {
  late final _domainController = TextEditingController(
    text: widget.prefillDomain ?? '',
  );
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await context.read<TenantCubit>().switchDomain(
      _domainController.text,
    );
    if (ok && mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<TenantCubit, TenantState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        switch (state.status) {
          case TenantStatus.rejected:
            context.showSnack(l10n.domainNotRecognized);
          case TenantStatus.unverifiable:
            context.showSnack(l10n.domainCheckFailed);
          case TenantStatus.idle:
          case TenantStatus.validating:
          case TenantStatus.success:
            break;
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.enterDomainTitle),
            leading: context.canPop() ? const BackButton() : null,
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.domain_outlined,
                          size: 56,
                          color: context.colorScheme.primary,
                        ),
                        const Gap(AppSpacing.lg),
                        Text(
                          l10n.enterDomainPrompt,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Gap(AppSpacing.xxl),
                        AppTextField(
                          controller: _domainController,
                          label: l10n.domainLabel,
                          hint: l10n.domainHint,
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          prefixIcon: Icons.language_outlined,
                          onFieldSubmitted: (_) => _submit(),
                          validator: _validateDomain,
                        ),
                        const Gap(AppSpacing.xl),
                        PrimaryButton(
                          label: l10n.continueButton,
                          isLoading: state.isSubmitting,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String? _validateDomain(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return context.l10n.fieldRequired;
    final ok = RegExp(
      '^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
      r'(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
    ).hasMatch(text);
    return ok ? null : context.l10n.invalidDomain;
  }
}
