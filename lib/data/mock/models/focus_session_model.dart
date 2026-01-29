import 'package:hive/hive.dart';

part 'focus_session_model.g.dart';

@HiveType(typeId: 8)
class FocusSessionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  final DateTime? endTime;

  @HiveField(3)
  final int durationMinutes;

  @HiveField(4)
  final bool isCompleted;

  @HiveField(5)
  final String? task;

  FocusSessionModel({
    required this.id,
    required this.startTime,
    this.endTime,
    this.durationMinutes = 25,
    this.isCompleted = false,
    this.task,
  });

  FocusSessionModel copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    bool? isCompleted,
    String? task,
  }) {
    return FocusSessionModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      task: task ?? this.task,
    );
  }
}
