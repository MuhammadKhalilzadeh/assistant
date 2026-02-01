import 'package:flutter/material.dart';
import 'package:assistant/data/mock/repositories/mock_repository.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'widgets/screen_time_app_bar.dart';
import 'widgets/screen_time_progress_card.dart';
import 'widgets/screen_time_stats_card.dart';
import 'widgets/screen_time_history_list.dart';
import 'widgets/screen_time_tips_card.dart';
import 'widgets/app_usage_chart.dart';
import 'widgets/goal_celebration.dart';

/// Main Screen Time page with auto-tracked usage and goal monitoring
class ScreenTimePage extends StatefulWidget {
  const ScreenTimePage({super.key});

  @override
  State<ScreenTimePage> createState() => _ScreenTimePageState();
}

class _ScreenTimePageState extends State<ScreenTimePage> with TickerProviderStateMixin {
  final MockRepository _repository = MockRepository();

  late AnimationController _listAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _listAnimation;

  bool _showCelebration = false;

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

    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _showGoalSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _GoalSettingsSheet(
        currentLimit: _repository.screenTimeGoal.dailyLimitMinutes,
        onLimitChanged: (newLimit) {
          _repository.updateScreenTimeGoal(dailyLimitMinutes: newLimit);
          setState(() {});
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
    final todayScreenTime = _repository.todayScreenTime;
    final yesterdayScreenTime = _repository.yesterdayScreenTime;
    final dailyLimit = _repository.screenTimeGoal.dailyLimitMinutes;
    final totalMinutes = todayScreenTime?.totalMinutes ?? 0;
    final progress = totalMinutes / dailyLimit;
    final isOverLimit = totalMinutes > dailyLimit;
    final stats = _repository.getWeeklyScreenTimeStats();
    final records = _repository.screenTimeRecords.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                ScreenTimeAppBar(
                  padding: padding,
                  progress: progress.clamp(0.0, 1.0),
                  isOverLimit: isOverLimit,
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
                              return ScreenTimeProgressCard(
                                todayScreenTime: todayScreenTime,
                                yesterdayScreenTime: yesterdayScreenTime,
                                dailyLimit: dailyLimit,
                                progress: progress,
                                animationPhase: _progressAnimationController.value,
                                padding: padding,
                              );
                            },
                          ),
                          SizedBox(height: padding),

                          // App usage breakdown
                          if (todayScreenTime != null && todayScreenTime.appUsage.isNotEmpty)
                            AppUsageChart(
                              appUsage: todayScreenTime.appUsage,
                              padding: padding,
                              animation: _listAnimation,
                            ),
                          if (todayScreenTime != null && todayScreenTime.appUsage.isNotEmpty)
                            SizedBox(height: padding),

                          ScreenTimeTipsCard(
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          ScreenTimeStatsCard(
                            stats: stats,
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          ScreenTimeHistoryList(
                            records: records,
                            dailyLimit: dailyLimit,
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
  final int currentLimit;
  final Function(int) onLimitChanged;

  const _GoalSettingsSheet({
    required this.currentLimit,
    required this.onLimitChanged,
  });

  @override
  State<_GoalSettingsSheet> createState() => _GoalSettingsSheetState();
}

class _GoalSettingsSheetState extends State<_GoalSettingsSheet> {
  late int _limit;

  @override
  void initState() {
    super.initState();
    _limit = widget.currentLimit;
  }

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
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
            'Daily Limit',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your daily screen time limit',
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
                  if (_limit > 30) {
                    setState(() => _limit -= 30);
                  }
                },
                icon: Icon(Icons.remove_circle_outline, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Text(
                _formatTime(_limit),
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  if (_limit < 480) {
                    setState(() => _limit += 30);
                  }
                },
                icon: Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Preset buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PresetButton(
                label: '1h',
                minutes: 60,
                isSelected: _limit == 60,
                onTap: () => setState(() => _limit = 60),
              ),
              _PresetButton(
                label: '2h',
                minutes: 120,
                isSelected: _limit == 120,
                onTap: () => setState(() => _limit = 120),
              ),
              _PresetButton(
                label: '3h',
                minutes: 180,
                isSelected: _limit == 180,
                onTap: () => setState(() => _limit = 180),
              ),
              _PresetButton(
                label: '4h',
                minutes: 240,
                isSelected: _limit == 240,
                onTap: () => setState(() => _limit = 240),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onLimitChanged(_limit),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Limit',
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

class _PresetButton extends StatelessWidget {
  final String label;
  final int minutes;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.minutes,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
