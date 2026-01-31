import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import '../focus_timer_page.dart';

/// Duration picker chips for selecting timer duration
class DurationSelector extends StatelessWidget {
  final TimerMode timerMode;
  final int selectedDuration;
  final ValueChanged<int> onDurationChanged;

  const DurationSelector({
    super.key,
    required this.timerMode,
    required this.selectedDuration,
    required this.onDurationChanged,
  });

  List<int> get _durations {
    switch (timerMode) {
      case TimerMode.focus:
        return [15, 25, 30, 45, 60];
      case TimerMode.shortBreak:
        return [5, 10, 15];
      case TimerMode.longBreak:
        return [15, 20, 30];
    }
  }

  String get _label {
    switch (timerMode) {
      case TimerMode.focus:
        return 'Focus Duration';
      case TimerMode.shortBreak:
        return 'Break Duration';
      case TimerMode.longBreak:
        return 'Break Duration';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                color: Colors.white.withValues(alpha: 0.8),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                _label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _durations.map((duration) {
                final isSelected = duration == selectedDuration;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _DurationChip(
                    duration: duration,
                    isSelected: isSelected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onDurationChanged(duration);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationChip extends StatefulWidget {
  final int duration;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.duration,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_DurationChip> createState() => _DurationChipState();
}

class _DurationChipState extends State<_DurationChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                '${widget.duration} min',
                style: TextStyle(
                  color: widget.isSelected
                      ? AppTheme.primaryColor
                      : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
