import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pnestaffapp/core/config/flavor.dart';
import 'package:pnestaffapp/core/tenant/tenant_endpoints.dart';
import 'package:pnestaffapp/core/tenant/tenant_storage.dart';

class _MockTenantStorage extends Mock implements TenantStorage {}

void main() {
  late _MockTenantStorage storage;

  setUp(() {
    storage = _MockTenantStorage();
    when(() => storage.writeActiveDomain(any())).thenAnswer((_) async {});
  });

  group('authBaseUrl host templating', () {
    test('dev + default domain uses authtesting host', () {
      when(storage.readActiveDomain).thenReturn(null);
      final endpoints = TenantEndpoints(FlavorConfig.dev(), storage);
      expect(
        endpoints.authBaseUrl.toString(),
        'https://authtesting.lcportal.cloud/api/v1',
      );
    });

    test('staging + default domain uses authtesting host', () {
      when(storage.readActiveDomain).thenReturn(null);
      final endpoints = TenantEndpoints(FlavorConfig.staging(), storage);
      expect(
        endpoints.authBaseUrl.toString(),
        'https://authtesting.lcportal.cloud/api/v1',
      );
    });

    test('prod + default domain never uses authtesting host', () {
      when(storage.readActiveDomain).thenReturn(null);
      final endpoints = TenantEndpoints(FlavorConfig.prod(), storage);
      expect(
        endpoints.authBaseUrl.toString(),
        'https://auth.lcportal.cloud/api/v1',
      );
    });

    test('dev + a real client domain never uses authtesting host', () {
      when(storage.readActiveDomain).thenReturn('bmwgate.ai');
      final endpoints = TenantEndpoints(FlavorConfig.dev(), storage);
      expect(
        endpoints.authBaseUrl.toString(),
        'https://auth.bmwgate.ai/api/v1',
      );
    });

    test('other service base URLs template off the active domain', () {
      when(storage.readActiveDomain).thenReturn('bmwgate.ai');
      final endpoints = TenantEndpoints(FlavorConfig.prod(), storage);
      expect(
        endpoints.dataBaseUrl.toString(),
        'https://data.bmwgate.ai/api/v1',
      );
      expect(
        endpoints.hiringBaseUrl.toString(),
        'https://hiring.bmwgate.ai/api/v1',
      );
      expect(endpoints.wsBaseUrl.toString(), 'wss://ws.bmwgate.ai');
    });
  });

  test('setActiveDomain persists and broadcasts the change', () async {
    when(storage.readActiveDomain).thenReturn(null);
    final endpoints = TenantEndpoints(FlavorConfig.prod(), storage);

    final emitted = <String>[];
    final sub = endpoints.onDomainChanged.listen(emitted.add);

    await endpoints.setActiveDomain('bmwgate.ai');

    expect(endpoints.activeDomain, 'bmwgate.ai');
    verify(() => storage.writeActiveDomain('bmwgate.ai')).called(1);
    await Future<void>.delayed(Duration.zero);
    expect(emitted, ['bmwgate.ai']);

    await sub.cancel();
    endpoints.dispose();
  });

  test('setActiveDomain is a no-op when the domain is unchanged', () async {
    when(storage.readActiveDomain).thenReturn('bmwgate.ai');
    final endpoints = TenantEndpoints(FlavorConfig.prod(), storage);

    await endpoints.setActiveDomain('bmwgate.ai');

    verifyNever(() => storage.writeActiveDomain(any()));
    endpoints.dispose();
  });
}
