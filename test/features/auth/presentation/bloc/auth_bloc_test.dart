import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_dummyjson_app/core/error/failures.dart';
import 'package:flutter_dummyjson_app/features/auth/domain/entity/user_entity.dart';
import 'package:flutter_dummyjson_app/features/auth/domain/usecase/get_cached_user_usecase.dart';
import 'package:flutter_dummyjson_app/features/auth/domain/usecase/login_usecase.dart';
import 'package:flutter_dummyjson_app/features/auth/domain/usecase/logout_usecase.dart';
import 'package:flutter_dummyjson_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([LoginUseCase, GetCachedUserUseCase, LogoutUseCase])
void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockGetCachedUserUseCase mockGetCachedUserUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late AuthBloc authBloc;

  const tUser = UserEntity(
    id: 1,
    username: 'emilys',
    email: 'emily.johnson@x.dummyjson.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    gender: 'female',
    image: 'https://dummyjson.com/icon/emilys/128',
    accessToken: 'access-token-123',
    refreshToken: 'refresh-token-456',
  );

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockGetCachedUserUseCase = MockGetCachedUserUseCase();
    mockLogoutUseCase = MockLogoutUseCase();

    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      getCachedUserUseCase: mockGetCachedUserUseCase,
      logoutUseCase: mockLogoutUseCase,
    );
  });

  tearDown(() => authBloc.close());

  test('initial state is AuthInitial', () {
    expect(authBloc.state, isA<AuthInitial>());
  });

  group('AuthCheckCachedUser', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when cached user is found',
      build: () {
        when(mockGetCachedUserUseCase()).thenAnswer(
          (_) async => const Right(tUser),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckCachedUser()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
      verify: (_) {
        verify(mockGetCachedUserUseCase()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when no cached user exists',
      build: () {
        when(mockGetCachedUserUseCase()).thenAnswer(
          (_) async => const Left(CacheFailure()),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckCachedUser()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'AuthAuthenticated carries the correct user',
      build: () {
        when(mockGetCachedUserUseCase()).thenAnswer(
          (_) async => const Right(tUser),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckCachedUser()),
      expect: () => [
        isA<AuthLoading>(),
        const AuthAuthenticated(tUser),
      ],
    );
  });

  group('AuthLoginRequested', () {
    const tUsername = 'emilys';
    const tPassword = 'emilyspass';

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful login',
      build: () {
        when(mockLoginUseCase(username: tUsername, password: tPassword))
            .thenAnswer((_) async => const Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(username: tUsername, password: tPassword),
      ),
      expect: () => [
        isA<AuthLoading>(),
        const AuthAuthenticated(tUser),
      ],
      verify: (_) {
        verify(mockLoginUseCase(username: tUsername, password: tPassword))
            .called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on ServerFailure',
      build: () {
        when(mockLoginUseCase(username: tUsername, password: tPassword))
            .thenAnswer(
          (_) async => const Left(
              ServerFailure('Server error occurred. Please try again.')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(username: tUsername, password: tPassword),
      ),
      expect: () => [
        isA<AuthLoading>(),
        const AuthError('Server error occurred. Please try again.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on AuthFailure',
      build: () {
        when(mockLoginUseCase(username: tUsername, password: tPassword))
            .thenAnswer(
          (_) async => const Left(AuthFailure()),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(username: tUsername, password: tPassword),
      ),
      expect: () => [
        isA<AuthLoading>(),
        const AuthError(
            'Authentication failed. Please check your credentials.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on NetworkFailure',
      build: () {
        when(mockLoginUseCase(username: tUsername, password: tPassword))
            .thenAnswer(
          (_) async => const Left(NetworkFailure()),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(username: tUsername, password: tPassword),
      ),
      expect: () => [
        isA<AuthLoading>(),
        const AuthError('No internet connection. Please check your network.'),
      ],
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] after logout',
      build: () {
        when(mockLogoutUseCase()).thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      expect: () => [
        isA<AuthUnauthenticated>(),
      ],
      verify: (_) {
        verify(mockLogoutUseCase()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] even when logged out from authenticated state',
      build: () {
        when(mockLogoutUseCase()).thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      seed: () => const AuthAuthenticated(tUser),
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      expect: () => [
        isA<AuthUnauthenticated>(),
      ],
    );
  });

  group('AuthState equality', () {
    test('AuthAuthenticated with same user are equal', () {
      expect(const AuthAuthenticated(tUser), const AuthAuthenticated(tUser));
    });

    test('AuthError with same message are equal', () {
      expect(
        const AuthError('some error'),
        const AuthError('some error'),
      );
    });

    test('AuthError with different messages are not equal', () {
      expect(
        const AuthError('error A'),
        isNot(const AuthError('error B')),
      );
    });
  });
}
