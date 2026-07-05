class ConfirmEmailRequest {
  final String userId;
  final String token;
  final String email;

  const ConfirmEmailRequest({
    required this.userId,
    required this.token,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'token': token,
      'email': email,
    };
  }
}
