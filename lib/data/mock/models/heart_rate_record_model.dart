import 'package:hive/hive.dart';

part 'heart_rate_record_model.g.dart';

@HiveType(typeId: 5)
enum HeartRateZone {
  @HiveField(0)
  resting,
  @HiveField(1)
  warmUp,
  @HiveField(2)
  fatBurn,
  @HiveField(3)
  cardio,
  @HiveField(4)
  peak,
}

@HiveType(typeId: 6)
class HeartRateRecordModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int bpm;

  @HiveField(2)
  final DateTime recordedAt;

  @HiveField(3)
  final HeartRateZone zone;

  HeartRateRecordModel({
    required this.id,
    required this.bpm,
    required this.recordedAt,
    HeartRateZone? zone,
  }) : zone = zone ?? _calculateZone(bpm);

  static HeartRateZone _calculateZone(int bpm) {
    if (bpm < 60) return HeartRateZone.resting;
    if (bpm < 100) return HeartRateZone.warmUp;
    if (bpm < 140) return HeartRateZone.fatBurn;
    if (bpm < 170) return HeartRateZone.cardio;
    return HeartRateZone.peak;
  }

  String get zoneLabel {
    switch (zone) {
      case HeartRateZone.resting:
        return 'Resting';
      case HeartRateZone.warmUp:
        return 'Warm Up';
      case HeartRateZone.fatBurn:
        return 'Fat Burn';
      case HeartRateZone.cardio:
        return 'Cardio';
      case HeartRateZone.peak:
        return 'Peak';
    }
  }

  HeartRateRecordModel copyWith({
    String? id,
    int? bpm,
    DateTime? recordedAt,
    HeartRateZone? zone,
  }) {
    return HeartRateRecordModel(
      id: id ?? this.id,
      bpm: bpm ?? this.bpm,
      recordedAt: recordedAt ?? this.recordedAt,
      zone: zone ?? this.zone,
    );
  }
}
