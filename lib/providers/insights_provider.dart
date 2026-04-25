import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/services/jarvis_insights_service.dart';

/// State for all intelligence features: weekly report, nudges, insights.
class InsightsState {
  final WeeklyReport? weeklyReport;
  final List<Nudge> nudges;
  final List<SmartInsight> insights;
  final Set<String> dismissedNudgeIds;
  final bool isLoading;
  final DateTime? lastRefreshed;

  const InsightsState({
    this.weeklyReport,
    this.nudges = const [],
    this.insights = const [],
    this.dismissedNudgeIds = const {},
    this.isLoading = false,
    this.lastRefreshed,
  });

  /// Nudges that haven't been dismissed this session.
  List<Nudge> get activeNudges =>
      nudges.where((n) => !dismissedNudgeIds.contains(n.id)).toList();

  InsightsState copyWith({
    WeeklyReport? weeklyReport,
    List<Nudge>? nudges,
    List<SmartInsight>? insights,
    Set<String>? dismissedNudgeIds,
    bool? isLoading,
    DateTime? lastRefreshed,
  }) {
    return InsightsState(
      weeklyReport: weeklyReport ?? this.weeklyReport,
      nudges: nudges ?? this.nudges,
      insights: insights ?? this.insights,
      dismissedNudgeIds: dismissedNudgeIds ?? this.dismissedNudgeIds,
      isLoading: isLoading ?? this.isLoading,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
    );
  }
}

/// Notifier that manages all intelligence features.
class InsightsNotifier extends StateNotifier<InsightsState> {
  final JarvisInsightsService _service;

  InsightsNotifier({required JarvisInsightsService service})
      : _service = service,
        super(const InsightsState()) {
    refresh();
  }

  /// Refresh all intelligence data: report, nudges, insights.
  /// Cached for the day — only recomputes if stale or forced.
  Future<void> refresh({bool force = false}) async {
    final now = DateTime.now();
    if (!force && state.lastRefreshed != null) {
      final diff = now.difference(state.lastRefreshed!);
      if (diff.inHours < 4) return; // Cache for 4 hours
    }

    state = state.copyWith(isLoading: true);

    try {
      // Run all three computations concurrently
      final results = await Future.wait([
        _service.generateWeeklyReport(),
        _service.computeNudges(),
        _service.computeInsights(),
      ]);

      state = state.copyWith(
        weeklyReport: results[0] as WeeklyReport,
        nudges: results[1] as List<Nudge>,
        insights: results[2] as List<SmartInsight>,
        isLoading: false,
        lastRefreshed: now,
      );
    } catch (e) {
      debugPrint('[InsightsProvider] Failed to refresh: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Dismiss a nudge for this session.
  void dismissNudge(String nudgeId) {
    state = state.copyWith(
      dismissedNudgeIds: {...state.dismissedNudgeIds, nudgeId},
    );
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

/// Provider for insights state.
final insightsProvider =
    StateNotifierProvider<InsightsNotifier, InsightsState>((ref) {
  return InsightsNotifier(
    service: ref.read(jarvisInsightsServiceProvider),
  );
});
