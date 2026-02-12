import 'package:flutter/material.dart';
import 'package:assistant/data/models/calendar_event.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Bottom sheet for adding/editing events — lightweight, no DraggableScrollableSheet
class AddEventSheet extends StatefulWidget {
  final CalendarEvent? event;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final List<DeviceCalendar> calendars;
  final Function(CalendarEvent) onSave;
  final VoidCallback? onDelete;

  const AddEventSheet({
    super.key,
    this.event,
    this.initialDate,
    this.initialTime,
    this.calendars = const [],
    required this.onSave,
    this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    CalendarEvent? event,
    DateTime? initialDate,
    TimeOfDay? initialTime,
    List<DeviceCalendar> calendars = const [],
    required Function(CalendarEvent) onSave,
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEventSheet(
        event: event,
        initialDate: initialDate,
        initialTime: initialTime,
        calendars: calendars,
        onSave: onSave,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<AddEventSheet> {
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;

  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  DeviceCalendar? _selectedCalendar;
  bool _isAllDay = false;
  bool _showDescription = false;

  bool get _isEditMode => widget.event != null;

  @override
  void initState() {
    super.initState();

    if (_isEditMode) {
      _titleController = TextEditingController(text: widget.event!.title);
      _locationController = TextEditingController(text: widget.event!.location ?? '');
      _descriptionController = TextEditingController(text: widget.event!.description ?? '');
      _selectedDate = widget.event!.startTime;
      _startTime = TimeOfDay.fromDateTime(widget.event!.startTime);
      _endTime = TimeOfDay.fromDateTime(widget.event!.endTime);
      _isAllDay = widget.event!.isAllDay;
      _showDescription = widget.event!.description?.isNotEmpty == true;

      if (widget.event!.calendarId != null && widget.calendars.isNotEmpty) {
        _selectedCalendar = widget.calendars
            .where((c) => c.id == widget.event!.calendarId)
            .firstOrNull;
      }
    } else {
      _titleController = TextEditingController();
      _locationController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedDate = widget.initialDate ?? DateTime.now();
      _startTime = widget.initialTime ?? TimeOfDay.now();
      _endTime = TimeOfDay(
        hour: (_startTime.hour + 1) % 24,
        minute: _startTime.minute,
      );
    }

    _selectedCalendar ??= widget.calendars.isNotEmpty ? widget.calendars.first : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _startTime = time;
        if (_endTime.hour < _startTime.hour ||
            (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
          _endTime = TimeOfDay(
            hour: (_startTime.hour + 1) % 24,
            minute: _startTime.minute,
          );
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() => _endTime = time);
    }
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an event title'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (_selectedCalendar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a calendar'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _isAllDay ? 0 : _startTime.hour,
      _isAllDay ? 0 : _startTime.minute,
    );

    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _isAllDay ? 23 : _endTime.hour,
      _isAllDay ? 59 : _endTime.minute,
    );

    final event = CalendarEvent(
      eventId: widget.event?.eventId,
      calendarId: _selectedCalendar!.id,
      calendarName: _selectedCalendar!.name,
      calendarColor: _selectedCalendar!.color,
      title: _titleController.text.trim(),
      description: _showDescription && _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      startTime: startDateTime,
      endTime: endDateTime,
      location: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : null,
      isAllDay: _isAllDay,
    );

    widget.onSave(event);
    Navigator.pop(context);
  }

  void _delete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              widget.onDelete?.call();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    // Fixed height: 75% of screen, adjusts for keyboard
    final sheetHeight = screenHeight * 0.75;

    return Container(
      height: sheetHeight,
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _isEditMode ? 'Edit Event' : 'New Event',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_isEditMode)
                  IconButton(
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor, size: 22),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar selector chips
                  if (widget.calendars.isNotEmpty) ...[
                    const Text(
                      'Calendar',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.calendars.map((calendar) {
                        final calColor = Color(calendar.color);
                        final isSelected = _selectedCalendar?.id == calendar.id;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedCalendar = calendar),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? calColor : calColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? calColor : calColor.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
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
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Title input
                  _buildInputField(
                    controller: _titleController,
                    label: 'Event Title',
                    hint: 'What\'s the event?',
                  ),
                  const SizedBox(height: 16),

                  // Date & Time section
                  const Text(
                    'Date & Time',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Date picker row
                  _buildTappableField(
                    icon: Icons.calendar_today,
                    label: _formatDate(_selectedDate),
                    onTap: _selectDate,
                  ),
                  const SizedBox(height: 10),

                  // All-day toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All-day event',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 28,
                        child: Switch(
                          value: _isAllDay,
                          onChanged: (value) => setState(() => _isAllDay = value),
                          activeThumbColor: AppTheme.primaryColor,
                          activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                          inactiveThumbColor: Colors.grey.shade400,
                          inactiveTrackColor: Colors.grey.shade200,
                        ),
                      ),
                    ],
                  ),

                  // Time pickers
                  if (!_isAllDay) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTappableField(
                            icon: Icons.access_time,
                            label: _startTime.format(context),
                            subtitle: 'Start',
                            onTap: _selectStartTime,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.arrow_forward, size: 16, color: AppTheme.textTertiary),
                        ),
                        Expanded(
                          child: _buildTappableField(
                            icon: Icons.access_time,
                            label: _endTime.format(context),
                            subtitle: 'End',
                            onTap: _selectEndTime,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Location input
                  _buildInputField(
                    controller: _locationController,
                    label: 'Location',
                    hint: 'Add location (optional)',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Description toggle and input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add description',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 28,
                        child: Switch(
                          value: _showDescription,
                          onChanged: (value) => setState(() => _showDescription = value),
                          activeThumbColor: AppTheme.primaryColor,
                          activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                          inactiveThumbColor: Colors.grey.shade400,
                          inactiveTrackColor: Colors.grey.shade200,
                        ),
                      ),
                    ],
                  ),
                  if (_showDescription) ...[
                    const SizedBox(height: 10),
                    _buildInputField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Add event details',
                      maxLines: 3,
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Action buttons (pinned at bottom)
          Container(
            padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPadding > 0 ? bottomPadding : 16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isEditMode ? 'Save Changes' : 'Add Event',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppTheme.textSecondary, size: 20)
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTappableField({
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'Today, ${months[date.month - 1]} ${date.day}';
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Tomorrow, ${months[date.month - 1]} ${date.day}';
    }

    return '${days[date.weekday % 7]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
