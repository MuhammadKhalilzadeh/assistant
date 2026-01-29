import 'package:hive/hive.dart';

part 'water_log_model.g.dart';

@HiveType(typeId: 0)
class WaterLogModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int amountMl;

  @HiveField(2)
  final DateTime loggedAt;

  WaterLogModel({
    required this.id,
    required this.amountMl,
    required this.loggedAt,
  });

  WaterLogModel copyWith({
    String? id,
    int? amountMl,
    DateTime? loggedAt,
  }) {
    return WaterLogModel(
      id: id ?? this.id,
      amountMl: amountMl ?? this.amountMl,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }
}
