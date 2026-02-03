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
  final DateTime createdAt;

  WaterLogModel({
    required this.id,
    required this.amountMl,
    required this.loggedAt,
    this.beverageType = BeverageType.water,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  WaterLogModel copyWith({
    String? id,
    int? amountMl,
    DateTime? loggedAt,
    BeverageType? beverageType,
    String? note,
    DateTime? createdAt,
  }) {
    return WaterLogModel(
      id: id ?? this.id,
      amountMl: amountMl ?? this.amountMl,
      loggedAt: loggedAt ?? this.loggedAt,
      beverageType: beverageType ?? this.beverageType,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory WaterLogModel.fromJson(Map<String, dynamic> json) {
    return WaterLogModel(
      id: json['id'] as String,
      amountMl: json['amountMl'] as int,
      loggedAt: DateTime.parse(json['loggedAt'] as String),
      beverageType: BeverageType.values.firstWhere(
        (b) => b.name == json['beverageType'],
        orElse: () => BeverageType.water,
      ),
      note: json['note'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amountMl': amountMl,
      'loggedAt': loggedAt.toIso8601String(),
      'beverageType': beverageType.name,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// JSON for creating a new water log (without server-managed fields)
  Map<String, dynamic> toCreateJson() {
    return {
      'amountMl': amountMl,
      'beverageType': beverageType.name,
      'note': note,
      'loggedAt': loggedAt.toIso8601String(),
    };
  }

  /// JSON for updating an existing water log
  Map<String, dynamic> toUpdateJson() {
    return {
      'amountMl': amountMl,
      'beverageType': beverageType.name,
      'note': note,
      'loggedAt': loggedAt.toIso8601String(),
    };
  }
}

/// Hydration goal configuration
class HydrationGoal {
  final String id;
  final int dailyGoalMl;
  final int reminderIntervalMinutes;
  final bool remindersEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HydrationGoal({
    required this.id,
    this.dailyGoalMl = 3000,
    this.reminderIntervalMinutes = 60,
    this.remindersEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  HydrationGoal copyWith({
    String? id,
    int? dailyGoalMl,
    int? reminderIntervalMinutes,
    bool? remindersEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HydrationGoal(
      id: id ?? this.id,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      reminderIntervalMinutes: reminderIntervalMinutes ?? this.reminderIntervalMinutes,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory HydrationGoal.fromJson(Map<String, dynamic> json) {
    return HydrationGoal(
      id: json['id'] as String,
      dailyGoalMl: json['dailyGoalMl'] as int? ?? 3000,
      reminderIntervalMinutes: json['reminderIntervalMinutes'] as int? ?? 60,
      remindersEnabled: json['remindersEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dailyGoalMl': dailyGoalMl,
      'reminderIntervalMinutes': reminderIntervalMinutes,
      'remindersEnabled': remindersEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// JSON for updating the goal
  Map<String, dynamic> toUpdateJson() {
    return {
      'dailyGoalMl': dailyGoalMl,
      'reminderIntervalMinutes': reminderIntervalMinutes,
      'remindersEnabled': remindersEnabled,
    };
  }
}

/// Water hydration statistics
class WaterStats {
  final int todayIntakeMl;
  final int dailyGoalMl;
  final int weeklyAverageMl;
  final int currentStreak;
  final int bestStreak;
  final double goalCompletionRate;

  const WaterStats({
    required this.todayIntakeMl,
    required this.dailyGoalMl,
    required this.weeklyAverageMl,
    required this.currentStreak,
    required this.bestStreak,
    required this.goalCompletionRate,
  });

  factory WaterStats.fromJson(Map<String, dynamic> json) {
    return WaterStats(
      todayIntakeMl: json['todayIntakeMl'] as int,
      dailyGoalMl: json['dailyGoalMl'] as int,
      weeklyAverageMl: json['weeklyAverageMl'] as int,
      currentStreak: json['currentStreak'] as int,
      bestStreak: json['bestStreak'] as int,
      goalCompletionRate: (json['goalCompletionRate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayIntakeMl': todayIntakeMl,
      'dailyGoalMl': dailyGoalMl,
      'weeklyAverageMl': weeklyAverageMl,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'goalCompletionRate': goalCompletionRate,
    };
  }

  double get progress => dailyGoalMl > 0 ? (todayIntakeMl / dailyGoalMl) : 0.0;
  bool get goalMet => todayIntakeMl >= dailyGoalMl;

  static WaterStats empty() {
    return const WaterStats(
      todayIntakeMl: 0,
      dailyGoalMl: 3000,
      weeklyAverageMl: 0,
      currentStreak: 0,
      bestStreak: 0,
      goalCompletionRate: 0.0,
    );
  }
}

/// Daily hydration summary for history chart
class DailySummary {
  final DateTime date;
  final int totalMl;
  final int goalMl;
  final bool goalMet;
  final int logCount;

  const DailySummary({
    required this.date,
    required this.totalMl,
    required this.goalMl,
    required this.goalMet,
    required this.logCount,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      date: DateTime.parse(json['date'] as String),
      totalMl: json['totalMl'] as int,
      goalMl: json['goalMl'] as int,
      goalMet: json['goalMet'] as bool,
      logCount: json['logCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'totalMl': totalMl,
      'goalMl': goalMl,
      'goalMet': goalMet,
      'logCount': logCount,
    };
  }

  double get progress => goalMl > 0 ? (totalMl / goalMl).clamp(0.0, 1.5) : 0.0;
}
