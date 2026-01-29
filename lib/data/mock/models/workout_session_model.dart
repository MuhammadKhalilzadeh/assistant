enum WorkoutType { running, cycling, strength, yoga, swimming, walking, hiit, other }

class ExerciseModel {
  final String name;
  final int sets;
  final int reps;
  final double? weight;

  ExerciseModel({
    required this.name,
    this.sets = 0,
    this.reps = 0,
    this.weight,
  });
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

  WorkoutSessionModel({
    required this.id,
    required this.type,
    required this.startTime,
    this.endTime,
    this.durationMinutes = 0,
    this.caloriesBurned = 0,
    this.exercises = const [],
    this.notes,
  });

  WorkoutSessionModel copyWith({
    String? id,
    WorkoutType? type,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    int? caloriesBurned,
    List<ExerciseModel>? exercises,
    String? notes,
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
    );
  }
}
