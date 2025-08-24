import 'package:dio/dio.dart';

/// Base class for all application-specific exceptions.
class AppException implements Exception {
  final String message;
  AppException(this.message);
  @override
  String toString() => message;
}

/// Exception for authentication-related errors.
class AuthException extends AppException {
  AuthException(super.message);
}

/// Exception for network-related errors, wrapping DioException.
class NetworkException extends AppException {
  final DioException? dioError;

  NetworkException(super.message, [this.dioError]);

  factory NetworkException.fromDioError(DioException e) {
    final message = switch (e.type) {
      DioExceptionType.connectionTimeout => 'Connection timed out. Please check your network.',
      DioExceptionType.sendTimeout => 'Request timed out. Please check your network.',
      DioExceptionType.receiveTimeout => 'Response timed out. Please check your network.',
      DioExceptionType.badResponse => 'Received an invalid response from the server.',
      DioExceptionType.cancel => 'Request was cancelled.',
      DioExceptionType.connectionError => 'Connection error. Please check your network.',
      DioExceptionType.unknown => 'An unknown network error occurred.',
      _ => 'An unknown network error occurred.',
    };
    return NetworkException(message, e);
  }
}

/// Exception for data parsing errors.
class ParseException extends AppException {
  ParseException(super.message);
}
