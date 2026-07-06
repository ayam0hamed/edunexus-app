import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:grad_project/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grad_project/features/auth/presentation/bloc/auth_event.dart';
import 'package:grad_project/features/auth/presentation/bloc/auth_state.dart';
import 'package:grad_project/features/auth/data/models/login_request.dart';
import 'package:grad_project/features/auth/data/models/login_response.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    registerFallbackValue(const LoginRequest(ssnOrEmail: '', password: ''));
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, const AuthInitial());
  });

  group('AppStarted', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthAuthenticated] when user is already authenticated',
      build: () {
        when(() => mockAuthRepository.isAuthenticated()).thenAnswer((_) async => true);
        when(() => mockAuthRepository.getToken()).thenAnswer((_) async => 'token123');
        when(() => mockAuthRepository.getUserRole()).thenAnswer((_) async => 'Student');
        return authBloc;
      },
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => const [
        AuthAuthenticated(token: 'token123', role: 'Student'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when user is not authenticated',
      build: () {
        when(() => mockAuthRepository.isAuthenticated()).thenAnswer((_) async => false);
        when(() => mockAuthRepository.deleteToken()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => const [
        AuthUnauthenticated(),
      ],
    );
  });

  group('LoginSubmitted', () {
    const ssnOrEmail = 'test@example.com';
    const password = 'password123';

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login is successful and role is valid',
      build: () {
        when(() => mockAuthRepository.login(any())).thenAnswer(
          (_) async => const LoginResponse(success: true, message: 'Success', token: 'token_val'),
        );
        when(() => mockAuthRepository.saveToken(any())).thenAnswer((_) async {});
        when(() => mockAuthRepository.getUserRole()).thenAnswer((_) async => 'Student');
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginSubmitted(ssnOrEmail: ssnOrEmail, password: password, rememberMe: true)),
      expect: () => const [
        AuthLoading(),
        AuthAuthenticated(token: 'token_val', role: 'Student'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login is successful but role is invalid',
      build: () {
        when(() => mockAuthRepository.login(any())).thenAnswer(
          (_) async => const LoginResponse(success: true, message: 'Success', token: 'token_val'),
        );
        when(() => mockAuthRepository.saveToken(any())).thenAnswer((_) async {});
        when(() => mockAuthRepository.getUserRole()).thenAnswer((_) async => 'Admin'); // invalid role
        when(() => mockAuthRepository.deleteToken()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginSubmitted(ssnOrEmail: ssnOrEmail, password: password, rememberMe: true)),
      expect: () => const [
        AuthLoading(),
        AuthError('Invalid user role received from server.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(() => mockAuthRepository.login(any())).thenThrow(Exception('Network Error'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginSubmitted(ssnOrEmail: ssnOrEmail, password: password, rememberMe: true)),
      expect: () => const [
        AuthLoading(),
        AuthError('Exception: Network Error'),
      ],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on logout success',
      build: () {
        when(() => mockAuthRepository.deleteToken()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => const [
        AuthLoading(),
        AuthUnauthenticated(),
      ],
    );
  });
}
