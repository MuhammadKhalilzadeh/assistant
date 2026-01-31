import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../focus_timer_page.dart';

/// Segmented control for switching between Focus/Short Break/Long Break
class TimerModeToggle extends StatelessWidget {
  final TimerMode currentMode;
  final TimerMode? suggestedMode;
  final ValueChanged<TimerMode> onModeChanged;
  final bool isEnabled;

  const TimerModeToggle({
    super.key,
    required this.currentMode,
    this.suggestedMode,
    required this.onModeChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: TimerMode.values.map((mode) {
          final isSelected = mode == currentMode;
          final isSuggested = mode == suggestedMode && !isSelected;

          return Expanded(
            child: _ModeButton(
              mode: mode,
              isSelected: isSelected,
              isSuggested: isSuggested,
              isEnabled: isEnabled,
              onTap: () {
                if (isEnabled && !isSelected) {
                  HapticFeedback.selectionClick();
                  onModeChanged(mode);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ModeButton extends StatefulWidget {
  final TimerMode mode;
  final bool isSelected;
  final bool isSuggested;
  final bool isEnabled;
  final VoidCallback onTap;

  const _ModeButton({
    required this.mode,
    required this.isSelected,
    required this.isSuggested,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  State<_ModeButton> createState() => _ModeButtonState();
}

class _ModeButtonState extends State<_ModeButton>
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

  String get _label {
    switch (widget.mode) {
      case TimerMode.focus:
        return 'Focus';
      case TimerMode.shortBreak:
        return 'Short';
      case TimerMode.longBreak:
        return 'Long';
    }
  }

  IconData get _icon {
    switch (widget.mode) {
      case TimerMode.focus:
        return Icons.psychology_outlined;
      case TimerMode.shortBreak:
        return Icons.coffee_outlined;
      case TimerMode.longBreak:
        return Icons.weekend_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isEnabled && !widget.isSelected
          ? (_) => _controller.forward()
          : null,
      onTapUp: widget.isEnabled && !widget.isSelected
          ? (_) {
              _controller.reverse();
              widget.onTap();
            }
          : null,
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? Colors.white
                    : widget.isSuggested
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: widget.isSuggested
                    ? Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1.5,
                      )
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _icon,
                    size: 16,
                    color: widget.isSelected
                        ? const Color(0xFF6366F1)
                        : Colors.white.withValues(
                            alpha: widget.isEnabled ? 0.9 : 0.5,
                          ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _label,
                      style: TextStyle(
                        color: widget.isSelected
                            ? const Color(0xFF6366F1)
                            : Colors.white.withValues(
                                alpha: widget.isEnabled ? 0.9 : 0.5,
                              ),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.isSuggested) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
