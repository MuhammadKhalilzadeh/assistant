import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assistant/data/mock/models/focus_session_model.dart';
import 'package:assistant/data/mock/repositories/mock_repository.dart';
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

class FocusTimerPage extends StatefulWidget {
  const FocusTimerPage({super.key});

  @override
  State<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage>
    with TickerProviderStateMixin {
  final MockRepository _repository = MockRepository();

  // Timer state
  Timer? _timer;
  TimerMode _timerMode = TimerMode.focus;
  TimerState _timerState = TimerState.idle;
  int _remainingSeconds = 25 * 60;
  int _totalSeconds = 25 * 60;

  // Session state
  String? _currentSessionId;
  String _currentTask = '';
  int _sessionsCompleted = 0;
  int _focusStreak = 0;

  // Settings
  TimerSettings _settings = const TimerSettings();

  // Suggested mode after completion
  TimerMode? _suggestedMode;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _completionController;

  @override
  void initState() {
    super.initState();
    _initializeSessionCount();
    _calculateStreak();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _completionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _initializeSessionCount() {
    _sessionsCompleted = _repository.todayCompletedSessions;
  }

  void _calculateStreak() {
    // Calculate streak based on consecutive days with completed sessions
    final sessions = _repository.focusSessions;
    if (sessions.isEmpty) {
      _focusStreak = 0;
      return;
    }

    final completedSessions = sessions.where((s) => s.isCompleted).toList();
    if (completedSessions.isEmpty) {
      _focusStreak = 0;
      return;
    }

    completedSessions.sort((a, b) => b.startTime.compareTo(a.startTime));

    int streak = 0;
    DateTime? lastDate;

    for (final session in completedSessions) {
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      if (lastDate == null) {
        streak = 1;
        lastDate = sessionDate;
      } else {
        final diff = lastDate.difference(sessionDate).inDays;
        if (diff == 0) {
          continue; // Same day
        } else if (diff == 1) {
          streak++;
          lastDate = sessionDate;
        } else {
          break;
        }
      }
    }

    _focusStreak = streak;
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
      _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _repository.addFocusSession(FocusSessionModel(
        id: _currentSessionId!,
        startTime: DateTime.now(),
        durationMinutes: _totalSeconds ~/ 60,
        task: _currentTask.isNotEmpty ? _currentTask : null,
      ));
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
      _currentSessionId = null;
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

    if (_timerMode == TimerMode.focus && _currentSessionId != null) {
      _repository.completeFocusSession(_currentSessionId!);
      _sessionsCompleted++;
      _calculateStreak();
    }

    // Haptic feedback
    if (_settings.vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }

    // Determine suggested mode
    TimerMode nextMode;
    if (_timerMode == TimerMode.focus) {
      if (_sessionsCompleted % _settings.sessionsBeforeLongBreak == 0) {
        nextMode = TimerMode.longBreak;
      } else {
        nextMode = TimerMode.shortBreak;
      }
    } else {
      nextMode = TimerMode.focus;
    }

    setState(() {
      _timerState = TimerState.completed;
      _currentSessionId = null;
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
      },
    );
  }

  void _deleteSession(String id) {
    // Note: Repository doesn't have delete for focus sessions yet
    // This would be implemented when that API is added
    setState(() {});
  }

  LinearGradient _getGradientForMode() {
    switch (_timerMode) {
      case TimerMode.focus:
        return AppTheme.primaryGradient;
      case TimerMode.shortBreak:
        return AppTheme.secondaryGradient;
      case TimerMode.longBreak:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEC4899), // Pink
            Color(0xFF8B5CF6), // Purple
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _getGradientForMode(),
        ),
        child: SafeArea(
          child: Column(
            children: [
              TimerAppBar(
                onSettingsTap: _openSettings,
                streak: _focusStreak,
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
                          currentStreak: _focusStreak,
                          bestStreak: _focusStreak + 3, // Mock best streak
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
                          completedSessions: _sessionsCompleted,
                          goalSessions: _settings.dailyGoalSessions,
                          timerMode: _timerMode,
                        ),

                        const SizedBox(height: 16),

                        // Stats card
                        StatsCard(
                          sessionsToday: _sessionsCompleted,
                          timerMode: _timerMode,
                        ),

                        const SizedBox(height: 16),

                        // Session history
                        SessionHistory(
                          sessions: _repository.focusSessions,
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
      ),
    );
  }
}
