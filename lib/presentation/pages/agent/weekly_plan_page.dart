import 'package:assistant/data/services/agent_api_service.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class WeeklyPlanPage extends StatefulWidget {
  const WeeklyPlanPage({super.key});

  @override
  State<WeeklyPlanPage> createState() => _WeeklyPlanPageState();
}

class _WeeklyPlanPageState extends State<WeeklyPlanPage> {
  final _api = AgentApiService();
  WeeklyPlanData? _plan;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final plan = await _api.getCurrentPlan();
      if (mounted) setState(() { _plan = plan; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _generate() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final plan = await _api.generatePlan();
      if (mounted) setState(() { _plan = plan; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Weekly Plan'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high, size: 20),
            tooltip: 'Generate new plan',
            onPressed: _generate,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppTheme.warningColor),
              const SizedBox(height: 12),
              Text('Failed to load plan', style: TextStyle(color: AppTheme.textSecondary)),
              TextButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_plan == null) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_month_outlined, size: 48, color: AppTheme.textTertiary),
              const SizedBox(height: 12),
              const Text('No active plan', style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _generate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Generate Weekly Plan'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // AI Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology_outlined, size: 16, color: AppTheme.primaryColor),
                  const SizedBox(width: 6),
                  const Text('AI Summary',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                ],
              ),
              const SizedBox(height: 8),
              Text(_plan!.aiSummary,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary, height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Focus areas
        if (_plan!.focusAreas.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _plan!.focusAreas.map((area) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(area,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryColor)),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Day-by-day
        ..._plan!.days.map((day) => _buildDayCard(day)),
      ],
    );
  }

  Widget _buildDayCard(DayPlanData day) {
    final isToday = day.date == DateTime.now().toIso8601String().split('T')[0];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? AppTheme.primaryColor.withValues(alpha: 0.5)
              : AppTheme.cardBorderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('TODAY',
                      style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              Text(day.dayOfWeek,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              const Spacer(),
              Text(day.date,
                  style: TextStyle(fontSize: 10, color: AppTheme.textTertiary)),
            ],
          ),

          // Recommendations
          if (day.recommendations.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...day.recommendations.map((rec) {
              final priorityColor = rec.priority == 'must_do'
                  ? AppTheme.warningColor
                  : rec.priority == 'should_do'
                      ? AppTheme.primaryColor
                      : AppTheme.textTertiary;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: priorityColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${rec.suggestedTime} - ${rec.activity}${rec.duration > 0 ? ' (${rec.duration}min)' : ''}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Targets
          if (day.targets.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: day.targets.map((target) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBorderColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_domainLabel(target.domain)}: ${target.target.round()}',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textTertiary),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _domainLabel(String domain) {
    return switch (domain) {
      'steps' => 'Steps',
      'water' => 'Water (ml)',
      'sleep' => 'Sleep (min)',
      'workout' => 'Workout',
      'meditation' => 'Meditation',
      _ => domain,
    };
  }
}
