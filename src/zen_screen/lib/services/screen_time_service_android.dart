import 'dart:developer' as developer;

import 'package:app_usage/app_usage.dart';
import 'package:permission_handler/permission_handler.dart';

import 'screen_time_service.dart';

/// Android-specific implementation of ScreenTimeService.
/// 
/// Uses the UsageStatsManager API via the app_usage Flutter package
/// to fetch device screen time statistics.
/// 
/// **Educational Note:**
/// Android's UsageStatsManager provides per-app usage data. We aggregate
/// all apps to get total device screen time. This requires special permission
/// (PACKAGE_USAGE_STATS) that users must grant manually in Settings.
class ScreenTimeServiceAndroidImpl implements ScreenTimeService {
  @override
  Future<bool> hasPermission() async {
    try {
      // Some versions of the app_usage package expose permission helpers.
      // To avoid API mismatch across versions, attempt a lightweight usage
      // query for the last minute — if it throws due to permission, we
      // consider permission not granted.
      final now = DateTime.now();
      final start = now.subtract(const Duration(minutes: 1));
      try {
        await AppUsage().getAppUsage(start, now);
        return true;
      } catch (e) {
        developer.log(
          'Usage permission not available or query failed: $e',
          name: 'ScreenTimeService',
          error: e,
        );
        return false;
      }
    } catch (e) {
      developer.log(
        'Error checking usage permission: $e',
        name: 'ScreenTimeService',
        error: e,
      );
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      // We can't request this permission directly - must open Settings
      await openUsageSettings();
      
      // Return false immediately since permission isn't granted yet
      // Caller should check hasPermission() after app resumes
      return false;
    } catch (e) {
      developer.log(
        'Error requesting usage permission: $e',
        name: 'ScreenTimeService',
        error: e,
      );
      return false;
    }
  }

  @override
  Future<int> getTodayUsedMinutes() async {
    try {
      // Check permission first
      final permitted = await hasPermission();
      if (!permitted) {
        developer.log(
          'Usage permission not granted, returning 0 minutes',
          name: 'ScreenTimeService',
        );
        return 0;
      }

      // Get start of today (midnight)
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfToday = now;

      developer.log(
        'Fetching usage from $startOfToday to $endOfToday',
        name: 'ScreenTimeService',
      );

      // Query usage statistics for today
      final usageStats = await AppUsage().getAppUsage(startOfToday, endOfToday);

      // Aggregate all app usage durations
      int totalMilliseconds = 0;
      for (final stat in usageStats) {
        // stat.usage is a Duration object
        totalMilliseconds += stat.usage.inMilliseconds;
      }

      // Convert milliseconds to minutes, round to nearest minute
      final totalMinutes = (totalMilliseconds / (1000 * 60)).round();

      developer.log(
        'Total usage today: $totalMinutes minutes (from ${usageStats.length} apps)',
        name: 'ScreenTimeService',
      );

      return totalMinutes;
    } catch (e, stackTrace) {
      // Log error but don't crash - return 0 as fallback
      developer.log(
        'Error fetching today\'s usage: $e',
        name: 'ScreenTimeService',
        error: e,
        stackTrace: stackTrace,
      );
      return 0;
    }
  }

  @override
  Future<bool> isOemRestricted() async {
    try {
      final hasUsagePermission = await hasPermission();
      if (!hasUsagePermission) {
        return false; // Not restricted if permission isn't even granted
      }

      // Attempt to get usage for a very short period. If permission is granted
      // but no data is returned, it suggests OEM restriction.
      final now = DateTime.now();
      final start = now.subtract(const Duration(seconds: 10)); // Short window
      final usageStats = await AppUsage().getAppUsage(start, now);

      if (usageStats.isEmpty) {
        developer.log(
          'OEM restriction detected: Usage stats empty despite permission',
          name: 'ScreenTimeService',
        );
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      developer.log(
        'Error checking OEM restriction: $e',
        name: 'ScreenTimeService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  Future<void> openUsageSettings() async {
    try {
      // Use permission_handler to open app settings
      // This will navigate to the Usage Access settings screen on Android
      await openAppSettings();
      
      developer.log(
        'Opened Usage Access settings',
        name: 'ScreenTimeService',
      );
    } catch (e) {
      developer.log(
        'Error opening usage settings: $e',
        name: 'ScreenTimeService',
        error: e,
      );
    }
  }
}

