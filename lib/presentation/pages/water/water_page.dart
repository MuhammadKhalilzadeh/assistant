import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/water_log_model.dart';
import 'package:assistant/providers/water_provider.dart';
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
class WaterPage extends ConsumerStatefulWidget {
  const WaterPage({super.key});

  @override
  ConsumerState<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends ConsumerState<WaterPage> with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late AnimationController _waveAnimationController;
  late Animation<double> _listAnimation;

  bool _showCelebration = false;
  bool _goalWasMetBefore = false;
  int _previousIntake = 0;

  @override
  void initState() {
    super.initState();

    // List stagger animation
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
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

    // Start animations
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _waveAnimationController.dispose();
    super.dispose();
  }

  void _checkGoalCelebration(int currentIntake, int dailyGoal) {
    // Check if goal was just achieved
    if (!_goalWasMetBefore && currentIntake >= dailyGoal && _previousIntake < dailyGoal) {
      setState(() {
        _showCelebration = true;
        _goalWasMetBefore = true;
      });
    }
    _previousIntake = currentIntake;
  }

  Future<void> _addWater(int amount, {BeverageType type = BeverageType.water, String? note}) async {
    try {
      final log = WaterLogModel(
        id: '', // Will be assigned by server
        amountMl: amount,
        loggedAt: DateTime.now(),
        beverageType: type,
        note: note,
      );

      await ref.read(waterLogsProvider.notifier).addLog(log);
      HapticFeedback.mediumImpact();

      if (mounted) {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add water: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteWaterLog(String id) async {
    try {
      await ref.read(waterLogsProvider.notifier).deleteLog(id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
    final goalAsync = ref.read(hydrationGoalProvider);
    final currentGoal = goalAsync.valueOrNull?.dailyGoalMl ?? 3000;
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _GoalSettingsSheet(
        currentGoal: currentGoal,
        onGoalChanged: (newGoal) async {
          try {
            final goal = ref.read(hydrationGoalProvider).valueOrNull;
            if (goal != null) {
              await ref.read(hydrationGoalProvider.notifier).updateGoal(
                goal.copyWith(dailyGoalMl: newGoal),
              );
            }
          } catch (e) {
            messenger.showSnackBar(
              SnackBar(
                content: Text('Failed to update goal: $e'),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
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

    // Watch providers
    final logsAsync = ref.watch(waterLogsProvider);
    final goalAsync = ref.watch(hydrationGoalProvider);
    final statsAsync = ref.watch(waterStatsProvider);
    final historyAsync = ref.watch(waterHistoryProvider);

    // Calculate current intake and progress
    final currentIntake = logsAsync.whenOrNull(
      data: (logs) => logs.fold<int>(0, (sum, log) => sum + log.amountMl),
    ) ?? 0;
    final dailyGoal = goalAsync.valueOrNull?.dailyGoalMl ?? 3000;
    final progress = dailyGoal > 0 ? (currentIntake / dailyGoal) : 0.0;

    // Check for goal celebration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkGoalCelebration(currentIntake, dailyGoal);
    });

    // Convert history to map for DailyHistoryWidget
    final last7Days = historyAsync.whenOrNull(
      data: (history) {
        final Map<String, int> result = {};
        for (final summary in history) {
          final dayName = _getDayName(summary.date);
          result[dayName] = summary.totalMl;
        }
        return result;
      },
    ) ?? {};

    // Get stats for HydrationStatsCard (convert from WaterStats to HydrationStats-like)
    final stats = statsAsync.whenOrNull(
      data: (s) => _HydrationStatsData(
        weeklyAverageMl: s.weeklyAverageMl.toDouble(),
        currentStreak: s.currentStreak,
        bestStreak: s.bestStreak,
        goalCompletionRate: s.goalCompletionRate,
      ),
    ) ?? _HydrationStatsData(
      weeklyAverageMl: 0,
      currentStreak: 0,
      bestStreak: 0,
      goalCompletionRate: 0,
    );

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
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(waterLogsProvider.notifier).refresh();
                      ref.invalidate(waterStatsProvider);
                      ref.invalidate(waterHistoryProvider);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                            statsAsync.when(
                              data: (_) => HydrationStatsCard(
                                stats: stats,
                                padding: padding,
                                animation: _listAnimation,
                              ),
                              loading: () => _buildLoadingCard(padding),
                              error: (e, _) => _buildErrorCard(padding, 'Stats: $e'),
                            ),
                            SizedBox(height: padding),

                            // Daily history chart
                            historyAsync.when(
                              data: (_) => DailyHistoryWidget(
                                last7DaysIntake: last7Days,
                                dailyGoal: dailyGoal,
                                padding: padding,
                                animation: _listAnimation,
                              ),
                              loading: () => _buildLoadingCard(padding),
                              error: (e, _) => _buildErrorCard(padding, 'History: $e'),
                            ),
                            SizedBox(height: padding),

                            // Today's logs
                            logsAsync.when(
                              data: (logs) => WaterLogList(
                                logs: logs,
                                onDelete: _deleteWaterLog,
                                padding: padding,
                                animation: _listAnimation,
                              ),
                              loading: () => _buildLoadingCard(padding),
                              error: (e, _) => _buildErrorCard(padding, 'Logs: $e'),
                            ),
                            SizedBox(height: padding * 4), // Space for FAB
                          ],
                        ),
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

  String _getDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  Widget _buildLoadingCard(double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
        boxShadow: AppTheme.cardShadow,
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorCard(double padding, String message) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: AppTheme.errorColor),
        ),
      ),
    );
  }
}

/// Helper class to pass stats to HydrationStatsCard
class _HydrationStatsData {
  final double weeklyAverageMl;
  final int currentStreak;
  final int bestStreak;
  final double goalCompletionRate;

  _HydrationStatsData({
    required this.weeklyAverageMl,
    required this.currentStreak,
    required this.bestStreak,
    required this.goalCompletionRate,
  });
}

/// Bottom sheet for updating daily goal (matches AddWaterSheet pattern)
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

  void _handleSave() {
    HapticFeedback.mediumImpact();
    widget.onGoalChanged(_sliderValue.toInt());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.75,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: AppTheme.elevatedShadow,
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Centered title
                      Center(
                        child: Text(
                          'Daily Goal',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Goal section label
                      Text(
                        'Target (ml)',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Goal display container with input styling
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${_sliderValue.toInt()}',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppTheme.primaryColor,
                          inactiveTrackColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                          thumbColor: AppTheme.primaryColor,
                          overlayColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: _sliderValue,
                          min: 1000,
                          max: 5000,
                          divisions: 40,
                          label: '${_sliderValue.toInt()}ml',
                          onChanged: (value) {
                            HapticFeedback.selectionClick();
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
                              color: AppTheme.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '5000ml',
                            style: TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Quick select section label
                      Text(
                        'Quick Select',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Quick select chips (responsive)
                      Row(
                        children: [2000, 2500, 3000, 3500].asMap().entries.map((entry) {
                          final index = entry.key;
                          final goal = entry.value;
                          final isSelected = _sliderValue.toInt() == goal;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: index > 0 ? 8 : 0),
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _sliderValue = goal.toDouble();
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : AppTheme.backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : AppTheme.primaryColor.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${goal}ml',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : AppTheme.textSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Tip card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: AppTheme.primaryColor.withValues(alpha: 0.8),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Adults should drink 2-3 liters of water daily for optimal hydration.',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Single save button (matches AddWaterSheet)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: AppTheme.textOnPrimary,
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
