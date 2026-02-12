enum MeditationType {
  breathing,
  guided,
  unguided,
  sleep,
  focus;

  String get label {
    switch (this) {
      case MeditationType.breathing: return 'Breathing';
      case MeditationType.guided: return 'Guided';
      case MeditationType.unguided: return 'Unguided';
      case MeditationType.sleep: return 'Sleep';
      case MeditationType.focus: return 'Focus';
    }
  }
}

class MeditationSessionModel {
  final String id;
  final MeditationType type;
  final DateTime startTime;
  final int durationMinutes;
  final bool isCompleted;
  final String? notes;
  final DateTime createdAt;

  MeditationSessionModel({
    required this.id,
    required this.type,
    required this.startTime,
    this.durationMinutes = 10,
    this.isCompleted = false,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get typeLabel => type.label;

  MeditationSessionModel copyWith({
    String? id,
    MeditationType? type,
    DateTime? startTime,
    int? durationMinutes,
    bool? isCompleted,
    String? notes,
    DateTime? createdAt,
  }) {
    return MeditationSessionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory MeditationSessionModel.fromJson(Map<String, dynamic> json) {
    return MeditationSessionModel(
      id: json['id'] as String,
      type: MeditationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => MeditationType.breathing,
      ),
      startTime: DateTime.parse(json['startTime'] as String),
      durationMinutes: json['durationMinutes'] as int? ?? 10,
      isCompleted: json['isCompleted'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'startTime': startTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'type': type.name,
      'startTime': startTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'type': type.name,
      'startTime': startTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }
}

class MeditationGoal {
  final String id;
  final int dailyMinutesGoal;
  final int weeklySessionsGoal;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MeditationGoal({
    required this.id,
    this.dailyMinutesGoal = 10,
    this.weeklySessionsGoal = 7,
    required this.createdAt,
    required this.updatedAt,
  });

  MeditationGoal copyWith({
    String? id,
    int? dailyMinutesGoal,
    int? weeklySessionsGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MeditationGoal(
      id: id ?? this.id,
      dailyMinutesGoal: dailyMinutesGoal ?? this.dailyMinutesGoal,
      weeklySessionsGoal: weeklySessionsGoal ?? this.weeklySessionsGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory MeditationGoal.fromJson(Map<String, dynamic> json) {
    return MeditationGoal(
      id: json['id'] as String,
      dailyMinutesGoal: json['dailyMinutesGoal'] as int? ?? 10,
      weeklySessionsGoal: json['weeklySessionsGoal'] as int? ?? 7,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dailyMinutesGoal': dailyMinutesGoal,
      'weeklySessionsGoal': weeklySessionsGoal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'dailyMinutesGoal': dailyMinutesGoal,
      'weeklySessionsGoal': weeklySessionsGoal,
    };
  }
}

class MeditationStats {
  final int weeklyMinutes;
  final int weeklySessions;
  final int currentStreak;
  final int bestStreak;
  final double goalCompletionRate;
  final Map<String, int> sessionsByType;
  final int todayMinutes;

  const MeditationStats({
    this.weeklyMinutes = 0,
    this.weeklySessions = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.goalCompletionRate = 0.0,
    this.sessionsByType = const {},
    this.todayMinutes = 0,
  });

  factory MeditationStats.fromJson(Map<String, dynamic> json) {
    return MeditationStats(
      weeklyMinutes: json['weeklyMinutes'] as int? ?? 0,
      weeklySessions: json['weeklySessions'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      goalCompletionRate: (json['goalCompletionRate'] as num?)?.toDouble() ?? 0.0,
      sessionsByType: (json['sessionsByType'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ?? {},
      todayMinutes: json['todayMinutes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weeklyMinutes': weeklyMinutes,
      'weeklySessions': weeklySessions,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'goalCompletionRate': goalCompletionRate,
      'sessionsByType': sessionsByType,
      'todayMinutes': todayMinutes,
    };
  }

  static MeditationStats empty() => const MeditationStats();
}

class MeditationDailySummary {
  final DateTime date;
  final int totalMinutes;
  final int sessionCount;
  final int goalMinutes;
  final bool goalMet;

  const MeditationDailySummary({
    required this.date,
    required this.totalMinutes,
    required this.sessionCount,
    required this.goalMinutes,
    required this.goalMet,
  });

  factory MeditationDailySummary.fromJson(Map<String, dynamic> json) {
    return MeditationDailySummary(
      date: DateTime.parse(json['date'] as String),
      totalMinutes: json['totalMinutes'] as int,
      sessionCount: json['sessionCount'] as int,
      goalMinutes: json['goalMinutes'] as int,
      goalMet: json['goalMet'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'totalMinutes': totalMinutes,
      'sessionCount': sessionCount,
      'goalMinutes': goalMinutes,
      'goalMet': goalMet,
    };
  }

  double get progress => goalMinutes > 0 ? (totalMinutes / goalMinutes).clamp(0.0, 1.5) : 0.0;
}
