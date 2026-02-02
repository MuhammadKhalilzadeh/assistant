import 'package:assistant/data/mock/models/todo_model.dart';
import 'package:assistant/data/models/category_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class AddTodoSheet extends StatefulWidget {
  final TodoModel? editingTodo;
  final Function(TodoModel) onSave;
  final VoidCallback? onDelete;
  final List<CategoryModel> categories;

  const AddTodoSheet({
    super.key,
    this.editingTodo,
    required this.onSave,
    this.onDelete,
    this.categories = const [],
  });

  static Future<void> show({
    required BuildContext context,
    TodoModel? editingTodo,
    required Function(TodoModel) onSave,
    VoidCallback? onDelete,
    List<CategoryModel> categories = const [],
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTodoSheet(
        editingTodo: editingTodo,
        onSave: onSave,
        onDelete: onDelete,
        categories: categories,
      ),
    );
  }

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  int _priority = 2;
  DateTime? _dueDate;
  bool _showDescription = false;
  String? _selectedCategoryId;

  bool get _isEditing => widget.editingTodo != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.editingTodo?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.editingTodo?.description ?? '',
    );
    _priority = widget.editingTodo?.priority ?? 2;
    _dueDate = widget.editingTodo?.dueDate;
    _showDescription = widget.editingTodo?.description != null &&
        widget.editingTodo!.description!.isNotEmpty;
    _selectedCategoryId = widget.editingTodo?.categoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    final description = _descriptionController.text.trim();
    final selectedCategory = _selectedCategoryId != null
        ? widget.categories.where((c) => c.id == _selectedCategoryId).firstOrNull
        : null;

    final todo = TodoModel(
      id: widget.editingTodo?.id ?? '',
      title: title,
      description: description.isEmpty ? null : description,
      priority: _priority,
      dueDate: _dueDate,
      createdAt: widget.editingTodo?.createdAt ?? DateTime.now(),
      isCompleted: widget.editingTodo?.isCompleted ?? false,
      categoryId: _selectedCategoryId,
      category: selectedCategory,
    );

    widget.onSave(todo);
    Navigator.pop(context);
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
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

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
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
                      color: Colors.grey.shade300,
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
                      _isEditing ? 'Edit Task' : 'New Task',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
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
                          color: AppTheme.errorColor,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                // Title field
                _buildTextField(
                  controller: _titleController,
                  label: 'Task Title',
                  hint: 'What needs to be done?',
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
                        color: AppTheme.primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add description',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
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
                    hint: 'Add more details...',
                    maxLines: 3,
                  ),
                const SizedBox(height: 24),
                // Category selector
                if (widget.categories.isNotEmpty) ...[
                  const Text(
                    'Category',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCategorySelector(),
                  const SizedBox(height: 24),
                ],
                // Priority selector
                const Text(
                  'Priority',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildPriorityChip(
                      priority: 1,
                      label: 'High',
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(width: 12),
                    _buildPriorityChip(
                      priority: 2,
                      label: 'Medium',
                      color: AppTheme.warningColor,
                    ),
                    const SizedBox(width: 12),
                    _buildPriorityChip(
                      priority: 3,
                      label: 'Low',
                      color: AppTheme.successColor,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Due date picker
                const Text(
                  'Due Date',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _dueDate != null
                                ? _formatDate(_dueDate!)
                                : 'No due date',
                            style: TextStyle(
                              color: _dueDate != null
                                  ? AppTheme.textPrimary
                                  : AppTheme.textTertiary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (_dueDate != null)
                          GestureDetector(
                            onTap: () => setState(() => _dueDate = null),
                            child: Icon(
                              Icons.close_rounded,
                              color: AppTheme.textTertiary,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
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
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
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
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isEditing ? 'Save Changes' : 'Add Task',
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

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // "None" option
        GestureDetector(
          onTap: () => setState(() => _selectedCategoryId = null),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _selectedCategoryId == null
                  ? AppTheme.textTertiary.withValues(alpha: 0.15)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _selectedCategoryId == null
                    ? AppTheme.textTertiary
                    : Colors.grey.shade200,
                width: _selectedCategoryId == null ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.label_off_rounded,
                  size: 16,
                  color: _selectedCategoryId == null
                      ? AppTheme.textSecondary
                      : AppTheme.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  'None',
                  style: TextStyle(
                    color: _selectedCategoryId == null
                        ? AppTheme.textSecondary
                        : AppTheme.textTertiary,
                    fontSize: 13,
                    fontWeight: _selectedCategoryId == null
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Category options
        ...widget.categories.map((category) {
          final isSelected = _selectedCategoryId == category.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryId = category.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? category.colorValue.withValues(alpha: 0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? category.colorValue : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category.iconData,
                    size: 16,
                    color: isSelected
                        ? category.colorValue
                        : AppTheme.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category.name,
                    style: TextStyle(
                      color: isSelected
                          ? category.colorValue
                          : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
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
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          autofocus: autofocus,
          maxLines: maxLines,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppTheme.textTertiary,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityChip({
    required int priority,
    required String label,
    required Color color,
  }) {
    final isSelected = _priority == priority;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = priority),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flag_rounded,
                color: isSelected ? color : AppTheme.textTertiary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = dateOnly.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]}, ${date.year}';
    }
  }
}
