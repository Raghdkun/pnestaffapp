import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/constants/app_constants.dart';
import 'package:pnestaffapp/core/storage/key_value_storage.dart';
import 'package:pnestaffapp/core/storage/token_storage.dart';
import 'package:pnestaffapp/core/tenant/tenant_allowlist_service.dart';
import 'package:pnestaffapp/core/tenant/tenant_endpoints.dart';
import 'package:pnestaffapp/core/utils/app_logger.dart';

enum TenantSwitchResult { alreadyActive, applied, rejected, unverifiable }

/// Orchestrates switching the active tenant: validates the domain against
/// the allowlist, then clears any session state carried over from the
/// previous tenant before committing the switch. Deliberately has no
/// `AuthBloc`/network-layer dependency — this must be safe to resolve very
/// early in `bootstrap()`, before `NetworkModule.dio`/`AuthInterceptor` are
/// first constructed, without risking constructing them prematurely.
@lazySingleton
class TenantDomainResolver {
  TenantDomainResolver(
    this._endpoints,
    this._allowlist,
    this._tokenStorage,
    this._keyValueStorage,
    this._logger,
  );

  final TenantEndpoints _endpoints;
  final TenantAllowlistService _allowlist;
  final TokenStorage _tokenStorage;
  final KeyValueStorage _keyValueStorage;
  final AppLogger _logger;

  Future<TenantSwitchResult> applyIfValid(String domain) async {
    if (domain == _endpoints.activeDomain) {
      return TenantSwitchResult.alreadyActive;
    }

    final verdict = await _allowlist.validate(domain);
    switch (verdict) {
      case AllowlistVerdict.rejected:
        _logger.w('Rejected unknown tenant domain: $domain');
        return TenantSwitchResult.rejected;
      case AllowlistVerdict.unverifiable:
        _logger.w(
          'Could not verify tenant domain (offline, no cache): $domain',
        );
        return TenantSwitchResult.unverifiable;
      case AllowlistVerdict.allowed:
        // Prevent a stale Company-A session/cached employee record from
        // leaking into the just-switched-to Company-B instance.
        await _tokenStorage.clear();
        await _keyValueStorage.remove(StorageKeys.cachedUser);
        await _endpoints.setActiveDomain(domain);
        return TenantSwitchResult.applied;
    }
  }
}
