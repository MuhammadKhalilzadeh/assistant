enum MealType { breakfast, lunch, dinner, snack }

class CalorieEntryModel {
  final String id;
  final String foodName;
  final int calories;
  final MealType mealType;
  final DateTime loggedAt;
  final int? protein;
  final int? carbs;
  final int? fat;

  CalorieEntryModel({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.mealType,
    required this.loggedAt,
    this.protein,
    this.carbs,
    this.fat,
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
    );
  }
}
