import 'package:hive/hive.dart';

part 'mood_entry_model.g.dart';

@HiveType(typeId: 1)
enum MoodLevel {
  @HiveField(0)
  great,
  @HiveField(1)
  good,
  @HiveField(2)
  okay,
  @HiveField(3)
  bad,
  @HiveField(4)
  awful,
}

@HiveType(typeId: 2)
class MoodEntryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final MoodLevel mood;

  @HiveField(2)
  final DateTime recordedAt;

  @HiveField(3)
  final String? notes;

  @HiveField(4)
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
