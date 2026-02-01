import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assistant/data/mock/repositories/mock_repository.dart';
import 'package:assistant/data/mock/models/sleep_record_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'widgets/sleep_app_bar.dart';
import 'widgets/sleep_progress_card.dart';
import 'widgets/quick_log_buttons.dart';
import 'widgets/sleep_history_list.dart';
import 'widgets/sleep_stats_card.dart';
import 'widgets/weekly_sleep_chart.dart';
import 'widgets/sleep_tips_card.dart';
import 'widgets/add_sleep_sheet.dart';
import 'widgets/sleep_goal_sheet.dart';
import 'widgets/goal_celebration.dart';

/// Main Sleep page with animated progress and comprehensive tracking
class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> with TickerProviderStateMixin {
  final MockRepository _repository = MockRepository();

  late AnimationController _listAnimationController;
  late AnimationController _moonAnimationController;
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

    // Moon glow animation (continuous)
    _moonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    // Check initial goal state
    final lastNight = _repository.lastNightSleep;
    final goalMinutes = _repository.sleepGoalMinutes;
    _goalWasMetBefore = lastNight != null && lastNight.duration.inMinutes >= goalMinutes;

    // Start animations
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _moonAnimationController.dispose();
    super.dispose();
  }

  void _addSleep(DateTime bedTime, DateTime wakeTime, SleepQuality quality) {
    final goalMinutes = _repository.sleepGoalMinutes;
    final previousLastNight = _repository.lastNightSleep;
    final wasPreviouslyMet = previousLastNight != null &&
        previousLastNight.duration.inMinutes >= goalMinutes;

    _repository.addSleepRecord(SleepRecordModel(
      id: '',
      bedTime: bedTime,
      wakeTime: wakeTime,
      quality: quality,
    ));

    HapticFeedback.mediumImpact();

    final newLastNight = _repository.lastNightSleep;
    final isNowMet = newLastNight != null &&
        newLastNight.duration.inMinutes >= goalMinutes;

    // Check if goal was just achieved
    if (!_goalWasMetBefore && isNowMet && !wasPreviouslyMet) {
      setState(() {
        _showCelebration = true;
        _goalWasMetBefore = true;
      });
    } else {
      setState(() {});
    }

    final hours = wakeTime.difference(bedTime).inHours;
    final minutes = wakeTime.difference(bedTime).inMinutes % 60;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.bedtime, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Logged ${hours}h ${minutes}m of sleep'),
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

  void _deleteSleepRecord(String id) {
    _repository.deleteSleepRecord(id);

    // Re-check goal status
    final lastNight = _repository.lastNightSleep;
    final goalMinutes = _repository.sleepGoalMinutes;
    _goalWasMetBefore = lastNight != null && lastNight.duration.inMinutes >= goalMinutes;

    setState(() {});
  }

  void _showAddSleepSheet() {
    AddSleepSheet.show(
      context,
      onAdd: (bedTime, wakeTime, quality) {
        _addSleep(bedTime, wakeTime, quality);
      },
    );
  }

  void _showGoalSettings() {
    SleepGoalSheet.show(
      context,
      currentGoalMinutes: _repository.sleepGoalMinutes,
      onGoalChanged: (newGoal) {
        _repository.updateSleepGoal(newGoal);
        setState(() {
          // Re-check goal status with new goal
          final lastNight = _repository.lastNightSleep;
          _goalWasMetBefore = lastNight != null &&
              lastNight.duration.inMinutes >= newGoal;
        });
      },
    );
  }

  void _handleQuickLog(TimeOfDay bedTime, TimeOfDay wakeTime) {
    final now = DateTime.now();
    final bedDateTime = DateTime(
      now.year,
      now.month,
      now.day - 1,
      bedTime.hour,
      bedTime.minute,
    );
    var wakeDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      wakeTime.hour,
      wakeTime.minute,
    );

    if (wakeDateTime.isBefore(bedDateTime)) {
      wakeDateTime = wakeDateTime.add(const Duration(days: 1));
    }

    // Determine quality based on duration
    final duration = wakeDateTime.difference(bedDateTime);
    SleepQuality quality;
    if (duration.inMinutes >= 480) {
      quality = SleepQuality.excellent;
    } else if (duration.inMinutes >= 420) {
      quality = SleepQuality.good;
    } else if (duration.inMinutes >= 360) {
      quality = SleepQuality.fair;
    } else {
      quality = SleepQuality.poor;
    }

    _addSleep(bedDateTime, wakeDateTime, quality);
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
    final lastNight = _repository.lastNightSleep;
    final goalMinutes = _repository.sleepGoalMinutes;
    final progress = lastNight != null
        ? (lastNight.duration.inMinutes / goalMinutes)
        : 0.0;
    final sleepRecords = _repository.sleepRecords.toList()
      ..sort((a, b) => b.wakeTime.compareTo(a.wakeTime));
    final stats = _repository.getWeeklySleepStats();
    final last7Days = _repository.getLast7DaysSleepHours();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // App bar
                SleepAppBar(
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
                          // Moon progress card
                          AnimatedBuilder(
                            animation: _moonAnimationController,
                            builder: (context, child) {
                              return SleepProgressCard(
                                lastNight: lastNight,
                                goalMinutes: goalMinutes,
                                progress: progress,
                                moonPhase: _moonAnimationController.value,
                                padding: padding,
                              );
                            },
                          ),
                          SizedBox(height: padding),

                          // Quick log buttons
                          QuickLogButtons(
                            onQuickLog: _handleQuickLog,
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          // Sleep tips
                          SleepTipsCard(
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          // Weekly stats
                          SleepStatsCard(
                            stats: stats,
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          // Weekly chart
                          WeeklySleepChart(
                            last7DaysHours: last7Days,
                            goalMinutes: goalMinutes,
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          // Sleep history
                          SleepHistoryList(
                            records: sleepRecords,
                            onDelete: _deleteSleepRecord,
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
        onPressed: _showAddSleepSheet,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Log Sleep',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
