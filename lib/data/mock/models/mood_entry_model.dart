enum MoodLevel { great, good, okay, bad, awful }

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
