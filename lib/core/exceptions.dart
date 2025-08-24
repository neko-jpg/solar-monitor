enum AppExceptionKind { timeout, dns, auth, server, parse, unknown }
class AppException implements Exception {
  final AppExceptionKind kind; final String message; final Object? cause;
  const AppException(this.kind, this.message, [this.cause]);
  @override String toString() => 'AppException($kind, $message)';
}
