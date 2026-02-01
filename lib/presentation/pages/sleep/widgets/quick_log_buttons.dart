import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Quick log buttons for common bedtimes with preset wake times
class QuickLogButtons extends StatelessWidget {
  final Function(TimeOfDay bedTime, TimeOfDay wakeTime) onQuickLog;
  final double padding;
  final Animation<double>? animation;

  const QuickLogButtons({
    super.key,
    required this.onQuickLog,
    required this.padding,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    // Common bedtime presets with assumed 7-8 hour sleep
    final presets = [
      (
        bedTime: const TimeOfDay(hour: 22, minute: 0),
        wakeTime: const TimeOfDay(hour: 6, minute: 0),
        label: '10 PM',
        description: '8h sleep',
      ),
      (
        bedTime: const TimeOfDay(hour: 23, minute: 0),
        wakeTime: const TimeOfDay(hour: 7, minute: 0),
        label: '11 PM',
        description: '8h sleep',
      ),
      (
        bedTime: const TimeOfDay(hour: 0, minute: 0),
        wakeTime: const TimeOfDay(hour: 7, minute: 30),
        label: '12 AM',
        description: '7.5h sleep',
      ),
      (
        bedTime: const TimeOfDay(hour: 1, minute: 0),
        wakeTime: const TimeOfDay(hour: 8, minute: 0),
        label: '1 AM',
        description: '7h sleep',
      ),
    ];

    Widget content = Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Log',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Last night',
                style: TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: presets.map((preset) {
              return _QuickLogButton(
                label: preset.label,
                description: preset.description,
                onTap: () => onQuickLog(preset.bedTime, preset.wakeTime),
              );
            }).toList(),
          ),
        ],
      ),
    );

    if (animation != null) {
      return FadeTransition(
        opacity: animation!,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation!,
            curve: Curves.easeOutCubic,
          )),
          child: content,
        ),
      );
    }

    return content;
  }
}

class _QuickLogButton extends StatefulWidget {
  final String label;
  final String description;
  final VoidCallback onTap;

  const _QuickLogButton({
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  State<_QuickLogButton> createState() => _QuickLogButtonState();
}

class _QuickLogButtonState extends State<_QuickLogButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
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
        HapticFeedback.lightImpact();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bedtime,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.description,
                style: TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
