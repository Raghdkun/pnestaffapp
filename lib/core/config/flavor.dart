import 'package:flutter/foundation.dart';

/// Build flavors. Each maps to an Android product flavor, an iOS scheme, and a
/// Dart entry point (`main_<flavor>.dart`). Also used as the injectable
/// environment name so DI can swap flavor-specific bindings.
enum Flavor { dev, staging, prod }

/// Immutable, per-environment configuration. Registered in DI as a singleton so
/// any layer (e.g. the Dio client) can read the active base URL / feature flags
/// without importing entry-point code.
@immutable
class FlavorConfig {
  const FlavorConfig({
    required this.flavor,
    required this.appName,
    required this.baseUrl,
    this.enableNetworkLogs = false,
    this.enableCrashReporting = true,
  });

  factory FlavorConfig.dev() => const FlavorConfig(
    flavor: Flavor.dev,
    appName: 'PNE Staff Dev',
    baseUrl: 'https://authtesting.lcportal.cloud/api/v1',
    enableNetworkLogs: true,
    enableCrashReporting: false,
  );

  factory FlavorConfig.staging() => const FlavorConfig(
    flavor: Flavor.staging,
    appName: 'PNE Staff Stg',
    baseUrl: 'https://authtesting.lcportal.cloud/api/v1',
    enableNetworkLogs: true,
  );

  factory FlavorConfig.prod() => const FlavorConfig(
    flavor: Flavor.prod,
    appName: 'PNE Staff',
    baseUrl: 'https://auth.lcportal.cloud/api/v1',
  );

  final Flavor flavor;
  final String appName;
  final String baseUrl;
  final bool enableNetworkLogs;
  final bool enableCrashReporting;

  bool get isDev => flavor == Flavor.dev;
  bool get isStaging => flavor == Flavor.staging;
  bool get isProd => flavor == Flavor.prod;

  /// The injectable environment name used by `configureDependencies`.
  String get environment => flavor.name;
}
