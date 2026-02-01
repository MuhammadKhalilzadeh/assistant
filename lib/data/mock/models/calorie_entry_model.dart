enum MealType { breakfast, lunch, dinner, snack }

enum FoodCategory {
  grains,
  protein,
  dairy,
  fruits,
  vegetables,
  fats,
  sweets,
  beverages,
  other,
}

class CalorieEntryModel {
  final String id;
  final String foodName;
  final int calories;
  final MealType mealType;
  final DateTime loggedAt;
  final int? protein;
  final int? carbs;
  final int? fat;
  final FoodCategory? foodCategory;
  final int? servingSize;
  final String? note;

  CalorieEntryModel({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.mealType,
    required this.loggedAt,
    this.protein,
    this.carbs,
    this.fat,
    this.foodCategory,
    this.servingSize,
    this.note,
  });

  CalorieEntryModel copyWith({
    String? id,
    String? foodName,
    int? calories,
    MealType? mealType,
    DateTime? loggedAt,
    int? protein,
    int? carbs,
    int? fat,
    FoodCategory? foodCategory,
    int? servingSize,
    String? note,
  }) {
    return CalorieEntryModel(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      calories: calories ?? this.calories,
      mealType: mealType ?? this.mealType,
      loggedAt: loggedAt ?? this.loggedAt,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      foodCategory: foodCategory ?? this.foodCategory,
      servingSize: servingSize ?? this.servingSize,
      note: note ?? this.note,
    );
  }
}

class NutritionGoal {
  final int dailyCalorieGoal;
  final int proteinGoalGrams;
  final int carbsGoalGrams;
  final int fatGoalGrams;
  final bool remindersEnabled;

  const NutritionGoal({
    this.dailyCalorieGoal = 2000,
    this.proteinGoalGrams = 50,
    this.carbsGoalGrams = 250,
    this.fatGoalGrams = 65,
    this.remindersEnabled = false,
  });

  NutritionGoal copyWith({
    int? dailyCalorieGoal,
    int? proteinGoalGrams,
    int? carbsGoalGrams,
    int? fatGoalGrams,
    bool? remindersEnabled,
  }) {
    return NutritionGoal(
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      proteinGoalGrams: proteinGoalGrams ?? this.proteinGoalGrams,
      carbsGoalGrams: carbsGoalGrams ?? this.carbsGoalGrams,
      fatGoalGrams: fatGoalGrams ?? this.fatGoalGrams,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    );
  }
}

class NutritionStats {
  final double weeklyAverageCalories;
  final int currentStreak;
  final int bestStreak;
  final double goalCompletionRate;
  final double avgProtein;
  final double avgCarbs;
  final double avgFat;

  const NutritionStats({
    required this.weeklyAverageCalories,
    required this.currentStreak,
    required this.bestStreak,
    required this.goalCompletionRate,
    required this.avgProtein,
    required this.avgCarbs,
    required this.avgFat,
  });
}

class DailyNutritionSummary {
  final DateTime date;
  final int totalCalories;
  final int goalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final List<CalorieEntryModel> meals;

  const DailyNutritionSummary({
    required this.date,
    required this.totalCalories,
    required this.goalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.meals,
  });

  bool get goalMet =>
      totalCalories <= goalCalories && totalCalories >= goalCalories * 0.8;
}
