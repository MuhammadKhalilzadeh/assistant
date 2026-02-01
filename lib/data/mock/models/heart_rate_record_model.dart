enum HeartRateZone { resting, warmUp, fatBurn, cardio, peak }

/// Goal settings for heart rate tracking
class HeartRateGoal {
  final int targetRestingBpm;
  final int maxBpm;

  const HeartRateGoal({
    this.targetRestingBpm = 65,
    this.maxBpm = 180,
  });

  HeartRateGoal copyWith({
    int? targetRestingBpm,
    int? maxBpm,
  }) {
    return HeartRateGoal(
      targetRestingBpm: targetRestingBpm ?? this.targetRestingBpm,
      maxBpm: maxBpm ?? this.maxBpm,
    );
  }
}

/// Statistics for heart rate tracking
class HeartRateStats {
  final double averageRestingBpm;
  final double averageActiveBpm;
  final int minBpm;
  final int maxBpm;
  final int currentStreak;
  final int bestStreak;
  final int totalReadings;
  final Map<HeartRateZone, int> zoneDistribution;

  const HeartRateStats({
    this.averageRestingBpm = 0.0,
    this.averageActiveBpm = 0.0,
    this.minBpm = 0,
    this.maxBpm = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalReadings = 0,
    this.zoneDistribution = const {},
  });
}

class HeartRateRecordModel {
  final String id;
  final int bpm;
  final DateTime recordedAt;
  final HeartRateZone zone;

  HeartRateRecordModel({
    required this.id,
    required this.bpm,
    required this.recordedAt,
    HeartRateZone? zone,
  }) : zone = zone ?? _calculateZone(bpm);

  static HeartRateZone _calculateZone(int bpm) {
    if (bpm < 60) return HeartRateZone.resting;
    if (bpm < 100) return HeartRateZone.warmUp;
    if (bpm < 140) return HeartRateZone.fatBurn;
    if (bpm < 170) return HeartRateZone.cardio;
    return HeartRateZone.peak;
  }

  String get zoneLabel {
    switch (zone) {
      case HeartRateZone.resting:
        return 'Resting';
      case HeartRateZone.warmUp:
        return 'Warm Up';
      case HeartRateZone.fatBurn:
        return 'Fat Burn';
      case HeartRateZone.cardio:
        return 'Cardio';
      case HeartRateZone.peak:
        return 'Peak';
    }
  }

  HeartRateRecordModel copyWith({
    String? id,
    int? bpm,
    DateTime? recordedAt,
    HeartRateZone? zone,
  }) {
    return HeartRateRecordModel(
      id: id ?? this.id,
      bpm: bpm ?? this.bpm,
      recordedAt: recordedAt ?? this.recordedAt,
      zone: zone ?? this.zone,
    );
  }
}
