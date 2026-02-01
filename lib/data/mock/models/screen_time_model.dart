/// Goal settings for screen time tracking
class ScreenTimeGoal {
  final int dailyLimitMinutes;

  const ScreenTimeGoal({
    this.dailyLimitMinutes = 180,
  });

  ScreenTimeGoal copyWith({
    int? dailyLimitMinutes,
  }) {
    return ScreenTimeGoal(
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
    );
  }
}

/// Statistics for screen time tracking
class ScreenTimeStats {
  final double dailyAverageMinutes;
  final double averagePickups;
  final int currentStreak;
  final int bestStreak;
  final double goalCompletionRate;
  final Map<String, int> appUsageBreakdown;

  const ScreenTimeStats({
    this.dailyAverageMinutes = 0.0,
    this.averagePickups = 0.0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.goalCompletionRate = 0.0,
    this.appUsageBreakdown = const {},
  });
}

class AppUsageModel {
  final String appName;
  final String category;
  final int minutesUsed;
  final String iconName;

  AppUsageModel({
    required this.appName,
    required this.category,
    required this.minutesUsed,
    this.iconName = 'apps',
  });
}

class ScreenTimeModel {
  final String id;
  final DateTime date;
  final int totalMinutes;
  final List<AppUsageModel> appUsage;
  final int pickups;

  ScreenTimeModel({
    required this.id,
    required this.date,
    required this.totalMinutes,
    this.appUsage = const [],
    this.pickups = 0,
  });

  String get formattedTime {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  ScreenTimeModel copyWith({
    String? id,
    DateTime? date,
    int? totalMinutes,
    List<AppUsageModel>? appUsage,
    int? pickups,
  }) {
    return ScreenTimeModel(
      id: id ?? this.id,
      date: date ?? this.date,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      appUsage: appUsage ?? this.appUsage,
      pickups: pickups ?? this.pickups,
    );
  }
}
