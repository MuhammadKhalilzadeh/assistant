import 'dart:io';

enum Environment { dev, prod }

/// Application configuration that varies by environment
class AppConfig {
  static late AppConfig _instance;

  final String apiBaseUrl;
  final String? apiKey;
  final Duration requestTimeout;
  final int maxRetries;
  final Duration cacheTtl;

  AppConfig._({
    required this.apiBaseUrl,
    this.apiKey,
    this.requestTimeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.cacheTtl = const Duration(minutes: 15),
  });

  /// Development configuration
  factory AppConfig._dev() {
    // Configure based on platform:
    // - Android emulator: 10.0.2.2
    // - iOS simulator / Web / Desktop: localhost
    final baseUrl = Platform.isAndroid
        ? 'http://10.0.2.2:3000/api'
        : 'http://localhost:3000/api';

    return AppConfig._(
      apiBaseUrl: baseUrl,
      apiKey: null, // No API key required in dev
      requestTimeout: const Duration(seconds: 30),
      maxRetries: 3,
      cacheTtl: const Duration(minutes: 5),
    );
  }

  /// Production configuration
  factory AppConfig._prod() {
    return AppConfig._(
      apiBaseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://api.example.com/api',
      ),
      apiKey: const String.fromEnvironment('API_KEY'),
      requestTimeout: const Duration(seconds: 30),
      maxRetries: 3,
      cacheTtl: const Duration(minutes: 15),
    );
  }

  /// Initialize configuration for the given environment
  static void initialize([Environment env = Environment.dev]) {
    _instance = switch (env) {
      Environment.dev => AppConfig._dev(),
      Environment.prod => AppConfig._prod(),
    };
  }

  /// Get the current configuration instance
  static AppConfig get instance {
    return _instance;
  }

  /// Check if configuration has been initialized
  static bool get isInitialized {
    try {
      // ignore: unnecessary_statements
      _instance;
      return true;
    } catch (_) {
      return false;
    }
  }
}
