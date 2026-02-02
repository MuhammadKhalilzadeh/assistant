/// Base class for all application errors
sealed class AppError implements Exception {
  final String message;
  final String? code;

  AppError(this.message, {this.code});

  @override
  String toString() => message;

  /// Returns a user-friendly error message
  String get userMessage => message;
}

/// Network connectivity error - no internet connection
class NetworkError extends AppError {
  NetworkError([String? message])
      : super(message ?? 'No internet connection', code: 'NETWORK_ERROR');

  @override
  String get userMessage => 'Please check your internet connection and try again.';
}

/// Server returned an error response
class ServerError extends AppError {
  final int? statusCode;

  ServerError(super.message, {this.statusCode, String? code})
      : super(code: code ?? 'SERVER_ERROR');

  @override
  String get userMessage {
    if (statusCode != null && statusCode! >= 500) {
      return 'The server is experiencing issues. Please try again later.';
    }
    return message;
  }
}

/// Validation error from the server
class ValidationError extends AppError {
  final List<ValidationDetail>? details;

  ValidationError(super.message, {this.details}) : super(code: 'VALIDATION_ERROR');

  @override
  String get userMessage => details?.map((d) => d.message).join(', ') ?? message;
}

class ValidationDetail {
  final String field;
  final String message;

  ValidationDetail({required this.field, required this.message});

  factory ValidationDetail.fromJson(Map<String, dynamic> json) {
    return ValidationDetail(
      field: json['field'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}

/// Authentication error - invalid or missing credentials
class AuthError extends AppError {
  AuthError([String? message])
      : super(message ?? 'Authentication required', code: 'AUTH_ERROR');

  @override
  String get userMessage => 'Please sign in to continue.';
}

/// Resource not found error
class NotFoundError extends AppError {
  NotFoundError([String? message])
      : super(message ?? 'Resource not found', code: 'NOT_FOUND');

  @override
  String get userMessage => 'The requested item was not found.';
}

/// Request timeout error
class TimeoutError extends AppError {
  TimeoutError([String? message])
      : super(message ?? 'Request timed out', code: 'TIMEOUT');

  @override
  String get userMessage => 'The request took too long. Please try again.';
}

/// Rate limit exceeded error
class RateLimitError extends AppError {
  RateLimitError([String? message])
      : super(message ?? 'Too many requests', code: 'RATE_LIMIT');

  @override
  String get userMessage => 'Too many requests. Please wait a moment and try again.';
}

/// Offline mode error - operation not available offline
class OfflineError extends AppError {
  OfflineError([String? message])
      : super(message ?? 'This action requires an internet connection',
            code: 'OFFLINE');

  @override
  String get userMessage => 'This action is not available offline.';
}

/// Unknown/unexpected error
class UnknownError extends AppError {
  final Object? originalError;

  UnknownError([String? message, this.originalError])
      : super(message ?? 'An unexpected error occurred', code: 'UNKNOWN');

  @override
  String get userMessage => 'Something went wrong. Please try again.';
}
