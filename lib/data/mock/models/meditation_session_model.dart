import 'package:hive/hive.dart';

part 'meditation_session_model.g.dart';

@HiveType(typeId: 9)
enum MeditationType {
  @HiveField(0)
  breathing,
  @HiveField(1)
  guided,
  @HiveField(2)
  unguided,
  @HiveField(3)
  sleep,
  @HiveField(4)
  focus,
}

@HiveType(typeId: 10)
class MeditationSessionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final MeditationType type;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  final int durationMinutes;

  @HiveField(4)
  final bool isCompleted;

  @HiveField(5)
  final String? notes;

  MeditationSessionModel({
    required this.id,
    required this.type,
    required this.startTime,
    this.durationMinutes = 10,
    this.isCompleted = false,
    this.notes,
  });

  String get typeLabel {
    switch (type) {
      case MeditationType.breathing:
        return 'Breathing';
      case MeditationType.guided:
        return 'Guided';
      case MeditationType.unguided:
        return 'Unguided';
      case MeditationType.sleep:
        return 'Sleep';
      case MeditationType.focus:
        return 'Focus';
    }
  }

  MeditationSessionModel copyWith({
    String? id,
    MeditationType? type,
    DateTime? startTime,
    int? durationMinutes,
    bool? isCompleted,
    String? notes,
  }) {
    return MeditationSessionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }
}
