import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import '../focus_timer_page.dart';

/// Timer settings bottom sheet
class SettingsSheet extends StatefulWidget {
  final TimerSettings settings;
  final ValueChanged<TimerSettings> onSettingsChanged;

  const SettingsSheet({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  /// Show the settings sheet
  static Future<void> show({
    required BuildContext context,
    required TimerSettings settings,
    required ValueChanged<TimerSettings> onSettingsChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SettingsSheet(
        settings: settings,
        onSettingsChanged: onSettingsChanged,
      ),
    );
  }

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late TimerSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  void _updateSettings(TimerSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
    widget.onSettingsChanged(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Timer Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Settings content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Duration settings
                    _SectionHeader(title: 'Durations'),
                    const SizedBox(height: 12),

                    _DurationSlider(
                      label: 'Focus Duration',
                      value: _settings.focusDuration,
                      min: 5,
                      max: 90,
                      step: 5,
                      unit: 'min',
                      icon: Icons.psychology_outlined,
                      onChanged: (value) {
                        _updateSettings(
                            _settings.copyWith(focusDuration: value));
                      },
                    ),

                    _DurationSlider(
                      label: 'Short Break',
                      value: _settings.shortBreakDuration,
                      min: 1,
                      max: 15,
                      step: 1,
                      unit: 'min',
                      icon: Icons.coffee_outlined,
                      onChanged: (value) {
                        _updateSettings(
                            _settings.copyWith(shortBreakDuration: value));
                      },
                    ),

                    _DurationSlider(
                      label: 'Long Break',
                      value: _settings.longBreakDuration,
                      min: 10,
                      max: 45,
                      step: 5,
                      unit: 'min',
                      icon: Icons.weekend_outlined,
                      onChanged: (value) {
                        _updateSettings(
                            _settings.copyWith(longBreakDuration: value));
                      },
                    ),

                    const SizedBox(height: 24),

                    // Pomodoro settings
                    _SectionHeader(title: 'Pomodoro'),
                    const SizedBox(height: 12),

                    _DurationSlider(
                      label: 'Sessions before long break',
                      value: _settings.sessionsBeforeLongBreak,
                      min: 2,
                      max: 6,
                      step: 1,
                      unit: '',
                      icon: Icons.repeat_rounded,
                      onChanged: (value) {
                        _updateSettings(
                            _settings.copyWith(sessionsBeforeLongBreak: value));
                      },
                    ),

                    _DurationSlider(
                      label: 'Daily Goal',
                      value: _settings.dailyGoalSessions,
                      min: 4,
                      max: 16,
                      step: 1,
                      unit: 'sessions',
                      icon: Icons.flag_outlined,
                      onChanged: (value) {
                        _updateSettings(
                            _settings.copyWith(dailyGoalSessions: value));
                      },
                    ),

                    const SizedBox(height: 24),

                    // Auto-start settings
                    _SectionHeader(title: 'Auto-start'),
                    const SizedBox(height: 12),

                    _ToggleSetting(
                      label: 'Auto-start breaks',
                      description:
                          'Automatically start break after focus session',
                      value: _settings.autoStartBreaks,
                      icon: Icons.play_circle_outline,
                      onChanged: (value) {
                        _updateSettings(
                            _settings.copyWith(autoStartBreaks: value));
                      },
                    ),

                    _ToggleSetting(
                      label: 'Auto-start focus',
                      description:
                          'Automatically start focus after break ends',
                      value: _settings.autoStartFocus,
                      icon: Icons.replay_rounded,
                      onChanged: (value) {
                        _updateSettings(
                            _settings.copyWith(autoStartFocus: value));
                      },
                    ),

                    const SizedBox(height: 24),

                    // Notifications settings
                    _SectionHeader(title: 'Notifications'),
                    const SizedBox(height: 12),

                    _ToggleSetting(
                      label: 'Sound',
                      description: 'Play sound when timer completes',
                      value: _settings.soundEnabled,
                      icon: Icons.volume_up_outlined,
                      onChanged: (value) {
                        _updateSettings(
                            _settings.copyWith(soundEnabled: value));
                      },
                    ),

                    _ToggleSetting(
                      label: 'Vibration',
                      description: 'Vibrate when timer completes',
                      value: _settings.vibrationEnabled,
                      icon: Icons.vibration,
                      onChanged: (value) {
                        _updateSettings(
                            _settings.copyWith(vibrationEnabled: value));
                      },
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.6),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }
}

class _DurationSlider extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final String unit;
  final IconData icon;
  final ValueChanged<int> onChanged;

  const _DurationSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.unit,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white.withValues(alpha: 0.7),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  unit.isNotEmpty ? '$value $unit' : '$value',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: (max - min) ~/ step,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                onChanged(val.round());
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleSetting extends StatelessWidget {
  final String label;
  final String description;
  final bool value;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  const _ToggleSetting({
    required this.label,
    required this.description,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              onChanged(val);
            },
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF10B981),
            inactiveThumbColor: Colors.white.withValues(alpha: 0.8),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
