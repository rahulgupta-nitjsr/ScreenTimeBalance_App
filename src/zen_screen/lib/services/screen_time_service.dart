import 'dart:io';

import 'screen_time_service_android.dart';

/// Abstract service for fetching device screen time usage.
/// 
/// This service provides a platform-agnostic interface for accessing
/// the device's screen time statistics. Implementations are platform-specific.
/// 
/// Feature 17: Device Screen Time Used (Android-first, Hybrid)
abstract class ScreenTimeService {
  /// Check if the app has permission to access usage statistics.
  /// 
  /// On Android, this checks for PACKAGE_USAGE_STATS permission.
  /// Returns true if permission is granted, false otherwise.
  Future<bool> hasPermission();

  /// Request permission to access usage statistics.
  /// 
  /// On Android, this opens the Usage Access settings screen where
  /// the user must manually grant permission. Returns false immediately
  /// since the permission cannot be granted programmatically.
  /// 
  /// On app resume, call [hasPermission] again to check if user granted it.
  Future<bool> requestPermission();

  /// Get the total screen time used today in minutes.
  /// 
  /// Fetches usage data from midnight (00:00) today until now.
  /// Aggregates all app usage into a single total.
  /// 
  /// Returns 0 if:
  /// - Permission is not granted
  /// - Device doesn't support usage stats
  /// - An error occurs during fetch
  /// 
  /// Throws: May log exceptions but won't throw to caller
  Future<int> getTodayUsedMinutes();

  /// Checks if the device is OEM-restricted, meaning usage stats might be
  /// unavailable even if permission is granted.
  Future<bool> isOemRestricted();

  /// Open the device's Usage Access settings screen.
  /// 
  /// On Android, deeplinks to Settings > Apps > Special app access > Usage access
  /// The user must tap the app name and toggle "Permit usage access".
  Future<void> openUsageSettings();

  /// Factory method to get the appropriate implementation for the current platform.
  /// 
  /// Returns:
  /// - [ScreenTimeServiceAndroid] on Android
  /// - [ScreenTimeServiceStub] on iOS, web, desktop, or unsupported platforms
  static ScreenTimeService getInstance() {
    if (Platform.isAndroid) {
      // Use dynamic import to avoid issues on other platforms
      return _getAndroidImplementation();
    } else {
      // Stub implementation for iOS, web, desktop
      return ScreenTimeServiceStub();
    }
  }

  /// Helper to get Android implementation using dynamic loading
  static ScreenTimeService _getAndroidImplementation() {
    return ScreenTimeServiceAndroidImpl();
  }
}

/// Stub implementation for platforms that don't support screen time tracking.
/// 
/// Used on iOS (until Platform Channels implementation), web, and desktop.
/// Provides safe defaults that won't crash the app.
class ScreenTimeServiceStub implements ScreenTimeService {
  @override
  Future<bool> hasPermission() async {
    return false;
  }

  @override
  Future<bool> requestPermission() async {
    return false;
  }

  @override
  Future<int> getTodayUsedMinutes() async {
    return 0;
  }

  @override
  Future<bool> isOemRestricted() async {
    return false;
  }

  @override
  Future<void> openUsageSettings() async {
    // No-op on unsupported platforms
  }
}


