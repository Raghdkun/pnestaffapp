import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pnestaffapp/core/error/failures.dart';
import 'package:pnestaffapp/core/network/session_expired_notifier.dart';
import 'package:pnestaffapp/features/auth/domain/entities/employee.dart';
import 'package:pnestaffapp/features/auth/domain/usecases/get_current_user.dart';
import 'package:pnestaffapp/features/auth/domain/usecases/get_profile.dart';
import 'package:pnestaffapp/features/auth/domain/usecases/login.dart';
import 'package:pnestaffapp/features/auth/domain/usecases/logout.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_state.dart';

class _MockLogin extends Mock implements Login {}

class _MockLogout extends Mock implements Logout {}

class _MockGetCurrentUser extends Mock implements GetCurrentUser {}

class _MockGetProfile extends Mock implements GetProfile {}

void main() {
  late _MockLogin login;
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
    login = _MockLogin();
    logout = _MockLogout();
    getCurrentUser = _MockGetCurrentUser();
    getProfile = _MockGetProfile();
    sessionExpired = SessionExpiredNotifier();
  });

  tearDown(() => sessionExpired.dispose());

  AuthBloc buildBloc() =>
      AuthBloc(login, logout, getCurrentUser, getProfile, sessionExpired);

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'authenticated when cache + server agree',
      setUp: () {
        when(getCurrentUser.call)
            .thenAnswer((_) async => const Right<Failure, Employee?>(employee));
        when(getProfile.call)
            .thenAnswer((_) async => const Right<Failure, Employee>(employee));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.employee, 'employee', employee),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'unauthenticated when there is no cached session',
      setUp: () => when(getCurrentUser.call)
          .thenAnswer((_) async => const Right<Failure, Employee?>(null)),
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated),
      ],
    );
  });

  group('AuthLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [submitting, authenticated] on success',
      setUp: () => when(
        () => login(
          employeeId: any(named: 'employeeId'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Right<Failure, Employee>(employee)),
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const AuthLoginRequested(employeeId: 1, password: 'secret1')),
      expect: () => [
        isA<AuthState>().having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<AuthState>()
            .having((s) => s.isSubmitting, 'isSubmitting', false)
            .having((s) => s.status, 'status', AuthStatus.authenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [submitting, unauthenticated + error] on failure',
      setUp: () => when(
        () => login(
          employeeId: any(named: 'employeeId'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, Employee>(AuthFailure('Invalid credentials')),
      ),
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const AuthLoginRequested(employeeId: 9, password: 'nope12')),
      expect: () => [
        isA<AuthState>().having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated)
            .having((s) => s.errorMessage, 'errorMessage', 'Invalid credentials'),
      ],
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'clears the session',
      setUp: () => when(logout.call)
          .thenAnswer((_) async => const Right<Failure, void>(null)),
      seed: () =>
          const AuthState(status: AuthStatus.authenticated, employee: employee),
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated)
            .having((s) => s.employee, 'employee', null),
      ],
    );
  });
}
