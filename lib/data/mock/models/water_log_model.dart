class WaterLogModel {
  final String id;
  final int amountMl;
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
