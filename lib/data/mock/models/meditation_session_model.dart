enum MeditationType { breathing, guided, unguided, sleep, focus }

/// Goal settings for meditation tracking
class MeditationGoal {
  final int dailyMinutesGoal;
  final int weeklySessionsGoal;

  const MeditationGoal({
    this.dailyMinutesGoal = 10,
    this.weeklySessionsGoal = 7,
  });

  MeditationGoal copyWith({
    int? dailyMinutesGoal,
    int? weeklySessionsGoal,
  }) {
    return MeditationGoal(
      dailyMinutesGoal: dailyMinutesGoal ?? this.dailyMinutesGoal,
      weeklySessionsGoal: weeklySessionsGoal ?? this.weeklySessionsGoal,
    );
  }
}

/// Statistics for meditation tracking
class MeditationStats {
  final int weeklyMinutes;
  final int weeklySessions;
  final int currentStreak;
  final int bestStreak;
  final double goalCompletionRate;
  final Map<MeditationType, int> sessionsByType;

  const MeditationStats({
    this.weeklyMinutes = 0,
    this.weeklySessions = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.goalCompletionRate = 0.0,
    this.sessionsByType = const {},
  });
}

class MeditationSessionModel {
  final String id;
  final MeditationType type;
  final DateTime startTime;
  final int durationMinutes;
  final bool isCompleted;
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
