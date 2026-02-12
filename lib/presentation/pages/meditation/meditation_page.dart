import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/meditation_session_model.dart';
import 'package:assistant/providers/meditation_provider.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'widgets/meditation_app_bar.dart';
import 'widgets/meditation_progress_card.dart';
import 'widgets/session_type_selector.dart';
import 'widgets/session_duration_selector.dart';
import 'widgets/meditation_history_list.dart';
import 'widgets/meditation_stats_card.dart';
import 'widgets/meditation_tips_card.dart';
import 'widgets/goal_celebration.dart';

/// Main Meditation page with timer-based session tracking
class MeditationPage extends ConsumerStatefulWidget {
  const MeditationPage({super.key});

  @override
  ConsumerState<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends ConsumerState<MeditationPage> with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late AnimationController _breathingAnimationController;
  late Animation<double> _listAnimation;

  bool _showCelebration = false;

  // Timer state
  bool _isTimerActive = false;
  bool _isPaused = false;
  int _remainingSeconds = 5 * 60;
  int _selectedDuration = 5;
  Timer? _timer;
  MeditationType _selectedSessionType = MeditationType.breathing;
  DateTime? _sessionStartTime;

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

    _breathingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _breathingAnimationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _isTimerActive = true;
      _isPaused = false;
      _remainingSeconds = _selectedDuration * 60;
      _sessionStartTime = DateTime.now();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _completeSession();
          }
        });
      }
    });

    HapticFeedback.mediumImpact();
  }

  void _pauseSession() {
    setState(() {
      _isPaused = true;
    });
    HapticFeedback.lightImpact();
  }

  void _resumeSession() {
    setState(() {
      _isPaused = false;
    });
    HapticFeedback.lightImpact();
  }

  void _stopSession() async {
    _timer?.cancel();

    final elapsedSeconds = (_selectedDuration * 60) - _remainingSeconds;
    if (elapsedSeconds >= 60) {
      // Only save sessions >= 1 minute
      final durationMinutes = (elapsedSeconds / 60).ceil();

      await ref.read(meditationSessionsProvider.notifier).addSession(MeditationSessionModel(
        id: '',
        type: _selectedSessionType,
        startTime: _sessionStartTime ?? DateTime.now(),
        durationMinutes: durationMinutes,
        isCompleted: true,
      ));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.self_improvement, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Session saved: $durationMinutes min'),
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
      _isPaused = false;
      _remainingSeconds = _selectedDuration * 60;
      _sessionStartTime = null;
    });

    HapticFeedback.mediumImpact();
  }

  void _completeSession() async {
    _timer?.cancel();

    await ref.read(meditationSessionsProvider.notifier).addSession(MeditationSessionModel(
      id: '',
      type: _selectedSessionType,
      startTime: _sessionStartTime ?? DateTime.now(),
      durationMinutes: _selectedDuration,
      isCompleted: true,
    ));

    if (!mounted) return;
    setState(() {
      _isTimerActive = false;
      _isPaused = false;
      _remainingSeconds = _selectedDuration * 60;
      _sessionStartTime = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Session completed: $_selectedDuration min'),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );

    HapticFeedback.heavyImpact();
  }

  void _deleteSession(String id) async {
    try {
      await ref.read(meditationSessionsProvider.notifier).deleteSession(id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete session: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showGoalSettings() {
    final goalAsync = ref.read(meditationGoalProvider);
    final currentGoal = goalAsync.valueOrNull;
    if (currentGoal == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _GoalSettingsSheet(
        currentGoal: currentGoal.dailyMinutesGoal,
        onGoalChanged: (newGoal) async {
          try {
            await ref.read(meditationGoalProvider.notifier).updateGoal(
              currentGoal.copyWith(dailyMinutesGoal: newGoal),
            );
          } catch (e) { /* ignore */ }
          if (context.mounted) Navigator.pop(context);
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

    final sessionsAsync = ref.watch(meditationSessionsProvider);
    final statsAsync = ref.watch(meditationStatsProvider);
    final goalAsync = ref.watch(meditationGoalProvider);

    final sessions = (sessionsAsync.valueOrNull ?? []).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    final stats = statsAsync.valueOrNull ?? MeditationStats.empty();
    final goal = goalAsync.valueOrNull;
    final dailyGoal = goal?.dailyMinutesGoal ?? 10;
    final todayMinutes = stats.todayMinutes;
    final todaySessions = sessions.length;
    final progress = dailyGoal > 0 ? todayMinutes / dailyGoal : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                MeditationAppBar(
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
                            animation: _breathingAnimationController,
                            builder: (context, child) {
                              return MeditationProgressCard(
                                todayMinutes: todayMinutes,
                                todaySessions: todaySessions,
                                dailyGoal: dailyGoal,
                                progress: progress,
                                animationPhase: _breathingAnimationController.value,
                                padding: padding,
                                isTimerActive: _isTimerActive,
                                isPaused: _isPaused,
                                remainingSeconds: _remainingSeconds,
                                totalSeconds: _selectedDuration * 60,
                                activeSessionType: _isTimerActive ? _selectedSessionType : null,
                                onStartSession: _startSession,
                                onPauseSession: _pauseSession,
                                onResumeSession: _resumeSession,
                                onStopSession: _stopSession,
                              );
                            },
                          ),
                          SizedBox(height: padding),

                          if (!_isTimerActive) ...[
                            SessionTypeSelector(
                              selectedType: _selectedSessionType,
                              onTypeSelected: (type) {
                                setState(() {
                                  _selectedSessionType = type;
                                });
                              },
                              padding: padding,
                              animation: _listAnimation,
                            ),
                            SizedBox(height: padding),

                            SessionDurationSelector(
                              selectedDuration: _selectedDuration,
                              onDurationSelected: (duration) {
                                setState(() {
                                  _selectedDuration = duration;
                                  _remainingSeconds = duration * 60;
                                });
                              },
                              padding: padding,
                              animation: _listAnimation,
                            ),
                            SizedBox(height: padding),
                          ],

                          MeditationTipsCard(
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          MeditationStatsCard(
                            stats: stats,
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          if (!_isTimerActive)
                            MeditationHistoryList(
                              sessions: sessions,
                              onDelete: _deleteSession,
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
            'Daily Goal',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your daily meditation minutes goal',
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
                  if (_goal > 5) {
                    setState(() => _goal -= 5);
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
                  if (_goal < 60) {
                    setState(() => _goal += 5);
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
