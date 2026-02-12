import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/focus_session_model.dart';
import 'package:assistant/providers/focus_timer_provider.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'widgets/timer_app_bar.dart';
import 'widgets/timer_display.dart';
import 'widgets/timer_controls.dart';
import 'widgets/duration_selector.dart';
import 'widgets/timer_mode_toggle.dart';
import 'widgets/session_task_input.dart';
import 'widgets/stats_card.dart';
import 'widgets/daily_progress.dart';
import 'widgets/session_history.dart';
import 'widgets/streak_display.dart';
import 'widgets/settings_sheet.dart';

/// Timer modes for the Pomodoro technique
enum TimerMode {
  focus,
  shortBreak,
  longBreak,
}

/// Timer states for the state machine
enum TimerState {
  idle,
  running,
  paused,
  completed,
}

/// Settings model for timer configuration
class TimerSettings {
  final int focusDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final int sessionsBeforeLongBreak;
  final bool autoStartBreaks;
  final bool autoStartFocus;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final int dailyGoalSessions;

  const TimerSettings({
    this.focusDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.sessionsBeforeLongBreak = 4,
    this.autoStartBreaks = false,
    this.autoStartFocus = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.dailyGoalSessions = 8,
  });

  TimerSettings copyWith({
    int? focusDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? sessionsBeforeLongBreak,
    bool? autoStartBreaks,
    bool? autoStartFocus,
    bool? soundEnabled,
    bool? vibrationEnabled,
    int? dailyGoalSessions,
  }) {
    return TimerSettings(
      focusDuration: focusDuration ?? this.focusDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      sessionsBeforeLongBreak: sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartFocus: autoStartFocus ?? this.autoStartFocus,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      dailyGoalSessions: dailyGoalSessions ?? this.dailyGoalSessions,
    );
  }
}

class FocusTimerPage extends ConsumerStatefulWidget {
  const FocusTimerPage({super.key});

  @override
  ConsumerState<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends ConsumerState<FocusTimerPage>
    with TickerProviderStateMixin {
  // Timer state
  Timer? _timer;
  TimerMode _timerMode = TimerMode.focus;
  TimerState _timerState = TimerState.idle;
  int _remainingSeconds = 25 * 60;
  int _totalSeconds = 25 * 60;

  // Session state
  String _currentTask = '';
  DateTime? _sessionStartTime;

  // Settings
  TimerSettings _settings = const TimerSettings();
  bool _settingsLoaded = false;

  // Suggested mode after completion
  TimerMode? _suggestedMode;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _completionController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _completionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Load settings from goal provider on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettingsFromGoal();
    });
  }

  void _loadSettingsFromGoal() {
    final goalAsync = ref.read(focusTimerGoalProvider);
    goalAsync.whenData((goal) {
      if (!_settingsLoaded) {
        setState(() {
          _settings = TimerSettings(
            focusDuration: goal.focusDuration,
            shortBreakDuration: goal.shortBreakDuration,
            longBreakDuration: goal.longBreakDuration,
            sessionsBeforeLongBreak: goal.sessionsBeforeLongBreak,
            autoStartBreaks: goal.autoStartBreaks,
            autoStartFocus: goal.autoStartFocus,
            soundEnabled: goal.soundEnabled,
            vibrationEnabled: goal.vibrationEnabled,
            dailyGoalSessions: goal.dailyGoalSessions,
          );
          _settingsLoaded = true;
          if (_timerState == TimerState.idle) {
            _totalSeconds = _getDurationForMode(_timerMode) * 60;
            _remainingSeconds = _totalSeconds;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  int _getDurationForMode(TimerMode mode) {
    switch (mode) {
      case TimerMode.focus:
        return _settings.focusDuration;
      case TimerMode.shortBreak:
        return _settings.shortBreakDuration;
      case TimerMode.longBreak:
        return _settings.longBreakDuration;
    }
  }

  void _setMode(TimerMode mode) {
    if (_timerState == TimerState.running) return;

    setState(() {
      _timerMode = mode;
      _totalSeconds = _getDurationForMode(mode) * 60;
      _remainingSeconds = _totalSeconds;
      _timerState = TimerState.idle;
      _suggestedMode = null;
    });
  }

  void _setDuration(int minutes) {
    if (_timerState == TimerState.running) return;

    setState(() {
      _totalSeconds = minutes * 60;
      _remainingSeconds = _totalSeconds;

      // Update settings based on current mode
      switch (_timerMode) {
        case TimerMode.focus:
          _settings = _settings.copyWith(focusDuration: minutes);
          break;
        case TimerMode.shortBreak:
          _settings = _settings.copyWith(shortBreakDuration: minutes);
          break;
        case TimerMode.longBreak:
          _settings = _settings.copyWith(longBreakDuration: minutes);
          break;
      }
    });
  }

  void _startTimer() {
    if (_timerMode == TimerMode.focus) {
      _sessionStartTime = DateTime.now();
    }

    setState(() {
      _timerState = TimerState.running;
      _suggestedMode = null;
    });

    _pulseController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeTimer();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _pulseController.stop();

    setState(() {
      _timerState = TimerState.paused;
    });
  }

  void _resumeTimer() {
    setState(() {
      _timerState = TimerState.running;
    });

    _pulseController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeTimer();
        }
      });
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    setState(() {
      _timerState = TimerState.idle;
      _remainingSeconds = _totalSeconds;
      _sessionStartTime = null;
      _suggestedMode = null;
    });
  }

  void _skipTimer() {
    _completeTimer();
  }

  void _completeTimer() {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    _completionController.forward(from: 0);

    // Get current sessions count from stats before persisting
    final stats = ref.read(focusTimerStatsProvider).valueOrNull ?? FocusTimerStats.empty();
    final sessionsCompleted = stats.todaySessions;

    if (_timerMode == TimerMode.focus && _sessionStartTime != null) {
      // Map TimerMode to FocusSessionType
      final sessionType = FocusSessionType.focus;
      final now = DateTime.now();

      final session = FocusSessionModel(
        id: '', // Backend will generate
        type: sessionType,
        startTime: _sessionStartTime!,
        endTime: now,
        durationMinutes: _totalSeconds ~/ 60,
        isCompleted: true,
        task: _currentTask.isNotEmpty ? _currentTask : null,
      );

      // Persist to backend
      ref.read(focusTimerSessionsProvider.notifier).addSession(session);
    }

    // Haptic feedback
    if (_settings.vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }

    // Determine suggested mode (use current sessionsCompleted + 1 for the just-completed session)
    TimerMode nextMode;
    if (_timerMode == TimerMode.focus) {
      if ((sessionsCompleted + 1) % _settings.sessionsBeforeLongBreak == 0) {
        nextMode = TimerMode.longBreak;
      } else {
        nextMode = TimerMode.shortBreak;
      }
    } else {
      nextMode = TimerMode.focus;
    }

    setState(() {
      _timerState = TimerState.completed;
      _sessionStartTime = null;
      _suggestedMode = nextMode;
    });

    // Show completion message
    _showCompletionMessage();

    // Auto-start next mode if enabled
    if ((_timerMode == TimerMode.focus && _settings.autoStartBreaks) ||
        (_timerMode != TimerMode.focus && _settings.autoStartFocus)) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _timerState == TimerState.completed) {
          _setMode(nextMode);
          _startTimer();
        }
      });
    }
  }

  void _showCompletionMessage() {
    String message;
    if (_timerMode == TimerMode.focus) {
      message = 'Great work! Focus session completed.';
    } else if (_timerMode == TimerMode.shortBreak) {
      message = 'Break over! Ready to focus again?';
    } else {
      message = 'Long break complete! You earned it.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _timerMode == TimerMode.focus
            ? AppTheme.successColor
            : AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        margin: const EdgeInsets.all(AppTheme.spacingMD),
      ),
    );
  }

  void _setTask(String task) {
    setState(() {
      _currentTask = task;
    });
  }

  void _openSettings() {
    SettingsSheet.show(
      context: context,
      settings: _settings,
      onSettingsChanged: (newSettings) {
        setState(() {
          _settings = newSettings;
          if (_timerState == TimerState.idle) {
            _totalSeconds = _getDurationForMode(_timerMode) * 60;
            _remainingSeconds = _totalSeconds;
          }
        });

        // Persist settings to backend
        final goalAsync = ref.read(focusTimerGoalProvider);
        goalAsync.whenData((currentGoal) {
          final updatedGoal = currentGoal.copyWith(
            dailyGoalSessions: newSettings.dailyGoalSessions,
            focusDuration: newSettings.focusDuration,
            shortBreakDuration: newSettings.shortBreakDuration,
            longBreakDuration: newSettings.longBreakDuration,
            sessionsBeforeLongBreak: newSettings.sessionsBeforeLongBreak,
            autoStartBreaks: newSettings.autoStartBreaks,
            autoStartFocus: newSettings.autoStartFocus,
            soundEnabled: newSettings.soundEnabled,
            vibrationEnabled: newSettings.vibrationEnabled,
          );
          ref.read(focusTimerGoalProvider.notifier).updateGoal(updatedGoal);
        });
      },
    );
  }

  void _deleteSession(String id) {
    ref.read(focusTimerSessionsProvider.notifier).deleteSession(id);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);

    // Watch providers for real data
    final stats = ref.watch(focusTimerStatsProvider).valueOrNull ?? FocusTimerStats.empty();
    final sessions = ref.watch(focusTimerSessionsProvider).valueOrNull ?? [];

    // Load settings from goal when it becomes available
    final goalAsync = ref.watch(focusTimerGoalProvider);
    goalAsync.whenData((goal) {
      if (!_settingsLoaded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadSettingsFromGoal();
        });
      }
    });

    final sessionsCompleted = stats.todaySessions;
    final currentStreak = stats.currentStreak;
    final bestStreak = stats.bestStreak;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            TimerAppBar(
              onSettingsTap: _openSettings,
              streak: currentStreak,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Streak display
                      StreakDisplay(
                        currentStreak: currentStreak,
                        bestStreak: bestStreak,
                      ),

                      const SizedBox(height: 16),

                      // Timer mode toggle
                      TimerModeToggle(
                        currentMode: _timerMode,
                        suggestedMode: _suggestedMode,
                        onModeChanged: _setMode,
                        isEnabled: _timerState != TimerState.running,
                      ),

                      const SizedBox(height: 24),

                      // Task input (only show when idle and in focus mode)
                      if (_timerState == TimerState.idle && _timerMode == TimerMode.focus)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SessionTaskInput(
                            currentTask: _currentTask,
                            onTaskChanged: _setTask,
                          ),
                        ),

                      // Timer display
                      TimerDisplay(
                        remainingSeconds: _remainingSeconds,
                        totalSeconds: _totalSeconds,
                        timerMode: _timerMode,
                        timerState: _timerState,
                        pulseAnimation: _pulseController,
                        completionAnimation: _completionController,
                      ),

                      const SizedBox(height: 24),

                      // Duration selector (only show when idle)
                      if (_timerState == TimerState.idle)
                        DurationSelector(
                          timerMode: _timerMode,
                          selectedDuration: _totalSeconds ~/ 60,
                          onDurationChanged: _setDuration,
                        ),

                      const SizedBox(height: 24),

                      // Timer controls
                      TimerControls(
                        timerState: _timerState,
                        onStart: _startTimer,
                        onPause: _pauseTimer,
                        onResume: _resumeTimer,
                        onReset: _resetTimer,
                        onSkip: _skipTimer,
                      ),

                      const SizedBox(height: 32),

                      // Daily progress
                      DailyProgress(
                        completedSessions: sessionsCompleted,
                        goalSessions: _settings.dailyGoalSessions,
                        timerMode: _timerMode,
                      ),

                      const SizedBox(height: 16),

                      // Stats card
                      StatsCard(
                        sessionsToday: sessionsCompleted,
                        timerMode: _timerMode,
                      ),

                      const SizedBox(height: 16),

                      // Session history
                      SessionHistory(
                        sessions: sessions,
                        onSessionDelete: _deleteSession,
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
