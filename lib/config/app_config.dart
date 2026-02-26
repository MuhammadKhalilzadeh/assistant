import 'dart:io';

enum Environment { dev, prod }

/// Application configuration that varies by environment
class AppConfig {
  static late AppConfig _instance;

  final String apiBaseUrl;
  final String googleServerClientId;
  final Duration requestTimeout;
  final int maxRetries;
  final Duration cacheTtl;

  AppConfig._({
    required this.apiBaseUrl,
    required this.googleServerClientId,
    this.requestTimeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.cacheTtl = const Duration(minutes: 15),
  });

  // Set this to your computer's local IP for physical device testing
  // Find it with: ipconfig (Windows) or ifconfig (macOS/Linux)
  // Leave empty to use default (10.0.2.2 for Android emulator, localhost for others)
  static const String _devServerIp = '192.168.1.102';

  /// Development configuration
  factory AppConfig._dev() {
    final String host;
    if (_devServerIp.isNotEmpty) {
      host = _devServerIp;
    } else if (Platform.isAndroid) {
      host = '10.0.2.2';
    } else {
      host = 'localhost';
    }
    final baseUrl = 'http://$host:3000/api';

    return AppConfig._(
      apiBaseUrl: baseUrl,
      googleServerClientId: const String.fromEnvironment(
        'GOOGLE_SERVER_CLIENT_ID',
        defaultValue: '',
      ),
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
      googleServerClientId: const String.fromEnvironment(
        'GOOGLE_SERVER_CLIENT_ID',
        defaultValue: '',
      ),
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
