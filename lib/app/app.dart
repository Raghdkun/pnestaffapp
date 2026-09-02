import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pnestaffapp/core/di/injection.dart';
import 'package:pnestaffapp/core/notifications/notification_router.dart';
import 'package:pnestaffapp/core/router/app_router.dart';
import 'package:pnestaffapp/core/router/app_routes.dart';
import 'package:pnestaffapp/core/tenant/deep_link_service.dart';
import 'package:pnestaffapp/core/theme/app_theme.dart';
import 'package:pnestaffapp/core/theme/cubit/theme_cubit.dart';
import 'package:pnestaffapp/core/theme/cubit/theme_state.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pnestaffapp/features/tenant/presentation/cubit/tenant_cubit.dart';
import 'package:pnestaffapp/l10n/generated/app_localizations.dart';

/// Root widget. Provides the app-wide singletons (theme + auth) and rebuilds
/// `MaterialApp` whenever the [ThemeCubit] emits, so preset/mode/font/text-scale
/// changes restyle the entire app live.
class PneStaffApp extends StatelessWidget {
  const PneStaffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<ThemeCubit>()),
        BlocProvider.value(value: getIt<AuthBloc>()),
        BlocProvider.value(value: getIt<TenantCubit>()),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  final GoRouter _router = getIt<AppRouter>().router;
  StreamSubscription<String>? _notificationSub;
  StreamSubscription<String>? _deepLinkSub;

  @override
  void initState() {
    super.initState();
    // Deep-link on notification taps (foreground/background + cold start).
    final notificationRouter = getIt<NotificationRouter>();
    _notificationSub = notificationRouter.onSelectRoute.listen(_router.go);
    final initialRoute = notificationRouter.consumeInitialRoute();
    if (initialRoute != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _router.go(initialRoute),
      );
    }

    // Universal/App Link taps while the app is already running. Routed to
    // the "enter domain" screen (rather than applied directly, the way the
    // bootstrap-time cold-start link is) so an active session goes through
    // TenantCubit's logout-first confirmation — see DeepLinkService.
    _deepLinkSub = getIt<DeepLinkService>().onLink.listen(
      (domain) => _router.go('${AppRoutes.enterDomain}?domain=$domain'),
    );
  }

  @override
  void dispose() {
    unawaited(_notificationSub?.cancel() ?? Future<void>.value());
    unawaited(_deepLinkSub?.cancel() ?? Future<void>.value());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp.router(
          title: 'PNE Staff',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(
            themeState.preset,
            fontFamily: themeState.fontFamily,
          ),
          darkTheme: AppTheme.dark(
            themeState.preset,
            fontFamily: themeState.fontFamily,
          ),
          themeMode: themeState.themeMode,
          routerConfig: _router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            // Apply the user's chosen text size app-wide.
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(themeState.textScale),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
