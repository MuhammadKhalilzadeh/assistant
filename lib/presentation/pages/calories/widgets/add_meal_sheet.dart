import 'package:assistant/data/mock/models/calorie_entry_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'food_category_selector.dart';

class AddMealSheet extends StatefulWidget {
  final Function(CalorieEntryModel) onMealAdded;

  const AddMealSheet({
    super.key,
    required this.onMealAdded,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(CalorieEntryModel) onMealAdded,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddMealSheet(onMealAdded: onMealAdded),
    );
  }

  @override
  State<AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<AddMealSheet> {
  final _foodController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  MealType _selectedMealType = MealType.breakfast;
  FoodCategory? _selectedCategory;
  int _calories = 0;
  bool _showMacros = false;

  @override
  void dispose() {
    _foodController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _incrementCalories(int amount) {
    setState(() {
      _calories = (_calories + amount).clamp(0, 9999);
      _caloriesController.text = _calories.toString();
    });
    HapticFeedback.selectionClick();
  }

  void _addMeal() {
    if (_foodController.text.trim().isEmpty || _calories <= 0) {
      return;
    }

    final entry = CalorieEntryModel(
      id: '',
      foodName: _foodController.text.trim(),
      calories: _calories,
      mealType: _selectedMealType,
      loggedAt: DateTime.now(),
      protein: int.tryParse(_proteinController.text),
      carbs: int.tryParse(_carbsController.text),
      fat: int.tryParse(_fatController.text),
      foodCategory: _selectedCategory,
    );

    widget.onMealAdded(entry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2D2D3A), Color(0xFF1A1A24)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Add Meal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food name input
                      _buildLabel('Food Name'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _foodController,
                        hint: 'What did you eat?',
                        icon: Icons.restaurant_menu,
                      ),
                      const SizedBox(height: 20),

                      // Calories input with +/- buttons
                      _buildLabel('Calories'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildCalorieButton(
                            icon: Icons.remove,
                            onTap: () => _incrementCalories(-10),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _caloriesController,
                              hint: '0',
                              icon: Icons.local_fire_department,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              onChanged: (value) {
                                setState(() {
                                  _calories = int.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildCalorieButton(
                            icon: Icons.add,
                            onTap: () => _incrementCalories(10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Meal type selector
                      _buildLabel('Meal Type'),
                      const SizedBox(height: 8),
                      _buildMealTypeSelector(),
                      const SizedBox(height: 20),

                      // Food category
                      _buildLabel('Category (Optional)'),
                      const SizedBox(height: 8),
                      FoodCategorySelector(
                        selectedCategory: _selectedCategory,
                        onCategorySelected: (category) {
                          setState(() => _selectedCategory = category);
                        },
                      ),
                      const SizedBox(height: 20),

                      // Macros toggle
                      GestureDetector(
                        onTap: () => setState(() => _showMacros = !_showMacros),
                        child: Row(
                          children: [
                            Icon(
                              _showMacros
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Add Macros (Optional)',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_showMacros) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMacroInput(
                                controller: _proteinController,
                                label: 'Protein',
                                color: Colors.red.shade400,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMacroInput(
                                controller: _carbsController,
                                label: 'Carbs',
                                color: Colors.blue.shade400,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMacroInput(
                                controller: _fatController,
                                label: 'Fat',
                                color: Colors.amber.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Add button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                              _foodController.text.trim().isNotEmpty && _calories > 0
                                  ? _addMeal
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B6B),
                            disabledBackgroundColor:
                                Colors.white.withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Add Meal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.8),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextAlign textAlign = TextAlign.start,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: textAlign,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.6)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCalorieButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return Row(
      children: MealType.values.map((type) {
        final isSelected = _selectedMealType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedMealType = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: type != MealType.values.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF6B6B)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF6B6B)
                      : Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _getMealIcon(type),
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getMealLabel(type),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMacroInput({
    required TextEditingController controller,
    required String label,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(color: color, fontSize: 16),
            decoration: InputDecoration(
              hintText: '0g',
              hintStyle: TextStyle(color: color.withValues(alpha: 0.5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getMealIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.free_breakfast;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.cookie;
    }
  }

  String _getMealLabel(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }
}
