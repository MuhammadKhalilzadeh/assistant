/// Beverage type enum for different drink types
enum BeverageType {
  water,
  coffee,
  tea,
  juice,
  milk,
  other;

  String get displayName {
    switch (this) {
      case BeverageType.water:
        return 'Water';
      case BeverageType.coffee:
        return 'Coffee';
      case BeverageType.tea:
        return 'Tea';
      case BeverageType.juice:
        return 'Juice';
      case BeverageType.milk:
        return 'Milk';
      case BeverageType.other:
        return 'Other';
    }
  }

  String get iconName {
    switch (this) {
      case BeverageType.water:
        return 'water_drop';
      case BeverageType.coffee:
        return 'coffee';
      case BeverageType.tea:
        return 'emoji_food_beverage';
      case BeverageType.juice:
        return 'local_bar';
      case BeverageType.milk:
        return 'local_cafe';
      case BeverageType.other:
        return 'local_drink';
    }
  }
}

class WaterLogModel {
  final String id;
  final int amountMl;
  final DateTime loggedAt;
  final BeverageType beverageType;
  final String? note;

  WaterLogModel({
    required this.id,
    required this.amountMl,
    required this.loggedAt,
    this.beverageType = BeverageType.water,
    this.note,
  });

  WaterLogModel copyWith({
    String? id,
    int? amountMl,
    DateTime? loggedAt,
    BeverageType? beverageType,
    String? note,
  }) {
    return WaterLogModel(
      id: id ?? this.id,
      amountMl: amountMl ?? this.amountMl,
      loggedAt: loggedAt ?? this.loggedAt,
      beverageType: beverageType ?? this.beverageType,
      note: note ?? this.note,
    );
  }
}

/// Hydration goal configuration
class HydrationGoal {
  final int dailyGoalMl;
  final int reminderIntervalMinutes;
  final bool remindersEnabled;

  const HydrationGoal({
    this.dailyGoalMl = 3000,
    this.reminderIntervalMinutes = 60,
    this.remindersEnabled = true,
  });

  HydrationGoal copyWith({
    int? dailyGoalMl,
    int? reminderIntervalMinutes,
    bool? remindersEnabled,
  }) {
    return HydrationGoal(
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      reminderIntervalMinutes: reminderIntervalMinutes ?? this.reminderIntervalMinutes,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    );
  }
}

/// Weekly hydration statistics
class HydrationStats {
  final double weeklyAverageMl;
  final int currentStreak;
  final int bestStreak;
  final double goalCompletionRate;

  const HydrationStats({
    required this.weeklyAverageMl,
    required this.currentStreak,
    required this.bestStreak,
    required this.goalCompletionRate,
  });
}

/// Daily hydration summary
class DailyHydrationSummary {
  final DateTime date;
  final int totalMl;
  final int goalMl;
  final List<WaterLogModel> logs;

  const DailyHydrationSummary({
    required this.date,
    required this.totalMl,
    required this.goalMl,
    required this.logs,
  });

  bool get goalMet => totalMl >= goalMl;
  double get progress => goalMl > 0 ? (totalMl / goalMl).clamp(0.0, 1.5) : 0.0;
}
