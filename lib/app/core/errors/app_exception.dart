/// Typed failures. Data sources throw these; controllers render them.
/// Nothing above the repository layer should ever inspect a status code.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Check your internet connection and try again.']);
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'That took too long. Please try again.']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Your session has expired. Please sign in again.']);
}

/// Signed in, but not allowed this.
///
/// Kept apart from [UnauthorizedException] because the two need opposite
/// answers. A 401 means the session is dead and signing in again fixes it.
/// A 403 means the session is fine and signing in again changes nothing --
/// telling somebody their session expired sends them round a loop that
/// cannot end, and hides the one sentence that would have explained it.
///
/// A studio whose login has the partner role but was never joined to a
/// studio is exactly this: every panel answers 403, and the server says
/// why. That sentence is what should reach them.
class ForbiddenException extends AppException {
  const ForbiddenException([
    super.message = 'This account is not allowed to see that.',
  ]);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'We could not find what you were looking for.']);
}

/// Validation errors from DRF, which returns {"field": ["msg", ...]}.
class ValidationException extends AppException {
  const ValidationException(super.message, {this.fieldErrors = const {}});

  final Map<String, List<String>> fieldErrors;
}

class ServerException extends AppException {
  const ServerException([super.message = 'Something went wrong on our end. Please try again.']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Could not read saved content.']);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'Something went wrong. Please try again.']);
}
