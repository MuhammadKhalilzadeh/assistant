import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assistant/data/mock/repositories/mock_repository.dart';
import 'package:assistant/data/mock/models/water_log_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'widgets/water_app_bar.dart';
import 'widgets/water_progress_card.dart';
import 'widgets/quick_add_buttons.dart';
import 'widgets/water_log_list.dart';
import 'widgets/hydration_stats_card.dart';
import 'widgets/daily_history_widget.dart';
import 'widgets/add_water_sheet.dart';
import 'widgets/hydration_tips_card.dart';
import 'widgets/goal_celebration.dart';

/// Main Water Intake page with animated wave progress and comprehensive tracking
class WaterPage extends StatefulWidget {
  const WaterPage({super.key});

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> with TickerProviderStateMixin {
  final MockRepository _repository = MockRepository();

  late AnimationController _listAnimationController;
  late AnimationController _waveAnimationController;
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

    // Wave animation (continuous)
    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Check initial goal state
    final currentIntake = _repository.todayWaterIntake;
    final dailyGoal = _repository.hydrationGoal.dailyGoalMl;
    _goalWasMetBefore = currentIntake >= dailyGoal;

    // Start animations
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _waveAnimationController.dispose();
    super.dispose();
  }

  void _addWater(int amount, {BeverageType type = BeverageType.water, String? note}) {
    final previousIntake = _repository.todayWaterIntake;
    final dailyGoal = _repository.hydrationGoal.dailyGoalMl;

    _repository.addWaterLog(amount, type: type, note: note);
    HapticFeedback.mediumImpact();

    final newIntake = _repository.todayWaterIntake;

    // Check if goal was just achieved
    if (!_goalWasMetBefore && newIntake >= dailyGoal && previousIntake < dailyGoal) {
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
            const Icon(Icons.water_drop, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Added ${amount}ml of ${type.displayName.toLowerCase()}'),
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

  void _deleteWaterLog(String id) {
    _repository.deleteWaterLog(id);

    // Re-check goal status
    final currentIntake = _repository.todayWaterIntake;
    final dailyGoal = _repository.hydrationGoal.dailyGoalMl;
    _goalWasMetBefore = currentIntake >= dailyGoal;

    setState(() {});
  }

  void _showAddWaterSheet() {
    AddWaterSheet.show(
      context,
      onAdd: (amount, type, note) {
        _addWater(amount, type: type, note: note);
      },
    );
  }

  void _showGoalSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _GoalSettingsSheet(
        currentGoal: _repository.hydrationGoal.dailyGoalMl,
        onGoalChanged: (newGoal) {
          _repository.updateDailyGoal(newGoal);
          setState(() {
            // Re-check goal status with new goal
            final currentIntake = _repository.todayWaterIntake;
            _goalWasMetBefore = currentIntake >= newGoal;
          });
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
    final currentIntake = _repository.todayWaterIntake;
    final dailyGoal = _repository.hydrationGoal.dailyGoalMl;
    final progress = dailyGoal > 0 ? (currentIntake / dailyGoal) : 0.0;
    final todayLogs = _repository.getWaterLogsForDate(DateTime.now());
    final stats = _repository.getWeeklyStats();
    final last7Days = _repository.getLast7DaysIntake();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
                children: [
                  // App bar
                  WaterAppBar(
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
                            // Wave progress card
                            AnimatedBuilder(
                              animation: _waveAnimationController,
                              builder: (context, child) {
                                return WaterProgressCard(
                                  currentIntake: currentIntake,
                                  dailyGoal: dailyGoal,
                                  progress: progress,
                                  wavePhase: _waveAnimationController.value * 2 * math.pi,
                                  padding: padding,
                                );
                              },
                            ),
                            SizedBox(height: padding),

                            // Quick add buttons
                            QuickAddButtons(
                              onAddWater: (amount) => _addWater(amount),
                              padding: padding,
                              animation: _listAnimation,
                              index: 0,
                            ),
                            SizedBox(height: padding),

                            // Hydration tips
                            HydrationTipsCard(
                              padding: padding,
                              animation: _listAnimation,
                            ),
                            SizedBox(height: padding),

                            // Weekly stats
                            HydrationStatsCard(
                              stats: stats,
                              padding: padding,
                              animation: _listAnimation,
                            ),
                            SizedBox(height: padding),

                            // Daily history chart
                            DailyHistoryWidget(
                              last7DaysIntake: last7Days,
                              dailyGoal: dailyGoal,
                              padding: padding,
                              animation: _listAnimation,
                            ),
                            SizedBox(height: padding),

                            // Today's logs
                            WaterLogList(
                              logs: todayLogs,
                              onDelete: _deleteWaterLog,
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
        onPressed: _showAddWaterSheet,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Custom',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Bottom sheet for updating daily goal
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
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.currentGoal.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10B981),
            Color(0xFF06B6D4),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Daily Goal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Set your daily hydration target',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              // Goal display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_sliderValue.toInt()} ml',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withValues(alpha: 0.2),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _sliderValue,
                  min: 1000,
                  max: 5000,
                  divisions: 40,
                  onChanged: (value) {
                    setState(() {
                      _sliderValue = value;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '1000ml',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '5000ml',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Quick select buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [2000, 2500, 3000, 3500].map((goal) {
                  final isSelected = _sliderValue.toInt() == goal;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _sliderValue = goal.toDouble();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${goal}ml',
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF10B981)
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onGoalChanged(_sliderValue.toInt());
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Goal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
