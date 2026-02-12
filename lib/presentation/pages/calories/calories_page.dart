import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/calorie_entry_model.dart';
import 'package:assistant/providers/calories_provider.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

import 'widgets/add_meal_sheet.dart';
import 'widgets/calories_app_bar.dart';
import 'widgets/calories_progress_card.dart';
import 'widgets/daily_history_widget.dart';
import 'widgets/goal_celebration.dart';
import 'widgets/macro_breakdown_card.dart';
import 'widgets/meal_log_list.dart';
import 'widgets/nutrition_stats_card.dart';
import 'widgets/nutrition_tips_card.dart';
import 'widgets/quick_add_buttons.dart';

class CaloriesPage extends ConsumerStatefulWidget {
  const CaloriesPage({super.key});

  @override
  ConsumerState<CaloriesPage> createState() => _CaloriesPageState();
}

class _CaloriesPageState extends ConsumerState<CaloriesPage>
    with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _listAnimation;
  late Animation<double> _progressAnimation;

  bool _showCelebration = false;
  bool _hasShownCelebration = false;

  @override
  void initState() {
    super.initState();

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _listAnimation = CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOutCubic,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeOutCubic,
    );

    _listAnimationController.forward();
    _progressAnimationController.forward();

    _checkGoalAchievement();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _checkGoalAchievement() {
    if (_hasShownCelebration) return;

    final stats = ref.read(nutritionStatsProvider).valueOrNull;
    if (stats == null) return;

    final isWithinGoal = stats.todayCalories >= stats.dailyCalorieGoal * 0.8 &&
        stats.todayCalories <= stats.dailyCalorieGoal;

    if (isWithinGoal && !_showCelebration) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _showCelebration = true;
            _hasShownCelebration = true;
          });
        }
      });
    }
  }

  void _handleQuickAdd(QuickAddItem item) async {
    final entry = CalorieEntryModel(
      id: '',
      foodName: item.name,
      calories: item.calories,
      mealType: _getCurrentMealType(),
      loggedAt: DateTime.now(),
      protein: item.protein,
      carbs: item.carbs,
      fat: item.fat,
      foodCategory: item.category,
    );

    try {
      await ref.read(calorieEntriesProvider.notifier).addEntry(entry);
      _refreshAfterChange();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add entry: $e')),
        );
      }
    }
  }

  void _handleMealAdded(CalorieEntryModel entry) async {
    try {
      await ref.read(calorieEntriesProvider.notifier).addEntry(entry);
      _refreshAfterChange();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add meal: $e')),
        );
      }
    }
  }

  void _handleDeleteEntry(String id) async {
    try {
      await ref.read(calorieEntriesProvider.notifier).deleteEntry(id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete entry: $e')),
        );
      }
    }
  }

  void _refreshAfterChange() {
    _progressAnimationController.reset();
    _progressAnimationController.forward();
    _checkGoalAchievement();
  }

  MealType _getCurrentMealType() {
    final hour = DateTime.now().hour;
    if (hour < 11) return MealType.breakfast;
    if (hour < 15) return MealType.lunch;
    if (hour < 20) return MealType.dinner;
    return MealType.snack;
  }

  void _showAddMealSheet() {
    AddMealSheet.show(
      context,
      onMealAdded: _handleMealAdded,
    );
  }

  void _showSettingsDialog() {
    final goalAsync = ref.read(nutritionGoalProvider);
    final currentGoal = goalAsync.valueOrNull;
    if (currentGoal == null) return;

    showDialog(
      context: context,
      builder: (context) => _GoalSettingsDialog(
        currentGoal: currentGoal,
        onSave: (goal, protein, carbs, fat) async {
          try {
            await ref.read(nutritionGoalProvider.notifier).updateGoal(
                  currentGoal.copyWith(
                    dailyCalorieGoal: goal,
                    proteinGoalGrams: protein,
                    carbsGoalGrams: carbs,
                    fatGoalGrams: fat,
                  ),
                );
          } catch (e) {
            // ignore
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);

    final entriesAsync = ref.watch(calorieEntriesProvider);
    final statsAsync = ref.watch(nutritionStatsProvider);
    final goalAsync = ref.watch(nutritionGoalProvider);
    final historyAsync = ref.watch(nutritionHistoryProvider);

    final entries = entriesAsync.valueOrNull ?? [];
    final stats = statsAsync.valueOrNull ?? NutritionStats.empty();
    final nutritionGoal = goalAsync.valueOrNull;
    final currentCalories = stats.todayCalories;
    final last7Days = historyAsync.valueOrNull ?? [];

    // Convert last7Days for DailyHistoryWidget
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final last7DaysCalories = <String, int>{};
    for (final day in last7Days) {
      final dayName = dayNames[day.date.weekday - 1];
      last7DaysCalories[dayName] = day.totalCalories;
    }

    // Compute macros from today's entries
    final macros = <String, int>{
      'protein': entries.fold<int>(0, (sum, e) => sum + (e.protein ?? 0)),
      'carbs': entries.fold<int>(0, (sum, e) => sum + (e.carbs ?? 0)),
      'fat': entries.fold<int>(0, (sum, e) => sum + (e.fat ?? 0)),
    };

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
                children: [
                  CaloriesAppBar(
                    currentCalories: currentCalories,
                    onSettingsTap: _showSettingsDialog,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          children: [
                            // Progress Card
                            CaloriesProgressCard(
                              currentCalories: currentCalories,
                              goalCalories: nutritionGoal?.dailyCalorieGoal ?? 2000,
                              animation: _progressAnimation,
                            ),
                            SizedBox(height: padding),

                            // Quick Add Buttons
                            QuickAddButtons(onQuickAdd: _handleQuickAdd),
                            SizedBox(height: padding),

                            // Macro Breakdown
                            MacroBreakdownCard(
                              protein: macros['protein'] ?? 0,
                              carbs: macros['carbs'] ?? 0,
                              fat: macros['fat'] ?? 0,
                              proteinGoal: nutritionGoal?.proteinGoalGrams ?? 50,
                              carbsGoal: nutritionGoal?.carbsGoalGrams ?? 250,
                              fatGoal: nutritionGoal?.fatGoalGrams ?? 65,
                              animation: _progressAnimation,
                            ),
                            SizedBox(height: padding),

                            // Nutrition Tips
                            const NutritionTipsCard(),
                            SizedBox(height: padding),

                            // Daily History
                            DailyHistoryWidget(
                              last7DaysCalories: last7DaysCalories,
                              goalCalories: nutritionGoal?.dailyCalorieGoal ?? 2000,
                              animation: _listAnimation,
                            ),
                            SizedBox(height: padding),

                            // Stats Card
                            NutritionStatsCard(
                              stats: stats,
                              animation: _listAnimation,
                            ),
                            SizedBox(height: padding),

                            // Meal Log
                            MealLogList(
                              entries: entries,
                              animation: _listAnimation,
                              onDeleteEntry: _handleDeleteEntry,
                            ),
                            SizedBox(height: padding * 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            // Celebration overlay
            if (_showCelebration)
              GoalCelebration(
                onDismiss: () => setState(() => _showCelebration = false),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMealSheet,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GoalSettingsDialog extends StatefulWidget {
  final NutritionGoal currentGoal;
  final Function(int goal, int protein, int carbs, int fat) onSave;

  const _GoalSettingsDialog({
    required this.currentGoal,
    required this.onSave,
  });

  @override
  State<_GoalSettingsDialog> createState() => _GoalSettingsDialogState();
}

class _GoalSettingsDialogState extends State<_GoalSettingsDialog> {
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;

  @override
  void initState() {
    super.initState();
    _caloriesController = TextEditingController(
      text: widget.currentGoal.dailyCalorieGoal.toString(),
    );
    _proteinController = TextEditingController(
      text: widget.currentGoal.proteinGoalGrams.toString(),
    );
    _carbsController = TextEditingController(
      text: widget.currentGoal.carbsGoalGrams.toString(),
    );
    _fatController = TextEditingController(
      text: widget.currentGoal.fatGoalGrams.toString(),
    );
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nutrition Goals'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: 'Daily Calories',
                suffixText: 'cal',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _proteinController,
              decoration: const InputDecoration(
                labelText: 'Protein',
                suffixText: 'g',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _carbsController,
              decoration: const InputDecoration(
                labelText: 'Carbs',
                suffixText: 'g',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fatController,
              decoration: const InputDecoration(
                labelText: 'Fat',
                suffixText: 'g',
              ),
              keyboardType: TextInputType.number,
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
            final goal = int.tryParse(_caloriesController.text) ?? 2000;
            final protein = int.tryParse(_proteinController.text) ?? 50;
            final carbs = int.tryParse(_carbsController.text) ?? 250;
            final fat = int.tryParse(_fatController.text) ?? 65;
            widget.onSave(goal, protein, carbs, fat);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
