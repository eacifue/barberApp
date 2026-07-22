class AppException implements Exception {
  AppException(this.message, {this.errors = const []});

  final String message;
  final List<String> errors;

  @override
  String toString() => message;
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.errors});
}

class NotFoundException extends AppException {
  NotFoundException(super.message);
}

class ServerException extends AppException {
  ServerException(super.message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message);
}

class ForbiddenException extends AppException {
  ForbiddenException(super.message);
}
