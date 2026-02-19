import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/screen_time_model.dart';
import 'package:assistant/data/services/device_screen_time_service.dart';
import 'package:assistant/providers/screen_time_provider.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'widgets/screen_time_app_bar.dart';
import 'widgets/screen_time_progress_card.dart';
import 'widgets/screen_time_stats_card.dart';
import 'widgets/screen_time_history_list.dart';
import 'widgets/screen_time_tips_card.dart';
import 'widgets/app_usage_chart.dart';
import 'widgets/goal_celebration.dart';

/// Main Screen Time page with auto-tracked usage and goal monitoring
class ScreenTimePage extends ConsumerStatefulWidget {
  const ScreenTimePage({super.key});

  @override
  ConsumerState<ScreenTimePage> createState() => _ScreenTimePageState();
}

class _ScreenTimePageState extends ConsumerState<ScreenTimePage> with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _listAnimation;

  bool _showCelebration = false;
  final DeviceScreenTimeService _deviceService = DeviceScreenTimeService();
  bool _syncedDeviceData = false;

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

    // Auto-sync device data on Android
    _syncDeviceData();
  }

  Future<void> _syncDeviceData() async {
    if (_syncedDeviceData || !_deviceService.isAndroid) return;
    _syncedDeviceData = true;

    final hasPermission = await _deviceService.hasPermission();
    if (!hasPermission) return;

    try {
      final record = await _deviceService.buildRecordFromDevice();
      if (record != null) {
        await ref.read(screenTimeRecordProvider.notifier).syncRecord(record);
      }
    } catch (_) {
      // Silently fail device sync - user can still see cached/manual data
    }
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _showGoalSettings() {
    final goalAsync = ref.read(screenTimeGoalProvider);
    final currentLimit = goalAsync.valueOrNull?.dailyLimitMinutes ?? 180;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _GoalSettingsSheet(
        currentLimit: currentLimit,
        onLimitChanged: (newLimit) async {
          final goal = ref.read(screenTimeGoalProvider).valueOrNull;
          if (goal != null) {
            await ref.read(screenTimeGoalProvider.notifier).updateGoal(
              goal.copyWith(dailyLimitMinutes: newLimit),
            );
          }
          if (!context.mounted) return;
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(
          'Usage Access Required',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'To track your screen time automatically, please grant usage access permission in Settings.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later', style: TextStyle(color: AppTheme.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deviceService.openUsageSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
          ),
        ],
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

    final recordAsync = ref.watch(screenTimeRecordProvider);
    final goalAsync = ref.watch(screenTimeGoalProvider);
    final statsAsync = ref.watch(screenTimeStatsProvider);
    final historyAsync = ref.watch(screenTimeHistoryProvider);

    final todayRecord = recordAsync.valueOrNull;
    final dailyLimit = goalAsync.valueOrNull?.dailyLimitMinutes ?? 180;
    final totalMinutes = todayRecord?.totalMinutes ?? 0;
    final progress = dailyLimit > 0 ? totalMinutes / dailyLimit : 0.0;
    final isOverLimit = totalMinutes > dailyLimit;

    // Build stats from provider or use empty
    final stats = statsAsync.valueOrNull ?? ScreenTimeStats.empty();

    // Build history records for the history list
    final historyRecords = historyAsync.valueOrNull
        ?.map((s) => ScreenTimeRecord(
              id: '',
              date: s.date,
              totalMinutes: s.totalMinutes,
              pickups: s.pickups,
            ))
        .toList()
      ?..sort((a, b) => b.date.compareTo(a.date));

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
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(screenTimeRecordProvider);
                      ref.invalidate(screenTimeStatsProvider);
                      ref.invalidate(screenTimeGoalProvider);
                      ref.invalidate(screenTimeHistoryProvider);
                      _syncedDeviceData = false;
                      await _syncDeviceData();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          children: [
                            // Android permission prompt
                            if (Platform.isAndroid)
                              FutureBuilder<bool>(
                                future: _deviceService.hasPermission(),
                                builder: (context, snapshot) {
                                  if (snapshot.data == false) {
                                    return Column(
                                      children: [
                                        _buildPermissionBanner(padding),
                                        SizedBox(height: padding),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),

                            // iOS info banner
                            if (Platform.isIOS)
                              Column(
                                children: [
                                  _buildIOSInfoBanner(padding),
                                  SizedBox(height: padding),
                                ],
                              ),

                            // Loading state
                            if (recordAsync.isLoading && !recordAsync.hasValue)
                              const Padding(
                                padding: EdgeInsets.all(32),
                                child: CircularProgressIndicator(),
                              )
                            else ...[
                              AnimatedBuilder(
                                animation: _progressAnimationController,
                                builder: (context, child) {
                                  return ScreenTimeProgressCard(
                                    todayScreenTime: todayRecord,
                                    yesterdayScreenTime: null, // We use stats comparison instead
                                    dailyLimit: dailyLimit,
                                    progress: progress,
                                    animationPhase: _progressAnimationController.value,
                                    padding: padding,
                                  );
                                },
                              ),
                              SizedBox(height: padding),

                              // App usage breakdown
                              if (todayRecord != null && todayRecord.appUsage.isNotEmpty)
                                AppUsageChart(
                                  appUsage: todayRecord.appUsage,
                                  padding: padding,
                                  animation: _listAnimation,
                                ),
                              if (todayRecord != null && todayRecord.appUsage.isNotEmpty)
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

                              if (historyRecords != null && historyRecords.isNotEmpty)
                                ScreenTimeHistoryList(
                                  records: historyRecords,
                                  dailyLimit: dailyLimit,
                                  padding: padding,
                                  animation: _listAnimation,
                                ),
                              SizedBox(height: padding * 2),
                            ],
                          ],
                        ),
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

  Widget _buildPermissionBanner(double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.infoColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.infoColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Auto-Tracking',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Grant usage access to automatically track your screen time.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _showPermissionDialog,
            child: Text('Enable', style: TextStyle(color: AppTheme.infoColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildIOSInfoBanner(double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.phone_iphone, color: AppTheme.warningColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Automatic screen time tracking is not available on iOS. You can manually log your usage.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ),
        ],
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
