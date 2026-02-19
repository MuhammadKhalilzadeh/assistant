/// App usage entry within a screen time record
class AppUsageEntry {
  final String id;
  final String appName;
  final String category;
  final int minutesUsed;
  final String iconName;

  const AppUsageEntry({
    required this.id,
    required this.appName,
    this.category = 'other',
    required this.minutesUsed,
    this.iconName = 'apps',
  });

  factory AppUsageEntry.fromJson(Map<String, dynamic> json) {
    return AppUsageEntry(
      id: json['id'] as String? ?? '',
      appName: json['appName'] as String,
      category: json['category'] as String? ?? 'other',
      minutesUsed: json['minutesUsed'] as int,
      iconName: json['iconName'] as String? ?? 'apps',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appName': appName,
      'category': category,
      'minutesUsed': minutesUsed,
      'iconName': iconName,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'appName': appName,
      'category': category,
      'minutesUsed': minutesUsed,
      'iconName': iconName,
    };
  }
}

/// A screen time record for a specific date
class ScreenTimeRecord {
  final String id;
  final DateTime date;
  final int totalMinutes;
  final int pickups;
  final String? note;
  final List<AppUsageEntry> appUsage;
  final DateTime createdAt;

  ScreenTimeRecord({
    required this.id,
    required this.date,
    required this.totalMinutes,
    this.pickups = 0,
    this.note,
    this.appUsage = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get formattedTime {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  ScreenTimeRecord copyWith({
    String? id,
    DateTime? date,
    int? totalMinutes,
    int? pickups,
    String? note,
    List<AppUsageEntry>? appUsage,
    DateTime? createdAt,
  }) {
    return ScreenTimeRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      pickups: pickups ?? this.pickups,
      note: note ?? this.note,
      appUsage: appUsage ?? this.appUsage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ScreenTimeRecord.fromJson(Map<String, dynamic> json) {
    return ScreenTimeRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      totalMinutes: json['totalMinutes'] as int,
      pickups: json['pickups'] as int? ?? 0,
      note: json['note'] as String?,
      appUsage: json['appUsage'] != null
          ? (json['appUsage'] as List)
              .map((e) => AppUsageEntry.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'totalMinutes': totalMinutes,
      'pickups': pickups,
      'note': note,
      'appUsage': appUsage.map((a) => a.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'totalMinutes': totalMinutes,
      'pickups': pickups,
      'note': note,
      'appUsage': appUsage.map((a) => a.toCreateJson()).toList(),
    };
  }
}

/// Screen time goal configuration
class ScreenTimeGoal {
  final String id;
  final int dailyLimitMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScreenTimeGoal({
    required this.id,
    this.dailyLimitMinutes = 180,
    required this.createdAt,
    required this.updatedAt,
  });

  ScreenTimeGoal copyWith({
    String? id,
    int? dailyLimitMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScreenTimeGoal(
      id: id ?? this.id,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ScreenTimeGoal.fromJson(Map<String, dynamic> json) {
    return ScreenTimeGoal(
      id: json['id'] as String,
      dailyLimitMinutes: json['dailyLimitMinutes'] as int? ?? 180,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dailyLimitMinutes': dailyLimitMinutes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'dailyLimitMinutes': dailyLimitMinutes,
    };
  }
}

/// Screen time statistics
class ScreenTimeStats {
  final int todayMinutes;
  final int todayPickups;
  final int dailyLimitMinutes;
  final double dailyAverageMinutes;
  final double averagePickups;
  final int currentStreak;
  final int bestStreak;
  final double goalCompletionRate;
  final Map<String, int> appUsageBreakdown;

  const ScreenTimeStats({
    required this.todayMinutes,
    required this.todayPickups,
    required this.dailyLimitMinutes,
    required this.dailyAverageMinutes,
    required this.averagePickups,
    required this.currentStreak,
    required this.bestStreak,
    required this.goalCompletionRate,
    required this.appUsageBreakdown,
  });

  factory ScreenTimeStats.fromJson(Map<String, dynamic> json) {
    final breakdown = json['appUsageBreakdown'] as Map<String, dynamic>? ?? {};
    return ScreenTimeStats(
      todayMinutes: json['todayMinutes'] as int? ?? 0,
      todayPickups: json['todayPickups'] as int? ?? 0,
      dailyLimitMinutes: json['dailyLimitMinutes'] as int? ?? 180,
      dailyAverageMinutes: (json['dailyAverageMinutes'] as num?)?.toDouble() ?? 0.0,
      averagePickups: (json['averagePickups'] as num?)?.toDouble() ?? 0.0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      goalCompletionRate: (json['goalCompletionRate'] as num?)?.toDouble() ?? 0.0,
      appUsageBreakdown: breakdown.map((k, v) => MapEntry(k, (v as num).toInt())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayMinutes': todayMinutes,
      'todayPickups': todayPickups,
      'dailyLimitMinutes': dailyLimitMinutes,
      'dailyAverageMinutes': dailyAverageMinutes,
      'averagePickups': averagePickups,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'goalCompletionRate': goalCompletionRate,
      'appUsageBreakdown': appUsageBreakdown,
    };
  }

  static ScreenTimeStats empty() {
    return const ScreenTimeStats(
      todayMinutes: 0,
      todayPickups: 0,
      dailyLimitMinutes: 180,
      dailyAverageMinutes: 0.0,
      averagePickups: 0.0,
      currentStreak: 0,
      bestStreak: 0,
      goalCompletionRate: 0.0,
      appUsageBreakdown: {},
    );
  }
}

/// Daily summary for screen time history
class ScreenTimeDailySummary {
  final DateTime date;
  final int totalMinutes;
  final int pickups;
  final int limitMinutes;
  final bool underLimit;

  const ScreenTimeDailySummary({
    required this.date,
    required this.totalMinutes,
    required this.pickups,
    required this.limitMinutes,
    required this.underLimit,
  });

  factory ScreenTimeDailySummary.fromJson(Map<String, dynamic> json) {
    return ScreenTimeDailySummary(
      date: DateTime.parse(json['date'] as String),
      totalMinutes: json['totalMinutes'] as int,
      pickups: json['pickups'] as int? ?? 0,
      limitMinutes: json['limitMinutes'] as int? ?? 180,
      underLimit: json['underLimit'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'totalMinutes': totalMinutes,
      'pickups': pickups,
      'limitMinutes': limitMinutes,
      'underLimit': underLimit,
    };
  }
}
