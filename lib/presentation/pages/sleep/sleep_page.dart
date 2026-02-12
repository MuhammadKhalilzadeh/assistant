import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/sleep_record_model.dart';
import 'package:assistant/providers/sleep_provider.dart';
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
class SleepPage extends ConsumerStatefulWidget {
  const SleepPage({super.key});

  @override
  ConsumerState<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends ConsumerState<SleepPage> with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late AnimationController _moonAnimationController;
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

    // Moon glow animation (continuous)
    _moonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    // Start animations
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _moonAnimationController.dispose();
    super.dispose();
  }

  void _addSleep(DateTime bedTime, DateTime wakeTime, SleepQuality quality) async {
    try {
      await ref.read(sleepRecordsProvider.notifier).addRecord(SleepRecordModel(
        id: '',
        bedTime: bedTime,
        wakeTime: wakeTime,
        quality: quality,
      ));
      HapticFeedback.mediumImpact();
      final hours = wakeTime.difference(bedTime).inHours;
      final minutes = wakeTime.difference(bedTime).inMinutes % 60;
      if (mounted) {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log sleep: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _deleteSleepRecord(String id) async {
    try {
      await ref.read(sleepRecordsProvider.notifier).deleteRecord(id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete record: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
    final goalAsync = ref.read(sleepGoalProvider);
    final currentGoal = goalAsync.valueOrNull;
    if (currentGoal == null) return;

    SleepGoalSheet.show(
      context,
      currentGoalMinutes: currentGoal.goalMinutes,
      onGoalChanged: (newGoal) async {
        try {
          await ref.read(sleepGoalProvider.notifier).updateGoal(
            currentGoal.copyWith(goalMinutes: newGoal),
          );
        } catch (e) { /* ignore */ }
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

    final recordsAsync = ref.watch(sleepRecordsProvider);
    final statsAsync = ref.watch(sleepStatsProvider);
    final goalAsync = ref.watch(sleepGoalProvider);
    final historyAsync = ref.watch(sleepHistoryProvider);

    final sleepRecords = (recordsAsync.valueOrNull ?? []).toList()
      ..sort((a, b) => b.wakeTime.compareTo(a.wakeTime));
    final stats = statsAsync.valueOrNull ?? SleepStats.empty();
    final goal = goalAsync.valueOrNull;
    final goalMinutes = goal?.goalMinutes ?? 480;
    final lastNight = sleepRecords.isNotEmpty ? sleepRecords.first : null;
    final progress = lastNight != null ? (lastNight.duration.inMinutes / goalMinutes) : 0.0;
    final last7Days = historyAsync.valueOrNull ?? [];

    // Convert to Map for WeeklySleepChart
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final last7DaysHours = <String, double>{};
    for (final day in last7Days) {
      final dayName = dayNames[day.date.weekday - 1];
      last7DaysHours[dayName] = day.durationHours;
    }

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
                            last7DaysHours: last7DaysHours,
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
