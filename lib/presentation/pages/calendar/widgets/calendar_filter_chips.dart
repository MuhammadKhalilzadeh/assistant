import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/calendar_event.dart';
import 'package:assistant/providers/calendar_provider.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Calendar account filter chips — consistent 36px height
class CalendarFilterChips extends ConsumerWidget {
  final List<DeviceCalendar> calendars;

  const CalendarFilterChips({
    super.key,
    required this.calendars,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(selectedCalendarIdsProvider);
    final allSelected = selectedIds.isEmpty;

    return SizedBox(
      height: 36,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            // "All" chip
            GestureDetector(
              onTap: () {
                ref.read(selectedCalendarIdsProvider.notifier).state = {};
                ref.invalidate(calendarEventsProvider);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: allSelected
                      ? AppTheme.primaryColor
                      : AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                  border: Border.all(
                    color: allSelected
                        ? AppTheme.primaryColor
                        : AppTheme.primaryColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'All',
                  style: TextStyle(
                    color: allSelected ? Colors.white : AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Individual calendar chips
            ...calendars.map((calendar) {
              final calColor = Color(calendar.color);
              final isSelected = allSelected || selectedIds.contains(calendar.id);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    final current = ref.read(selectedCalendarIdsProvider);
                    Set<String> newIds;

                    if (current.isEmpty) {
                      newIds = {calendar.id};
                    } else if (current.contains(calendar.id)) {
                      newIds = {...current}..remove(calendar.id);
                      if (newIds.isEmpty) {
                        newIds = {};
                      }
                    } else {
                      newIds = {...current, calendar.id};
                      if (newIds.length == calendars.length) {
                        newIds = {};
                      }
                    }

                    ref.read(selectedCalendarIdsProvider.notifier).state = newIds;
                    ref.invalidate(calendarEventsProvider);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? calColor
                          : calColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                      border: Border.all(
                        color: isSelected
                            ? calColor
                            : calColor.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: calColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : calColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          calendar.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
