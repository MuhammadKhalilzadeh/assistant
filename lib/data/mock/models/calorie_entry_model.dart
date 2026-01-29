import 'package:hive/hive.dart';

part 'calorie_entry_model.g.dart';

@HiveType(typeId: 12)
enum MealType {
  @HiveField(0)
  breakfast,
  @HiveField(1)
  lunch,
  @HiveField(2)
  dinner,
  @HiveField(3)
  snack,
}

@HiveType(typeId: 13)
class CalorieEntryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String foodName;

  @HiveField(2)
  final int calories;

  @HiveField(3)
  final MealType mealType;

  @HiveField(4)
  final DateTime loggedAt;

  @HiveField(5)
  final int? protein;

  @HiveField(6)
  final int? carbs;

  @HiveField(7)
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
