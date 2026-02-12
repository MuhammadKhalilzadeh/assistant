import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/step_record_model.dart';
import 'package:assistant/providers/steps_provider.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'widgets/steps_app_bar.dart';
import 'widgets/steps_progress_card.dart';
import 'widgets/quick_add_buttons.dart';
import 'widgets/steps_history_list.dart';
import 'widgets/steps_stats_card.dart';
import 'widgets/weekly_steps_chart.dart';
import 'widgets/steps_tips_card.dart';
import 'widgets/add_steps_sheet.dart';
import 'widgets/steps_goal_sheet.dart';
import 'widgets/goal_celebration.dart';

/// Main Steps page with animated progress and comprehensive tracking
class StepsPage extends ConsumerStatefulWidget {
  const StepsPage({super.key});

  @override
  ConsumerState<StepsPage> createState() => _StepsPageState();
}

class _StepsPageState extends ConsumerState<StepsPage> with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _listAnimation;

  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();

    // List stagger animation
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _listAnimation = CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOutCubic,
    );

    // Progress ring animation (continuous pulse)
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Start animations
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _addSteps(int steps) async {
    try {
      await ref.read(stepRecordsProvider.notifier).addSteps(steps);
      HapticFeedback.mediumImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.directions_walk, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Added ${_formatNumber(steps)} steps'),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add steps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteStepRecord(String id) async {
    try {
      await ref.read(stepRecordsProvider.notifier).deleteRecord(id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete record: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddStepsSheet() {
    AddStepsSheet.show(
      context,
      onAdd: (steps) {
        _addSteps(steps);
      },
    );
  }

  void _showGoalSettings() {
    final goalAsync = ref.read(stepsGoalProvider);
    final currentGoal = goalAsync.valueOrNull;
    if (currentGoal == null) return;

    StepsGoalSheet.show(
      context,
      currentGoal: currentGoal.dailyGoal,
      onGoalChanged: (newGoal) async {
        try {
          await ref.read(stepsGoalProvider.notifier).updateGoal(
            currentGoal.copyWith(dailyGoal: newGoal),
          );
        } catch (e) {
          // ignore
        }
      },
    );
  }

  void _dismissCelebration() {
    setState(() {
      _showCelebration = false;
    });
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1).replaceAll('.0', '')}k';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);

    final recordsAsync = ref.watch(stepRecordsProvider);
    final statsAsync = ref.watch(stepsStatsProvider);
    final goalAsync = ref.watch(stepsGoalProvider);
    final historyAsync = ref.watch(stepsHistoryProvider);

    final stepRecords = (recordsAsync.valueOrNull ?? []).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final stats = statsAsync.valueOrNull ?? StepsStats.empty();
    final goal = goalAsync.valueOrNull;
    final dailyGoal = goal?.dailyGoal ?? 10000;
    final todaySteps = stats.todaySteps;
    final progress = dailyGoal > 0 ? (todaySteps / dailyGoal) : 0.0;
    final last7Days = historyAsync.valueOrNull ?? [];

    // Convert last7Days to Map<String, int> for WeeklyStepsChart
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final last7DaysMap = <String, int>{};
    for (final day in last7Days) {
      final dayName = dayNames[day.date.weekday - 1];
      last7DaysMap[dayName] = day.steps;
    }

    // Create a synthetic StepRecordModel for StepsProgressCard
    final todayRecord = todaySteps > 0
        ? StepRecordModel(
            id: '',
            date: DateTime.now(),
            steps: todaySteps,
            goal: dailyGoal,
          )
        : null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // App bar
                StepsAppBar(
                  padding: padding,
                  progress: progress.clamp(0.0, 1.0),
                  onSettingsTap: _showGoalSettings,
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        children: [
                          // Progress card with ring
                          AnimatedBuilder(
                            animation: _progressAnimationController,
                            builder: (context, child) {
                              return StepsProgressCard(
                                todaySteps: todayRecord,
                                dailyGoal: dailyGoal,
                                progress: progress,
                                animationPhase: _progressAnimationController.value,
                                padding: padding,
                              );
                            },
                          ),
                          SizedBox(height: padding),

                          // Quick add buttons
                          QuickAddButtons(
                            onAddSteps: (steps) => _addSteps(steps),
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          // Walking tips
                          StepsTipsCard(
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          // Weekly stats
                          StepsStatsCard(
                            stats: stats,
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          // Weekly chart
                          WeeklyStepsChart(
                            last7DaysSteps: last7DaysMap,
                            dailyGoal: dailyGoal,
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          // Steps history
                          StepsHistoryList(
                            records: stepRecords,
                            onDelete: _deleteStepRecord,
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding * 4), // Space for FAB
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Celebration overlay
            if (_showCelebration)
              GoalCelebration(
                onDismiss: _dismissCelebration,
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStepsSheet,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Log Steps',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
