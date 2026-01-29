class FocusSessionModel {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final bool isCompleted;
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
