import 'dart:async';

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
import 'package:pnestaffapp/features/auth/presentation/forgot_password/forgot_password_cubit.dart';
import 'package:pnestaffapp/features/auth/presentation/forgot_password/forgot_password_state.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ForgotPasswordCubit>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  ForgotPasswordCubit get _cubit => context.read<ForgotPasswordCubit>();

  void _submit(ForgotStep step) {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    switch (step) {
      case ForgotStep.email:
        unawaited(_cubit.requestOtp(_emailController.text.trim()));
      case ForgotStep.otp:
        unawaited(_cubit.verifyOtp(_otpController.text.trim()));
      case ForgotStep.password:
        unawaited(
          _cubit.setNewPassword(
            _passwordController.text,
            _confirmController.text,
          ),
        );
      case ForgotStep.done:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listenWhen: (p, c) =>
          c.errorMessage != null && p.errorMessage != c.errorMessage,
      listener: (context, state) => context.showSnack(state.errorMessage!),
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.forgotPasswordTitle),
            leading: BackButton(
              onPressed: () {
                if (state.step == ForgotStep.otp ||
                    state.step == ForgotStep.password) {
                  _cubit.back();
                } else {
                  context.pop();
                }
              },
            ),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: _buildStep(context, state),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep(BuildContext context, ForgotPasswordState state) {
    final l10n = context.l10n;
    switch (state.step) {
      case ForgotStep.email:
        return _StepColumn(
          icon: Icons.lock_reset_rounded,
          title: l10n.forgotPasswordTitle,
          subtitle: l10n.forgotPasswordEmailPrompt,
          children: [
            AppTextField(
              controller: _emailController,
              label: l10n.emailLabel,
              hint: l10n.emailHint,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(ForgotStep.email),
              validator: _validateEmail,
            ),
            const Gap(AppSpacing.xl),
            PrimaryButton(
              label: l10n.sendCode,
              isLoading: state.isSubmitting,
              onPressed: () => _submit(ForgotStep.email),
            ),
          ],
        );
      case ForgotStep.otp:
        return _StepColumn(
          icon: Icons.mark_email_read_outlined,
          title: l10n.otpTitle,
          subtitle: l10n.otpPrompt(state.email),
          children: [
            AppTextField(
              controller: _otpController,
              label: l10n.otpLabel,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.pin_outlined,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(ForgotStep.otp),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
            ),
            const Gap(AppSpacing.xl),
            PrimaryButton(
              label: l10n.verifyCode,
              isLoading: state.isSubmitting,
              onPressed: () => _submit(ForgotStep.otp),
            ),
            const Gap(AppSpacing.sm),
            TextButton(
              onPressed: state.isSubmitting
                  ? null
                  : () => _cubit.requestOtp(state.email),
              child: Text(l10n.resendCode),
            ),
          ],
        );
      case ForgotStep.password:
        return _StepColumn(
          icon: Icons.password_rounded,
          title: l10n.newPasswordTitle,
          subtitle: l10n.newPasswordPrompt,
          children: [
            AppTextField(
              controller: _passwordController,
              label: l10n.newPasswordLabel,
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              validator: _validatePassword,
            ),
            const Gap(AppSpacing.md),
            AppTextField(
              controller: _confirmController,
              label: l10n.confirmPasswordLabel,
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(ForgotStep.password),
              validator: (v) => v != _passwordController.text
                  ? l10n.passwordsDoNotMatch
                  : null,
            ),
            const Gap(AppSpacing.xl),
            PrimaryButton(
              label: l10n.resetPasswordButton,
              isLoading: state.isSubmitting,
              onPressed: () => _submit(ForgotStep.password),
            ),
          ],
        );
      case ForgotStep.done:
        return _StepColumn(
          icon: Icons.check_circle_outline_rounded,
          title: l10n.passwordResetDoneTitle,
          subtitle: l10n.passwordResetDoneSubtitle,
          children: [
            const Gap(AppSpacing.md),
            PrimaryButton(
              label: l10n.backToSignIn,
              onPressed: () => context.go(AppRoutes.login),
            ),
          ],
        );
    }
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return context.l10n.fieldRequired;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
    return ok ? null : context.l10n.invalidEmail;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return context.l10n.fieldRequired;
    if (value.length < 6) return context.l10n.passwordTooShort(6);
    return null;
  }
}

class _StepColumn extends StatelessWidget {
  const _StepColumn({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(icon, size: 56, color: context.colorScheme.primary),
        const Gap(AppSpacing.lg),
        Text(
          title,
          textAlign: TextAlign.center,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(AppSpacing.xs),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(AppSpacing.xl),
        ...children,
      ],
    );
  }
}
