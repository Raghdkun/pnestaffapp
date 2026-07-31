import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/error/failures.dart';
import 'package:pnestaffapp/core/network/session_expired_notifier.dart';
import 'package:pnestaffapp/features/auth/domain/usecases/get_current_user.dart';
import 'package:pnestaffapp/features/auth/domain/usecases/get_profile.dart';
import 'package:pnestaffapp/features/auth/domain/usecases/login.dart';
import 'package:pnestaffapp/features/auth/domain/usecases/logout.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_state.dart';

/// App-wide auth state. Singleton so the router guard and every screen observe
/// one instance; `GoRouter.refreshListenable` watches its stream.
@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._login,
    this._logout,
    this._getCurrentUser,
    this._getProfile,
    this._sessionExpired,
  ) : super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested, transformer: droppable());
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSessionExpired>(_onSessionExpired);
    on<AuthRefreshRequested>(_onRefreshRequested);

    _sessionSub = _sessionExpired.onUnauthorized.listen(
      (_) => add(const AuthSessionExpired()),
    );
  }

  final Login _login;
  final Logout _logout;
  final GetCurrentUser _getCurrentUser;
  final GetProfile _getProfile;
  final SessionExpiredNotifier _sessionExpired;

  late final StreamSubscription<void> _sessionSub;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final cached = (await _getCurrentUser()).fold((_) => null, (e) => e);
    if (cached == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, employee: null));
      return;
    }
    emit(state.copyWith(status: AuthStatus.authenticated, employee: cached));

    (await _getProfile()).fold(
      (failure) {
        if (failure is AuthFailure) {
          emit(
            state.copyWith(
              status: AuthStatus.unauthenticated,
              employee: null,
            ),
          );
        }
      },
      (employee) => emit(
        state.copyWith(status: AuthStatus.authenticated, employee: employee),
      ),
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(isSubmitting: true, errorMessage: null, fieldErrors: null),
    );
    final result = await _login(
      employeeId: event.employeeId,
      password: event.password,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isSubmitting: false,
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
          fieldErrors: failure is ValidationFailure
              ? failure.fieldErrors
              : null,
        ),
      ),
      (employee) => emit(
        state.copyWith(
          isSubmitting: false,
          status: AuthStatus.authenticated,
          employee: employee,
          errorMessage: null,
          fieldErrors: null,
        ),
      ),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout();
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        employee: null,
        errorMessage: null,
        fieldErrors: null,
      ),
    );
  }

  void _onSessionExpired(AuthSessionExpired event, Emitter<AuthState> emit) {
    if (state.status == AuthStatus.authenticated) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, employee: null));
    }
  }

  Future<void> _onRefreshRequested(
    AuthRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    (await _getProfile()).fold(
      (_) {},
      (employee) => emit(
        state.copyWith(status: AuthStatus.authenticated, employee: employee),
      ),
    );
  }

  @override
  Future<void> close() {
    unawaited(_sessionSub.cancel());
    return super.close();
  }
}
