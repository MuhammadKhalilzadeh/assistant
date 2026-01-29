class AppUsageModel {
  final String appName;
  final String category;
  final int minutesUsed;
  final String iconName;

  AppUsageModel({
    required this.appName,
    required this.category,
    required this.minutesUsed,
    this.iconName = 'apps',
  });
}

class ScreenTimeModel {
  final String id;
  final DateTime date;
  final int totalMinutes;
  final List<AppUsageModel> appUsage;
  final int pickups;

  ScreenTimeModel({
    required this.id,
    required this.date,
    required this.totalMinutes,
    this.appUsage = const [],
    this.pickups = 0,
  });

  String get formattedTime {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  ScreenTimeModel copyWith({
    String? id,
    DateTime? date,
    int? totalMinutes,
    List<AppUsageModel>? appUsage,
    int? pickups,
  }) {
    return ScreenTimeModel(
      id: id ?? this.id,
      date: date ?? this.date,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      appUsage: appUsage ?? this.appUsage,
      pickups: pickups ?? this.pickups,
    );
  }
}
