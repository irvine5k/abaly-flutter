import 'package:abaly/features/auth/cubit/auth_cubit.dart';
import 'package:abaly/features/auth/cubit/auth_state.dart';
import 'package:abaly/features/auth/data/auth_repository.dart';
import 'package:abaly/shared/models/app_user.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  const testUser = AppUser(
    id: 'user-1',
    email: 'test@example.com',
    fullName: 'Test User',
    role: UserRole.therapist,
    organizationId: 'org-1',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
  });

  group('AuthCubit', () {
    blocTest<AuthCubit, AuthState>(
      'initial state is AuthInitial',
      build: () => AuthCubit(authRepository: mockAuthRepository),
      verify: (cubit) => expect(cubit.state, const AuthInitial()),
    );

    group('signIn', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on successful signIn',
        build: () {
          when(() => mockAuthRepository.signIn(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenAnswer((_) async => testUser);
          return AuthCubit(authRepository: mockAuthRepository);
        },
        act: (cubit) => cubit.signIn(
          email: 'test@example.com',
          password: 'password123',
        ),
        expect: () => [
          const AuthLoading(),
          const AuthAuthenticated(testUser),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] on failed signIn',
        build: () {
          when(() => mockAuthRepository.signIn(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenThrow(Exception('Invalid credentials'));
          return AuthCubit(authRepository: mockAuthRepository);
        },
        act: (cubit) => cubit.signIn(
          email: 'test@example.com',
          password: 'wrong',
        ),
        expect: () => [
          const AuthLoading(),
          isA<AuthError>(),
        ],
      );
    });

    group('signUp', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on successful signUp',
        build: () {
          when(() => mockAuthRepository.signUp(
                email: any(named: 'email'),
                password: any(named: 'password'),
                fullName: any(named: 'fullName'),
              )).thenAnswer((_) async => testUser);
          return AuthCubit(authRepository: mockAuthRepository);
        },
        act: (cubit) => cubit.signUp(
          email: 'test@example.com',
          password: 'password123',
          fullName: 'Test User',
        ),
        expect: () => [
          const AuthLoading(),
          const AuthAuthenticated(testUser),
        ],
      );
    });

    group('signOut', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthUnauthenticated] on signOut',
        build: () {
          when(() => mockAuthRepository.signOut())
              .thenAnswer((_) async {});
          return AuthCubit(authRepository: mockAuthRepository);
        },
        act: (cubit) => cubit.signOut(),
        expect: () => [const AuthUnauthenticated()],
      );
    });

    group('checkAuthStatus', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when user is logged in',
        build: () {
          when(() => mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => testUser);
          return AuthCubit(authRepository: mockAuthRepository);
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          const AuthLoading(),
          const AuthAuthenticated(testUser),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when no user',
        build: () {
          when(() => mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => null);
          return AuthCubit(authRepository: mockAuthRepository);
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
      );
    });
  });
}
