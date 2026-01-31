import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import '../focus_timer_page.dart';

/// Control buttons for the timer: Play/Pause, Reset, Skip
class TimerControls extends StatefulWidget {
  final TimerState timerState;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;
  final VoidCallback onSkip;

  const TimerControls({
    super.key,
    required this.timerState,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onReset,
    required this.onSkip,
  });

  @override
  State<TimerControls> createState() => _TimerControlsState();
}

class _TimerControlsState extends State<TimerControls>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onPrimaryTap() {
    HapticFeedback.mediumImpact();
    switch (widget.timerState) {
      case TimerState.idle:
      case TimerState.completed:
        widget.onStart();
        break;
      case TimerState.running:
        widget.onPause();
        break;
      case TimerState.paused:
        widget.onResume();
        break;
    }
  }

  IconData get _primaryIcon {
    switch (widget.timerState) {
      case TimerState.idle:
      case TimerState.completed:
        return Icons.play_arrow_rounded;
      case TimerState.running:
        return Icons.pause_rounded;
      case TimerState.paused:
        return Icons.play_arrow_rounded;
    }
  }

  String get _primaryLabel {
    switch (widget.timerState) {
      case TimerState.idle:
      case TimerState.completed:
        return 'Start';
      case TimerState.running:
        return 'Pause';
      case TimerState.paused:
        return 'Resume';
    }
  }

  bool get _showSecondaryControls =>
      widget.timerState == TimerState.running ||
      widget.timerState == TimerState.paused;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset button (left)
        AnimatedOpacity(
          opacity: _showSecondaryControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedScale(
            scale: _showSecondaryControls ? 1.0 : 0.8,
            duration: const Duration(milliseconds: 200),
            child: _SecondaryButton(
              icon: Icons.refresh_rounded,
              label: 'Reset',
              onTap: _showSecondaryControls ? widget.onReset : null,
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Primary play/pause button
        GestureDetector(
          onTapDown: (_) => _scaleController.forward(),
          onTapUp: (_) {
            _scaleController.reverse();
            _onPrimaryTap();
          },
          onTapCancel: () => _scaleController.reverse(),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          _primaryIcon,
                          key: ValueKey(_primaryIcon),
                          color: AppTheme.primaryColor,
                          size: 40,
                        ),
                      ),
                      Text(
                        _primaryLabel,
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 24),

        // Skip button (right)
        AnimatedOpacity(
          opacity: _showSecondaryControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedScale(
            scale: _showSecondaryControls ? 1.0 : 0.8,
            duration: const Duration(milliseconds: 200),
            child: _SecondaryButton(
              icon: Icons.skip_next_rounded,
              label: 'Skip',
              onTap: _showSecondaryControls ? widget.onSkip : null,
            ),
          ),
        ),
      ],
    );
  }
}

/// Secondary control button (Reset, Skip)
class _SecondaryButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  State<_SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<_SecondaryButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
      onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _controller.reverse();
              HapticFeedback.lightImpact();
              widget.onTap!();
            }
          : null,
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
