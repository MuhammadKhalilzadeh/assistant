class TodoStats {
  final int total;
  final int completed;
  final int todayCount;
  final int overdueCount;
  final double completionRate;
  final int currentStreak;
  final int thisWeekCompleted;

  const TodoStats({
    required this.total,
    required this.completed,
    required this.todayCount,
    required this.overdueCount,
    required this.completionRate,
    required this.currentStreak,
    required this.thisWeekCompleted,
  });

  factory TodoStats.fromJson(Map<String, dynamic> json) {
    return TodoStats(
      total: json['total'] as int,
      completed: json['completed'] as int,
      todayCount: json['todayCount'] as int,
      overdueCount: json['overdueCount'] as int,
      completionRate: (json['completionRate'] as num).toDouble(),
      currentStreak: json['currentStreak'] as int,
      thisWeekCompleted: json['thisWeekCompleted'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'completed': completed,
      'todayCount': todayCount,
      'overdueCount': overdueCount,
      'completionRate': completionRate,
      'currentStreak': currentStreak,
      'thisWeekCompleted': thisWeekCompleted,
    };
  }

  static TodoStats empty() {
    return const TodoStats(
      total: 0,
      completed: 0,
      todayCount: 0,
      overdueCount: 0,
      completionRate: 0.0,
      currentStreak: 0,
      thisWeekCompleted: 0,
    );
  }
}
