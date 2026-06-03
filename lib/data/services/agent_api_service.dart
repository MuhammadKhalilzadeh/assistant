import 'dart:convert';
import 'package:assistant/data/services/http_client.dart';
import 'package:assistant/config/app_config.dart';

// ─── Goal Suggestion Model ───────────────────────────────────────────

class GoalSuggestionData {
  final String id;
  final String domain;
  final double currentGoal;
  final double suggestedGoal;
  final String direction; // increase, decrease
  final String reason;
  final double confidence;
  final Map<String, dynamic> evidence;
  final String status; // pending, accepted, rejected, expired
  final DateTime createdAt;

  const GoalSuggestionData({
    required this.id,
    required this.domain,
    required this.currentGoal,
    required this.suggestedGoal,
    required this.direction,
    required this.reason,
    required this.confidence,
    required this.evidence,
    required this.status,
    required this.createdAt,
  });

  factory GoalSuggestionData.fromJson(Map<String, dynamic> json) {
    return GoalSuggestionData(
      id: json['id'] as String,
      domain: json['domain'] as String,
      currentGoal: (json['currentGoal'] as num).toDouble(),
      suggestedGoal: (json['suggestedGoal'] as num).toDouble(),
      direction: json['direction'] as String,
      reason: json['reason'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      evidence: json['evidence'] as Map<String, dynamic>? ?? {},
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

// ─── Weekly Plan Model ───────────────────────────────────────────────

class DayPlanData {
  final String date;
  final String dayOfWeek;
  final List<RecommendationData> recommendations;
  final List<TargetData> targets;

  const DayPlanData({
    required this.date,
    required this.dayOfWeek,
    required this.recommendations,
    required this.targets,
  });

  factory DayPlanData.fromJson(Map<String, dynamic> json) {
    return DayPlanData(
      date: json['date'] as String,
      dayOfWeek: json['dayOfWeek'] as String,
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((r) =>
                  RecommendationData.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      targets: (json['targets'] as List<dynamic>?)
              ?.map((t) => TargetData.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class RecommendationData {
  final String activity;
  final String domain;
  final String suggestedTime;
  final int duration;
  final String priority; // must_do, should_do, nice_to_do
  final String reason;

  const RecommendationData({
    required this.activity,
    required this.domain,
    required this.suggestedTime,
    required this.duration,
    required this.priority,
    required this.reason,
  });

  factory RecommendationData.fromJson(Map<String, dynamic> json) {
    return RecommendationData(
      activity: json['activity'] as String,
      domain: json['domain'] as String,
      suggestedTime: json['suggestedTime'] as String,
      duration: json['duration'] as int,
      priority: json['priority'] as String,
      reason: json['reason'] as String,
    );
  }
}

class TargetData {
  final String domain;
  final double target;
  final String rationale;

  const TargetData({
    required this.domain,
    required this.target,
    required this.rationale,
  });

  factory TargetData.fromJson(Map<String, dynamic> json) {
    return TargetData(
      domain: json['domain'] as String,
      target: (json['target'] as num).toDouble(),
      rationale: json['rationale'] as String,
    );
  }
}

class WeeklyPlanData {
  final String id;
  final String weekStart;
  final String weekEnd;
  final List<DayPlanData> days;
  final List<String> focusAreas;
  final String aiSummary;
  final String status;

  const WeeklyPlanData({
    required this.id,
    required this.weekStart,
    required this.weekEnd,
    required this.days,
    required this.focusAreas,
    required this.aiSummary,
    required this.status,
  });

  factory WeeklyPlanData.fromJson(Map<String, dynamic> json) {
    return WeeklyPlanData(
      id: json['id'] as String,
      weekStart: json['weekStart'] as String,
      weekEnd: json['weekEnd'] as String,
      days: (json['days'] as List<dynamic>?)
              ?.map((d) => DayPlanData.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      focusAreas: (json['focusAreas'] as List<dynamic>?)
              ?.map((f) => f as String)
              .toList() ??
          [],
      aiSummary: json['aiSummary'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
    );
  }
}

// ─── Agent Settings Model ────────────────────────────────────────────

class AgentSettings {
  final String autonomyLevel;
  final String goalChanges;
  final String reminders;
  final String dataLogging;

  const AgentSettings({
    required this.autonomyLevel,
    required this.goalChanges,
    required this.reminders,
    required this.dataLogging,
  });

  factory AgentSettings.fromJson(Map<String, dynamic> json) {
    return AgentSettings(
      autonomyLevel: json['autonomyLevel'] as String? ?? 'suggest_only',
      goalChanges: json['goalChanges'] as String? ?? 'ask_first',
      reminders: json['reminders'] as String? ?? 'auto_with_notify',
      dataLogging: json['dataLogging'] as String? ?? 'suggest_only',
    );
  }

  Map<String, String> toJson() => {
        'autonomyLevel': autonomyLevel,
        'goalChanges': goalChanges,
        'reminders': reminders,
        'dataLogging': dataLogging,
      };
}

// ─── API Service ─────────────────────────────────────────────────────

class AgentApiService {
  final AppHttpClient _client;

  AgentApiService({AppHttpClient? client})
      : _client = client ??
            AppHttpClient(
              timeout: AppConfig.instance.requestTimeout,
              maxRetries: AppConfig.instance.maxRetries,
            );

  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  // Goal suggestions
  Future<List<GoalSuggestionData>> getPendingGoals() async {
    final response = await _client.get(Uri.parse('$_baseUrl/agent/goals'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((j) => GoalSuggestionData.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    throw parseErrorResponse(response);
  }

  Future<void> respondToGoal(String id, bool accept) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/agent/goals/$id/respond'),
      body: {'accept': accept},
    );
    if (response.statusCode != 200) throw parseErrorResponse(response);
  }

  Future<void> reviewGoals() async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/agent/goals/review'),
      body: {},
    );
    if (response.statusCode != 200) throw parseErrorResponse(response);
  }

  // Weekly plan
  Future<WeeklyPlanData?> getCurrentPlan() async {
    final response = await _client.get(Uri.parse('$_baseUrl/agent/plan'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data.containsKey('message')) return null; // No active plan
      return WeeklyPlanData.fromJson(data);
    }
    throw parseErrorResponse(response);
  }

  Future<WeeklyPlanData> generatePlan() async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/agent/plan/generate'),
      body: {},
    );
    if (response.statusCode == 200) {
      return WeeklyPlanData.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw parseErrorResponse(response);
  }

  // Agent settings
  Future<AgentSettings> getSettings() async {
    final response =
        await _client.get(Uri.parse('$_baseUrl/agent/settings'));
    if (response.statusCode == 200) {
      return AgentSettings.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw parseErrorResponse(response);
  }

  Future<void> updateSettings(AgentSettings settings) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/agent/settings'),
      body: settings.toJson(),
    );
    if (response.statusCode != 200) throw parseErrorResponse(response);
  }
}
