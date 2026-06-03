import 'package:hive_flutter/hive_flutter.dart';

/// Hive-based cache for Health Connect sync metadata
class HealthSyncCache {
  static const _boxName = 'health_sync_cache';
  static const _enabledKey = 'enabled';
  static const _lastSyncKey = 'last_sync_time';

  Box? _box;

  Future<Box> _getBox() async {
    _box ??= await Hive.openBox(_boxName);
    return _box!;
  }

  Future<bool> getIsEnabled() async {
    final box = await _getBox();
    return box.get(_enabledKey, defaultValue: false) as bool;
  }

  Future<void> setIsEnabled(bool enabled) async {
    final box = await _getBox();
    await box.put(_enabledKey, enabled);
  }

  Future<DateTime?> getLastSyncTime() async {
    final box = await _getBox();
    final ms = box.get(_lastSyncKey) as int?;
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setLastSyncTime(DateTime time) async {
    final box = await _getBox();
    await box.put(_lastSyncKey, time.millisecondsSinceEpoch);
  }
}
