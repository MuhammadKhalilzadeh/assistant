class StepRecordModel {
  final String id;
  final DateTime date;
  final int steps;
  final int goal;
  final double distanceKm;
  final int caloriesBurned;
  final DateTime createdAt;
  final DateTime updatedAt;

  StepRecordModel({
    required this.id,
    required this.date,
    required this.steps,
    this.goal = 10000,
    this.distanceKm = 0,
    this.caloriesBurned = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get progressPercent => goal > 0 ? (steps / goal).clamp(0.0, 1.0) : 0.0;

  StepRecordModel copyWith({
    String? id,
    DateTime? date,
    int? steps,
    int? goal,
    double? distanceKm,
    int? caloriesBurned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StepRecordModel(
      id: id ?? this.id,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      goal: goal ?? this.goal,
      distanceKm: distanceKm ?? this.distanceKm,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory StepRecordModel.fromJson(Map<String, dynamic> json) {
    return StepRecordModel(
      id: json['id'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      steps: json['steps'] as int? ?? 0,
      goal: json['goal'] as int? ?? 10000,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      caloriesBurned: json['caloriesBurned'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'steps': steps,
      'goal': goal,
      'distanceKm': distanceKm,
      'caloriesBurned': caloriesBurned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'steps': steps,
      'goal': goal,
      'distanceKm': distanceKm,
      'caloriesBurned': caloriesBurned,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'steps': steps,
      'goal': goal,
      'distanceKm': distanceKm,
      'caloriesBurned': caloriesBurned,
    };
  }
}

class StepsGoal {
  final String id;
  final int dailyGoal;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StepsGoal({
    required this.id,
    this.dailyGoal = 10000,
    required this.createdAt,
    required this.updatedAt,
  });

  StepsGoal copyWith({
    String? id,
    int? dailyGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StepsGoal(
      id: id ?? this.id,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory StepsGoal.fromJson(Map<String, dynamic> json) {
    return StepsGoal(
      id: json['id'] as String,
      dailyGoal: json['dailyGoal'] as int? ?? 10000,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dailyGoal': dailyGoal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'dailyGoal': dailyGoal,
    };
  }
}

class StepsStats {
  final int todaySteps;
  final int dailyGoal;
  final int weeklyAverageSteps;
  final int currentStreak;
  final int bestStreak;
  final double goalCompletionRate;
  final double totalDistanceKm;
  final int totalCaloriesBurned;

  const StepsStats({
    this.todaySteps = 0,
    this.dailyGoal = 10000,
    this.weeklyAverageSteps = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.goalCompletionRate = 0.0,
    this.totalDistanceKm = 0.0,
    this.totalCaloriesBurned = 0,
  });

  factory StepsStats.fromJson(Map<String, dynamic> json) {
    return StepsStats(
      todaySteps: json['todaySteps'] as int? ?? 0,
      dailyGoal: json['dailyGoal'] as int? ?? 10000,
      weeklyAverageSteps: json['weeklyAverageSteps'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      goalCompletionRate: (json['goalCompletionRate'] as num?)?.toDouble() ?? 0.0,
      totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0.0,
      totalCaloriesBurned: json['totalCaloriesBurned'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todaySteps': todaySteps,
      'dailyGoal': dailyGoal,
      'weeklyAverageSteps': weeklyAverageSteps,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'goalCompletionRate': goalCompletionRate,
      'totalDistanceKm': totalDistanceKm,
      'totalCaloriesBurned': totalCaloriesBurned,
    };
  }

  double get progress => dailyGoal > 0 ? (todaySteps / dailyGoal) : 0.0;
  bool get goalMet => todaySteps >= dailyGoal;

  static StepsStats empty() => const StepsStats();
}

class StepsDailySummary {
  final DateTime date;
  final int steps;
  final int goal;
  final bool goalMet;
  final double distanceKm;
  final int caloriesBurned;

  const StepsDailySummary({
    required this.date,
    required this.steps,
    required this.goal,
    required this.goalMet,
    required this.distanceKm,
    required this.caloriesBurned,
  });

  factory StepsDailySummary.fromJson(Map<String, dynamic> json) {
    return StepsDailySummary(
      date: DateTime.parse(json['date'] as String),
      steps: json['steps'] as int,
      goal: json['goal'] as int,
      goalMet: json['goalMet'] as bool,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      caloriesBurned: json['caloriesBurned'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'steps': steps,
      'goal': goal,
      'goalMet': goalMet,
      'distanceKm': distanceKm,
      'caloriesBurned': caloriesBurned,
    };
  }

  double get progress => goal > 0 ? (steps / goal).clamp(0.0, 1.5) : 0.0;
}
