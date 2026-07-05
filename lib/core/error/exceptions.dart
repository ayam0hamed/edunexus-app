abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}

class TimeoutException extends AppException {
  const TimeoutException(super.message);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}
