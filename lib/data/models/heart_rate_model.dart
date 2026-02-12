enum HeartRateZone {
  resting,
  warmUp,
  fatBurn,
  cardio,
  peak;

  String get label {
    switch (this) {
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
}

class HeartRateRecordModel {
  final String id;
  final int bpm;
  final DateTime recordedAt;
  final HeartRateZone zone;
  final DateTime createdAt;

  HeartRateRecordModel({
    required this.id,
    required this.bpm,
    required this.recordedAt,
    HeartRateZone? zone,
    DateTime? createdAt,
  })  : zone = zone ?? _calculateZone(bpm),
        createdAt = createdAt ?? DateTime.now();

  static HeartRateZone _calculateZone(int bpm) {
    if (bpm < 60) return HeartRateZone.resting;
    if (bpm < 100) return HeartRateZone.warmUp;
    if (bpm < 140) return HeartRateZone.fatBurn;
    if (bpm < 170) return HeartRateZone.cardio;
    return HeartRateZone.peak;
  }

  String get zoneLabel => zone.label;

  HeartRateRecordModel copyWith({
    String? id,
    int? bpm,
    DateTime? recordedAt,
    HeartRateZone? zone,
    DateTime? createdAt,
  }) {
    return HeartRateRecordModel(
      id: id ?? this.id,
      bpm: bpm ?? this.bpm,
      recordedAt: recordedAt ?? this.recordedAt,
      zone: zone ?? this.zone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory HeartRateRecordModel.fromJson(Map<String, dynamic> json) {
    return HeartRateRecordModel(
      id: json['id'] as String,
      bpm: json['bpm'] as int,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      zone: HeartRateZone.values.firstWhere(
        (z) => z.name == json['zone'],
        orElse: () => HeartRateZone.resting,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bpm': bpm,
      'recordedAt': recordedAt.toIso8601String(),
      'zone': zone.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'bpm': bpm,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'bpm': bpm,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }
}

class HeartRateGoal {
  final String id;
  final int targetRestingBpm;
  final int maxBpm;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HeartRateGoal({
    required this.id,
    this.targetRestingBpm = 65,
    this.maxBpm = 180,
    required this.createdAt,
    required this.updatedAt,
  });

  HeartRateGoal copyWith({
    String? id,
    int? targetRestingBpm,
    int? maxBpm,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HeartRateGoal(
      id: id ?? this.id,
      targetRestingBpm: targetRestingBpm ?? this.targetRestingBpm,
      maxBpm: maxBpm ?? this.maxBpm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory HeartRateGoal.fromJson(Map<String, dynamic> json) {
    return HeartRateGoal(
      id: json['id'] as String,
      targetRestingBpm: json['targetRestingBpm'] as int? ?? 65,
      maxBpm: json['maxBpm'] as int? ?? 180,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'targetRestingBpm': targetRestingBpm,
      'maxBpm': maxBpm,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'targetRestingBpm': targetRestingBpm,
      'maxBpm': maxBpm,
    };
  }
}

class HeartRateStats {
  final double averageRestingBpm;
  final double averageActiveBpm;
  final int minBpm;
  final int maxBpm;
  final int currentStreak;
  final int bestStreak;
  final int totalReadings;
  final Map<String, int> zoneDistribution;

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

  factory HeartRateStats.fromJson(Map<String, dynamic> json) {
    return HeartRateStats(
      averageRestingBpm: (json['averageRestingBpm'] as num?)?.toDouble() ?? 0.0,
      averageActiveBpm: (json['averageActiveBpm'] as num?)?.toDouble() ?? 0.0,
      minBpm: json['minBpm'] as int? ?? 0,
      maxBpm: json['maxBpm'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      totalReadings: json['totalReadings'] as int? ?? 0,
      zoneDistribution: (json['zoneDistribution'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageRestingBpm': averageRestingBpm,
      'averageActiveBpm': averageActiveBpm,
      'minBpm': minBpm,
      'maxBpm': maxBpm,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalReadings': totalReadings,
      'zoneDistribution': zoneDistribution,
    };
  }

  static HeartRateStats empty() => const HeartRateStats();
}

class HeartRateDailySummary {
  final DateTime date;
  final int avgBpm;
  final int minBpm;
  final int maxBpm;
  final int readingCount;

  const HeartRateDailySummary({
    required this.date,
    required this.avgBpm,
    required this.minBpm,
    required this.maxBpm,
    required this.readingCount,
  });

  factory HeartRateDailySummary.fromJson(Map<String, dynamic> json) {
    return HeartRateDailySummary(
      date: DateTime.parse(json['date'] as String),
      avgBpm: json['avgBpm'] as int,
      minBpm: json['minBpm'] as int,
      maxBpm: json['maxBpm'] as int,
      readingCount: json['readingCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'avgBpm': avgBpm,
      'minBpm': minBpm,
      'maxBpm': maxBpm,
      'readingCount': readingCount,
    };
  }
}
