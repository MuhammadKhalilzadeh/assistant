enum MoodLevel {
  great,
  good,
  okay,
  bad,
  awful;

  String get emoji {
    switch (this) {
      case MoodLevel.great: return '😄';
      case MoodLevel.good: return '🙂';
      case MoodLevel.okay: return '😐';
      case MoodLevel.bad: return '😔';
      case MoodLevel.awful: return '😢';
    }
  }

  String get label {
    switch (this) {
      case MoodLevel.great: return 'Great';
      case MoodLevel.good: return 'Good';
      case MoodLevel.okay: return 'Okay';
      case MoodLevel.bad: return 'Bad';
      case MoodLevel.awful: return 'Awful';
    }
  }
}

class MoodEntryModel {
  final String id;
  final MoodLevel mood;
  final DateTime recordedAt;
  final String? notes;
  final List<String> activities;
  final DateTime createdAt;

  MoodEntryModel({
    required this.id,
    required this.mood,
    required this.recordedAt,
    this.notes,
    this.activities = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get moodEmoji => mood.emoji;
  String get moodLabel => mood.label;

  MoodEntryModel copyWith({
    String? id,
    MoodLevel? mood,
    DateTime? recordedAt,
    String? notes,
    List<String>? activities,
    DateTime? createdAt,
  }) {
    return MoodEntryModel(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      recordedAt: recordedAt ?? this.recordedAt,
      notes: notes ?? this.notes,
      activities: activities ?? this.activities,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory MoodEntryModel.fromJson(Map<String, dynamic> json) {
    return MoodEntryModel(
      id: json['id'] as String,
      mood: MoodLevel.values.firstWhere(
        (m) => m.name == json['mood'],
        orElse: () => MoodLevel.okay,
      ),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      notes: json['notes'] as String?,
      activities: (json['activities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mood': mood.name,
      'recordedAt': recordedAt.toIso8601String(),
      'notes': notes,
      'activities': activities,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'mood': mood.name,
      'notes': notes,
      'activities': activities,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'mood': mood.name,
      'notes': notes,
      'activities': activities,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }
}

class MoodGoal {
  final String id;
  final int dailyEntriesGoal;
  final String targetMood;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MoodGoal({
    required this.id,
    this.dailyEntriesGoal = 1,
    this.targetMood = 'good',
    required this.createdAt,
    required this.updatedAt,
  });

  MoodGoal copyWith({
    String? id,
    int? dailyEntriesGoal,
    String? targetMood,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoodGoal(
      id: id ?? this.id,
      dailyEntriesGoal: dailyEntriesGoal ?? this.dailyEntriesGoal,
      targetMood: targetMood ?? this.targetMood,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory MoodGoal.fromJson(Map<String, dynamic> json) {
    return MoodGoal(
      id: json['id'] as String,
      dailyEntriesGoal: json['dailyEntriesGoal'] as int? ?? 1,
      targetMood: json['targetMood'] as String? ?? 'good',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dailyEntriesGoal': dailyEntriesGoal,
      'targetMood': targetMood,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'dailyEntriesGoal': dailyEntriesGoal,
      'targetMood': targetMood,
    };
  }
}

class MoodStats {
  final double weeklyAverageMood;
  final int currentStreak;
  final int bestStreak;
  final int totalEntries;
  final Map<String, int> moodDistribution;
  final Map<String, int> commonActivities;

  const MoodStats({
    this.weeklyAverageMood = 0.0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalEntries = 0,
    this.moodDistribution = const {},
    this.commonActivities = const {},
  });

  factory MoodStats.fromJson(Map<String, dynamic> json) {
    return MoodStats(
      weeklyAverageMood: (json['weeklyAverageMood'] as num?)?.toDouble() ?? 0.0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      totalEntries: json['totalEntries'] as int? ?? 0,
      moodDistribution: (json['moodDistribution'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ?? {},
      commonActivities: (json['commonActivities'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weeklyAverageMood': weeklyAverageMood,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalEntries': totalEntries,
      'moodDistribution': moodDistribution,
      'commonActivities': commonActivities,
    };
  }

  static MoodStats empty() => const MoodStats();
}

class MoodDailySummary {
  final DateTime date;
  final int entries;
  final String? dominantMood;
  final bool hasEntry;

  const MoodDailySummary({
    required this.date,
    required this.entries,
    this.dominantMood,
    required this.hasEntry,
  });

  factory MoodDailySummary.fromJson(Map<String, dynamic> json) {
    return MoodDailySummary(
      date: DateTime.parse(json['date'] as String),
      entries: json['entries'] as int,
      dominantMood: json['dominantMood'] as String?,
      hasEntry: json['hasEntry'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'entries': entries,
      'dominantMood': dominantMood,
      'hasEntry': hasEntry,
    };
  }
}
