import 'package:assistant/data/mock/models/habit_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class AddHabitSheet extends StatefulWidget {
  final HabitModel? editingHabit;
  final Function(HabitModel) onSave;
  final VoidCallback? onDelete;

  const AddHabitSheet({
    super.key,
    this.editingHabit,
    required this.onSave,
    this.onDelete,
  });

  static Future<void> show({
    required BuildContext context,
    HabitModel? editingHabit,
    required Function(HabitModel) onSave,
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddHabitSheet(
        editingHabit: editingHabit,
        onSave: onSave,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String _selectedIcon = 'check_circle';
  HabitCategory _selectedCategory = HabitCategory.other;
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  List<int> _selectedDays = [0, 1, 2, 3, 4, 5, 6];
  bool _showDescription = false;

  bool get _isEditing => widget.editingHabit != null;

  static const Map<String, IconData> _iconOptions = {
    'check_circle': Icons.check_circle,
    'fitness_center': Icons.fitness_center,
    'menu_book': Icons.menu_book,
    'self_improvement': Icons.self_improvement,
    'edit_note': Icons.edit_note,
    'water_drop': Icons.water_drop,
    'bedtime': Icons.bedtime,
    'directions_run': Icons.directions_run,
    'phone_disabled': Icons.phone_disabled,
    'phone': Icons.phone,
    'favorite': Icons.favorite,
    'work': Icons.work,
    'people': Icons.people,
    'local_cafe': Icons.local_cafe,
    'restaurant': Icons.restaurant,
    'music_note': Icons.music_note,
    'code': Icons.code,
    'brush': Icons.brush,
    'sports_soccer': Icons.sports_soccer,
    'pets': Icons.pets,
    'language': Icons.language,
    'savings': Icons.savings,
  };

  static const List<String> _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.editingHabit?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.editingHabit?.description ?? '',
    );
    _selectedIcon = widget.editingHabit?.icon ?? 'check_circle';
    _selectedCategory = widget.editingHabit?.category ?? HabitCategory.other;
    _selectedFrequency = widget.editingHabit?.frequency ?? HabitFrequency.daily;
    _selectedDays = List.from(widget.editingHabit?.targetDays ?? [0, 1, 2, 3, 4, 5, 6]);
    _showDescription = widget.editingHabit?.description != null &&
        widget.editingHabit!.description!.isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit name')),
      );
      return;
    }

    final description = _descriptionController.text.trim();

    // Get target days based on frequency
    List<int> targetDays;
    if (_selectedFrequency == HabitFrequency.specificDays) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one day')),
        );
        return;
      }
      targetDays = _selectedDays;
    } else {
      targetDays = _selectedFrequency.defaultTargetDays;
    }

    final habit = HabitModel(
      id: widget.editingHabit?.id ?? '',
      name: name,
      description: description.isEmpty ? null : description,
      icon: _selectedIcon,
      category: _selectedCategory,
      frequency: _selectedFrequency,
      targetDays: targetDays,
      streak: widget.editingHabit?.streak ?? 0,
      bestStreak: widget.editingHabit?.bestStreak ?? 0,
      completedDates: widget.editingHabit?.completedDates ?? [],
      isCompletedToday: widget.editingHabit?.isCompletedToday ?? false,
      createdAt: widget.editingHabit?.createdAt ?? DateTime.now(),
    );

    widget.onSave(habit);
    Navigator.pop(context);
  }

  void _onFrequencyChanged(HabitFrequency frequency) {
    setState(() {
      _selectedFrequency = frequency;
      if (frequency != HabitFrequency.specificDays) {
        _selectedDays = frequency.defaultTargetDays;
      }
    });
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
        _selectedDays.sort();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SingleChildScrollView(
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
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isEditing ? 'Edit Habit' : 'New Habit',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_isEditing && widget.onDelete != null)
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onDelete!();
                        },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                // Name field
                _buildTextField(
                  controller: _nameController,
                  label: 'Habit Name',
                  hint: 'What habit do you want to build?',
                  autofocus: !_isEditing,
                ),
                const SizedBox(height: 16),
                // Description toggle & field
                if (!_showDescription)
                  GestureDetector(
                    onTap: () => setState(() => _showDescription = true),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add description',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Why is this habit important to you?',
                    maxLines: 2,
                  ),
                const SizedBox(height: 24),
                // Icon picker
                _buildSectionTitle('Choose Icon'),
                const SizedBox(height: 12),
                _buildIconPicker(),
                const SizedBox(height: 24),
                // Category selector
                _buildSectionTitle('Category'),
                const SizedBox(height: 12),
                _buildCategorySelector(),
                const SizedBox(height: 24),
                // Frequency selector
                _buildSectionTitle('Frequency'),
                const SizedBox(height: 12),
                _buildFrequencySelector(),
                // Day picker (only for specific days)
                if (_selectedFrequency == HabitFrequency.specificDays) ...[
                  const SizedBox(height: 16),
                  _buildDayPicker(),
                ],
                const SizedBox(height: 32),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isEditing ? 'Save Changes' : 'Create Habit',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
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
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconPicker() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _iconOptions.entries.map((entry) {
          final isSelected = _selectedIcon == entry.key;
          return GestureDetector(
            onTap: () => setState(() => _selectedIcon = entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Icon(
                entry.value,
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.white.withValues(alpha: 0.8),
                size: 24,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: HabitCategory.values.map((category) {
        final isSelected = _selectedCategory == category;
        final color = Color(category.colorValue);

        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = category),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.white.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              category.label,
              style: TextStyle(
                color: isSelected ? color : Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFrequencySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: HabitFrequency.values.map((frequency) {
        final isSelected = _selectedFrequency == frequency;

        return GestureDetector(
          onTap: () => _onFrequencyChanged(frequency),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  frequency.label,
                  style: TextStyle(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  frequency.description,
                  style: TextStyle(
                    color: isSelected
                        ? AppTheme.primaryColor.withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Days',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final isSelected = _selectedDays.contains(index);
            return GestureDetector(
              onTap: () => _toggleDay(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _dayLabels[index],
                  style: TextStyle(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
