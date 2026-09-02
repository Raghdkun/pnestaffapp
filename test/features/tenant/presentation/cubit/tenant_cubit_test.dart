import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pnestaffapp/core/error/failures.dart';
import 'package:pnestaffapp/core/network/session_expired_notifier.dart';
import 'package:pnestaffapp/core/tenant/tenant_domain_resolver.dart';
import 'package:pnestaffapp/core/tenant/tenant_endpoints.dart';
import 'package:pnestaffapp/features/auth/domain/entities/employee.dart';
import 'package:pnestaffapp/features/auth/domain/usecases/get_current_user.dart';
import 'package:pnestaffapp/features/auth/domain/usecases/get_profile.dart';
import 'package:pnestaffapp/features/auth/domain/usecases/login.dart';
import 'package:pnestaffapp/features/auth/domain/usecases/logout.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:pnestaffapp/features/tenant/presentation/cubit/tenant_cubit.dart';
import 'package:pnestaffapp/features/tenant/presentation/cubit/tenant_state.dart';

class _MockTenantDomainResolver extends Mock implements TenantDomainResolver {}

class _MockTenantEndpoints extends Mock implements TenantEndpoints {}

class _MockLogin extends Mock implements Login {}

class _MockLogout extends Mock implements Logout {}

class _MockGetCurrentUser extends Mock implements GetCurrentUser {}

class _MockGetProfile extends Mock implements GetProfile {}

void main() {
  late _MockTenantDomainResolver resolver;
  late _MockTenantEndpoints endpoints;
  late _MockLogout logout;
  late _MockGetCurrentUser getCurrentUser;
  late _MockGetProfile getProfile;
  late SessionExpiredNotifier sessionExpired;

  const employee = Employee(
    id: 1,
    firstName: 'Ada',
    lastName: 'Lovelace',
    fullName: 'Ada Lovelace',
  );

  setUp(() {
    resolver = _MockTenantDomainResolver();
    endpoints = _MockTenantEndpoints();
    logout = _MockLogout();
    getCurrentUser = _MockGetCurrentUser();
    getProfile = _MockGetProfile();
    sessionExpired = SessionExpiredNotifier();

    when(() => endpoints.activeDomain).thenReturn('lcportal.cloud');
    when(() => endpoints.onDomainChanged)
        .thenAnswer((_) => const Stream<String>.empty());
    when(logout.call).thenAnswer((_) async => const Right<Failure, void>(null));
  });

  tearDown(() => sessionExpired.dispose());

  AuthBloc buildAuthBloc() =>
      AuthBloc(_MockLogin(), logout, getCurrentUser, getProfile, sessionExpired);

  test('not authenticated: applies directly, no logout dispatched', () async {
    when(getCurrentUser.call)
        .thenAnswer((_) async => const Right<Failure, Employee?>(null));
    final authBloc = buildAuthBloc()..add(const AuthCheckRequested());
    await authBloc.stream.firstWhere(
      (s) => s.status == AuthStatus.unauthenticated,
    );

    when(() => resolver.applyIfValid('bmwgate.ai'))
        .thenAnswer((_) async => TenantSwitchResult.applied);

    final cubit = TenantCubit(resolver, authBloc, endpoints);
    final ok = await cubit.switchDomain('bmwgate.ai');

    expect(ok, true);
    expect(cubit.state.status, TenantStatus.success);
    expect(cubit.state.activeDomain, 'bmwgate.ai');
    verifyNever(logout.call);

    await cubit.close();
    await authBloc.close();
  });

  test('authenticated: logs out before applying the switch', () async {
    when(getCurrentUser.call)
        .thenAnswer((_) async => const Right<Failure, Employee?>(employee));
    when(getProfile.call)
        .thenAnswer((_) async => const Right<Failure, Employee>(employee));
    final authBloc = buildAuthBloc()..add(const AuthCheckRequested());
    await authBloc.stream.firstWhere(
      (s) => s.status == AuthStatus.authenticated,
    );

    when(() => resolver.applyIfValid('bmwgate.ai'))
        .thenAnswer((_) async => TenantSwitchResult.applied);

    final cubit = TenantCubit(resolver, authBloc, endpoints);
    final ok = await cubit.switchDomain('bmwgate.ai');

    expect(ok, true);
    verify(logout.call).called(1);
    expect(authBloc.state.status, AuthStatus.unauthenticated);

    await cubit.close();
    await authBloc.close();
  });

  test('rejected verdict surfaces as a rejected status', () async {
    when(getCurrentUser.call)
        .thenAnswer((_) async => const Right<Failure, Employee?>(null));
    final authBloc = buildAuthBloc()..add(const AuthCheckRequested());
    await authBloc.stream.firstWhere(
      (s) => s.status == AuthStatus.unauthenticated,
    );

    when(() => resolver.applyIfValid('evil.example'))
        .thenAnswer((_) async => TenantSwitchResult.rejected);

    final cubit = TenantCubit(resolver, authBloc, endpoints);
    final ok = await cubit.switchDomain('evil.example');

    expect(ok, false);
    expect(cubit.state.status, TenantStatus.rejected);

    await cubit.close();
    await authBloc.close();
  });
}
