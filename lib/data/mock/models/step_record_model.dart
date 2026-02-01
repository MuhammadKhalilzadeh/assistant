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

/// Steps goal configuration
class StepsGoal {
  final int dailyGoal;

  const StepsGoal({this.dailyGoal = 10000});

  StepsGoal copyWith({int? dailyGoal}) {
    return StepsGoal(dailyGoal: dailyGoal ?? this.dailyGoal);
  }
}

/// Weekly steps statistics
class StepsStats {
  final double weeklyAverageSteps;
  final int currentStreak;
  final int bestStreak;
  final double goalCompletionRate;
  final double totalDistanceKm;
  final int totalCaloriesBurned;

  const StepsStats({
    required this.weeklyAverageSteps,
    required this.currentStreak,
    required this.bestStreak,
    required this.goalCompletionRate,
    required this.totalDistanceKm,
    required this.totalCaloriesBurned,
  });
}
