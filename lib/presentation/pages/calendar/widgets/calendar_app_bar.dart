import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Calendar view types
enum CalendarViewType {
  month,
  week,
  day,
  agenda;

  String get label {
    switch (this) {
      case CalendarViewType.month:
        return 'Month';
      case CalendarViewType.week:
        return 'Week';
      case CalendarViewType.day:
        return 'Day';
      case CalendarViewType.agenda:
        return 'Agenda';
    }
  }

  IconData get icon {
    switch (this) {
      case CalendarViewType.month:
        return Icons.calendar_view_month;
      case CalendarViewType.week:
        return Icons.calendar_view_week;
      case CalendarViewType.day:
        return Icons.calendar_view_day;
      case CalendarViewType.agenda:
        return Icons.view_agenda;
    }
  }
}

/// Custom app bar with view toggle
class CalendarAppBar extends StatelessWidget {
  final CalendarViewType currentView;
  final ValueChanged<CalendarViewType> onViewChanged;
  final VoidCallback onTodayPressed;
  final VoidCallback? onBackPressed;

  const CalendarAppBar({
    super.key,
    required this.currentView,
    required this.onViewChanged,
    required this.onTodayPressed,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top row: Back button, title, and today button
          Row(
            children: [
              IconButton(
                onPressed: onBackPressed ?? () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Calendar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _TodayButton(onPressed: onTodayPressed),
            ],
          ),
          const SizedBox(height: 16),
          // View toggle tabs
          _ViewToggle(
            currentView: currentView,
            onViewChanged: onViewChanged,
          ),
        ],
      ),
    );
  }
}

class _TodayButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _TodayButton({required this.onPressed});

  @override
  State<_TodayButton> createState() => _TodayButtonState();
}

class _TodayButtonState extends State<_TodayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Pulse animation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.repeat(reverse: false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Today',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final CalendarViewType currentView;
  final ValueChanged<CalendarViewType> onViewChanged;

  const _ViewToggle({
    required this.currentView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Row(
        children: CalendarViewType.values.map((view) {
          final isSelected = view == currentView;
          return Expanded(
            child: GestureDetector(
              onTap: () => onViewChanged(view),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      view.icon,
                      size: 16,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      view.label,
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
