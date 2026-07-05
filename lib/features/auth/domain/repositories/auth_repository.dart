import '../../data/models/login_request.dart';
import '../../data/models/login_response.dart';
import '../../data/models/forgot_password_request.dart';
import '../../data/models/reset_password_request.dart';
import '../../data/models/confirm_email_request.dart';
import '../../data/models/change_password_request.dart';
import '../../data/models/change_password_response.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(LoginRequest request);
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<bool> isAuthenticated();
  Future<String?> getUserRole();
  Future<void> forgotPassword(ForgotPasswordRequest request);
  Future<void> resetPassword(ResetPasswordRequest request);
  Future<void> confirmEmail(ConfirmEmailRequest request);
  Future<void> logout();
  Future<ChangePasswordResponse> changePassword(ChangePasswordRequest request);
}
