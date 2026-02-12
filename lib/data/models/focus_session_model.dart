enum FocusSessionType {
  focus,
  shortBreak,
  longBreak;

  String get apiValue {
    switch (this) {
      case FocusSessionType.focus: return 'focus';
      case FocusSessionType.shortBreak: return 'short_break';
      case FocusSessionType.longBreak: return 'long_break';
    }
  }

  String get label {
    switch (this) {
      case FocusSessionType.focus: return 'Focus';
      case FocusSessionType.shortBreak: return 'Short Break';
      case FocusSessionType.longBreak: return 'Long Break';
    }
  }

  static FocusSessionType fromApiValue(String value) {
    switch (value) {
      case 'focus': return FocusSessionType.focus;
      case 'short_break': return FocusSessionType.shortBreak;
      case 'long_break': return FocusSessionType.longBreak;
      default: return FocusSessionType.focus;
    }
  }
}

class FocusSessionModel {
  final String id;
  final FocusSessionType type;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final bool isCompleted;
  final String? task;
  final DateTime createdAt;

  FocusSessionModel({
    required this.id,
    required this.type,
    required this.startTime,
    this.endTime,
    this.durationMinutes = 25,
    this.isCompleted = false,
    this.task,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get typeLabel => type.label;

  FocusSessionModel copyWith({
    String? id,
    FocusSessionType? type,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    bool? isCompleted,
    String? task,
    DateTime? createdAt,
  }) {
    return FocusSessionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      task: task ?? this.task,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory FocusSessionModel.fromJson(Map<String, dynamic> json) {
    return FocusSessionModel(
      id: json['id'] as String,
      type: FocusSessionType.fromApiValue(json['type'] as String? ?? 'focus'),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      durationMinutes: json['durationMinutes'] as int? ?? 25,
      isCompleted: json['isCompleted'] as bool? ?? false,
      task: json['task'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.apiValue,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted,
      'task': task,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'type': type.apiValue,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted,
      'task': task,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'type': type.apiValue,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted,
      'task': task,
    };
  }
}

class FocusTimerGoal {
  final String id;
  final int dailyGoalSessions;
  final int focusDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final int sessionsBeforeLongBreak;
  final bool autoStartBreaks;
  final bool autoStartFocus;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FocusTimerGoal({
    required this.id,
    this.dailyGoalSessions = 8,
    this.focusDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.sessionsBeforeLongBreak = 4,
    this.autoStartBreaks = false,
    this.autoStartFocus = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  FocusTimerGoal copyWith({
    String? id,
    int? dailyGoalSessions,
    int? focusDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? sessionsBeforeLongBreak,
    bool? autoStartBreaks,
    bool? autoStartFocus,
    bool? soundEnabled,
    bool? vibrationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FocusTimerGoal(
      id: id ?? this.id,
      dailyGoalSessions: dailyGoalSessions ?? this.dailyGoalSessions,
      focusDuration: focusDuration ?? this.focusDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      sessionsBeforeLongBreak: sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartFocus: autoStartFocus ?? this.autoStartFocus,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory FocusTimerGoal.fromJson(Map<String, dynamic> json) {
    return FocusTimerGoal(
      id: json['id'] as String,
      dailyGoalSessions: json['dailyGoalSessions'] as int? ?? 8,
      focusDuration: json['focusDuration'] as int? ?? 25,
      shortBreakDuration: json['shortBreakDuration'] as int? ?? 5,
      longBreakDuration: json['longBreakDuration'] as int? ?? 15,
      sessionsBeforeLongBreak: json['sessionsBeforeLongBreak'] as int? ?? 4,
      autoStartBreaks: json['autoStartBreaks'] as bool? ?? false,
      autoStartFocus: json['autoStartFocus'] as bool? ?? false,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dailyGoalSessions': dailyGoalSessions,
      'focusDuration': focusDuration,
      'shortBreakDuration': shortBreakDuration,
      'longBreakDuration': longBreakDuration,
      'sessionsBeforeLongBreak': sessionsBeforeLongBreak,
      'autoStartBreaks': autoStartBreaks,
      'autoStartFocus': autoStartFocus,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'dailyGoalSessions': dailyGoalSessions,
      'focusDuration': focusDuration,
      'shortBreakDuration': shortBreakDuration,
      'longBreakDuration': longBreakDuration,
      'sessionsBeforeLongBreak': sessionsBeforeLongBreak,
      'autoStartBreaks': autoStartBreaks,
      'autoStartFocus': autoStartFocus,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }
}

class FocusTimerStats {
  final int todaySessions;
  final int todayMinutes;
  final int weeklySessions;
  final int weeklyMinutes;
  final int currentStreak;
  final int bestStreak;
  final double goalCompletionRate;
  final Map<String, int> sessionsByType;

  const FocusTimerStats({
    this.todaySessions = 0,
    this.todayMinutes = 0,
    this.weeklySessions = 0,
    this.weeklyMinutes = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.goalCompletionRate = 0.0,
    this.sessionsByType = const {},
  });

  factory FocusTimerStats.fromJson(Map<String, dynamic> json) {
    return FocusTimerStats(
      todaySessions: json['todaySessions'] as int? ?? 0,
      todayMinutes: json['todayMinutes'] as int? ?? 0,
      weeklySessions: json['weeklySessions'] as int? ?? 0,
      weeklyMinutes: json['weeklyMinutes'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      goalCompletionRate: (json['goalCompletionRate'] as num?)?.toDouble() ?? 0.0,
      sessionsByType: (json['sessionsByType'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todaySessions': todaySessions,
      'todayMinutes': todayMinutes,
      'weeklySessions': weeklySessions,
      'weeklyMinutes': weeklyMinutes,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'goalCompletionRate': goalCompletionRate,
      'sessionsByType': sessionsByType,
    };
  }

  static FocusTimerStats empty() => const FocusTimerStats();
}

class FocusTimerDailySummary {
  final DateTime date;
  final int totalMinutes;
  final int sessionCount;
  final int goalSessions;
  final bool goalMet;

  const FocusTimerDailySummary({
    required this.date,
    required this.totalMinutes,
    required this.sessionCount,
    required this.goalSessions,
    required this.goalMet,
  });

  factory FocusTimerDailySummary.fromJson(Map<String, dynamic> json) {
    return FocusTimerDailySummary(
      date: DateTime.parse(json['date'] as String),
      totalMinutes: json['totalMinutes'] as int,
      sessionCount: json['sessionCount'] as int,
      goalSessions: json['goalSessions'] as int,
      goalMet: json['goalMet'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'totalMinutes': totalMinutes,
      'sessionCount': sessionCount,
      'goalSessions': goalSessions,
      'goalMet': goalMet,
    };
  }

  double get progress => goalSessions > 0 ? (sessionCount / goalSessions).clamp(0.0, 1.5) : 0.0;
}
