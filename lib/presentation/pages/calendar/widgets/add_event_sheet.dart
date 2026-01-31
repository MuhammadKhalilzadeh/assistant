import 'package:flutter/material.dart';
import 'package:assistant/data/mock/models/calendar_event_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'event_category_chip.dart';

/// Bottom sheet for adding/editing events
class AddEventSheet extends StatefulWidget {
  final CalendarEventModel? event;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final Function(CalendarEventModel) onSave;
  final VoidCallback? onDelete;

  const AddEventSheet({
    super.key,
    this.event,
    this.initialDate,
    this.initialTime,
    required this.onSave,
    this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    CalendarEventModel? event,
    DateTime? initialDate,
    TimeOfDay? initialTime,
    required Function(CalendarEventModel) onSave,
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
  late EventCategory _selectedCategory;
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
      _selectedCategory = EventCategory.fromHexColor(widget.event!.color);
      _isAllDay = widget.event!.isAllDay;
      _showDescription = widget.event!.description?.isNotEmpty == true;
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
      _selectedCategory = EventCategory.work;
    }
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
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
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
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _startTime = time;
        // Ensure end time is after start time
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
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
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
        const SnackBar(
          content: Text('Please enter an event title'),
          backgroundColor: AppTheme.errorColor,
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

    final event = CalendarEventModel(
      id: widget.event?.id ?? '',
      title: _titleController.text.trim(),
      description: _showDescription && _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      startTime: startDateTime,
      endTime: endDateTime,
      location: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : null,
      color: _selectedCategory.hexColor,
      isAllDay: _isAllDay,
    );

    widget.onSave(event);
    Navigator.pop(context);
  }

  void _delete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close sheet
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
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditMode ? 'Edit Event' : 'New Event',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_isEditMode)
                    IconButton(
                      onPressed: _delete,
                      icon: const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Title input
              _buildInputField(
                controller: _titleController,
                label: 'Event Title',
                hint: 'Enter event title',
                autofocus: true,
              ),
              const SizedBox(height: 16),

              // Category selector
              const Text(
                'Category',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              CategorySelector(
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() => _selectedCategory = category);
                },
              ),
              const SizedBox(height: 16),

              // Date picker
              _buildDateTimeRow(
                icon: Icons.calendar_today,
                label: _formatDate(_selectedDate),
                onTap: _selectDate,
              ),
              const SizedBox(height: 12),

              // All-day toggle
              _buildToggleRow(
                label: 'All-day event',
                value: _isAllDay,
                onChanged: (value) {
                  setState(() => _isAllDay = value);
                },
              ),

              // Time pickers (hidden if all-day)
              if (!_isAllDay) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateTimeRow(
                        icon: Icons.access_time,
                        label: 'Start: ${_startTime.format(context)}',
                        onTap: _selectStartTime,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateTimeRow(
                        icon: Icons.access_time,
                        label: 'End: ${_endTime.format(context)}',
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
                hint: 'Enter location (optional)',
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),

              // Description toggle and input
              _buildToggleRow(
                label: 'Add description',
                value: _showDescription,
                onChanged: (value) {
                  setState(() => _showDescription = value);
                },
              ),
              if (_showDescription) ...[
                const SizedBox(height: 12),
                _buildInputField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Enter event description',
                  maxLines: 3,
                ),
              ],
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isEditMode ? 'Save Changes' : 'Add Event',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
    bool autofocus = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          autofocus: autofocus,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.white.withValues(alpha: 0.6))
                : null,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppTheme.accentColor,
          activeTrackColor: AppTheme.accentColor.withValues(alpha: 0.3),
          inactiveThumbColor: Colors.white.withValues(alpha: 0.6),
          inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
        ),
      ],
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
