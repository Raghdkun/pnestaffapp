import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/tenant/tenant_domain_resolver.dart';
import 'package:pnestaffapp/core/tenant/tenant_endpoints.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:pnestaffapp/features/tenant/presentation/cubit/tenant_state.dart';

/// Drives the "enter/change company domain" flow and keeps the login
/// screen's "Signing in to `<domain>`" banner live. If a session is active
/// when [switchDomain] is called, it logs out first (via [AuthBloc]) so
/// `AuthBloc` state and the cleared token storage never desync — see
/// `TenantDomainResolver` for why that clearing can't happen silently
/// underneath an authenticated UI.
@lazySingleton
class TenantCubit extends Cubit<TenantState> {
  TenantCubit(this._resolver, AuthBloc authBloc, TenantEndpoints endpoints)
    : _authBloc = authBloc,
      super(TenantState(activeDomain: endpoints.activeDomain)) {
    _domainSub = endpoints.onDomainChanged.listen(
      (domain) => emit(state.copyWith(activeDomain: domain)),
    );
  }

  final TenantDomainResolver _resolver;
  final AuthBloc _authBloc;

  late final StreamSubscription<String> _domainSub;

  Future<bool> switchDomain(String rawInput) async {
    final domain = rawInput.trim().toLowerCase();
    if (domain.isEmpty) return false;

    emit(state.copyWith(status: TenantStatus.validating));

    if (_authBloc.state.isAuthenticated) {
      _authBloc.add(const AuthLogoutRequested());
      await _authBloc.stream.firstWhere(
        (s) => s.status == AuthStatus.unauthenticated,
      );
    }

    final result = await _resolver.applyIfValid(domain);
    switch (result) {
      case TenantSwitchResult.alreadyActive:
      case TenantSwitchResult.applied:
        emit(
          state.copyWith(status: TenantStatus.success, activeDomain: domain),
        );
        return true;
      case TenantSwitchResult.rejected:
        emit(state.copyWith(status: TenantStatus.rejected));
        return false;
      case TenantSwitchResult.unverifiable:
        emit(state.copyWith(status: TenantStatus.unverifiable));
        return false;
    }
  }

  @override
  Future<void> close() {
    unawaited(_domainSub.cancel());
    return super.close();
  }
}
