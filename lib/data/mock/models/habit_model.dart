/// Category types for habits
enum HabitCategory {
  health,
  fitness,
  mindfulness,
  learning,
  productivity,
  social,
  other,
}

extension HabitCategoryExtension on HabitCategory {
  String get label {
    switch (this) {
      case HabitCategory.health:
        return 'Health';
      case HabitCategory.fitness:
        return 'Fitness';
      case HabitCategory.mindfulness:
        return 'Mindfulness';
      case HabitCategory.learning:
        return 'Learning';
      case HabitCategory.productivity:
        return 'Productivity';
      case HabitCategory.social:
        return 'Social';
      case HabitCategory.other:
        return 'Other';
    }
  }

  /// Category color as hex string for serialization
  int get colorValue {
    switch (this) {
      case HabitCategory.health:
        return 0xFF10B981; // Emerald
      case HabitCategory.fitness:
        return 0xFFF59E0B; // Amber
      case HabitCategory.mindfulness:
        return 0xFF8B5CF6; // Purple
      case HabitCategory.learning:
        return 0xFF3B82F6; // Blue
      case HabitCategory.productivity:
        return 0xFF6366F1; // Indigo
      case HabitCategory.social:
        return 0xFFEC4899; // Pink
      case HabitCategory.other:
        return 0xFF64748B; // Slate
    }
  }

  String get iconName {
    switch (this) {
      case HabitCategory.health:
        return 'favorite';
      case HabitCategory.fitness:
        return 'fitness_center';
      case HabitCategory.mindfulness:
        return 'self_improvement';
      case HabitCategory.learning:
        return 'menu_book';
      case HabitCategory.productivity:
        return 'work';
      case HabitCategory.social:
        return 'people';
      case HabitCategory.other:
        return 'category';
    }
  }
}

/// Frequency options for habits
enum HabitFrequency {
  daily,
  weekdays,
  weekends,
  specificDays,
}

extension HabitFrequencyExtension on HabitFrequency {
  String get label {
    switch (this) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekdays:
        return 'Weekdays';
      case HabitFrequency.weekends:
        return 'Weekends';
      case HabitFrequency.specificDays:
        return 'Specific Days';
    }
  }

  String get description {
    switch (this) {
      case HabitFrequency.daily:
        return 'Every day';
      case HabitFrequency.weekdays:
        return 'Mon - Fri';
      case HabitFrequency.weekends:
        return 'Sat - Sun';
      case HabitFrequency.specificDays:
        return 'Custom schedule';
    }
  }

  /// Returns the target days for this frequency (0 = Monday, 6 = Sunday)
  List<int> get defaultTargetDays {
    switch (this) {
      case HabitFrequency.daily:
        return [0, 1, 2, 3, 4, 5, 6];
      case HabitFrequency.weekdays:
        return [0, 1, 2, 3, 4]; // Mon-Fri
      case HabitFrequency.weekends:
        return [5, 6]; // Sat-Sun
      case HabitFrequency.specificDays:
        return [];
    }
  }
}

class HabitModel {
  final String id;
  final String name;
  final String? description;
  final String icon; // Icon name string
  final int streak;
  final int bestStreak;
  final List<DateTime> completedDates;
  final bool isCompletedToday;
  final HabitCategory category;
  final HabitFrequency frequency;
  final List<int> targetDays; // 0-6 (Mon-Sun)
  final DateTime createdAt;

  HabitModel({
    required this.id,
    required this.name,
    this.description,
    this.icon = 'check_circle',
    this.streak = 0,
    this.bestStreak = 0,
    this.completedDates = const [],
    this.isCompletedToday = false,
    this.category = HabitCategory.other,
    this.frequency = HabitFrequency.daily,
    this.targetDays = const [0, 1, 2, 3, 4, 5, 6],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Check if today is a target day for this habit
  bool get isTodayTargetDay {
    final today = DateTime.now();
    // DateTime.weekday: 1 = Monday, 7 = Sunday
    // We use 0 = Monday, 6 = Sunday
    final dayIndex = today.weekday - 1;
    return targetDays.contains(dayIndex);
  }

  /// Get total completions count
  int get totalCompletions => completedDates.length;

  /// Get completion rate as a percentage (0.0 to 1.0)
  double get completionRate {
    if (completedDates.isEmpty) return 0.0;

    final now = DateTime.now();
    final daysSinceCreation = now.difference(createdAt).inDays + 1;

    // Count how many target days have passed since creation
    int targetDaysPassed = 0;
    for (int i = 0; i < daysSinceCreation; i++) {
      final date = createdAt.add(Duration(days: i));
      final dayIndex = date.weekday - 1;
      if (targetDays.contains(dayIndex)) {
        targetDaysPassed++;
      }
    }

    if (targetDaysPassed == 0) return 0.0;
    return (completedDates.length / targetDaysPassed).clamp(0.0, 1.0);
  }

  HabitModel copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    int? streak,
    int? bestStreak,
    List<DateTime>? completedDates,
    bool? isCompletedToday,
    HabitCategory? category,
    HabitFrequency? frequency,
    List<int>? targetDays,
    DateTime? createdAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      completedDates: completedDates ?? this.completedDates,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      targetDays: targetDays ?? this.targetDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String? ?? 'check_circle',
      streak: json['streak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      completedDates: (json['completedDates'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          [],
      isCompletedToday: json['isCompletedToday'] as bool? ?? false,
      category: HabitCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => HabitCategory.other,
      ),
      frequency: HabitFrequency.values.firstWhere(
        (f) => f.name == json['frequency'],
        orElse: () => HabitFrequency.daily,
      ),
      targetDays: (json['targetDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [0, 1, 2, 3, 4, 5, 6],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'streak': streak,
      'bestStreak': bestStreak,
      'completedDates':
          completedDates.map((d) => d.toIso8601String()).toList(),
      'isCompletedToday': isCompletedToday,
      'category': category.name,
      'frequency': frequency.name,
      'targetDays': targetDays,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// JSON for creating a new habit (without server-managed fields)
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'category': category.name,
      'frequency': frequency.name,
      'targetDays': targetDays,
    };
  }

  /// JSON for updating an existing habit
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'category': category.name,
      'frequency': frequency.name,
      'targetDays': targetDays,
    };
  }
}
