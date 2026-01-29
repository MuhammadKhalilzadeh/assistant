import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 14)
class HabitModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String icon; // Icon name string

  @HiveField(4)
  final int streak;

  @HiveField(5)
  final List<DateTime> completedDates;

  @HiveField(6)
  final bool isCompletedToday;

  HabitModel({
    required this.id,
    required this.name,
    this.description,
    this.icon = 'check_circle',
    this.streak = 0,
    this.completedDates = const [],
    this.isCompletedToday = false,
  });

  HabitModel copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    int? streak,
    List<DateTime>? completedDates,
    bool? isCompletedToday,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      streak: streak ?? this.streak,
      completedDates: completedDates ?? this.completedDates,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
    );
  }
}
