import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:pnestaffapp/core/extensions/context_extensions.dart';
import 'package:pnestaffapp/core/router/app_routes.dart';
import 'package:pnestaffapp/core/theme/tokens/app_radii.dart';
import 'package:pnestaffapp/core/theme/tokens/app_spacing.dart';
import 'package:pnestaffapp/core/widgets/app_text_field.dart';
import 'package:pnestaffapp/core/widgets/fade_slide_in.dart';
import 'package:pnestaffapp/core/widgets/primary_button.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_state.dart';

/// Employee sign-in (employee id + password). On success the router's auth guard
/// redirects to /home. Errors surface as a snackbar.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _employeeIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final employeeId = int.tryParse(_employeeIdController.text.trim());
    if (employeeId == null) return;
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        employeeId: employeeId,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: BlocConsumer<AuthBloc, AuthState>(
                listenWhen: (previous, current) =>
                    current.errorMessage != null &&
                    previous.errorMessage != current.errorMessage,
                listener: (context, state) =>
                    context.showSnack(state.errorMessage!),
                builder: (context, state) {
                  return FadeSlideIn(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _BrandMark(),
                          const Gap(AppSpacing.lg),
                          Text(
                            l10n.welcomeTitle,
                            textAlign: TextAlign.center,
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(AppSpacing.xs),
                          Text(
                            l10n.welcomeSubtitle,
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Gap(AppSpacing.xxl),
                          AppTextField(
                            controller: _employeeIdController,
                            label: l10n.employeeIdLabel,
                            hint: l10n.employeeIdHint,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.badge_outlined,
                            validator: _validateEmployeeId,
                          ),
                          const Gap(AppSpacing.md),
                          AppTextField(
                            controller: _passwordController,
                            label: l10n.passwordLabel,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            prefixIcon: Icons.lock_outline,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) => _submit(),
                            validator: _validatePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  context.push(AppRoutes.forgotPassword),
                              child: Text(l10n.forgotPassword),
                            ),
                          ),
                          const Gap(AppSpacing.sm),
                          PrimaryButton(
                            label: l10n.loginButton,
                            isLoading: state.isSubmitting,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmployeeId(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return context.l10n.fieldRequired;
    final id = int.tryParse(text);
    if (id == null || id <= 0) return context.l10n.invalidEmployeeId;
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return context.l10n.fieldRequired;
    return null;
  }
}

/// Rounded brand tile used as the login header mark.
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colorScheme.primaryContainer,
          borderRadius: AppRadii.brXl,
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.primary.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(
          Icons.badge_outlined,
          size: 44,
          color: context.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
