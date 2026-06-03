import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/services/jarvis_insights_service.dart';
import 'package:assistant/data/services/insights_api_service.dart';

/// State for all intelligence features: weekly report, nudges, insights.
class InsightsState {
  final WeeklyReport? weeklyReport;
  final List<Nudge> nudges;
  final List<SmartInsight> insights;
  final List<ServerInsight> serverInsights;
  final Set<String> dismissedNudgeIds;
  final Set<String> dismissedServerInsightIds;
  final bool isLoading;
  final DateTime? lastRefreshed;

  const InsightsState({
    this.weeklyReport,
    this.nudges = const [],
    this.insights = const [],
    this.serverInsights = const [],
    this.dismissedNudgeIds = const {},
    this.dismissedServerInsightIds = const {},
    this.isLoading = false,
    this.lastRefreshed,
  });

  /// Nudges that haven't been dismissed this session.
  List<Nudge> get activeNudges =>
      nudges.where((n) => !dismissedNudgeIds.contains(n.id)).toList();

  /// Server insights that haven't been dismissed.
  List<ServerInsight> get activeServerInsights => serverInsights
      .where((i) => !dismissedServerInsightIds.contains(i.id))
      .toList();

  InsightsState copyWith({
    WeeklyReport? weeklyReport,
    List<Nudge>? nudges,
    List<SmartInsight>? insights,
    List<ServerInsight>? serverInsights,
    Set<String>? dismissedNudgeIds,
    Set<String>? dismissedServerInsightIds,
    bool? isLoading,
    DateTime? lastRefreshed,
  }) {
    return InsightsState(
      weeklyReport: weeklyReport ?? this.weeklyReport,
      nudges: nudges ?? this.nudges,
      insights: insights ?? this.insights,
      serverInsights: serverInsights ?? this.serverInsights,
      dismissedNudgeIds: dismissedNudgeIds ?? this.dismissedNudgeIds,
      dismissedServerInsightIds:
          dismissedServerInsightIds ?? this.dismissedServerInsightIds,
      isLoading: isLoading ?? this.isLoading,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
    );
  }
}

/// Notifier that manages all intelligence features.
class InsightsNotifier extends StateNotifier<InsightsState> {
  final JarvisInsightsService _service;
  final InsightsApiService _apiService;

  InsightsNotifier({
    required JarvisInsightsService service,
    required InsightsApiService apiService,
  })  : _service = service,
        _apiService = apiService,
        super(const InsightsState()) {
    refresh();
  }

  /// Refresh all intelligence data: report, nudges, insights + server insights.
  /// Cached for the day — only recomputes if stale or forced.
  Future<void> refresh({bool force = false}) async {
    final now = DateTime.now();
    if (!force && state.lastRefreshed != null) {
      final diff = now.difference(state.lastRefreshed!);
      if (diff.inHours < 4) return; // Cache for 4 hours
    }

    state = state.copyWith(isLoading: true);

    try {
      // Run client-side and server-side fetches concurrently
      final results = await Future.wait([
        _service.generateWeeklyReport(),
        _service.computeNudges(),
        _service.computeInsights(),
        _fetchServerInsights(),
      ]);

      state = state.copyWith(
        weeklyReport: results[0] as WeeklyReport,
        nudges: results[1] as List<Nudge>,
        insights: results[2] as List<SmartInsight>,
        serverInsights: results[3] as List<ServerInsight>,
        isLoading: false,
        lastRefreshed: now,
      );
    } catch (e) {
      debugPrint('[InsightsProvider] Failed to refresh: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Fetch server insights, generating new ones then fetching the list.
  Future<List<ServerInsight>> _fetchServerInsights() async {
    try {
      // Trigger generation first, then fetch all active
      await _apiService.generateInsights();
      return await _apiService.getInsights();
    } catch (e) {
      debugPrint('[InsightsProvider] Server insights unavailable: $e');
      return [];
    }
  }

  /// Dismiss a nudge for this session.
  void dismissNudge(String nudgeId) {
    state = state.copyWith(
      dismissedNudgeIds: {...state.dismissedNudgeIds, nudgeId},
    );
  }

  /// Dismiss a server insight (persisted to backend).
  Future<void> dismissServerInsight(String insightId) async {
    state = state.copyWith(
      dismissedServerInsightIds: {
        ...state.dismissedServerInsightIds,
        insightId,
      },
    );
    try {
      await _apiService.dismissInsight(insightId);
    } catch (e) {
      debugPrint('[InsightsProvider] Failed to dismiss server insight: $e');
    }
  }

  /// Force refresh nudges (e.g. on app resume).
  Future<void> refreshNudges() async {
    try {
      final nudges = await _service.computeNudges();
      state = state.copyWith(nudges: nudges);
    } catch (e) {
      debugPrint('[InsightsProvider] Failed to refresh nudges: $e');
    }
  }
}

/// Provider for the insights API service.
final insightsApiServiceProvider = Provider<InsightsApiService>((ref) {
  return InsightsApiService();
});

/// Provider for insights state.
final insightsProvider =
    StateNotifierProvider<InsightsNotifier, InsightsState>((ref) {
  return InsightsNotifier(
    service: ref.read(jarvisInsightsServiceProvider),
    apiService: ref.read(insightsApiServiceProvider),
  );
});
