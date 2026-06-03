import 'dart:convert';
import 'package:assistant/data/services/http_client.dart';
import 'package:assistant/config/app_config.dart';

/// Model for a server-generated insight.
class ServerInsight {
  final String id;
  final String type; // correlation, pattern, anomaly, trend, suggestion
  final List<String> domains;
  final String title;
  final String description;
  final double confidence;
  final Map<String, dynamic> data;
  final bool dismissed;
  final DateTime? expiresAt;
  final DateTime createdAt;

  const ServerInsight({
    required this.id,
    required this.type,
    required this.domains,
    required this.title,
    required this.description,
    required this.confidence,
    required this.data,
    required this.dismissed,
    this.expiresAt,
    required this.createdAt,
  });

  factory ServerInsight.fromJson(Map<String, dynamic> json) {
    return ServerInsight(
      id: json['id'] as String,
      type: json['type'] as String,
      domains: (json['domains'] as List<dynamic>?)
              ?.map((d) => d as String)
              .toList() ??
          [],
      title: json['title'] as String,
      description: json['description'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      data: json['data'] as Map<String, dynamic>? ?? {},
      dismissed: json['dismissed'] as bool? ?? false,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// HTTP client for the server-side insights API.
class InsightsApiService {
  final AppHttpClient _client;

  InsightsApiService({AppHttpClient? client})
      : _client = client ??
            AppHttpClient(
              timeout: AppConfig.instance.requestTimeout,
              maxRetries: AppConfig.instance.maxRetries,
            );

  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  /// GET /api/insights - Fetch active (non-dismissed, non-expired) insights.
  Future<List<ServerInsight>> getInsights({String? type, int limit = 20}) async {
    String url = '$_baseUrl/insights?limit=$limit';
    if (type != null) url += '&type=$type';

    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => ServerInsight.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// POST /api/insights/generate - Trigger server-side insight generation.
  Future<List<ServerInsight>> generateInsights() async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/insights/generate'),
      body: {},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> insights = data['insights'] ?? [];
      return insights
          .map((json) => ServerInsight.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// POST /api/insights/:id/dismiss - Dismiss an insight.
  Future<void> dismissInsight(String id) async {
    final response =
        await _client.post(Uri.parse('$_baseUrl/insights/$id/dismiss'), body: {});
    if (response.statusCode != 200) {
      throw parseErrorResponse(response);
    }
  }

  /// GET /api/insights/correlations - Fetch correlation analysis.
  Future<List<Correlation>> getCorrelations() async {
    final response =
        await _client.get(Uri.parse('$_baseUrl/insights/correlations'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => Correlation.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// GET /api/insights/trends - Fetch trend analysis.
  Future<List<TrendData>> getTrends() async {
    final response =
        await _client.get(Uri.parse('$_baseUrl/insights/trends'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => TrendData.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// GET /api/insights/anomalies - Fetch anomaly detection results.
  Future<List<AnomalyData>> getAnomalies() async {
    final response =
        await _client.get(Uri.parse('$_baseUrl/insights/anomalies'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => AnomalyData.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw parseErrorResponse(response);
    }
  }
}

/// Model for a correlation result.
class Correlation {
  final String featureA;
  final String featureB;
  final double coefficient;
  final String strength; // weak, moderate, strong
  final String direction; // positive, negative
  final int sampleSize;
  final double confidence;
  final String humanReadable;

  const Correlation({
    required this.featureA,
    required this.featureB,
    required this.coefficient,
    required this.strength,
    required this.direction,
    required this.sampleSize,
    required this.confidence,
    required this.humanReadable,
  });

  factory Correlation.fromJson(Map<String, dynamic> json) {
    return Correlation(
      featureA: json['featureA'] as String,
      featureB: json['featureB'] as String,
      coefficient: (json['coefficient'] as num).toDouble(),
      strength: json['strength'] as String,
      direction: json['direction'] as String,
      sampleSize: json['sampleSize'] as int,
      confidence: (json['confidence'] as num).toDouble(),
      humanReadable: json['humanReadable'] as String,
    );
  }
}

/// Model for a trend result.
class TrendData {
  final String domain;
  final String label;
  final String direction; // improving, declining, stable
  final double momentum;
  final List<double> values; // sparkline data
  final double currentValue;
  final double averageValue;
  final String summary;

  const TrendData({
    required this.domain,
    required this.label,
    required this.direction,
    required this.momentum,
    required this.values,
    required this.currentValue,
    required this.averageValue,
    required this.summary,
  });

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      domain: json['domain'] as String,
      label: json['label'] as String,
      direction: json['direction'] as String,
      momentum: (json['momentum'] as num).toDouble(),
      values: (json['values'] as List<dynamic>)
          .map((v) => (v as num).toDouble())
          .toList(),
      currentValue: (json['currentValue'] as num).toDouble(),
      averageValue: (json['averageValue'] as num).toDouble(),
      summary: json['summary'] as String,
    );
  }
}

/// Model for an anomaly result.
class AnomalyData {
  final String domain;
  final String metric;
  final double value;
  final double baseline;
  final double deviation;
  final String direction; // above, below
  final String severity; // mild, notable, significant
  final String message;

  const AnomalyData({
    required this.domain,
    required this.metric,
    required this.value,
    required this.baseline,
    required this.deviation,
    required this.direction,
    required this.severity,
    required this.message,
  });

  factory AnomalyData.fromJson(Map<String, dynamic> json) {
    return AnomalyData(
      domain: json['domain'] as String,
      metric: json['metric'] as String,
      value: (json['value'] as num).toDouble(),
      baseline: (json['baseline'] as num).toDouble(),
      deviation: (json['deviation'] as num).toDouble(),
      direction: json['direction'] as String,
      severity: json['severity'] as String,
      message: json['message'] as String,
    );
  }
}
