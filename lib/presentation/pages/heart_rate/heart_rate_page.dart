import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/heart_rate_model.dart';
import 'package:assistant/providers/heart_rate_provider.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'widgets/heart_rate_app_bar.dart';
import 'widgets/heart_rate_progress_card.dart';
import 'widgets/heart_rate_history_list.dart';
import 'widgets/heart_rate_stats_card.dart';
import 'widgets/heart_rate_tips_card.dart';
import 'widgets/goal_celebration.dart';

/// Main Heart Rate page with BPM tracking and zone display
class HeartRatePage extends ConsumerStatefulWidget {
  const HeartRatePage({super.key});

  @override
  ConsumerState<HeartRatePage> createState() => _HeartRatePageState();
}

class _HeartRatePageState extends ConsumerState<HeartRatePage> with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _listAnimation;

  bool _showCelebration = false;

  // Quick BPM options for logging
  static const List<int> _quickBpmOptions = [60, 70, 80, 90, 100, 120];

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

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  void _addHeartRateReading(int bpm) async {
    try {
      await ref.read(heartRateRecordsProvider.notifier).addRecord(
        HeartRateRecordModel(id: '', bpm: bpm, recordedAt: DateTime.now()),
      );
      HapticFeedback.mediumImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Heart rate logged: $bpm BPM'),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
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
          SnackBar(content: Text('Failed to log heart rate: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _deleteReading(String id) async {
    try {
      await ref.read(heartRateRecordsProvider.notifier).deleteRecord(id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showGoalSettings() {
    final goalAsync = ref.read(heartRateGoalProvider);
    final currentGoal = goalAsync.valueOrNull;
    if (currentGoal == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _GoalSettingsSheet(
        currentGoal: currentGoal.targetRestingBpm,
        onGoalChanged: (newGoal) async {
          try {
            await ref.read(heartRateGoalProvider.notifier).updateGoal(
              currentGoal.copyWith(targetRestingBpm: newGoal),
            );
          } catch (e) {
            // ignore
          }
          if (mounted) Navigator.pop(context);
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

    final recordsAsync = ref.watch(heartRateRecordsProvider);
    final statsAsync = ref.watch(heartRateStatsProvider);
    final goalAsync = ref.watch(heartRateGoalProvider);

    final records = recordsAsync.valueOrNull ?? [];
    final stats = statsAsync.valueOrNull ?? HeartRateStats.empty();
    final goal = goalAsync.valueOrNull;

    final sortedRecords = records.toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    final latestReading = sortedRecords.isNotEmpty ? sortedRecords.first : null;
    final progress = (stats.totalReadings / 7).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                HeartRateAppBar(
                  padding: padding,
                  progress: progress,
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
                            animation: _pulseAnimationController,
                            builder: (context, child) {
                              return HeartRateProgressCard(
                                currentBpm: latestReading?.bpm,
                                currentZone: latestReading?.zone,
                                targetRestingBpm: goal?.targetRestingBpm ?? 65,
                                animationPhase: _pulseAnimationController.value,
                                padding: padding,
                                quickBpmOptions: _quickBpmOptions,
                                onQuickAdd: _addHeartRateReading,
                              );
                            },
                          ),
                          SizedBox(height: padding),

                          HeartRateTipsCard(
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          HeartRateStatsCard(
                            stats: stats,
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          HeartRateHistoryList(
                            records: sortedRecords,
                            onDelete: _deleteReading,
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
            'Target Resting Heart Rate',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your target resting heart rate goal',
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
                  if (_goal > 40) {
                    setState(() => _goal -= 5);
                  }
                },
                icon: Icon(Icons.remove_circle_outline, color: AppTheme.errorColor),
              ),
              const SizedBox(width: 16),
              Text(
                '$_goal BPM',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  if (_goal < 100) {
                    setState(() => _goal += 5);
                  }
                },
                icon: Icon(Icons.add_circle_outline, color: AppTheme.errorColor),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onGoalChanged(_goal),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
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
