import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:assistant/data/errors/app_errors.dart';
import 'package:assistant/config/app_config.dart';

/// A robust HTTP client with retry logic, timeout, and error handling
class AppHttpClient {
  final http.Client _client;
  final Duration timeout;
  final int maxRetries;
  final Duration initialRetryDelay;

  AppHttpClient({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.initialRetryDelay = const Duration(seconds: 1),
  }) : _client = client ?? http.Client();

  /// Default headers for all requests
  Map<String, String> get _defaultHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final apiKey = AppConfig.instance.apiKey;
    if (apiKey != null && apiKey.isNotEmpty) {
      headers['x-api-key'] = apiKey;
    }

    return headers;
  }

  /// Performs a GET request with retry logic
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return _withRetry(() => _client
        .get(url, headers: {..._defaultHeaders, ...?headers})
        .timeout(timeout));
  }

  /// Performs a POST request with retry logic
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _withRetry(() => _client
        .post(
          url,
          headers: {..._defaultHeaders, ...?headers},
          body: body is String ? body : jsonEncode(body),
        )
        .timeout(timeout));
  }

  /// Performs a PUT request with retry logic
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _withRetry(() => _client
        .put(
          url,
          headers: {..._defaultHeaders, ...?headers},
          body: body is String ? body : jsonEncode(body),
        )
        .timeout(timeout));
  }

  /// Performs a PATCH request with retry logic
  Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _withRetry(() => _client
        .patch(
          url,
          headers: {..._defaultHeaders, ...?headers},
          body: body != null ? (body is String ? body : jsonEncode(body)) : null,
        )
        .timeout(timeout));
  }

  /// Performs a DELETE request with retry logic
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _withRetry(() => _client
        .delete(
          url,
          headers: {..._defaultHeaders, ...?headers},
          body: body != null ? (body is String ? body : jsonEncode(body)) : null,
        )
        .timeout(timeout));
  }

  /// Executes a request with exponential backoff retry logic
  Future<http.Response> _withRetry(
    Future<http.Response> Function() request,
  ) async {
    int attempts = 0;
    Duration delay = initialRetryDelay;

    while (true) {
      try {
        final response = await request();

        // Don't retry on successful responses or client errors (4xx)
        if (response.statusCode < 500) {
          return response;
        }

        // Retry on server errors (5xx)
        if (++attempts >= maxRetries) {
          return response;
        }

        await Future.delayed(delay);
        delay = Duration(milliseconds: min(delay.inMilliseconds * 2, 30000));
      } on SocketException {
        if (++attempts >= maxRetries) {
          throw NetworkError('Unable to connect to server');
        }
        await Future.delayed(delay);
        delay = Duration(milliseconds: min(delay.inMilliseconds * 2, 30000));
      } on TimeoutException {
        if (++attempts >= maxRetries) {
          throw TimeoutError('Request timed out after ${timeout.inSeconds} seconds');
        }
        await Future.delayed(delay);
        delay = Duration(milliseconds: min(delay.inMilliseconds * 2, 30000));
      } on http.ClientException catch (e) {
        if (++attempts >= maxRetries) {
          throw NetworkError(e.message);
        }
        await Future.delayed(delay);
        delay = Duration(milliseconds: min(delay.inMilliseconds * 2, 30000));
      }
    }
  }

  void close() {
    _client.close();
  }
}

/// Parses error responses from the API
AppError parseErrorResponse(http.Response response) {
  try {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final message = body['error'] as String? ?? 'Unknown error';
    final code = body['code'] as String?;

    switch (response.statusCode) {
      case 400:
        if (code == 'VALIDATION_ERROR') {
          final details = (body['details'] as List<dynamic>?)
              ?.map((d) => ValidationDetail.fromJson(d as Map<String, dynamic>))
              .toList();
          return ValidationError(message, details: details);
        }
        return ServerError(message, statusCode: 400, code: code);
      case 401:
        return AuthError(message);
      case 404:
        return NotFoundError(message);
      case 429:
        return RateLimitError(message);
      case >= 500:
        return ServerError(message, statusCode: response.statusCode, code: code);
      default:
        return ServerError(message, statusCode: response.statusCode, code: code);
    }
  } catch (_) {
    return ServerError(
      'Server error (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }
}
