enum MoodLevel { great, good, okay, bad, awful }

/// Goal settings for mood tracking
class MoodGoal {
  final int dailyEntriesGoal;
  final MoodLevel targetMood;

  const MoodGoal({
    this.dailyEntriesGoal = 1,
    this.targetMood = MoodLevel.good,
  });

  MoodGoal copyWith({
    int? dailyEntriesGoal,
    MoodLevel? targetMood,
  }) {
    return MoodGoal(
      dailyEntriesGoal: dailyEntriesGoal ?? this.dailyEntriesGoal,
      targetMood: targetMood ?? this.targetMood,
    );
  }
}

/// Statistics for mood tracking
class MoodStats {
  final double weeklyAverageMood;
  final int currentStreak;
  final int bestStreak;
  final int totalEntries;
  final Map<MoodLevel, int> moodDistribution;
  final Map<String, int> commonActivities;

  const MoodStats({
    this.weeklyAverageMood = 0.0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalEntries = 0,
    this.moodDistribution = const {},
    this.commonActivities = const {},
  });
}

class MoodEntryModel {
  final String id;
  final MoodLevel mood;
  final DateTime recordedAt;
  final String? notes;
  final List<String> activities;

  MoodEntryModel({
    required this.id,
    required this.mood,
    required this.recordedAt,
    this.notes,
    this.activities = const [],
  });

  String get moodEmoji {
    switch (mood) {
      case MoodLevel.great:
        return '😄';
      case MoodLevel.good:
        return '🙂';
      case MoodLevel.okay:
        return '😐';
      case MoodLevel.bad:
        return '😔';
      case MoodLevel.awful:
        return '😢';
    }
  }

  String get moodLabel {
    switch (mood) {
      case MoodLevel.great:
        return 'Great';
      case MoodLevel.good:
        return 'Good';
      case MoodLevel.okay:
        return 'Okay';
      case MoodLevel.bad:
        return 'Bad';
      case MoodLevel.awful:
        return 'Awful';
    }
  }

  MoodEntryModel copyWith({
    String? id,
    MoodLevel? mood,
    DateTime? recordedAt,
    String? notes,
    List<String>? activities,
  }) {
    return MoodEntryModel(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      recordedAt: recordedAt ?? this.recordedAt,
      notes: notes ?? this.notes,
      activities: activities ?? this.activities,
    );
  }
}
