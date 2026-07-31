import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched at startup to restore + validate the persisted session.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.employeeId, required this.password});

  final int employeeId;
  final String password;

  @override
  List<Object?> get props => [employeeId, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Fired (via [SessionExpiredNotifier]) when a token refresh fails server-side.
class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}

/// Re-fetches the employee profile (`GET /auth/employee/me`).
class AuthRefreshRequested extends AuthEvent {
  const AuthRefreshRequested();
}
