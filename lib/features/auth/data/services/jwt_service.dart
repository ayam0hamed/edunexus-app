import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/foundation.dart';

class JwtService {
  static const String _roleClaimKey = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';

  /// Decodes the JWT token and returns the role.
  /// If the token is invalid or does not contain the role claim, returns null.
  String? getRole(String token) {
    try {
      if (token.isEmpty) return null;
      final Map<String, dynamic> decoded = JwtDecoder.decode(token);
      final role = decoded[_roleClaimKey];
      if (role == null) return null;
      return role.toString();
    } catch (e) {
      debugPrint('JwtService: Error decoding role from token: $e');
      return null;
    }
  }

  /// Decodes the JWT token and returns the UserId.
  /// If the token is invalid or does not contain the UserId claim, returns null.
  String? getUserId(String token) {
    try {
      if (token.isEmpty) return null;
      final Map<String, dynamic> decoded = JwtDecoder.decode(token);
      final userId = decoded['UserId'];
      if (userId == null) return null;
      return userId.toString();
    } catch (e) {
      debugPrint('JwtService: Error decoding UserId from token: $e');
      return null;
    }
  }

  /// Checks if the token is expired.
  /// Returns true if it is expired or invalid.
  bool isExpired(String token) {
    try {
      if (token.isEmpty) return true;
      return JwtDecoder.isExpired(token);
    } catch (e) {
      debugPrint('JwtService: Error checking expiration: $e');
      return true; // Treat as expired if parsing fails
    }
  }

  /// Safely decodes a token. Returns decoded map or empty map on error.
  Map<String, dynamic> tryDecode(String token) {
    try {
      if (token.isEmpty) return const {};
      return JwtDecoder.decode(token);
    } catch (e) {
      debugPrint('JwtService: Failure decoding: $e');
      return const {};
    }
  }
}
