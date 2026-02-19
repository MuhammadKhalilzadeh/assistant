import 'dart:io';
import 'package:flutter/services.dart';
import 'package:assistant/data/models/screen_time_model.dart';

class DeviceScreenTimeService {
  static const _channel = MethodChannel('com.assistant/screen_time');

  /// Check if running on Android
  bool get isAndroid => Platform.isAndroid;

  /// Check if running on iOS
  bool get isIOS => Platform.isIOS;

  /// Check if device usage stats permission is granted (Android only)
  Future<bool> hasPermission() async {
    if (!isAndroid) return false;

    try {
      final result = await _channel.invokeMethod<bool>('hasPermission');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Open usage access settings so user can grant permission (Android only)
  Future<void> openUsageSettings() async {
    if (!isAndroid) return;

    try {
      await _channel.invokeMethod('openUsageSettings');
    } on PlatformException {
      // Settings couldn't be opened
    }
  }

  /// Get usage stats from the device for a specific date (Android only)
  /// Returns null if not supported or permission not granted
  Future<List<DeviceAppUsage>?> getUsageStats({DateTime? date}) async {
    if (!isAndroid) return null;

    try {
      final dateStr = (date ?? DateTime.now()).toIso8601String().split('T')[0];
      final result = await _channel.invokeListMethod<Map>('getUsageStats', {
        'date': dateStr,
      });

      if (result == null) return null;

      return result
          .map((item) => DeviceAppUsage(
                appName: item['appName'] as String? ?? 'Unknown',
                packageName: item['packageName'] as String? ?? '',
                minutesUsed: (item['totalTimeInForeground'] as num?)?.toInt() ?? 0,
                category: item['category'] as String? ?? 'other',
              ))
          .where((app) => app.minutesUsed > 0) // Filter out apps with 0 usage
          .toList();
    } on PlatformException {
      return null;
    }
  }

  /// Convert device usage data to a ScreenTimeRecord for syncing to backend
  Future<ScreenTimeRecord?> buildRecordFromDevice({DateTime? date}) async {
    final usageData = await getUsageStats(date: date);
    if (usageData == null || usageData.isEmpty) return null;

    final targetDate = date ?? DateTime.now();
    final totalMinutes = usageData.fold<int>(0, (sum, app) => sum + app.minutesUsed);

    return ScreenTimeRecord(
      id: '', // Will be assigned by backend
      date: DateTime(targetDate.year, targetDate.month, targetDate.day),
      totalMinutes: totalMinutes,
      pickups: 0, // Android UsageStats doesn't provide pickup count
      appUsage: usageData
          .map((app) => AppUsageEntry(
                id: '',
                appName: app.appName,
                category: app.category,
                minutesUsed: app.minutesUsed,
                iconName: _categoryToIcon(app.category),
              ))
          .toList(),
    );
  }

  String _categoryToIcon(String category) {
    switch (category) {
      case 'social':
        return 'people';
      case 'game':
        return 'sports_esports';
      case 'productivity':
        return 'work';
      case 'video':
        return 'video_library';
      case 'audio':
        return 'music_note';
      case 'news':
        return 'article';
      case 'maps':
        return 'map';
      case 'image':
        return 'photo';
      default:
        return 'apps';
    }
  }
}

/// Raw device app usage data from platform channel
class DeviceAppUsage {
  final String appName;
  final String packageName;
  final int minutesUsed;
  final String category;

  const DeviceAppUsage({
    required this.appName,
    required this.packageName,
    required this.minutesUsed,
    required this.category,
  });
}
