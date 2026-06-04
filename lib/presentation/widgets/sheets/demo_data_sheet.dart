import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/data/services/demo_data_service.dart';
import 'package:assistant/providers/steps_provider.dart';
import 'package:assistant/providers/heart_rate_provider.dart';
import 'package:assistant/providers/sleep_provider.dart';
import 'package:assistant/providers/workout_provider.dart';
import 'package:assistant/providers/water_provider.dart';
import 'package:assistant/providers/calories_provider.dart';
import 'package:assistant/providers/mood_provider.dart';
import 'package:assistant/providers/meditation_provider.dart';
import 'package:assistant/providers/habit_provider.dart';
import 'package:assistant/providers/todo_provider.dart';
import 'package:assistant/providers/screen_time_provider.dart';
import 'package:assistant/providers/focus_timer_provider.dart';

class DemoDataSheet extends ConsumerStatefulWidget {
  const DemoDataSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      builder: (_) => const DemoDataSheet(),
    );
  }

  @override
  ConsumerState<DemoDataSheet> createState() => _DemoDataSheetState();
}

class _DemoDataSheetState extends ConsumerState<DemoDataSheet> {
  final _service = DemoDataService();
  bool _isLoading = false;
  String _statusText = '';
  double _progress = 0;

  Future<void> _createDemoData() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Starting...';
      _progress = 0;
    });

    try {
      final errors = await _service.createDemoData(
        onProgress: (module, current, total) {
          if (mounted) {
            setState(() {
              _statusText = 'Creating $module...';
              _progress = current / total;
            });
          }
        },
      );
      _invalidateProviders();
      if (mounted) {
        setState(() {
          _statusText = errors.isEmpty
              ? 'Demo data created!'
              : 'Done with errors in: ${errors.join(', ')}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusText = 'Error: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteDemoData() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Starting...';
      _progress = 0;
    });

    try {
      await _service.deleteDemoData(
        onProgress: (module, current, total) {
          if (mounted) {
            setState(() {
              _statusText = 'Deleting $module...';
              _progress = current / total;
            });
          }
        },
      );
      _invalidateProviders();
      if (mounted) {
        setState(() {
          _statusText = 'All data deleted!';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusText = 'Error: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _invalidateProviders() {
    // Steps
    ref.invalidate(stepRecordsProvider);
    ref.invalidate(stepsStatsProvider);
    ref.invalidate(stepsHistoryProvider);
    // Heart Rate
    ref.invalidate(heartRateRecordsProvider);
    ref.invalidate(heartRateStatsProvider);
    ref.invalidate(heartRateHistoryProvider);
    // Sleep
    ref.invalidate(sleepRecordsProvider);
    ref.invalidate(sleepStatsProvider);
    ref.invalidate(sleepHistoryProvider);
    // Workout
    ref.invalidate(workoutSessionsProvider);
    ref.invalidate(workoutStatsProvider);
    ref.invalidate(workoutHistoryProvider);
    // Water
    ref.invalidate(waterLogsProvider);
    ref.invalidate(waterStatsProvider);
    ref.invalidate(waterHistoryProvider);
    // Calories
    ref.invalidate(calorieEntriesProvider);
    ref.invalidate(nutritionStatsProvider);
    ref.invalidate(nutritionHistoryProvider);
    // Mood
    ref.invalidate(moodEntriesProvider);
    ref.invalidate(moodStatsProvider);
    ref.invalidate(moodHistoryProvider);
    // Meditation
    ref.invalidate(meditationSessionsProvider);
    ref.invalidate(meditationStatsProvider);
    ref.invalidate(meditationHistoryProvider);
    // Habits
    ref.invalidate(habitListProvider);
    ref.invalidate(habitStatsProvider);
    // Todos
    ref.invalidate(todoListProvider);
    ref.invalidate(todoStatsProvider);
    // Screen Time
    ref.invalidate(screenTimeRecordProvider);
    ref.invalidate(screenTimeStatsProvider);
    ref.invalidate(screenTimeHistoryProvider);
    // Focus Timer
    ref.invalidate(focusTimerSessionsProvider);
    ref.invalidate(focusTimerStatsProvider);
    ref.invalidate(focusTimerHistoryProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLG,
        vertical: AppTheme.spacingLG,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLG),

          // Title
          const Text(
            'Demo Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          const Text(
            'Generate 7 days of realistic sample data across all modules, or clear everything.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLG),

          // Progress indicator
          if (_isLoading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: AppTheme.cardColor,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSM),
          ],

          // Status text
          if (_statusText.isNotEmpty) ...[
            Text(
              _statusText,
              style: TextStyle(
                fontSize: 13,
                color: _statusText.startsWith('Error')
                    ? AppTheme.errorColor
                    : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMD),
          ],

          // Create Demo Data button
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _isLoading ? null : _createDemoData,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingMD,
                ),
                decoration: BoxDecoration(
                  gradient: _isLoading ? null : AppTheme.primaryGradient,
                  color: _isLoading ? AppTheme.cardColor : null,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Create Demo Data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _isLoading
                          ? AppTheme.textTertiary
                          : AppTheme.textOnPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingSM),

          // Delete All Data button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _isLoading ? null : _deleteDemoData,
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.cardColor,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingMD,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium,
                  ),
                ),
              ),
              child: Text(
                'Delete All Data',
                style: TextStyle(
                  color: _isLoading
                      ? AppTheme.textTertiary
                      : AppTheme.errorColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMD),
        ],
      ),
    );
  }
}
