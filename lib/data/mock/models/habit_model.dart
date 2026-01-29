class HabitModel {
  final String id;
  final String name;
  final String? description;
  final String icon; // Icon name string
  final int streak;
  final List<DateTime> completedDates;
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
