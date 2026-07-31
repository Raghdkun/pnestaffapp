import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/router/app_routes.dart';
import 'package:pnestaffapp/core/router/go_router_refresh_stream.dart';
import 'package:pnestaffapp/core/router/transitions.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:pnestaffapp/features/auth/presentation/forgot_password/forgot_password_page.dart';
import 'package:pnestaffapp/features/auth/presentation/view/login_page.dart';
import 'package:pnestaffapp/features/home/presentation/view/home_page.dart';
import 'package:pnestaffapp/features/notifications/presentation/view/notifications_page.dart';
import 'package:pnestaffapp/features/profile/presentation/view/profile_page.dart';
import 'package:pnestaffapp/features/settings/presentation/view/appearance_page.dart';
import 'package:pnestaffapp/features/settings/presentation/view/settings_page.dart';
import 'package:pnestaffapp/features/shell/presentation/app_shell.dart';

/// Central navigation. The [AuthBloc]-driven [_redirect] guard gates the whole
/// authenticated area; `refreshListenable` re-runs it on sign-in/out. Every
/// route uses a fade-through transition ([fadeThroughPage]).
@lazySingleton
class AppRouter {
  AppRouter(this._authBloc);

  final AuthBloc _authBloc;

  static final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final _homeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
  static final _notificationsKey = GlobalKey<NavigatorState>(
    debugLabel: 'notifications',
  );
  static final _settingsKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

  late final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.home,
    refreshListenable: GoRouterRefreshStream(_authBloc.stream),
    redirect: _redirect,
    errorBuilder: (context, state) =>
        _RouterErrorScreen(message: '${state.error}'),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        pageBuilder: (context, state) =>
            fadeThroughPage(state, const LoginPage()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPasswordName,
        pageBuilder: (context, state) =>
            fadeThroughPage(state, const ForgotPasswordPage()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: AppRoutes.homeName,
                pageBuilder: (context, state) =>
                    fadeThroughPage(state, const HomePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _notificationsKey,
            routes: [
              GoRoute(
                path: AppRoutes.notifications,
                name: AppRoutes.notificationsName,
                pageBuilder: (context, state) =>
                    fadeThroughPage(state, const NotificationsPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _settingsKey,
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                name: AppRoutes.settingsName,
                pageBuilder: (context, state) =>
                    fadeThroughPage(state, const SettingsPage()),
                routes: [
                  GoRoute(
                    path: 'appearance',
                    name: AppRoutes.appearanceName,
                    pageBuilder: (context, state) =>
                        fadeThroughPage(state, const AppearancePage()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.profileName,
        parentNavigatorKey: _rootKey,
        pageBuilder: (context, state) =>
            fadeThroughPage(state, const ProfilePage()),
      ),
    ],
  );

  /// Unauthenticated users are pushed to /login (except the public /login and
  /// /forgot-password screens); authenticated users are kept out of them.
  /// `unknown` (session still resolving) makes no decision.
  String? _redirect(BuildContext context, GoRouterState state) {
    final status = _authBloc.state.status;
    if (status == AuthStatus.unknown) return null;

    final location = state.matchedLocation;
    final isPublic =
        location == AppRoutes.login || location == AppRoutes.forgotPassword;
    final isLoggedIn = status == AuthStatus.authenticated;

    if (!isLoggedIn) return isPublic ? null : AppRoutes.login;
    if (isPublic) return AppRoutes.home;
    return null;
  }
}

class _RouterErrorScreen extends StatelessWidget {
  const _RouterErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text(message)),
    );
  }
}
