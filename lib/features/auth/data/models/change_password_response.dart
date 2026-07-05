class ChangePasswordResponse {
  final bool success;
  final String message;
  final List<String>? errors;

  const ChangePasswordResponse({
    required this.success,
    required this.message,
    this.errors,
  });

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      errors: (json['errors'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
}
