import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/tenant/tenant_domain_resolver.dart';
import 'package:pnestaffapp/core/utils/app_logger.dart';

/// Ingests `https://auth.lcportal.cloud/open?domain=<clientDomain>` Universal
/// / App Links.
///
/// The cold-start path ([handleInitialLink]) is awaited directly from
/// `bootstrap()` — before `AuthBloc`'s session check, and therefore before
/// anything has read `AuthBloc.state` — so it's safe to apply the tenant
/// switch directly via [TenantDomainResolver].
///
/// The warm-app path ([onLink]) fires while the app (and `AuthBloc`'s
/// possibly-authenticated state) already exists, so it deliberately does
/// NOT apply the switch itself — the root widget routes it to the
/// "enter domain" screen instead, which goes through `TenantCubit` so a
/// live session is logged out (with confirmation) before the switch,
/// keeping `AuthBloc` state and the cleared token storage in sync.
@lazySingleton
class DeepLinkService {
  DeepLinkService(this._resolver, this._logger) : _appLinks = AppLinks();

  final TenantDomainResolver _resolver;
  final AppLogger _logger;
  final AppLinks _appLinks;

  static final RegExp _hostPattern = RegExp(
    '^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
    r'(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
  );

  /// Validated tenant domains extracted from links tapped while the app is
  /// already running.
  Stream<String> get onLink => _appLinks.uriLinkStream
      .map(_extractDomain)
      .where((domain) => domain != null)
      .cast<String>();

  Future<void> handleInitialLink() async {
    final uri = await _appLinks.getInitialLink();
    final domain = uri == null ? null : _extractDomain(uri);
    if (domain != null) await _resolver.applyIfValid(domain);
  }

  String? _extractDomain(Uri uri) {
    if (uri.path != '/open') return null;
    final domain = uri.queryParameters['domain']?.trim();
    if (domain == null || domain.isEmpty) return null;
    if (!_hostPattern.hasMatch(domain)) {
      _logger.w('Ignoring malformed tenant domain in deep link: $domain');
      return null;
    }
    return domain;
  }
}
