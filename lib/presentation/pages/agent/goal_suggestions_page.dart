import 'package:assistant/data/services/agent_api_service.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class GoalSuggestionsPage extends StatefulWidget {
  const GoalSuggestionsPage({super.key});

  @override
  State<GoalSuggestionsPage> createState() => _GoalSuggestionsPageState();
}

class _GoalSuggestionsPageState extends State<GoalSuggestionsPage> {
  final _api = AgentApiService();
  List<GoalSuggestionData> _suggestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final suggestions = await _api.getPendingGoals();
      if (mounted) setState(() { _suggestions = suggestions; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _respond(String id, bool accept) async {
    try {
      await _api.respondToGoal(id, accept);
      setState(() => _suggestions.removeWhere((s) => s.id == id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(accept ? 'Goal updated!' : 'Suggestion dismissed'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: $e'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Goal Suggestions'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high, size: 20),
            tooltip: 'Generate new suggestions',
            onPressed: () async {
              await _api.reviewGoals();
              _load();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _suggestions.isEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 48, color: AppTheme.successColor),
                          const SizedBox(height: 12),
                          const Text('All caught up!',
                              style: TextStyle(
                                  fontSize: 14, color: AppTheme.textSecondary)),
                          const SizedBox(height: 4),
                          Text('No pending goal suggestions',
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.textTertiary)),
                        ],
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) =>
                      _buildSuggestionCard(_suggestions[index]),
                ),
    );
  }

  Widget _buildSuggestionCard(GoalSuggestionData suggestion) {
    final isIncrease = suggestion.direction == 'increase';
    final color = isIncrease ? AppTheme.successColor : AppTheme.primaryColor;
    final icon = isIncrease ? Icons.trending_up : Icons.trending_down;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_domainLabel(suggestion.domain)} Goal',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${suggestion.currentGoal.round()} → ${suggestion.suggestedGoal.round()}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${(suggestion.confidence * 100).round()}%',
                  style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            suggestion.reason,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _respond(suggestion.id, false),
                child: Text('Dismiss',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textTertiary)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _respond(suggestion.id, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Apply', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _domainLabel(String domain) {
    return switch (domain) {
      'steps' => 'Steps',
      'water' => 'Water',
      'sleep' => 'Sleep',
      'workout' => 'Workout',
      'meditation' => 'Meditation',
      _ => domain,
    };
  }
}
