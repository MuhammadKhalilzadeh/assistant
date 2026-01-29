class StepRecordModel {
  final String id;
  final DateTime date;
  final int steps;
  final int goal;
  final double distanceKm;
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
