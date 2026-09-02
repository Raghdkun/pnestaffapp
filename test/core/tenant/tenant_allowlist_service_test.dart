import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pnestaffapp/core/tenant/tenant_allowlist_service.dart';
import 'package:pnestaffapp/core/tenant/tenant_storage.dart';
import 'package:pnestaffapp/core/utils/app_logger.dart';

class _MockDio extends Mock implements Dio {}

class _MockTenantStorage extends Mock implements TenantStorage {}

class _MockAppLogger extends Mock implements AppLogger {}

void main() {
  late _MockDio dio;
  late _MockTenantStorage storage;
  late _MockAppLogger logger;
  late TenantAllowlistService service;

  Response<Map<String, dynamic>> jsonResponse(List<String> domains) =>
      Response(
        requestOptions: RequestOptions(path: '/known-domains.json'),
        data: {'domains': domains},
      );

  setUp(() {
    dio = _MockDio();
    storage = _MockTenantStorage();
    logger = _MockAppLogger();
    service = TenantAllowlistService(dio, storage, logger);
    when(() => storage.writeAllowlistCache(any())).thenAnswer((_) async {});
  });

  test('fresh cache: allowed without any network call', () async {
    when(storage.readAllowlistCachedAt).thenReturn(DateTime.now());
    when(storage.readAllowlistCache).thenReturn(['lcportal.cloud', 'bmwgate.ai']);

    final verdict = await service.validate('bmwgate.ai');

    expect(verdict, AllowlistVerdict.allowed);
    verifyNever(() => dio.get<Map<String, dynamic>>(any()));
  });

  test('fresh cache: rejected when the domain is absent', () async {
    when(storage.readAllowlistCachedAt).thenReturn(DateTime.now());
    when(storage.readAllowlistCache).thenReturn(['lcportal.cloud']);

    final verdict = await service.validate('evil.example');

    expect(verdict, AllowlistVerdict.rejected);
    verifyNever(() => dio.get<Map<String, dynamic>>(any()));
  });

  test('stale cache: fetches, refreshes the cache, and validates fresh data', () async {
    when(storage.readAllowlistCachedAt)
        .thenReturn(DateTime.now().subtract(const Duration(days: 2)));
    when(storage.readAllowlistCache).thenReturn(['lcportal.cloud']);
    when(() => dio.get<Map<String, dynamic>>('/known-domains.json')).thenAnswer(
      (_) async => jsonResponse(['lcportal.cloud', 'bmwgate.ai']),
    );

    final verdict = await service.validate('bmwgate.ai');

    expect(verdict, AllowlistVerdict.allowed);
    verify(
      () => storage.writeAllowlistCache(['lcportal.cloud', 'bmwgate.ai']),
    ).called(1);
  });

  test('no cache: fetches and validates fresh data', () async {
    when(storage.readAllowlistCachedAt).thenReturn(null);
    when(storage.readAllowlistCache).thenReturn(null);
    when(() => dio.get<Map<String, dynamic>>('/known-domains.json')).thenAnswer(
      (_) async => jsonResponse(['lcportal.cloud', 'bmwgate.ai']),
    );

    final verdict = await service.validate('bmwgate.ai');

    expect(verdict, AllowlistVerdict.allowed);
  });

  test('fetch fails but a stale cache exists: falls back to it', () async {
    when(storage.readAllowlistCachedAt)
        .thenReturn(DateTime.now().subtract(const Duration(days: 2)));
    when(storage.readAllowlistCache).thenReturn(['lcportal.cloud', 'bmwgate.ai']);
    when(() => dio.get<Map<String, dynamic>>('/known-domains.json'))
        .thenThrow(Exception('offline'));

    final verdict = await service.validate('bmwgate.ai');

    expect(verdict, AllowlistVerdict.allowed);
  });

  test('fetch fails and no cache exists at all: unverifiable', () async {
    when(storage.readAllowlistCachedAt).thenReturn(null);
    when(storage.readAllowlistCache).thenReturn(null);
    when(() => dio.get<Map<String, dynamic>>('/known-domains.json'))
        .thenThrow(Exception('offline'));

    final verdict = await service.validate('bmwgate.ai');

    expect(verdict, AllowlistVerdict.unverifiable);
  });
}
