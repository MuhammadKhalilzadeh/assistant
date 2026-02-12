import 'package:flutter/material.dart';
import 'package:assistant/data/models/focus_session_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Individual session card for the history list
class SessionItem extends StatelessWidget {
  final FocusSessionModel session;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const SessionItem({
    super.key,
    required this.session,
    this.onDelete,
    this.onTap,
  });

  String get _formattedTime {
    final hour = session.startTime.hour;
    final minute = session.startTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String get _formattedDuration {
    if (session.durationMinutes >= 60) {
      final hours = session.durationMinutes ~/ 60;
      final mins = session.durationMinutes % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
    return '${session.durationMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(session.id),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.errorColor.withValues(alpha: 0.3),
        child: const Icon(
          Icons.delete_outline,
          color: AppTheme.errorColor,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Completion indicator
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: session.isCompleted
                      ? AppTheme.successColor.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  session.isCompleted
                      ? Icons.check_rounded
                      : Icons.timer_outlined,
                  color: session.isCompleted
                      ? AppTheme.successColor
                      : Colors.orange,
                  size: 18,
                ),
              ),

              const SizedBox(width: 12),

              // Task info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.task ?? 'Focus Session',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 12,
                          color: AppTheme.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formattedDuration,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppTheme.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formattedTime,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Points earned
              if (session.isCompleted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        color: Colors.amber,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+10',
                        style: TextStyle(
                          color: Colors.amber.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
