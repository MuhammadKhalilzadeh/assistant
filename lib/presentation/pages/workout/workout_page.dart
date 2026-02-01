import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assistant/data/mock/repositories/mock_repository.dart';
import 'package:assistant/data/mock/models/workout_session_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'widgets/workout_app_bar.dart';
import 'widgets/workout_progress_card.dart';
import 'widgets/workout_type_selector.dart';
import 'widgets/workout_history_list.dart';
import 'widgets/workout_stats_card.dart';
import 'widgets/workout_tips_card.dart';
import 'widgets/goal_celebration.dart';

/// Main Workout page with timer-based tracking
class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> with TickerProviderStateMixin {
  final MockRepository _repository = MockRepository();

  late AnimationController _listAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _listAnimation;

  bool _showCelebration = false;
  bool _goalWasMetBefore = false;

  // Timer state
  bool _isTimerActive = false;
  int _timerSeconds = 0;
  Timer? _timer;
  WorkoutType _selectedWorkoutType = WorkoutType.running;
  DateTime? _workoutStartTime;

  @override
  void initState() {
    super.initState();

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _listAnimation = CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOutCubic,
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Check initial goal state
    final weeklyMinutes = _repository.getWeeklyWorkoutStats().weeklyMinutes;
    final weeklyGoal = _repository.workoutGoal.weeklyMinutesGoal;
    _goalWasMetBefore = weeklyMinutes >= weeklyGoal;

    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _progressAnimationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startWorkout() {
    setState(() {
      _isTimerActive = true;
      _timerSeconds = 0;
      _workoutStartTime = DateTime.now();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timerSeconds++;
      });
    });

    HapticFeedback.mediumImpact();
  }

  void _stopWorkout() {
    _timer?.cancel();

    if (_timerSeconds >= 60) {
      // Only save workouts >= 1 minute
      final durationMinutes = (_timerSeconds / 60).ceil();
      final caloriesBurned = _calculateCalories(durationMinutes);

      final previousMinutes = _repository.getWeeklyWorkoutStats().weeklyMinutes;
      final weeklyGoal = _repository.workoutGoal.weeklyMinutesGoal;

      _repository.addWorkoutSession(WorkoutSessionModel(
        id: '',
        type: _selectedWorkoutType,
        startTime: _workoutStartTime ?? DateTime.now(),
        endTime: DateTime.now(),
        durationMinutes: durationMinutes,
        caloriesBurned: caloriesBurned,
      ));

      final newMinutes = _repository.getWeeklyWorkoutStats().weeklyMinutes;

      // Check if goal was just achieved
      if (!_goalWasMetBefore && newMinutes >= weeklyGoal && previousMinutes < weeklyGoal) {
        setState(() {
          _showCelebration = true;
          _goalWasMetBefore = true;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.fitness_center, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Workout saved: $durationMinutes min'),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }

    setState(() {
      _isTimerActive = false;
      _timerSeconds = 0;
      _workoutStartTime = null;
    });

    HapticFeedback.mediumImpact();
  }

  int _calculateCalories(int durationMinutes) {
    // Rough calorie estimate based on workout type
    final caloriesPerMinute = switch (_selectedWorkoutType) {
      WorkoutType.running => 10,
      WorkoutType.cycling => 8,
      WorkoutType.strength => 6,
      WorkoutType.yoga => 3,
      WorkoutType.swimming => 9,
      WorkoutType.walking => 4,
      WorkoutType.hiit => 12,
      WorkoutType.other => 5,
    };
    return durationMinutes * caloriesPerMinute;
  }

  void _deleteWorkout(String id) {
    _repository.deleteWorkoutSession(id);

    // Re-check goal status
    final weeklyMinutes = _repository.getWeeklyWorkoutStats().weeklyMinutes;
    final weeklyGoal = _repository.workoutGoal.weeklyMinutesGoal;
    _goalWasMetBefore = weeklyMinutes >= weeklyGoal;

    setState(() {});
  }

  void _showGoalSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _GoalSettingsSheet(
        currentGoal: _repository.workoutGoal.weeklyMinutesGoal,
        onGoalChanged: (newGoal) {
          _repository.updateWorkoutGoal(weeklyMinutesGoal: newGoal);
          setState(() {
            final weeklyMinutes = _repository.getWeeklyWorkoutStats().weeklyMinutes;
            _goalWasMetBefore = weeklyMinutes >= newGoal;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _dismissCelebration() {
    setState(() {
      _showCelebration = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);
    final stats = _repository.getWeeklyWorkoutStats();
    final weeklyGoal = _repository.workoutGoal.weeklyMinutesGoal;
    final progress = stats.weeklyMinutes / weeklyGoal;
    final workouts = _repository.workoutSessions.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                WorkoutAppBar(
                  padding: padding,
                  progress: progress.clamp(0.0, 1.0),
                  onSettingsTap: _showGoalSettings,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _progressAnimationController,
                            builder: (context, child) {
                              return WorkoutProgressCard(
                                todayMinutes: _repository.todayWorkoutMinutes,
                                todaySessions: _repository.todayWorkoutSessions,
                                todayCalories: _repository.todayWorkoutCalories,
                                weeklyGoal: weeklyGoal,
                                progress: progress,
                                animationPhase: _progressAnimationController.value,
                                padding: padding,
                                isTimerActive: _isTimerActive,
                                timerSeconds: _timerSeconds,
                                activeWorkoutType: _isTimerActive ? _selectedWorkoutType : null,
                                onStartWorkout: _startWorkout,
                                onStopWorkout: _stopWorkout,
                              );
                            },
                          ),
                          SizedBox(height: padding),

                          WorkoutTypeSelector(
                            selectedType: _selectedWorkoutType,
                            onTypeSelected: (type) {
                              setState(() {
                                _selectedWorkoutType = type;
                              });
                            },
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          WorkoutTipsCard(
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          WorkoutStatsCard(
                            stats: stats,
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          WorkoutHistoryList(
                            workouts: workouts,
                            onDelete: _deleteWorkout,
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding * 2),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_showCelebration)
              GoalCelebration(
                onDismiss: _dismissCelebration,
              ),
          ],
        ),
      ),
    );
  }
}

class _GoalSettingsSheet extends StatefulWidget {
  final int currentGoal;
  final Function(int) onGoalChanged;

  const _GoalSettingsSheet({
    required this.currentGoal,
    required this.onGoalChanged,
  });

  @override
  State<_GoalSettingsSheet> createState() => _GoalSettingsSheetState();
}

class _GoalSettingsSheetState extends State<_GoalSettingsSheet> {
  late int _goal;

  @override
  void initState() {
    super.initState();
    _goal = widget.currentGoal;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Goal',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your weekly workout minutes goal',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (_goal > 30) {
                    setState(() => _goal -= 30);
                  }
                },
                icon: Icon(Icons.remove_circle_outline, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Text(
                '$_goal min',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  if (_goal < 600) {
                    setState(() => _goal += 30);
                  }
                },
                icon: Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onGoalChanged(_goal),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Goal',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
