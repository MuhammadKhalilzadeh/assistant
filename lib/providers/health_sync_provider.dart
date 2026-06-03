import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/services/health_connect_service.dart';
import 'package:assistant/data/cache/health_sync_cache.dart';
import 'package:assistant/providers/steps_provider.dart';
import 'package:assistant/providers/heart_rate_provider.dart';
import 'package:assistant/providers/sleep_provider.dart';
import 'package:assistant/providers/workout_provider.dart';
import 'package:assistant/providers/calories_provider.dart';
import 'package:assistant/providers/connectivity_provider.dart';
import 'package:assistant/data/models/heart_rate_model.dart';
import 'package:assistant/data/models/sleep_record_model.dart';
import 'package:assistant/data/models/workout_session_model.dart';

// Singleton service provider
final healthConnectServiceProvider = Provider<HealthConnectService>((ref) {
  return HealthConnectService();
});

// Cache for sync metadata
final healthSyncCacheProvider = Provider<HealthSyncCache>((ref) {
  return HealthSyncCache();
});

// Health sync state
class HealthSyncState {
  final HealthSyncStatus status;
  final bool isAvailable;
  final bool hasPermissions;
  final bool isEnabled;
  final DateTime? lastSyncTime;
  final int lastRecordsSynced;
  final String? errorMessage;

  const HealthSyncState({
    this.status = HealthSyncStatus.idle,
    this.isAvailable = false,
    this.hasPermissions = false,
    this.isEnabled = false,
    this.lastSyncTime,
    this.lastRecordsSynced = 0,
    this.errorMessage,
  });

  HealthSyncState copyWith({
    HealthSyncStatus? status,
    bool? isAvailable,
    bool? hasPermissions,
    bool? isEnabled,
    DateTime? lastSyncTime,
    int? lastRecordsSynced,
    String? errorMessage,
  }) {
    return HealthSyncState(
      status: status ?? this.status,
      isAvailable: isAvailable ?? this.isAvailable,
      hasPermissions: hasPermissions ?? this.hasPermissions,
      isEnabled: isEnabled ?? this.isEnabled,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastRecordsSynced: lastRecordsSynced ?? this.lastRecordsSynced,
      errorMessage: errorMessage,
    );
  }
}

// Main health sync provider
final healthSyncProvider =
    AsyncNotifierProvider<HealthSyncNotifier, HealthSyncState>(
        HealthSyncNotifier.new);

class HealthSyncNotifier extends AsyncNotifier<HealthSyncState> {
  Timer? _periodicSyncTimer;

  @override
  Future<HealthSyncState> build() async {
    ref.onDispose(() {
      _periodicSyncTimer?.cancel();
    });

    final service = ref.read(healthConnectServiceProvider);
    final cache = ref.read(healthSyncCacheProvider);

    final isAvailable = await service.checkAvailability();
    final hasPermissions = isAvailable ? await service.hasPermissions() : false;
    final isEnabled = await cache.getIsEnabled();
    final lastSync = await cache.getLastSyncTime();

    final syncState = HealthSyncState(
      isAvailable: isAvailable,
      hasPermissions: hasPermissions,
      isEnabled: isEnabled,
      lastSyncTime: lastSync,
    );

    // Auto-sync on init if enabled and has permissions
    if (isEnabled && hasPermissions) {
      _startPeriodicSync();
      // Sync on startup (non-blocking)
      _syncInBackground();
    }

    return syncState;
  }

  /// Request Health Connect permissions
  Future<bool> requestPermissions() async {
    final service = ref.read(healthConnectServiceProvider);
    final granted = await service.requestPermissions();

    state = state.whenData((s) => s.copyWith(hasPermissions: granted));

    if (granted) {
      await setEnabled(true);
      // Run initial history sync (30 days backfill)
      await syncHistory();
    }

    return granted;
  }

  /// Enable or disable Health Connect sync
  Future<void> setEnabled(bool enabled) async {
    final cache = ref.read(healthSyncCacheProvider);
    await cache.setIsEnabled(enabled);

    state = state.whenData((s) => s.copyWith(isEnabled: enabled));

    if (enabled) {
      _startPeriodicSync();
    } else {
      _periodicSyncTimer?.cancel();
      _periodicSyncTimer = null;
    }
  }

  /// Sync last 24 hours of data
  Future<void> syncRecent() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    if (currentState.status == HealthSyncStatus.syncing) return;
    if (!currentState.hasPermissions) return;

    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) return;

    state = AsyncValue.data(
        currentState.copyWith(status: HealthSyncStatus.syncing));

    try {
      final service = ref.read(healthConnectServiceProvider);
      final result = await service.syncRecent();
      await _pushDataToProviders(result);

      final cache = ref.read(healthSyncCacheProvider);
      await cache.setLastSyncTime(result.syncedAt);

      state = AsyncValue.data(currentState.copyWith(
        status: HealthSyncStatus.success,
        lastSyncTime: result.syncedAt,
        lastRecordsSynced: result.recordsSynced,
        errorMessage: null,
      ));
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(
        status: HealthSyncStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Sync last 30 days (initial setup / backfill)
  Future<void> syncHistory() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    if (!currentState.hasPermissions) return;

    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) return;

    state = AsyncValue.data(
        currentState.copyWith(status: HealthSyncStatus.syncing));

    try {
      final service = ref.read(healthConnectServiceProvider);
      final result = await service.syncHistory();
      await _pushDataToProviders(result);

      final cache = ref.read(healthSyncCacheProvider);
      await cache.setLastSyncTime(result.syncedAt);

      state = AsyncValue.data(currentState.copyWith(
        status: HealthSyncStatus.success,
        lastSyncTime: result.syncedAt,
        lastRecordsSynced: result.recordsSynced,
        errorMessage: null,
      ));
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(
        status: HealthSyncStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Push synced Health Connect data into the existing providers -> API -> backend
  Future<void> _pushDataToProviders(HealthSyncResult result) async {
    // Steps: use addSteps API which merges with existing daily record
    if (result.stepsTotal > 0) {
      try {
        final stepsApi = ref.read(stepsApiServiceProvider);
        await stepsApi.addSteps(result.stepsTotal);
        ref.invalidate(stepRecordsProvider);
        ref.invalidate(stepsStatsProvider);
        ref.invalidate(stepsHistoryProvider);
      } catch (_) {}
    }

    // Heart rate: create records for each reading
    if (result.heartRateReadings.isNotEmpty) {
      try {
        final hrNotifier = ref.read(heartRateRecordsProvider.notifier);
        // Batch: only sync the most recent 10 readings to avoid flooding
        final readings = result.heartRateReadings.length > 10
            ? result.heartRateReadings.sublist(
                result.heartRateReadings.length - 10)
            : result.heartRateReadings;

        for (final reading in readings) {
          final record = HeartRateRecordModel(
            id: '',
            bpm: reading.bpm,
            recordedAt: reading.timestamp,
          );
          try {
            await hrNotifier.addRecord(record);
          } catch (_) {
            // Skip duplicates or errors for individual readings
          }
        }
      } catch (_) {}
    }

    // Sleep: create a sleep record if we got sleep data
    if (result.sleepSession != null) {
      try {
        final sleep = result.sleepSession!;
        final qualityEnum = _mapSleepQuality(sleep.qualityScore);

        final record = SleepRecordModel(
          id: '',
          bedTime: sleep.bedTime,
          wakeTime: sleep.wakeTime,
          quality: qualityEnum,
          durationMinutes: sleep.totalMinutes,
          notes:
              'Health Connect: ${sleep.deepMinutes}m deep, ${sleep.remMinutes}m REM, ${sleep.lightMinutes}m light',
          createdAt: DateTime.now(),
        );

        final sleepNotifier = ref.read(sleepRecordsProvider.notifier);
        await sleepNotifier.addRecord(record);
      } catch (_) {}
    }

    // Workouts: create workout sessions
    if (result.workouts.isNotEmpty) {
      try {
        final workoutNotifier = ref.read(workoutSessionsProvider.notifier);
        for (final workout in result.workouts) {
          final session = WorkoutSessionModel(
            id: '',
            type: _mapWorkoutTypeEnum(workout.type),
            startTime: workout.startTime,
            endTime: workout.endTime,
            durationMinutes: workout.durationMinutes,
            caloriesBurned: workout.caloriesBurned.round(),
            exercises: [],
            notes: 'Synced from Health Connect',
            createdAt: DateTime.now(),
          );
          try {
            await workoutNotifier.addSession(session);
          } catch (_) {}
        }
      } catch (_) {}
    }

    // Calories burned: invalidate nutrition stats to reflect new data
    if (result.activeCaloriesBurned > 0) {
      ref.invalidate(nutritionStatsProvider);
      ref.invalidate(nutritionHistoryProvider);
    }
  }

  SleepQuality _mapSleepQuality(double score) {
    if (score >= 4.0) return SleepQuality.excellent;
    if (score >= 3.0) return SleepQuality.good;
    if (score >= 2.0) return SleepQuality.fair;
    return SleepQuality.poor;
  }

  WorkoutType _mapWorkoutTypeEnum(String type) {
    switch (type) {
      case 'running':
        return WorkoutType.running;
      case 'cycling':
        return WorkoutType.cycling;
      case 'swimming':
        return WorkoutType.swimming;
      case 'walking':
        return WorkoutType.walking;
      case 'yoga':
        return WorkoutType.yoga;
      case 'hiit':
        return WorkoutType.hiit;
      case 'strength':
        return WorkoutType.strength;
      default:
        return WorkoutType.other;
    }
  }

  void _startPeriodicSync() {
    _periodicSyncTimer?.cancel();
    // Sync every 15 minutes
    _periodicSyncTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _syncInBackground(),
    );
  }

  void _syncInBackground() {
    // Fire and forget - errors are captured in state
    syncRecent();
  }
}
