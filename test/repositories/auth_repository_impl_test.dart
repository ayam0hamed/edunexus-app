import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:grad_project/core/network/dio_client.dart';
import 'package:grad_project/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:grad_project/features/auth/data/services/jwt_service.dart';
import 'package:grad_project/features/auth/data/models/login_request.dart';
import 'package:grad_project/features/auth/data/models/forgot_password_request.dart';
import 'package:grad_project/features/auth/data/models/change_password_request.dart';
import 'package:grad_project/core/error/exceptions.dart' as app_exceptions;

class MockDio extends Mock implements Dio {}
class MockDioClient extends Mock implements DioClient {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockJwtService extends Mock implements JwtService {}

void main() {
  late AuthRepositoryImpl authRepository;
  late MockDioClient mockDioClient;
  late MockDio mockDio;
  late MockFlutterSecureStorage mockSecureStorage;
  late MockJwtService mockJwtService;

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    mockSecureStorage = MockFlutterSecureStorage();
    mockJwtService = MockJwtService();

    when(() => mockDioClient.dio).thenReturn(mockDio);

    authRepository = AuthRepositoryImpl(
      dioClient: mockDioClient,
      secureStorage: mockSecureStorage,
      jwtService: mockJwtService,
    );
  });

  group('login', () {
    final loginRequest = LoginRequest(
      ssnOrEmail: 'student@example.com',
      password: 'password123',
      rememberMe: true,
    );

    test('should return LoginResponse when login is successful', () async {
      // Arrange
      final responseData = {
        'success': true,
        'message': 'Login successful',
        'token': 'valid_token',
      };
      
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/api/Auth/login'),
            data: responseData,
            statusCode: 200,
          ));
      
      when(() => mockJwtService.getRole('valid_token')).thenReturn('Student');

      // Act
      final result = await authRepository.login(loginRequest);

      // Assert
      expect(result.success, true);
      expect(result.token, 'valid_token');
      verify(() => mockDio.post('/api/Auth/login', data: loginRequest.toJson())).called(1);
    });

    test('should throw ServerException when response role is invalid', () async {
      // Arrange
      final responseData = {
        'success': true,
        'message': 'Login successful',
        'token': 'valid_token',
      };

      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/api/Auth/login'),
            data: responseData,
            statusCode: 200,
          ));

      when(() => mockJwtService.getRole('valid_token')).thenReturn('Admin'); // Invalid role

      // Act & Assert
      expect(
        () => authRepository.login(loginRequest),
        throwsA(isA<app_exceptions.ServerException>()),
      );
    });

    test('should throw ServerException when server returns success = false', () async {
      // Arrange
      final responseData = {
        'success': false,
        'message': 'Invalid credentials',
      };

      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/api/Auth/login'),
            data: responseData,
            statusCode: 200,
          ));

      // Act & Assert
      expect(
        () => authRepository.login(loginRequest),
        throwsA(isA<app_exceptions.ServerException>()),
      );
    });

    test('should throw NetworkException when SocketException is thrown', () async {
      // Arrange
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
          )).thenThrow(const SocketException('No Internet'));

      // Act & Assert
      expect(
        () => authRepository.login(loginRequest),
        throwsA(isA<app_exceptions.NetworkException>()),
      );
    });

    test('should throw ServerException when DioException is thrown', () async {
      // Arrange
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: '/api/Auth/login'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: '/api/Auth/login'),
              statusCode: 401,
              data: {'message': 'Unauthorized access'},
            ),
          ));

      // Act & Assert
      expect(
        () => authRepository.login(loginRequest),
        throwsA(isA<app_exceptions.UnauthorizedException>()),
      );
    });
  });

  group('secure storage token operations', () {
    test('should write token to secure storage', () async {
      // Arrange
      when(() => mockSecureStorage.write(key: 'jwt_token', value: 'my_token'))
          .thenAnswer((_) async {});

      // Act
      await authRepository.saveToken('my_token');

      // Assert
      verify(() => mockSecureStorage.write(key: 'jwt_token', value: 'my_token')).called(1);
    });

    test('should read token from secure storage', () async {
      // Arrange
      when(() => mockSecureStorage.read(key: 'jwt_token'))
          .thenAnswer((_) async => 'retrieved_token');

      // Act
      final result = await authRepository.getToken();

      // Assert
      expect(result, 'retrieved_token');
      verify(() => mockSecureStorage.read(key: 'jwt_token')).called(1);
    });

    test('should delete token from secure storage', () async {
      // Arrange
      when(() => mockSecureStorage.delete(key: 'jwt_token'))
          .thenAnswer((_) async {});

      // Act
      await authRepository.deleteToken();

      // Assert
      verify(() => mockSecureStorage.delete(key: 'jwt_token')).called(1);
    });
  });

  group('isAuthenticated', () {
    test('should return true when token is valid and not expired', () async {
      // Arrange
      when(() => mockSecureStorage.read(key: 'jwt_token'))
          .thenAnswer((_) async => 'valid_token');
      when(() => mockJwtService.isExpired('valid_token')).thenReturn(false);

      // Act
      final result = await authRepository.isAuthenticated();

      // Assert
      expect(result, true);
    });

    test('should return false when token is null', () async {
      // Arrange
      when(() => mockSecureStorage.read(key: 'jwt_token'))
          .thenAnswer((_) async => null);

      // Act
      final result = await authRepository.isAuthenticated();

      // Assert
      expect(result, false);
    });

    test('should return false when token is expired', () async {
      // Arrange
      when(() => mockSecureStorage.read(key: 'jwt_token'))
          .thenAnswer((_) async => 'expired_token');
      when(() => mockJwtService.isExpired('expired_token')).thenReturn(true);

      // Act
      final result = await authRepository.isAuthenticated();

      // Assert
      expect(result, false);
    });
  });

  group('forgotPassword', () {
    test('should call post forgot-password endpoint successfully', () async {
      // Arrange
      final request = ForgotPasswordRequest(email: 'test@example.com');
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/api/Auth/forgot-password'),
                statusCode: 200,
              ));

      // Act
      await authRepository.forgotPassword(request);

      // Assert
      verify(() => mockDio.post('/api/Auth/forgot-password', data: jsonEncode(request.email))).called(1);
    });
  });

  group('changePassword', () {
    test('should successfully change password when token is valid', () async {
      // Arrange
      final request = ChangePasswordRequest(
        currentPassword: 'old',
        newPassword: 'new',
        confirmPassword: 'new',
      );
      when(() => mockSecureStorage.read(key: 'jwt_token'))
          .thenAnswer((_) async => 'valid_token');
      when(() => mockJwtService.isExpired('valid_token')).thenReturn(false);
      when(() => mockJwtService.getUserId('valid_token')).thenReturn('user-123');
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/api/Auth/change-password/user-123'),
                statusCode: 200,
                data: {'success': true, 'message': 'Password changed.'},
              ));

      // Act
      final result = await authRepository.changePassword(request);

      // Assert
      expect(result.success, true);
      verify(() => mockDio.post('/api/Auth/change-password/user-123', data: request.toJson())).called(1);
    });

    test('should throw UnauthorizedException when token is expired', () async {
      // Arrange
      final request = ChangePasswordRequest(
        currentPassword: 'old',
        newPassword: 'new',
        confirmPassword: 'new',
      );
      when(() => mockSecureStorage.read(key: 'jwt_token'))
          .thenAnswer((_) async => 'expired_token');
      when(() => mockJwtService.isExpired('expired_token')).thenReturn(true);

      // Act & Assert
      expect(
        () => authRepository.changePassword(request),
        throwsA(isA<app_exceptions.UnauthorizedException>()),
      );
    });
  });
}
