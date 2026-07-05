class LoginRequest {
  final String ssnOrEmail;
  final String password;
  final bool rememberMe;

  const LoginRequest({
    required this.ssnOrEmail,
    required this.password,
    this.rememberMe = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'ssnOrEmail': ssnOrEmail,
      'password': password,
      'rememberMe': rememberMe,
    };
  }
}
