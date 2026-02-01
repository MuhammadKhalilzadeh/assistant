import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assistant/data/mock/repositories/mock_repository.dart';
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
class StepsPage extends StatefulWidget {
  const StepsPage({super.key});

  @override
  State<StepsPage> createState() => _StepsPageState();
}

class _StepsPageState extends State<StepsPage> with TickerProviderStateMixin {
  final MockRepository _repository = MockRepository();

  late AnimationController _listAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _listAnimation;

  bool _showCelebration = false;
  bool _goalWasMetBefore = false;

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

    // Check initial goal state
    final todaySteps = _repository.todaySteps;
    final dailyGoal = _repository.stepsGoal.dailyGoal;
    _goalWasMetBefore = todaySteps != null && todaySteps.steps >= dailyGoal;

    // Start animations
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _addSteps(int steps) {
    final previousSteps = _repository.todaySteps?.steps ?? 0;
    final dailyGoal = _repository.stepsGoal.dailyGoal;

    _repository.addSteps(steps);
    HapticFeedback.mediumImpact();

    final newSteps = _repository.todaySteps?.steps ?? 0;

    // Check if goal was just achieved
    if (!_goalWasMetBefore && newSteps >= dailyGoal && previousSteps < dailyGoal) {
      setState(() {
        _showCelebration = true;
        _goalWasMetBefore = true;
      });
    } else {
      setState(() {});
    }

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

  void _deleteStepRecord(String id) {
    _repository.deleteStepRecord(id);

    // Re-check goal status
    final todaySteps = _repository.todaySteps;
    final dailyGoal = _repository.stepsGoal.dailyGoal;
    _goalWasMetBefore = todaySteps != null && todaySteps.steps >= dailyGoal;

    setState(() {});
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
    StepsGoalSheet.show(
      context,
      currentGoal: _repository.stepsGoal.dailyGoal,
      onGoalChanged: (newGoal) {
        _repository.updateStepsGoal(newGoal);
        setState(() {
          // Re-check goal status with new goal
          final todaySteps = _repository.todaySteps;
          _goalWasMetBefore = todaySteps != null && todaySteps.steps >= newGoal;
        });
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
    final todaySteps = _repository.todaySteps;
    final dailyGoal = _repository.stepsGoal.dailyGoal;
    final progress = todaySteps != null
        ? (todaySteps.steps / dailyGoal)
        : 0.0;
    final stepRecords = _repository.stepRecords.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final stats = _repository.getWeeklyStepsStats();
    final last7Days = _repository.getLast7DaysStepsMap();

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
                                todaySteps: todaySteps,
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
                            last7DaysSteps: last7Days,
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
