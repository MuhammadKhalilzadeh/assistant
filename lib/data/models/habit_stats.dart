class HabitStats {
  final int totalHabits;
  final int completedToday;
  final int totalForToday;
  final int maxStreak;
  final int maxBestStreak;
  final double weeklyCompletionRate;

  const HabitStats({
    required this.totalHabits,
    required this.completedToday,
    required this.totalForToday,
    required this.maxStreak,
    required this.maxBestStreak,
    required this.weeklyCompletionRate,
  });

  factory HabitStats.fromJson(Map<String, dynamic> json) {
    return HabitStats(
      totalHabits: json['totalHabits'] as int,
      completedToday: json['completedToday'] as int,
      totalForToday: json['totalForToday'] as int,
      maxStreak: json['maxStreak'] as int,
      maxBestStreak: json['maxBestStreak'] as int,
      weeklyCompletionRate: (json['weeklyCompletionRate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalHabits': totalHabits,
      'completedToday': completedToday,
      'totalForToday': totalForToday,
      'maxStreak': maxStreak,
      'maxBestStreak': maxBestStreak,
      'weeklyCompletionRate': weeklyCompletionRate,
    };
  }

  static HabitStats empty() {
    return const HabitStats(
      totalHabits: 0,
      completedToday: 0,
      totalForToday: 0,
      maxStreak: 0,
      maxBestStreak: 0,
      weeklyCompletionRate: 0.0,
    );
  }
}
