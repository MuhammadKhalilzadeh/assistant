enum SleepQuality { poor, fair, good, excellent }

class SleepRecordModel {
  final String id;
  final DateTime bedTime;
  final DateTime wakeTime;
  final SleepQuality quality;
  final String? notes;

  SleepRecordModel({
    required this.id,
    required this.bedTime,
    required this.wakeTime,
    this.quality = SleepQuality.good,
    this.notes,
  });

  Duration get duration => wakeTime.difference(bedTime);

  double get durationHours => duration.inMinutes / 60.0;

  SleepRecordModel copyWith({
    String? id,
    DateTime? bedTime,
    DateTime? wakeTime,
    SleepQuality? quality,
    String? notes,
  }) {
    return SleepRecordModel(
      id: id ?? this.id,
      bedTime: bedTime ?? this.bedTime,
      wakeTime: wakeTime ?? this.wakeTime,
      quality: quality ?? this.quality,
      notes: notes ?? this.notes,
    );
  }
}
