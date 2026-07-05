class ResetPasswordRequest {
  final String userId;
  final String token;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordRequest({
    required this.userId,
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'token': token,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}
