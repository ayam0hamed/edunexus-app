import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/models/login_request.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<TokenExpired>(_onTokenExpired);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      final authenticated = await authRepository.isAuthenticated();
      if (authenticated) {
        final token = await authRepository.getToken();
        final role = await authRepository.getUserRole();
        if (token != null && role != null) {
          emit(AuthAuthenticated(token: token, role: role));
          return;
        }
      }
      await authRepository.deleteToken();
      emit(const AuthUnauthenticated());
    } catch (e) {
      debugPrint('AuthBloc: Error during app startup check: $e');
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final response = await authRepository.login(
        LoginRequest(
          ssnOrEmail: event.ssnOrEmail,
          password: event.password,
          rememberMe: event.rememberMe,
        ),
      );

      if (response.success && response.token != null) {
        await authRepository.saveToken(response.token!);
        final savedRole = await authRepository.getUserRole();
        if (savedRole != null && (savedRole == 'Student' || savedRole == 'Instructor')) {
          emit(AuthAuthenticated(token: response.token!, role: savedRole));
        } else {
          await authRepository.deleteToken();
          emit(const AuthError('Invalid user role received from server.'));
        }
      } else {
        emit(AuthError(response.message));
      }
    } catch (e) {
      debugPrint('AuthBloc: Login error: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await authRepository.deleteToken();
      emit(const AuthUnauthenticated());
    } catch (e) {
      debugPrint('AuthBloc: Logout error: $e');
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onTokenExpired(TokenExpired event, Emitter<AuthState> emit) async {
    try {
      await authRepository.deleteToken();
    } catch (e) {
      debugPrint('AuthBloc: Error deleting token on expiry: $e');
    }
    emit(const AuthUnauthenticated());
  }
}
