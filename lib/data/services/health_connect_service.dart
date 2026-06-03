import 'dart:async';
import 'package:health/health.dart';

enum HealthSyncStatus {
  idle,
  syncing,
  success,
  error,
  unavailable,
  noPermissions,
}

class HealthSyncResult {
  final int stepsTotal;
  final double distanceKm;
  final List<HeartRateReading> heartRateReadings;
  final SleepSessionData? sleepSession;
  final List<WorkoutData> workouts;
  final double activeCaloriesBurned;
  final int recordsSynced;
  final DateTime syncedAt;

  HealthSyncResult({
    required this.stepsTotal,
    required this.distanceKm,
    required this.heartRateReadings,
    required this.sleepSession,
    required this.workouts,
    required this.activeCaloriesBurned,
    required this.recordsSynced,
    required this.syncedAt,
  });
}

class HeartRateReading {
  final int bpm;
  final DateTime timestamp;

  HeartRateReading({required this.bpm, required this.timestamp});
}

class SleepSessionData {
  final DateTime bedTime;
  final DateTime wakeTime;
  final int totalMinutes;
  final int deepMinutes;
  final int remMinutes;
  final int lightMinutes;
  final int awakeMinutes;

  SleepSessionData({
    required this.bedTime,
    required this.wakeTime,
    required this.totalMinutes,
    required this.deepMinutes,
    required this.remMinutes,
    required this.lightMinutes,
    required this.awakeMinutes,
  });

  /// Quality score derived from deep + REM ratio (1-5 scale)
  double get qualityScore {
    if (totalMinutes == 0) return 1.0;
    final restorativeRatio = (deepMinutes + remMinutes) / totalMinutes;
    return (restorativeRatio * 5).clamp(1.0, 5.0);
  }

  double get durationHours => totalMinutes / 60.0;
}

class WorkoutData {
  final String type;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final double caloriesBurned;
  final double? distanceKm;

  WorkoutData({
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.distanceKm,
  });
}

class HealthConnectService {
  static final HealthConnectService _instance = HealthConnectService._();
  factory HealthConnectService() => _instance;
  HealthConnectService._();

  final Health _health = Health();
  bool _isConfigured = false;

  /// Data types we read from Health Connect / Samsung Health
  static const List<HealthDataType> _readTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.WORKOUT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.WEIGHT,
    HealthDataType.TOTAL_CALORIES_BURNED,
  ];

  static final List<HealthDataAccess> _permissions =
      List.filled(_readTypes.length, HealthDataAccess.READ);

  void _configure() {
    if (!_isConfigured) {
      _health.configure();
      _isConfigured = true;
    }
  }

  /// Check if Health Connect is installed and available
  Future<bool> checkAvailability() async {
    _configure();
    try {
      final status = await _health.getHealthConnectSdkStatus();
      return status == HealthConnectSdkStatus.sdkAvailable;
    } catch (_) {
      return false;
    }
  }

  /// Check if we already have permissions
  Future<bool> hasPermissions() async {
    _configure();
    try {
      return await _health.hasPermissions(_readTypes,
              permissions: _permissions) ??
          false;
    } catch (_) {
      return false;
    }
  }

  /// Request Health Connect permissions
  Future<bool> requestPermissions() async {
    _configure();
    try {
      return await _health.requestAuthorization(
        _readTypes,
        permissions: _permissions,
      );
    } catch (_) {
      return false;
    }
  }

  /// Sync last 24 hours of data from Health Connect
  Future<HealthSyncResult> syncRecent() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));
    return _syncRange(yesterday, now);
  }

  /// Sync last 30 days of data (initial setup / backfill)
  Future<HealthSyncResult> syncHistory() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    return _syncRange(thirtyDaysAgo, now);
  }

  /// Core sync method for a date range
  Future<HealthSyncResult> _syncRange(DateTime from, DateTime to) async {
    _configure();

    final steps = await _getTotalSteps(from, to);
    final distance = await _getTotalDistance(from, to);
    final heartRateReadings = await _getHeartRateReadings(from, to);
    final sleepSession = await _getLastNightSleep(from, to);
    final workouts = await _getWorkouts(from, to);
    final activeCalories = await _getActiveCaloriesBurned(from, to);

    final totalRecords = (steps > 0 ? 1 : 0) +
        heartRateReadings.length +
        (sleepSession != null ? 1 : 0) +
        workouts.length +
        (activeCalories > 0 ? 1 : 0);

    return HealthSyncResult(
      stepsTotal: steps,
      distanceKm: distance,
      heartRateReadings: heartRateReadings,
      sleepSession: sleepSession,
      workouts: workouts,
      activeCaloriesBurned: activeCalories,
      recordsSynced: totalRecords,
      syncedAt: DateTime.now(),
    );
  }

  /// Get total steps for a date range
  Future<int> _getTotalSteps(DateTime from, DateTime to) async {
    try {
      final steps = await _health.getTotalStepsInInterval(from, to);
      return steps ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Get today's step count
  Future<int> getTodaySteps() async {
    _configure();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return _getTotalSteps(startOfDay, now);
  }

  /// Get total distance in km
  Future<double> _getTotalDistance(DateTime from, DateTime to) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.DISTANCE_DELTA],
        startTime: from,
        endTime: to,
      );
      double totalMeters = 0;
      for (final point in data) {
        if (point.value is NumericHealthValue) {
          totalMeters +=
              (point.value as NumericHealthValue).numericValue.toDouble();
        }
      }
      return totalMeters / 1000.0;
    } catch (_) {
      return 0;
    }
  }

  /// Get heart rate readings
  Future<List<HeartRateReading>> _getHeartRateReadings(
      DateTime from, DateTime to) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: from,
        endTime: to,
      );

      return data
          .where((point) => point.value is NumericHealthValue)
          .map((point) => HeartRateReading(
                bpm: (point.value as NumericHealthValue)
                    .numericValue
                    .toInt(),
                timestamp: point.dateFrom,
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Get heart rate readings for a custom range (public API)
  Future<List<HeartRateReading>> getHeartRateReadings(
      DateTime from, DateTime to) async {
    _configure();
    return _getHeartRateReadings(from, to);
  }

  /// Get last night's sleep session
  Future<SleepSessionData?> _getLastNightSleep(
      DateTime from, DateTime to) async {
    try {
      final sleepTypes = [
        HealthDataType.SLEEP_IN_BED,
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.SLEEP_LIGHT,
        HealthDataType.SLEEP_DEEP,
        HealthDataType.SLEEP_REM,
      ];

      final data = await _health.getHealthDataFromTypes(
        types: sleepTypes,
        startTime: from,
        endTime: to,
      );

      if (data.isEmpty) return null;

      // Find bed/wake times from SLEEP_IN_BED or SLEEP_ASLEEP
      DateTime? bedTime;
      DateTime? wakeTime;
      int deepMinutes = 0;
      int remMinutes = 0;
      int lightMinutes = 0;

      for (final point in data) {
        switch (point.type) {
          case HealthDataType.SLEEP_IN_BED:
          case HealthDataType.SLEEP_ASLEEP:
            if (bedTime == null || point.dateFrom.isBefore(bedTime)) {
              bedTime = point.dateFrom;
            }
            if (wakeTime == null || point.dateTo.isAfter(wakeTime)) {
              wakeTime = point.dateTo;
            }
            break;
          case HealthDataType.SLEEP_DEEP:
            deepMinutes +=
                point.dateTo.difference(point.dateFrom).inMinutes;
            if (bedTime == null || point.dateFrom.isBefore(bedTime)) {
              bedTime = point.dateFrom;
            }
            if (wakeTime == null || point.dateTo.isAfter(wakeTime)) {
              wakeTime = point.dateTo;
            }
            break;
          case HealthDataType.SLEEP_REM:
            remMinutes +=
                point.dateTo.difference(point.dateFrom).inMinutes;
            if (bedTime == null || point.dateFrom.isBefore(bedTime)) {
              bedTime = point.dateFrom;
            }
            if (wakeTime == null || point.dateTo.isAfter(wakeTime)) {
              wakeTime = point.dateTo;
            }
            break;
          case HealthDataType.SLEEP_LIGHT:
            lightMinutes +=
                point.dateTo.difference(point.dateFrom).inMinutes;
            if (bedTime == null || point.dateFrom.isBefore(bedTime)) {
              bedTime = point.dateFrom;
            }
            if (wakeTime == null || point.dateTo.isAfter(wakeTime)) {
              wakeTime = point.dateTo;
            }
            break;
          default:
            break;
        }
      }

      if (bedTime == null || wakeTime == null) return null;

      final totalMinutes = wakeTime.difference(bedTime).inMinutes;
      final awakeMinutes =
          totalMinutes - deepMinutes - remMinutes - lightMinutes;

      return SleepSessionData(
        bedTime: bedTime,
        wakeTime: wakeTime,
        totalMinutes: totalMinutes,
        deepMinutes: deepMinutes,
        remMinutes: remMinutes,
        lightMinutes: lightMinutes,
        awakeMinutes: awakeMinutes.clamp(0, totalMinutes),
      );
    } catch (_) {
      return null;
    }
  }

  /// Get last night's sleep (public API)
  Future<SleepSessionData?> getLastNightSleep() async {
    _configure();
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));
    return _getLastNightSleep(yesterday, now);
  }

  /// Get workouts
  Future<List<WorkoutData>> _getWorkouts(DateTime from, DateTime to) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT],
        startTime: from,
        endTime: to,
      );

      return data
          .where((point) => point.value is WorkoutHealthValue)
          .map((point) {
        final workout = point.value as WorkoutHealthValue;
        return WorkoutData(
          type: _mapWorkoutType(workout.workoutActivityType),
          startTime: point.dateFrom,
          endTime: point.dateTo,
          durationMinutes: point.dateTo.difference(point.dateFrom).inMinutes,
          caloriesBurned: workout.totalEnergyBurned?.toDouble() ?? 0,
          distanceKm: workout.totalDistance != null
              ? workout.totalDistance!.toDouble() / 1000.0
              : null,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Get workouts for a custom range (public API)
  Future<List<WorkoutData>> getWorkouts(DateTime from, DateTime to) async {
    _configure();
    return _getWorkouts(from, to);
  }

  /// Get active calories burned
  Future<double> _getActiveCaloriesBurned(DateTime from, DateTime to) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: from,
        endTime: to,
      );
      double total = 0;
      for (final point in data) {
        if (point.value is NumericHealthValue) {
          total +=
              (point.value as NumericHealthValue).numericValue.toDouble();
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  /// Get active calories burned for a custom range (public API)
  Future<double> getActiveCaloriesBurned(DateTime from, DateTime to) async {
    _configure();
    return _getActiveCaloriesBurned(from, to);
  }

  /// Map Health Connect workout types to app workout type strings
  String _mapWorkoutType(HealthWorkoutActivityType type) {
    switch (type) {
      case HealthWorkoutActivityType.RUNNING:
      case HealthWorkoutActivityType.RUNNING_TREADMILL:
        return 'running';
      case HealthWorkoutActivityType.BIKING:
      case HealthWorkoutActivityType.BIKING_STATIONARY:
        return 'cycling';
      case HealthWorkoutActivityType.SWIMMING_POOL:
      case HealthWorkoutActivityType.SWIMMING_OPEN_WATER:
        return 'swimming';
      case HealthWorkoutActivityType.WALKING:
        return 'walking';
      case HealthWorkoutActivityType.YOGA:
        return 'yoga';
      case HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING:
        return 'hiit';
      case HealthWorkoutActivityType.WEIGHTLIFTING:
      case HealthWorkoutActivityType.CALISTHENICS:
        return 'strength';
      default:
        return 'other';
    }
  }
}
