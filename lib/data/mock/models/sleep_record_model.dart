import 'package:hive/hive.dart';

part 'sleep_record_model.g.dart';

@HiveType(typeId: 3)
enum SleepQuality {
  @HiveField(0)
  poor,
  @HiveField(1)
  fair,
  @HiveField(2)
  good,
  @HiveField(3)
  excellent,
}

@HiveType(typeId: 4)
class SleepRecordModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime bedTime;

  @HiveField(2)
  final DateTime wakeTime;

  @HiveField(3)
  final SleepQuality quality;

  @HiveField(4)
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
