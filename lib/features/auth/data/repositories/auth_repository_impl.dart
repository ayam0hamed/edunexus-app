import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:grad_project/core/error/exceptions.dart' as app_exceptions;
import 'package:grad_project/core/network/dio_client.dart';
import 'package:grad_project/features/auth/data/models/login_request.dart';
import 'package:grad_project/features/auth/data/models/login_response.dart';
import 'package:grad_project/features/auth/data/models/forgot_password_request.dart';
import 'package:grad_project/features/auth/data/models/reset_password_request.dart';
import 'package:grad_project/features/auth/data/models/confirm_email_request.dart';
import 'package:grad_project/features/auth/data/models/change_password_request.dart';
import 'package:grad_project/features/auth/data/models/change_password_response.dart';
import 'package:grad_project/features/auth/data/services/jwt_service.dart';
import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient dioClient;
  final FlutterSecureStorage secureStorage;
  final JwtService jwtService;

  static const String _tokenKey = 'jwt_token';

  AuthRepositoryImpl({
    required this.dioClient,
    required this.secureStorage,
    required this.jwtService,
  });

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await dioClient.dio
          .post('/api/Auth/login', data: request.toJson())
          .timeout(const Duration(seconds: 15));

      final data = response.data;
      if (data == null) {
        throw const app_exceptions.ServerException(
          'Received empty response from server',
        );
      }

      if (data is Map<String, dynamic>) {
        final loginResponse = LoginResponse.fromJson(data);
        if (loginResponse.success && loginResponse.token != null) {
          final role = jwtService.getRole(loginResponse.token!);
          if (role == null || (role != 'Student' && role != 'Instructor')) {
            throw const app_exceptions.ServerException(
              'Invalid user role received from server',
            );
          }
          return loginResponse;
        } else {
          throw app_exceptions.ServerException(loginResponse.message);
        }
      } else {
        throw const FormatException('Invalid server response format');
      }
    } on DioException catch (e) {
      _handleDioException(e);
      throw const app_exceptions.ServerException(
        'Unreachable code',
      ); // compilation safety
    } on SocketException catch (e) {
      throw app_exceptions.NetworkException(
        'No Internet connection: ${e.message}',
      );
    } on FormatException catch (e) {
      throw app_exceptions.ServerException('Bad response format: ${e.message}');
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.UnknownException('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      await secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw app_exceptions.UnknownException(
        'Failed to securely save token: ${e.toString()}',
      );
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await secureStorage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      await secureStorage.delete(key: _tokenKey);
    } catch (e) {
      throw app_exceptions.UnknownException(
        'Failed to delete token: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) return false;
      return !jwtService.isExpired(token);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getUserRole() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) return null;
      if (jwtService.isExpired(token)) return null;
      return jwtService.getRole(token);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    try {
      await dioClient.dio
          .post('/api/Auth/forgot-password', data: jsonEncode(request.email))
          .timeout(const Duration(seconds: 15));
    } on DioException catch (e) {
      _handleDioException(e);
    } on SocketException catch (e) {
      throw app_exceptions.NetworkException(
        'No Internet connection: ${e.message}',
      );
    } on FormatException catch (e) {
      throw app_exceptions.ServerException('Bad response format: ${e.message}');
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.UnknownException(
        'Forgot password failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> resetPassword(ResetPasswordRequest request) async {
    try {
      await dioClient.dio
          .post('/api/Auth/reset-password', data: request.toJson())
          .timeout(const Duration(seconds: 15));
    } on DioException catch (e) {
      _handleDioException(e);
    } on SocketException catch (e) {
      throw app_exceptions.NetworkException(
        'No Internet connection: ${e.message}',
      );
    } on FormatException catch (e) {
      throw app_exceptions.ServerException('Bad response format: ${e.message}');
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.UnknownException(
        'Reset password failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> confirmEmail(ConfirmEmailRequest request) async {
    try {
      await dioClient.dio
          .post('/api/Auth/confirm-email', data: request.toJson())
          .timeout(const Duration(seconds: 15));
    } on DioException catch (e) {
      _handleDioException(e);
    } on SocketException catch (e) {
      throw app_exceptions.NetworkException(
        'No Internet connection: ${e.message}',
      );
    } on FormatException catch (e) {
      throw app_exceptions.ServerException('Bad response format: ${e.message}');
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.UnknownException(
        'Confirm email failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.dio
          .post('/api/Auth/logout')
          .timeout(const Duration(seconds: 15));
      await deleteToken();
    } on DioException catch (e) {
      _handleDioException(e);
    } on SocketException catch (e) {
      throw app_exceptions.NetworkException(
        'No Internet connection: ${e.message}',
      );
    } on FormatException catch (e) {
      throw app_exceptions.ServerException('Bad response format: ${e.message}');
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.UnknownException('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<ChangePasswordResponse> changePassword(ChangePasswordRequest request) async {
    try {
      // Extract userId from stored JWT token
      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw const app_exceptions.UnauthorizedException(
          'You must be logged in to change your password.',
        );
      }

      if (jwtService.isExpired(token)) {
        throw const app_exceptions.UnauthorizedException(
          'Your session has expired. Please log in again.',
        );
      }

      final userId = jwtService.getUserId(token);
      if (userId == null || userId.isEmpty) {
        throw const app_exceptions.ServerException(
          'Unable to identify user. Please log in again.',
        );
      }

      final response = await dioClient.dio
          .post(
            '/api/Auth/change-password/$userId',
            data: request.toJson(),
          )
          .timeout(const Duration(seconds: 15));

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ChangePasswordResponse.fromJson(data);
      } else {
        return const ChangePasswordResponse(
          success: true,
          message: 'Password changed successfully.',
        );
      }
    } on DioException catch (e) {
      // Try to parse structured error response from API
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final parsed = ChangePasswordResponse.fromJson(responseData);
        if (!parsed.success) {
          return parsed;
        }
      }
      _handleDioException(e);
      throw const app_exceptions.ServerException('Unreachable code');
    } on SocketException catch (e) {
      throw app_exceptions.NetworkException(
        'No Internet connection: ${e.message}',
      );
    } on FormatException catch (e) {
      throw app_exceptions.ServerException('Bad response format: ${e.message}');
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.UnknownException(
        'Change password failed: ${e.toString()}',
      );
    }
  }

  void _handleDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    String message = 'Server connection failed';
    if (responseData is Map<String, dynamic>) {
      message =
          responseData['message']?.toString() ??
          responseData['error']?.toString() ??
          message;
    } else if (responseData != null) {
      message = responseData.toString();
    } else if (e.message != null) {
      message = e.message!;
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw const app_exceptions.TimeoutException(
        'Connection timed out. Please try again.',
      );
    }

    if (e.error is SocketException) {
      throw const app_exceptions.NetworkException(
        'Network error: No internet connection.',
      );
    }

    if (statusCode == 401 || statusCode == 403) {
      throw app_exceptions.UnauthorizedException(message);
    }

    throw app_exceptions.ServerException(message, statusCode: statusCode);
  }
}
