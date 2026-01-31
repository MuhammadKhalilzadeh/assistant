import 'package:flutter/material.dart';
import 'package:assistant/data/mock/models/calendar_event_model.dart';
import 'package:assistant/data/mock/repositories/mock_repository.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

import 'widgets/calendar_app_bar.dart';
import 'widgets/calendar_header.dart';
import 'widgets/month_view.dart';
import 'widgets/week_view.dart';
import 'widgets/day_view.dart';
import 'widgets/agenda_view.dart';
import 'widgets/add_event_sheet.dart';
import 'widgets/event_category_chip.dart';

/// Advanced Calendar Page with multiple views and full event management
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin {
  final MockRepository _repository = MockRepository();

  // View state
  CalendarViewType _currentView = CalendarViewType.month;
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  // Filter state
  Set<EventCategory> _selectedCategories = Set.from(EventCategory.values);

  // Animation controller for view transitions
  late AnimationController _viewTransitionController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _viewTransitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _viewTransitionController,
        curve: Curves.easeOut,
      ),
    );
    _viewTransitionController.forward();
  }

  @override
  void dispose() {
    _viewTransitionController.dispose();
    super.dispose();
  }

  List<CalendarEventModel> get _filteredEvents {
    final allEvents = _repository.events;

    // If all categories selected, return all events
    if (_selectedCategories.length == EventCategory.values.length) {
      return allEvents.toList();
    }

    // Filter by selected categories
    return allEvents.where((event) {
      final category = EventCategory.fromHexColor(event.color);
      return _selectedCategories.contains(category);
    }).toList();
  }

  void _onViewChanged(CalendarViewType view) async {
    if (view == _currentView) return;

    await _viewTransitionController.reverse();
    setState(() => _currentView = view);
    await _viewTransitionController.forward();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _focusedMonth = DateTime(date.year, date.month);
    });
  }

  void _onMonthChanged(DateTime month) {
    setState(() => _focusedMonth = month);
  }

  void _onTodayPressed() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = now;
      _focusedMonth = DateTime(now.year, now.month);
    });
  }

  void _onEventTap(CalendarEventModel event) {
    AddEventSheet.show(
      context,
      event: event,
      onSave: (updatedEvent) {
        _repository.updateEvent(updatedEvent);
        setState(() {});
      },
      onDelete: () {
        _repository.deleteEvent(event.id);
        setState(() {});
      },
    );
  }

  void _onEventDelete(CalendarEventModel event) {
    _repository.deleteEvent(event.id);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${event.title}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _repository.addEvent(event);
            setState(() {});
          },
        ),
      ),
    );
  }

  void _onAddEvent({DateTime? date, TimeOfDay? time}) {
    AddEventSheet.show(
      context,
      initialDate: date ?? _selectedDate,
      initialTime: time,
      onSave: (event) {
        _repository.addEvent(event);
        setState(() {});
      },
    );
  }

  void _onTimeSlotTap(DateTime date, TimeOfDay time) {
    _onAddEvent(date: date, time: time);
  }

  void _onCategoryToggled(EventCategory category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        // Don't allow deselecting all categories
        if (_selectedCategories.length > 1) {
          _selectedCategories.remove(category);
        }
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _onClearCategoryFilters() {
    setState(() {
      _selectedCategories = Set.from(EventCategory.values);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: Column(
            children: [
              // App bar with view toggle
              CalendarAppBar(
                currentView: _currentView,
                onViewChanged: _onViewChanged,
                onTodayPressed: _onTodayPressed,
              ),

              // Month/week header (only for month and week views)
              if (_currentView == CalendarViewType.month ||
                  _currentView == CalendarViewType.week)
                CalendarHeader(
                  focusedMonth: _focusedMonth,
                  selectedDate: _selectedDate,
                  onMonthChanged: _onMonthChanged,
                  onDateSelected: _onDateSelected,
                ),

              // Category filter bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
                child: CategoryFilterBar(
                  selectedCategories: _selectedCategories,
                  onCategoryToggled: _onCategoryToggled,
                  onClearAll: _onClearCategoryFilters,
                ),
              ),

              // Calendar view content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildCurrentView(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddEvent(),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case CalendarViewType.month:
        return MonthView(
          selectedDate: _selectedDate,
          focusedMonth: _focusedMonth,
          events: _filteredEvents,
          onDateSelected: _onDateSelected,
          onMonthChanged: _onMonthChanged,
          onEventTap: _onEventTap,
          onEventDelete: _onEventDelete,
          onAddEvent: () => _onAddEvent(),
        );

      case CalendarViewType.week:
        return WeekView(
          selectedDate: _selectedDate,
          focusedWeek: _getWeekStart(_selectedDate),
          events: _filteredEvents,
          onDateSelected: _onDateSelected,
          onWeekChanged: (weekStart) {
            setState(() {
              _focusedMonth = DateTime(weekStart.year, weekStart.month);
            });
          },
          onEventTap: _onEventTap,
          onTimeSlotTap: _onTimeSlotTap,
        );

      case CalendarViewType.day:
        return DayView(
          selectedDate: _selectedDate,
          events: _filteredEvents,
          onDateSelected: _onDateSelected,
          onEventTap: _onEventTap,
          onEventDelete: _onEventDelete,
          onTimeSlotTap: _onTimeSlotTap,
          onAddEvent: () => _onAddEvent(),
        );

      case CalendarViewType.agenda:
        return AgendaView(
          selectedDate: _selectedDate,
          events: _filteredEvents,
          onDateSelected: _onDateSelected,
          onEventTap: _onEventTap,
          onEventDelete: _onEventDelete,
          onAddEvent: () => _onAddEvent(),
        );
    }
  }

  DateTime _getWeekStart(DateTime date) {
    // Get the start of the week (Sunday)
    final weekday = date.weekday == 7 ? 0 : date.weekday;
    return DateTime(date.year, date.month, date.day - weekday);
  }
}
