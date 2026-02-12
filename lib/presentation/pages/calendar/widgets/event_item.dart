import 'package:flutter/material.dart';
import 'package:assistant/data/models/calendar_event.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Event card component with calendar-color left border
///
/// Two variants:
/// - Compact (`isCompact: true`): Single row — 3px left border + time + title. ~40px height.
/// - Full (`isCompact: false`): White card with IntrinsicHeight color border + time/title/location. Dismissible.
class EventItem extends StatelessWidget {
  final CalendarEvent event;
  final bool isCompact;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const EventItem({
    super.key,
    required this.event,
    this.isCompact = false,
    this.onTap,
    this.onDelete,
  });

  Color get eventColor {
    if (event.calendarColor != null) {
      return Color(event.calendarColor!);
    }
    return AppTheme.primaryColor;
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactVariant();
    }
    return _buildFullVariant();
  }

  Widget _buildCompactVariant() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: eventColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          border: Border(
            left: BorderSide(color: eventColor, width: 3),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 58,
              child: Text(
                event.isAllDay ? 'All day' : _formatTime(event.startTime),
                style: TextStyle(
                  color: event.isAllDay ? eventColor : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                event.title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (event.location != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppTheme.textTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullVariant() {
    final content = GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: AppTheme.cardShadow,
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: eventColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.borderRadiusLarge),
                    bottomLeft: Radius.circular(AppTheme.borderRadiusLarge),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      if (!event.isAllDay) ...[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatTime(event.startTime),
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatTime(event.endTime),
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: eventColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                          ),
                          child: Text(
                            'All Day',
                            style: TextStyle(
                              color: eventColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (event.calendarName != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                event.calendarName!,
                                style: TextStyle(
                                  color: eventColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (event.location != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: AppTheme.primaryColor.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      event.location!,
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (onDelete == null) return content;

    return Dismissible(
      key: Key('${event.calendarId}_${event.eventId ?? event.title}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: AppTheme.errorColor,
        ),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: content,
    );
  }
}
