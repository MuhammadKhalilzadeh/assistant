enum SleepQuality { poor, fair, good, excellent }

class SleepRecordModel {
  final String id;
  final DateTime bedTime;
  final DateTime wakeTime;
  final SleepQuality quality;
  final String? notes;

  SleepRecordModel({
    required this.id,
    required this.bedTime,
    required this.wakeTime,
    this.quality = SleepQuality.good,
    this.notes,
  });

  Duration get duration => wakeTime.difference(bedTime);

  double get durationHours => duration.inMinutes / 60.0;

  SleepRecordModel copyWith({
    String? id,
    DateTime? bedTime,
    DateTime? wakeTime,
    SleepQuality? quality,
    String? notes,
  }) {
    return SleepRecordModel(
      id: id ?? this.id,
      bedTime: bedTime ?? this.bedTime,
      wakeTime: wakeTime ?? this.wakeTime,
      quality: quality ?? this.quality,
      notes: notes ?? this.notes,
    );
  }
}

/// Sleep goal settings
class SleepGoal {
  final int goalMinutes; // Default 8 hours = 480 minutes

  const SleepGoal({
    this.goalMinutes = 480,
  });

  double get goalHours => goalMinutes / 60.0;

  SleepGoal copyWith({
    int? goalMinutes,
  }) {
    return SleepGoal(
      goalMinutes: goalMinutes ?? this.goalMinutes,
    );
  }
}

/// Weekly sleep statistics
class SleepStats {
  final double weeklyAverageHours;
  final int currentStreak;
  final int bestStreak;
  final double goalCompletionRate;
  final Map<SleepQuality, int> qualityDistribution;

  const SleepStats({
    this.weeklyAverageHours = 0.0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.goalCompletionRate = 0.0,
    this.qualityDistribution = const {},
  });
}
