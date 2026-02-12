enum WorkoutType {
  running,
  cycling,
  strength,
  yoga,
  swimming,
  walking,
  hiit,
  other;

  String get label {
    switch (this) {
      case WorkoutType.running: return 'Running';
      case WorkoutType.cycling: return 'Cycling';
      case WorkoutType.strength: return 'Strength';
      case WorkoutType.yoga: return 'Yoga';
      case WorkoutType.swimming: return 'Swimming';
      case WorkoutType.walking: return 'Walking';
      case WorkoutType.hiit: return 'HIIT';
      case WorkoutType.other: return 'Other';
    }
  }
}

class ExerciseModel {
  final String name;
  final int sets;
  final int reps;
  final double? weight;

  const ExerciseModel({
    required this.name,
    this.sets = 0,
    this.reps = 0,
    this.weight,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      name: json['name'] as String,
      sets: json['sets'] as int? ?? 0,
      reps: json['reps'] as int? ?? 0,
      weight: (json['weight'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }

  ExerciseModel copyWith({
    String? name,
    int? sets,
    int? reps,
    double? weight,
  }) {
    return ExerciseModel(
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
    );
  }
}

class WorkoutSessionModel {
  final String id;
  final WorkoutType type;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final int caloriesBurned;
  final List<ExerciseModel> exercises;
  final String? notes;
  final DateTime createdAt;

  WorkoutSessionModel({
    required this.id,
    required this.type,
    required this.startTime,
    this.endTime,
    this.durationMinutes = 0,
    this.caloriesBurned = 0,
    this.exercises = const [],
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  WorkoutSessionModel copyWith({
    String? id,
    WorkoutType? type,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    int? caloriesBurned,
    List<ExerciseModel>? exercises,
    String? notes,
    DateTime? createdAt,
  }) {
    return WorkoutSessionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory WorkoutSessionModel.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionModel(
      id: json['id'] as String,
      type: WorkoutType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => WorkoutType.other,
      ),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      caloriesBurned: json['caloriesBurned'] as int? ?? 0,
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'type': type.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'type': type.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }
}

class WorkoutGoal {
  final String id;
  final int weeklyMinutesGoal;
  final int weeklySessionsGoal;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkoutGoal({
    required this.id,
    this.weeklyMinutesGoal = 150,
    this.weeklySessionsGoal = 5,
    required this.createdAt,
    required this.updatedAt,
  });

  WorkoutGoal copyWith({
    String? id,
    int? weeklyMinutesGoal,
    int? weeklySessionsGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutGoal(
      id: id ?? this.id,
      weeklyMinutesGoal: weeklyMinutesGoal ?? this.weeklyMinutesGoal,
      weeklySessionsGoal: weeklySessionsGoal ?? this.weeklySessionsGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory WorkoutGoal.fromJson(Map<String, dynamic> json) {
    return WorkoutGoal(
      id: json['id'] as String,
      weeklyMinutesGoal: json['weeklyMinutesGoal'] as int? ?? 150,
      weeklySessionsGoal: json['weeklySessionsGoal'] as int? ?? 5,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weeklyMinutesGoal': weeklyMinutesGoal,
      'weeklySessionsGoal': weeklySessionsGoal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'weeklyMinutesGoal': weeklyMinutesGoal,
      'weeklySessionsGoal': weeklySessionsGoal,
    };
  }
}

class WorkoutStats {
  final int weeklyMinutes;
  final int weeklySessions;
  final int weeklyCalories;
  final int currentStreak;
  final int bestStreak;
  final double goalCompletionRate;
  final Map<String, int> workoutsByType;

  const WorkoutStats({
    this.weeklyMinutes = 0,
    this.weeklySessions = 0,
    this.weeklyCalories = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.goalCompletionRate = 0.0,
    this.workoutsByType = const {},
  });

  factory WorkoutStats.fromJson(Map<String, dynamic> json) {
    return WorkoutStats(
      weeklyMinutes: json['weeklyMinutes'] as int? ?? 0,
      weeklySessions: json['weeklySessions'] as int? ?? 0,
      weeklyCalories: json['weeklyCalories'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      goalCompletionRate: (json['goalCompletionRate'] as num?)?.toDouble() ?? 0.0,
      workoutsByType: (json['workoutsByType'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weeklyMinutes': weeklyMinutes,
      'weeklySessions': weeklySessions,
      'weeklyCalories': weeklyCalories,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'goalCompletionRate': goalCompletionRate,
      'workoutsByType': workoutsByType,
    };
  }

  static WorkoutStats empty() => const WorkoutStats();
}

class WorkoutDailySummary {
  final DateTime date;
  final int totalMinutes;
  final int totalCalories;
  final int sessionCount;
  final bool goalMet;

  const WorkoutDailySummary({
    required this.date,
    required this.totalMinutes,
    required this.totalCalories,
    required this.sessionCount,
    required this.goalMet,
  });

  factory WorkoutDailySummary.fromJson(Map<String, dynamic> json) {
    return WorkoutDailySummary(
      date: DateTime.parse(json['date'] as String),
      totalMinutes: json['totalMinutes'] as int,
      totalCalories: json['totalCalories'] as int,
      sessionCount: json['sessionCount'] as int,
      goalMet: json['goalMet'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'totalMinutes': totalMinutes,
      'totalCalories': totalCalories,
      'sessionCount': sessionCount,
      'goalMet': goalMet,
    };
  }
}
