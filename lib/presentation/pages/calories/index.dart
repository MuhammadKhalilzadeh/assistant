import 'package:assistant/data/mock/models/calorie_entry_model.dart';
import 'package:assistant/data/mock/repositories/mock_repository.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class CaloriesPage extends StatefulWidget {
  const CaloriesPage({super.key});

  @override
  State<CaloriesPage> createState() => _CaloriesPageState();
}

class _CaloriesPageState extends State<CaloriesPage> {
  final MockRepository _repository = MockRepository();
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  MealType _selectedMealType = MealType.breakfast;
  final int _dailyGoal = 2000;

  @override
  void dispose() {
    _foodController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _showAddEntryDialog() {
    _foodController.clear();
    _caloriesController.clear();
    _selectedMealType = MealType.breakfast;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Log Meal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _foodController,
                  decoration: const InputDecoration(
                    labelText: 'Food Name',
                    hintText: 'What did you eat?',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _caloriesController,
                  decoration: const InputDecoration(
                    labelText: 'Calories',
                    hintText: 'Estimated calories',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<MealType>(
                  initialValue: _selectedMealType,
                  decoration: const InputDecoration(
                    labelText: 'Meal Type',
                  ),
                  items: MealType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getMealTypeLabel(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => _selectedMealType = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final calories = int.tryParse(_caloriesController.text);
                if (_foodController.text.trim().isNotEmpty && calories != null) {
                  _repository.addCalorieEntry(CalorieEntryModel(
                    id: '',
                    foodName: _foodController.text.trim(),
                    calories: calories,
                    mealType: _selectedMealType,
                    loggedAt: DateTime.now(),
                  ));
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  String _getMealTypeLabel(MealType type) {
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

  IconData _getMealTypeIcon(MealType type) {
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);
    final currentCalories = _repository.todayCalories;
    final progress = (currentCalories / _dailyGoal).clamp(0.0, 1.0);
    final entries = _repository.todayCalorieEntries;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.secondaryGradient,
          ),
          child: Column(
            children: [
              _buildAppBar(padding),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      children: [
                        _buildSummaryCard(currentCalories, progress, padding),
                        SizedBox(height: padding),
                        _buildMacroBreakdown(entries, padding),
                        SizedBox(height: padding),
                        _buildMealsList(entries, padding),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryDialog,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.accentColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppBar(double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          SizedBox(width: AppTheme.spacingSM),
          const Expanded(
            child: Text(
              'Calories',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int current, double progress, double padding) {
    final remaining = (_dailyGoal - current).clamp(0, _dailyGoal);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s Intake',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingXS),
                  Text(
                    '$current / $_dailyGoal cal',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMD, vertical: AppTheme.spacingSM),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '$remaining',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'cal left',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMD),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 1.0 ? Colors.red : Colors.white,
              ),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBreakdown(List<CalorieEntryModel> entries, double padding) {
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;

    for (final entry in entries) {
      totalProtein += entry.protein ?? 0;
      totalCarbs += entry.carbs ?? 0;
      totalFat += entry.fat ?? 0;
    }

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildMacroItem('Protein', '${totalProtein}g', Colors.blue)),
          Expanded(child: _buildMacroItem('Carbs', '${totalCarbs}g', Colors.orange)),
          Expanded(child: _buildMacroItem('Fat', '${totalFat}g', Colors.purple)),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              label[0],
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        SizedBox(height: AppTheme.spacingSM),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMealsList(List<CalorieEntryModel> entries, double padding) {
    final groupedEntries = <MealType, List<CalorieEntryModel>>{};
    for (final entry in entries) {
      groupedEntries.putIfAbsent(entry.mealType, () => []).add(entry);
    }

    if (entries.isEmpty) {
      return Container(
        padding: EdgeInsets.all(padding * 2),
        child: Column(
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 48,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            SizedBox(height: AppTheme.spacingSM + AppTheme.spacingXS),
            Text(
              'No meals logged today',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Meals',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppTheme.spacingSM + AppTheme.spacingXS),
        ...MealType.values.where((type) => groupedEntries.containsKey(type)).map((type) {
          final typeEntries = groupedEntries[type]!;
          final totalCalories = typeEntries.fold(0, (sum, e) => sum + e.calories);

          return Container(
            margin: EdgeInsets.only(bottom: AppTheme.spacingSM + AppTheme.spacingXS),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(padding),
                  child: Row(
                    children: [
                      Icon(_getMealTypeIcon(type), color: Colors.white, size: 24),
                      SizedBox(width: AppTheme.spacingSM + AppTheme.spacingXS),
                      Expanded(
                        child: Text(
                          _getMealTypeLabel(type),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '$totalCalories cal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                ...typeEntries.map((entry) => Container(
                  padding: EdgeInsets.symmetric(horizontal: padding, vertical: AppTheme.spacingSM),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: AppTheme.spacingXL + AppTheme.spacingXS),
                      Expanded(
                        child: Text(
                          entry.foodName,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${entry.calories} cal',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _repository.deleteCalorieEntry(entry.id);
                          setState(() {});
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.white.withValues(alpha: 0.5),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          );
        }),
      ],
    );
  }
}
