enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get label {
    switch (this) {
      case MealType.breakfast: return 'Breakfast';
      case MealType.lunch: return 'Lunch';
      case MealType.dinner: return 'Dinner';
      case MealType.snack: return 'Snack';
    }
  }
}

enum FoodCategory {
  grains,
  protein,
  dairy,
  fruits,
  vegetables,
  fats,
  sweets,
  beverages,
  other;

  String get label {
    switch (this) {
      case FoodCategory.grains: return 'Grains';
      case FoodCategory.protein: return 'Protein';
      case FoodCategory.dairy: return 'Dairy';
      case FoodCategory.fruits: return 'Fruits';
      case FoodCategory.vegetables: return 'Vegetables';
      case FoodCategory.fats: return 'Fats';
      case FoodCategory.sweets: return 'Sweets';
      case FoodCategory.beverages: return 'Beverages';
      case FoodCategory.other: return 'Other';
    }
  }
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
  final DateTime createdAt;

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
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

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
    DateTime? createdAt,
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
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CalorieEntryModel.fromJson(Map<String, dynamic> json) {
    return CalorieEntryModel(
      id: json['id'] as String,
      foodName: json['foodName'] as String,
      calories: json['calories'] as int,
      mealType: MealType.values.firstWhere(
        (m) => m.name == json['mealType'],
        orElse: () => MealType.snack,
      ),
      loggedAt: DateTime.parse(json['loggedAt'] as String),
      protein: json['protein'] as int?,
      carbs: json['carbs'] as int?,
      fat: json['fat'] as int?,
      foodCategory: json['foodCategory'] != null
          ? FoodCategory.values.firstWhere(
              (c) => c.name == json['foodCategory'],
              orElse: () => FoodCategory.other,
            )
          : null,
      servingSize: json['servingSize'] as int?,
      note: json['note'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': foodName,
      'calories': calories,
      'mealType': mealType.name,
      'loggedAt': loggedAt.toIso8601String(),
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'foodCategory': foodCategory?.name,
      'servingSize': servingSize,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'foodName': foodName,
      'calories': calories,
      'mealType': mealType.name,
      'loggedAt': loggedAt.toIso8601String(),
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'foodCategory': foodCategory?.name,
      'servingSize': servingSize,
      'note': note,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'foodName': foodName,
      'calories': calories,
      'mealType': mealType.name,
      'loggedAt': loggedAt.toIso8601String(),
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'foodCategory': foodCategory?.name,
      'servingSize': servingSize,
      'note': note,
    };
  }
}

class NutritionGoal {
  final String id;
  final int dailyCalorieGoal;
  final int proteinGoalGrams;
  final int carbsGoalGrams;
  final int fatGoalGrams;
  final bool remindersEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NutritionGoal({
    required this.id,
    this.dailyCalorieGoal = 2000,
    this.proteinGoalGrams = 50,
    this.carbsGoalGrams = 250,
    this.fatGoalGrams = 65,
    this.remindersEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  });

  NutritionGoal copyWith({
    String? id,
    int? dailyCalorieGoal,
    int? proteinGoalGrams,
    int? carbsGoalGrams,
    int? fatGoalGrams,
    bool? remindersEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NutritionGoal(
      id: id ?? this.id,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      proteinGoalGrams: proteinGoalGrams ?? this.proteinGoalGrams,
      carbsGoalGrams: carbsGoalGrams ?? this.carbsGoalGrams,
      fatGoalGrams: fatGoalGrams ?? this.fatGoalGrams,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory NutritionGoal.fromJson(Map<String, dynamic> json) {
    return NutritionGoal(
      id: json['id'] as String,
      dailyCalorieGoal: json['dailyCalorieGoal'] as int? ?? 2000,
      proteinGoalGrams: json['proteinGoalGrams'] as int? ?? 50,
      carbsGoalGrams: json['carbsGoalGrams'] as int? ?? 250,
      fatGoalGrams: json['fatGoalGrams'] as int? ?? 65,
      remindersEnabled: json['remindersEnabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dailyCalorieGoal': dailyCalorieGoal,
      'proteinGoalGrams': proteinGoalGrams,
      'carbsGoalGrams': carbsGoalGrams,
      'fatGoalGrams': fatGoalGrams,
      'remindersEnabled': remindersEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'dailyCalorieGoal': dailyCalorieGoal,
      'proteinGoalGrams': proteinGoalGrams,
      'carbsGoalGrams': carbsGoalGrams,
      'fatGoalGrams': fatGoalGrams,
      'remindersEnabled': remindersEnabled,
    };
  }
}

class NutritionStats {
  final int todayCalories;
  final int todayProtein;
  final int todayCarbs;
  final int todayFat;
  final int dailyCalorieGoal;
  final int weeklyAverageCalories;
  final int currentStreak;
  final int bestStreak;
  final double goalCompletionRate;
  final int avgProtein;
  final int avgCarbs;
  final int avgFat;

  const NutritionStats({
    this.todayCalories = 0,
    this.todayProtein = 0,
    this.todayCarbs = 0,
    this.todayFat = 0,
    this.dailyCalorieGoal = 2000,
    this.weeklyAverageCalories = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.goalCompletionRate = 0.0,
    this.avgProtein = 0,
    this.avgCarbs = 0,
    this.avgFat = 0,
  });

  factory NutritionStats.fromJson(Map<String, dynamic> json) {
    return NutritionStats(
      todayCalories: json['todayCalories'] as int? ?? 0,
      todayProtein: json['todayProtein'] as int? ?? 0,
      todayCarbs: json['todayCarbs'] as int? ?? 0,
      todayFat: json['todayFat'] as int? ?? 0,
      dailyCalorieGoal: json['dailyCalorieGoal'] as int? ?? 2000,
      weeklyAverageCalories: json['weeklyAverageCalories'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      goalCompletionRate: (json['goalCompletionRate'] as num?)?.toDouble() ?? 0.0,
      avgProtein: json['avgProtein'] as int? ?? 0,
      avgCarbs: json['avgCarbs'] as int? ?? 0,
      avgFat: json['avgFat'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayCalories': todayCalories,
      'todayProtein': todayProtein,
      'todayCarbs': todayCarbs,
      'todayFat': todayFat,
      'dailyCalorieGoal': dailyCalorieGoal,
      'weeklyAverageCalories': weeklyAverageCalories,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'goalCompletionRate': goalCompletionRate,
      'avgProtein': avgProtein,
      'avgCarbs': avgCarbs,
      'avgFat': avgFat,
    };
  }

  double get progress => dailyCalorieGoal > 0 ? (todayCalories / dailyCalorieGoal) : 0.0;
  bool get goalMet => todayCalories >= dailyCalorieGoal * 0.8 && todayCalories <= dailyCalorieGoal * 1.2;

  static NutritionStats empty() => const NutritionStats();
}

class DailyNutritionSummary {
  final DateTime date;
  final int totalCalories;
  final int goalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final int entryCount;
  final bool goalMet;

  const DailyNutritionSummary({
    required this.date,
    required this.totalCalories,
    required this.goalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.entryCount,
    required this.goalMet,
  });

  factory DailyNutritionSummary.fromJson(Map<String, dynamic> json) {
    return DailyNutritionSummary(
      date: DateTime.parse(json['date'] as String),
      totalCalories: json['totalCalories'] as int,
      goalCalories: json['goalCalories'] as int,
      totalProtein: json['totalProtein'] as int,
      totalCarbs: json['totalCarbs'] as int,
      totalFat: json['totalFat'] as int,
      entryCount: json['entryCount'] as int,
      goalMet: json['goalMet'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'totalCalories': totalCalories,
      'goalCalories': goalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'entryCount': entryCount,
      'goalMet': goalMet,
    };
  }

  double get progress => goalCalories > 0 ? (totalCalories / goalCalories).clamp(0.0, 1.5) : 0.0;
}
