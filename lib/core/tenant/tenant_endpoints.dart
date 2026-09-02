import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/config/flavor.dart';
import 'package:pnestaffapp/core/tenant/tenant_storage.dart';

/// The default (first-party) root domain — the only one dev/staging are
/// allowed to resolve through the `authtesting.` host instead of `auth.`.
const String defaultTenantDomain = 'lcportal.cloud';

/// Live, runtime-resolved service base URLs for the active tenant. Replaces
/// the old compile-time `FlavorConfig.baseUrl`: every base URL here is a pure
/// function of [activeDomain], recomputed on every read (never cached into a
/// stored full URL), so a later change to the subdomain convention only needs
/// to change this class, not every persisted install.
///
/// [NetworkModule.dio] and [AuthInterceptor] read [authBaseUrl] at
/// construction and again on every [onDomainChanged] event to keep their
/// live `Dio` instances' `baseUrl` in sync without rebuilding the DI graph.
@lazySingleton
class TenantEndpoints {
  TenantEndpoints(this._flavorConfig, this._storage)
    : _activeDomain = _storage.readActiveDomain() ?? defaultTenantDomain;

  final FlavorConfig _flavorConfig;
  final TenantStorage _storage;

  String _activeDomain;

  final StreamController<String> _domainChanges =
      StreamController<String>.broadcast();

  /// The active tenant's root domain, e.g. `lcportal.cloud` or `bmwgate.ai`.
  String get activeDomain => _activeDomain;

  /// Emits the new active domain whenever [setActiveDomain] changes it.
  Stream<String> get onDomainChanged => _domainChanges.stream;

  /// Only the default domain keeps the legacy `authtesting.` host for
  /// dev/staging — a real client domain has no "authtesting" deployment.
  String get _authHost {
    final useTestingHost =
        _activeDomain == defaultTenantDomain &&
        (_flavorConfig.isDev || _flavorConfig.isStaging);
    return useTestingHost ? 'authtesting.$_activeDomain' : 'auth.$_activeDomain';
  }

  Uri get authBaseUrl => Uri.parse('https://$_authHost/api/v1');

  /// Not yet consumed by any data source — exposed now so features that
  /// need the data/hiring/websocket services later don't need another
  /// runtime-config migration.
  Uri get dataBaseUrl => Uri.parse('https://data.$_activeDomain/api/v1');

  Uri get hiringBaseUrl => Uri.parse('https://hiring.$_activeDomain/api/v1');

  Uri get wsBaseUrl => Uri.parse('wss://ws.$_activeDomain');

  Future<void> setActiveDomain(String domain) async {
    if (domain == _activeDomain) return;
    _activeDomain = domain;
    await _storage.writeActiveDomain(domain);
    _domainChanges.add(domain);
  }

  @disposeMethod
  void dispose() => _domainChanges.close();
}
