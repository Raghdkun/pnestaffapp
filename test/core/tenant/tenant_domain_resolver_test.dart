import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pnestaffapp/core/constants/app_constants.dart';
import 'package:pnestaffapp/core/storage/key_value_storage.dart';
import 'package:pnestaffapp/core/storage/token_storage.dart';
import 'package:pnestaffapp/core/tenant/tenant_allowlist_service.dart';
import 'package:pnestaffapp/core/tenant/tenant_domain_resolver.dart';
import 'package:pnestaffapp/core/tenant/tenant_endpoints.dart';
import 'package:pnestaffapp/core/utils/app_logger.dart';

class _MockTenantEndpoints extends Mock implements TenantEndpoints {}

class _MockTenantAllowlistService extends Mock
    implements TenantAllowlistService {}

class _MockTokenStorage extends Mock implements TokenStorage {}

class _MockKeyValueStorage extends Mock implements KeyValueStorage {}

class _MockAppLogger extends Mock implements AppLogger {}

void main() {
  late _MockTenantEndpoints endpoints;
  late _MockTenantAllowlistService allowlist;
  late _MockTokenStorage tokenStorage;
  late _MockKeyValueStorage keyValueStorage;
  late TenantDomainResolver resolver;

  setUp(() {
    endpoints = _MockTenantEndpoints();
    allowlist = _MockTenantAllowlistService();
    tokenStorage = _MockTokenStorage();
    keyValueStorage = _MockKeyValueStorage();
    resolver = TenantDomainResolver(
      endpoints,
      allowlist,
      tokenStorage,
      keyValueStorage,
      _MockAppLogger(),
    );

    when(() => endpoints.activeDomain).thenReturn('lcportal.cloud');
    when(() => endpoints.setActiveDomain(any())).thenAnswer((_) async {});
    when(tokenStorage.clear).thenAnswer((_) async {});
    when(() => keyValueStorage.remove(any())).thenAnswer((_) async {});
  });

  test('no-ops when the domain is already active', () async {
    final result = await resolver.applyIfValid('lcportal.cloud');

    expect(result, TenantSwitchResult.alreadyActive);
    verifyNever(() => allowlist.validate(any()));
    verifyNever(tokenStorage.clear);
  });

  test('allowed: clears the previous session before switching', () async {
    when(() => allowlist.validate('bmwgate.ai'))
        .thenAnswer((_) async => AllowlistVerdict.allowed);

    final result = await resolver.applyIfValid('bmwgate.ai');

    expect(result, TenantSwitchResult.applied);
    verify(tokenStorage.clear).called(1);
    verify(() => keyValueStorage.remove(StorageKeys.cachedUser)).called(1);
    verify(() => endpoints.setActiveDomain('bmwgate.ai')).called(1);
  });

  test('rejected: leaves the current session and tenant untouched', () async {
    when(() => allowlist.validate('evil.example'))
        .thenAnswer((_) async => AllowlistVerdict.rejected);

    final result = await resolver.applyIfValid('evil.example');

    expect(result, TenantSwitchResult.rejected);
    verifyNever(tokenStorage.clear);
    verifyNever(() => endpoints.setActiveDomain(any()));
  });

  test('unverifiable: leaves the current session and tenant untouched', () async {
    when(() => allowlist.validate('bmwgate.ai'))
        .thenAnswer((_) async => AllowlistVerdict.unverifiable);

    final result = await resolver.applyIfValid('bmwgate.ai');

    expect(result, TenantSwitchResult.unverifiable);
    verifyNever(tokenStorage.clear);
    verifyNever(() => endpoints.setActiveDomain(any()));
  });
}
