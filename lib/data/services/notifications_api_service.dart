import 'dart:convert';
import 'package:assistant/data/services/http_client.dart';
import 'package:assistant/config/app_config.dart';

/// Weekly report data from the server.
class WeeklyReportData {
  final String summary;
  final List<String> highlights;
  final List<String> concerns;
  final List<String> correlations;
  final List<String> trends;
  final List<String> recommendations;
  final DateTime generatedAt;

  const WeeklyReportData({
    required this.summary,
    required this.highlights,
    required this.concerns,
    required this.correlations,
    required this.trends,
    required this.recommendations,
    required this.generatedAt,
  });

  factory WeeklyReportData.fromJson(Map<String, dynamic> json) {
    return WeeklyReportData(
      summary: json['summary'] as String? ?? '',
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      concerns: (json['concerns'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      correlations: (json['correlations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      trends: (json['trends'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }
}

/// HTTP client for notification-related API endpoints.
class NotificationsApiService {
  final AppHttpClient _client;

  NotificationsApiService({AppHttpClient? client})
      : _client = client ??
            AppHttpClient(
              timeout: AppConfig.instance.requestTimeout,
              maxRetries: AppConfig.instance.maxRetries,
            );

  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  /// POST /api/notifications/morning-briefing - Request morning briefing.
  Future<void> requestMorningBriefing() async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/notifications/morning-briefing'),
      body: {},
    );
    if (response.statusCode != 200) {
      throw parseErrorResponse(response);
    }
  }

  /// POST /api/notifications/weekly-report - Request weekly report.
  Future<WeeklyReportData> requestWeeklyReport() async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/notifications/weekly-report'),
      body: {},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return WeeklyReportData.fromJson(data);
    } else {
      throw parseErrorResponse(response);
    }
  }
}
