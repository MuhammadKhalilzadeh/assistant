# Wave 1: Health Connect Integration

> **Goal:** Connect all health modules to Samsung Health / Health Connect for real sensor data
> **Status:** Complete (implementation done, pending real device testing)
> **Depends on:** Nothing (first wave)

---

## Why This First

Everything else (AI brain, insights, correlations) is only as good as the data feeding it. Currently steps, heart rate, sleep, and workout data are **mocked**. We need real sensor data before intelligence makes sense.

---

## What Changes

### New Flutter Package
```yaml
# pubspec.yaml - add:
health: ^11.1.0   # Wraps Health Connect (Android) + HealthKit (iOS)
permission_handler: ^11.3.0  # Unified permission management
```

### New Files to Create

| File | Purpose |
|------|---------|
| `lib/data/services/health_connect_service.dart` | Core service: reads from Health Connect, writes to app providers |
| `lib/providers/health_sync_provider.dart` | Riverpod provider managing sync state, schedule, permissions |
| `lib/presentation/widgets/health_permission_sheet.dart` | Bottom sheet UI for requesting Health Connect permissions |

### Files to Modify

| File | Change |
|------|--------|
| `pubspec.yaml` | Add `health` and `permission_handler` dependencies |
| `android/app/build.gradle.kts` | Add Health Connect permissions to manifest |
| `android/app/src/main/AndroidManifest.xml` | Health Connect intent filter + permissions |
| `lib/providers/steps_provider.dart` | Replace mock data source with Health Connect sync |
| `lib/providers/heart_rate_provider.dart` | Replace mock data source with Health Connect sync |
| `lib/providers/sleep_provider.dart` | Replace mock data source with Health Connect sync |
| `lib/providers/workout_provider.dart` | Replace mock data source with Health Connect sync |
| `lib/providers/calories_provider.dart` | Add burned calories from Health Connect (supplements manual food logging) |
| `lib/presentation/pages/settings_page.dart` | Add Health Connect connection toggle + sync status |
| `lib/presentation/pages/dashboard_page.dart` | Show real-time health data from device |

---

## Health Connect Service Design

```dart
/// lib/data/services/health_connect_service.dart
class HealthConnectService {
  final Health _health = Health();

  /// Data types we request from Health Connect / Samsung Health
  static const _types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_REM,
    HealthDataType.WORKOUT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.WEIGHT,
  ];

  /// Check if Health Connect is available + has permissions
  Future<bool> checkAvailability();

  /// Request all health permissions
  Future<bool> requestPermissions();

  /// Sync last 24 hours of data from Health Connect
  /// Called on app open + every 15 minutes in foreground
  Future<HealthSyncResult> syncRecent();

  /// Sync last 30 days (initial setup / backfill)
  Future<HealthSyncResult> syncHistory();

  /// Individual data type readers
  Future<int> getTodaySteps();
  Future<List<HeartRateReading>> getHeartRateReadings(DateTime from, DateTime to);
  Future<SleepSession?> getLastNightSleep();
  Future<List<WorkoutSession>> getWorkouts(DateTime from, DateTime to);
  Future<double> getActiveCaloriesBurned(DateTime from, DateTime to);
}
```

## Data Flow: Health Connect -> Backend

```
Samsung Health / Wearable
    |
    v
Health Connect API (Android)
    |
    v
Flutter `health` package
    |
    v
HealthConnectService.syncRecent()
    |
    +-> StepsProvider.updateFromDevice(steps, distance)
    +-> HeartRateProvider.updateFromDevice(readings)
    +-> SleepProvider.updateFromDevice(sleepSession)
    +-> WorkoutProvider.updateFromDevice(workouts)
    +-> CaloriesProvider.updateBurnedFromDevice(calories)
    |
    v
Each provider -> API Service -> POST to backend
    |
    v
Backend stores in DB (available for AI analysis)
```

## Sync Strategy

- **On app open:** Sync last 24 hours
- **Foreground timer:** Re-sync every 15 minutes
- **Background:** Not in Wave 1 (add in Wave 4 with WorkManager)
- **Initial setup:** Backfill last 30 days on first Health Connect grant
- **Conflict resolution:** Device data wins over manual entries for overlapping timestamps
- **Deduplication:** Hash (type + timestamp + value) to prevent duplicate records

## Android Configuration

```xml
<!-- AndroidManifest.xml additions -->
<uses-permission android:name="android.permission.health.READ_STEPS"/>
<uses-permission android:name="android.permission.health.READ_HEART_RATE"/>
<uses-permission android:name="android.permission.health.READ_SLEEP"/>
<uses-permission android:name="android.permission.health.READ_EXERCISE"/>
<uses-permission android:name="android.permission.health.READ_ACTIVE_CALORIES_BURNED"/>
<uses-permission android:name="android.permission.health.READ_DISTANCE"/>
<uses-permission android:name="android.permission.health.READ_BLOOD_OXYGEN"/>
<uses-permission android:name="android.permission.health.READ_BODY_TEMPERATURE"/>
<uses-permission android:name="android.permission.health.READ_WEIGHT"/>

<!-- Health Connect intent filter -->
<intent-filter>
  <action android:name="androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE" />
</intent-filter>
```

## Module-Specific Integration

### Steps
- Read: `STEPS` + `DISTANCE_DELTA` from Health Connect
- Aggregate: daily total steps, total distance
- Backend sync: POST to `/api/steps` with `source: 'health_connect'`
- Keep manual entry as fallback

### Heart Rate
- Read: `HEART_RATE` from Health Connect (Samsung Watch, Galaxy Ring)
- Store: individual BPM readings with timestamps
- Calculate: resting HR (readings during sleep), active HR (during workouts), zones
- Backend sync: POST batch readings to `/api/heart-rate`

### Sleep
- Read: `SLEEP_IN_BED`, `SLEEP_ASLEEP`, `SLEEP_LIGHT`, `SLEEP_DEEP`, `SLEEP_REM`
- Map to existing model: bedTime, wakeTime, quality (derived from deep/REM ratio), duration
- Quality algorithm: `(deepMinutes + remMinutes) / totalMinutes * 5` (scale 1-5)
- Backend sync: POST to `/api/sleep`

### Workout
- Read: `WORKOUT` from Health Connect
- Map workout types: RUNNING, WALKING, CYCLING, STRENGTH, etc.
- Include: duration, calories, distance (if applicable)
- Backend sync: POST to `/api/workouts`

### Calories (Burned)
- Read: `ACTIVE_ENERGY_BURNED` from Health Connect
- Supplements the existing manual food calorie logging
- New field on calorie stats: `burnedToday` alongside `consumedToday`
- Net calories = consumed - burned

---

## Checklist

- [x] Add `health` + `permission_handler` to pubspec.yaml
- [x] Configure Android manifest for Health Connect
- [x] Create `HealthConnectService` with all data type readers
- [x] Create `health_sync_provider.dart` managing sync lifecycle
- [x] Create permission request UI (settings page + first-run prompt)
- [x] Integrate with StepsProvider (via HealthSyncProvider._pushDataToProviders)
- [x] Integrate with HeartRateProvider (via HealthSyncProvider._pushDataToProviders)
- [x] Integrate with SleepProvider (via HealthSyncProvider._pushDataToProviders)
- [x] Integrate with WorkoutProvider (via HealthSyncProvider._pushDataToProviders)
- [x] Add burned calories to CaloriesProvider (invalidates nutrition stats on sync)
- [x] Backfill 30-day history on initial connect (syncHistory on first permission grant)
- [x] 15-minute foreground sync timer (Timer.periodic in HealthSyncNotifier)
- [x] Settings page: Health Connect toggle, last sync time, sync now button
- [ ] Test with Samsung Health on real device
