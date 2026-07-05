abstract class Failure {
  final String message;
  const Failure(this.message);

  /// Critical: without this override, catch(e) { e.toString() } prints
  /// "Instance of 'ServerFailure'" instead of the actual error message.
  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});

  @override
  String toString() => message;
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);

  @override
  String toString() => message;
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);

  @override
  String toString() => message;
}
