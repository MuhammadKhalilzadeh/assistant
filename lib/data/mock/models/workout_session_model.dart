import 'package:hive/hive.dart';

part 'workout_session_model.g.dart';

@HiveType(typeId: 16)
enum WorkoutType {
  @HiveField(0)
  running,
  @HiveField(1)
  cycling,
  @HiveField(2)
  strength,
  @HiveField(3)
  yoga,
  @HiveField(4)
  swimming,
  @HiveField(5)
  walking,
  @HiveField(6)
  hiit,
  @HiveField(7)
  other,
}

@HiveType(typeId: 17)
class ExerciseModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int sets;

  @HiveField(2)
  final int reps;

  @HiveField(3)
  final double? weight;

  ExerciseModel({
    required this.name,
    this.sets = 0,
    this.reps = 0,
    this.weight,
  });
}

@HiveType(typeId: 18)
class WorkoutSessionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final WorkoutType type;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  final DateTime? endTime;

  @HiveField(4)
  final int durationMinutes;

  @HiveField(5)
  final int caloriesBurned;

  @HiveField(6)
  final List<ExerciseModel> exercises;

  @HiveField(7)
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
