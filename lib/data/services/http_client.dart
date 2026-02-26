import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:assistant/data/errors/app_errors.dart';
import 'package:assistant/services/token_storage_service.dart';
import 'package:assistant/data/services/auth_api_service.dart';

/// Callback to notify when auth tokens are expired and cannot be refreshed
typedef OnAuthExpired = void Function();

/// A robust HTTP client with JWT auth, auto-refresh, retry logic, and error handling
class AppHttpClient {
  final http.Client _client;
  final Duration timeout;
  final int maxRetries;
  final Duration initialRetryDelay;
  final TokenStorageService _tokenStorage;
  final AuthApiService _authApi;
  OnAuthExpired? onAuthExpired;

  bool _isRefreshing = false;
  final List<Completer<String?>> _refreshQueue = [];

  AppHttpClient({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.initialRetryDelay = const Duration(seconds: 1),
    TokenStorageService? tokenStorage,
    AuthApiService? authApi,
    this.onAuthExpired,
  })  : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorageService(),
        _authApi = authApi ?? AuthApiService();

  /// Default headers for all requests
  Future<Map<String, String>> _getHeaders([Map<String, String>? extra]) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = await _tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (extra != null) headers.addAll(extra);
    return headers;
  }

  /// Performs a GET request with retry logic and auto-refresh
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return _withAuthRetry(() async {
      final h = await _getHeaders(headers);
      return _withRetry(() => _client.get(url, headers: h).timeout(timeout));
    });
  }

  /// Performs a POST request with retry logic and auto-refresh
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _withAuthRetry(() async {
      final h = await _getHeaders(headers);
      return _withRetry(() => _client
          .post(url, headers: h, body: body is String ? body : jsonEncode(body))
          .timeout(timeout));
    });
  }

  /// Performs a PUT request with retry logic and auto-refresh
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _withAuthRetry(() async {
      final h = await _getHeaders(headers);
      return _withRetry(() => _client
          .put(url, headers: h, body: body is String ? body : jsonEncode(body))
          .timeout(timeout));
    });
  }

  /// Performs a PATCH request with retry logic and auto-refresh
  Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _withAuthRetry(() async {
      final h = await _getHeaders(headers);
      return _withRetry(() => _client
          .patch(url,
              headers: h,
              body: body != null
                  ? (body is String ? body : jsonEncode(body))
                  : null)
          .timeout(timeout));
    });
  }

  /// Performs a DELETE request with retry logic and auto-refresh
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _withAuthRetry(() async {
      final h = await _getHeaders(headers);
      return _withRetry(() => _client
          .delete(url,
              headers: h,
              body: body != null
                  ? (body is String ? body : jsonEncode(body))
                  : null)
          .timeout(timeout));
    });
  }

  /// Wraps a request with 401 auto-refresh logic
  Future<http.Response> _withAuthRetry(
    Future<http.Response> Function() request,
  ) async {
    final response = await request();

    if (response.statusCode == 401) {
      // Try refreshing the token
      final newToken = await _refreshAccessToken();
      if (newToken != null) {
        // Retry the original request with new token
        return request();
      } else {
        // Refresh failed — session expired
        onAuthExpired?.call();
        return response;
      }
    }

    return response;
  }

  /// Refreshes access token, coalescing concurrent refresh requests
  Future<String?> _refreshAccessToken() async {
    if (_isRefreshing) {
      final completer = Completer<String?>();
      _refreshQueue.add(completer);
      return completer.future;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return null;

      final response = await _authApi.refreshToken(refreshToken);
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      // Resolve all queued requests
      for (final completer in _refreshQueue) {
        completer.complete(response.accessToken);
      }

      return response.accessToken;
    } catch (_) {
      // Resolve all queued requests with null
      for (final completer in _refreshQueue) {
        completer.complete(null);
      }
      return null;
    } finally {
      _refreshQueue.clear();
      _isRefreshing = false;
    }
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
          throw TimeoutError(
              'Request timed out after ${timeout.inSeconds} seconds');
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
              ?.map(
                  (d) => ValidationDetail.fromJson(d as Map<String, dynamic>))
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
        return ServerError(message,
            statusCode: response.statusCode, code: code);
      default:
        return ServerError(message,
            statusCode: response.statusCode, code: code);
    }
  } catch (_) {
    return ServerError(
      'Server error (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }
}
