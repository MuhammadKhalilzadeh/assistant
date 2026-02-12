enum SleepQuality {
  poor,
  fair,
  good,
  excellent;

  String get label {
    switch (this) {
      case SleepQuality.poor: return 'Poor';
      case SleepQuality.fair: return 'Fair';
      case SleepQuality.good: return 'Good';
      case SleepQuality.excellent: return 'Excellent';
    }
  }
}

class SleepRecordModel {
  final String id;
  final DateTime bedTime;
  final DateTime wakeTime;
  final SleepQuality quality;
  final String? notes;
  final int durationMinutes;
  final DateTime createdAt;

  SleepRecordModel({
    required this.id,
    required this.bedTime,
    required this.wakeTime,
    this.quality = SleepQuality.good,
    this.notes,
    int? durationMinutes,
    DateTime? createdAt,
  })  : durationMinutes = durationMinutes ?? wakeTime.difference(bedTime).inMinutes,
        createdAt = createdAt ?? DateTime.now();

  Duration get duration => Duration(minutes: durationMinutes);
  double get durationHours => durationMinutes / 60.0;

  SleepRecordModel copyWith({
    String? id,
    DateTime? bedTime,
    DateTime? wakeTime,
    SleepQuality? quality,
    String? notes,
    int? durationMinutes,
    DateTime? createdAt,
  }) {
    return SleepRecordModel(
      id: id ?? this.id,
      bedTime: bedTime ?? this.bedTime,
      wakeTime: wakeTime ?? this.wakeTime,
      quality: quality ?? this.quality,
      notes: notes ?? this.notes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory SleepRecordModel.fromJson(Map<String, dynamic> json) {
    return SleepRecordModel(
      id: json['id'] as String,
      bedTime: DateTime.parse(json['bedTime'] as String),
      wakeTime: DateTime.parse(json['wakeTime'] as String),
      quality: SleepQuality.values.firstWhere(
        (q) => q.name == json['quality'],
        orElse: () => SleepQuality.good,
      ),
      notes: json['notes'] as String?,
      durationMinutes: json['durationMinutes'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bedTime': bedTime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'quality': quality.name,
      'notes': notes,
      'durationMinutes': durationMinutes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'bedTime': bedTime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'quality': quality.name,
      'notes': notes,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'bedTime': bedTime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'quality': quality.name,
      'notes': notes,
    };
  }
}

class SleepGoal {
  final String id;
  final int goalMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SleepGoal({
    required this.id,
    this.goalMinutes = 480,
    required this.createdAt,
    required this.updatedAt,
  });

  double get goalHours => goalMinutes / 60.0;

  SleepGoal copyWith({
    String? id,
    int? goalMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SleepGoal(
      id: id ?? this.id,
      goalMinutes: goalMinutes ?? this.goalMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory SleepGoal.fromJson(Map<String, dynamic> json) {
    return SleepGoal(
      id: json['id'] as String,
      goalMinutes: json['goalMinutes'] as int? ?? 480,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalMinutes': goalMinutes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'goalMinutes': goalMinutes,
    };
  }
}

class SleepStats {
  final double weeklyAverageHours;
  final int currentStreak;
  final int bestStreak;
  final double goalCompletionRate;
  final Map<String, int> qualityDistribution;
  final String? averageBedTime;
  final String? averageWakeTime;

  const SleepStats({
    this.weeklyAverageHours = 0.0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.goalCompletionRate = 0.0,
    this.qualityDistribution = const {},
    this.averageBedTime,
    this.averageWakeTime,
  });

  factory SleepStats.fromJson(Map<String, dynamic> json) {
    return SleepStats(
      weeklyAverageHours: (json['weeklyAverageHours'] as num?)?.toDouble() ?? 0.0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      goalCompletionRate: (json['goalCompletionRate'] as num?)?.toDouble() ?? 0.0,
      qualityDistribution: (json['qualityDistribution'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ?? {},
      averageBedTime: json['averageBedTime'] as String?,
      averageWakeTime: json['averageWakeTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weeklyAverageHours': weeklyAverageHours,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'goalCompletionRate': goalCompletionRate,
      'qualityDistribution': qualityDistribution,
      'averageBedTime': averageBedTime,
      'averageWakeTime': averageWakeTime,
    };
  }

  static SleepStats empty() => const SleepStats();
}

class SleepDailySummary {
  final DateTime date;
  final int durationMinutes;
  final String? quality;
  final int goalMinutes;
  final bool goalMet;

  const SleepDailySummary({
    required this.date,
    required this.durationMinutes,
    this.quality,
    required this.goalMinutes,
    required this.goalMet,
  });

  double get durationHours => durationMinutes / 60.0;
  double get progress => goalMinutes > 0 ? (durationMinutes / goalMinutes).clamp(0.0, 1.5) : 0.0;

  factory SleepDailySummary.fromJson(Map<String, dynamic> json) {
    return SleepDailySummary(
      date: DateTime.parse(json['date'] as String),
      durationMinutes: json['durationMinutes'] as int,
      quality: json['quality'] as String?,
      goalMinutes: json['goalMinutes'] as int,
      goalMet: json['goalMet'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'durationMinutes': durationMinutes,
      'quality': quality,
      'goalMinutes': goalMinutes,
      'goalMet': goalMet,
    };
  }
}
