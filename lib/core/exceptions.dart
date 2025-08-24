enum AppExceptionKind {
  timeout,
  dns,
  auth,
  server,
  parse,
  unknown,
}

class AppException implements Exception {
  final AppExceptionKind kind;
  final String message;
  final Object? cause;

  AppException(this.kind, this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) {
      return 'AppException(kind: $kind, message: "$message", cause: $cause)';
    }
    return 'AppException(kind: $kind, message: "$message")';
  }
}
