import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/tenant/tenant_storage.dart';
import 'package:pnestaffapp/core/utils/app_logger.dart';

enum AllowlistVerdict { allowed, rejected, unverifiable }

/// Validates a candidate tenant domain against the allowlist served from the
/// first-party host (`/known-domains.json`) before the app trusts it for
/// login. Takes a dedicated `@Named('allowlist')` [Dio] (see
/// `NetworkModule.allowlistDio`) rather than the DI-managed tenant-aware one:
/// that Dio's `baseUrl` is itself derived from the tenant being validated
/// here (a circular dependency), and its `AuthInterceptor` would attach a
/// stale/wrong-tenant bearer token to what must be a public, unauthenticated
/// request.
@lazySingleton
class TenantAllowlistService {
  TenantAllowlistService(
    @Named('allowlist') this._dio,
    this._storage,
    this._logger,
  );

  final Dio _dio;
  final TenantStorage _storage;
  final AppLogger _logger;

  static const Duration _cacheTtl = Duration(hours: 24);

  /// * fresh cache → checked against the cache only, no network call.
  /// * stale/absent cache → fetches `/known-domains.json`; refreshes the
  ///   cache on success.
  /// * fetch fails but a (possibly stale) cache exists → falls back to it
  ///   (offline-safe for an already-configured tenant).
  /// * fetch fails and no cache exists at all (true first launch, offline) →
  ///   [AllowlistVerdict.unverifiable] — never silently accepted.
  Future<AllowlistVerdict> validate(
    String domain, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final cachedAt = _storage.readAllowlistCachedAt();
    final cache = _storage.readAllowlistCache();
    final cacheFresh =
        cachedAt != null && DateTime.now().difference(cachedAt) < _cacheTtl;

    if (cacheFresh && cache != null) {
      return _verdict(cache, domain);
    }

    try {
      final response = await _dio
          .get<Map<String, dynamic>>('/known-domains.json')
          .timeout(timeout);
      final domains = (response.data?['domains'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();
      await _storage.writeAllowlistCache(domains);
      return _verdict(domains, domain);
    } on Object catch (e, s) {
      _logger.w(
        'Tenant allowlist fetch failed, falling back to cache',
        error: e,
        stackTrace: s,
      );
      return cache == null
          ? AllowlistVerdict.unverifiable
          : _verdict(cache, domain);
    }
  }

  AllowlistVerdict _verdict(List<String> domains, String domain) =>
      domains.contains(domain)
      ? AllowlistVerdict.allowed
      : AllowlistVerdict.rejected;
}
