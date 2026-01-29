import 'package:hive/hive.dart';

part 'step_record_model.g.dart';

@HiveType(typeId: 11)
class StepRecordModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int steps;

  @HiveField(3)
  final int goal;

  @HiveField(4)
  final double distanceKm;

  @HiveField(5)
  final int caloriesBurned;

  StepRecordModel({
    required this.id,
    required this.date,
    required this.steps,
    this.goal = 10000,
    this.distanceKm = 0,
    this.caloriesBurned = 0,
  });

  double get progressPercent => (steps / goal).clamp(0.0, 1.0);

  StepRecordModel copyWith({
    String? id,
    DateTime? date,
    int? steps,
    int? goal,
    double? distanceKm,
    int? caloriesBurned,
  }) {
    return StepRecordModel(
      id: id ?? this.id,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      goal: goal ?? this.goal,
      distanceKm: distanceKm ?? this.distanceKm,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    );
  }
}
