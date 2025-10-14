import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

import 'screen_time_service.dart';
import '../providers/screen_time_provider.dart';
import '../providers/repository_providers.dart';
import '../providers/algorithm_provider.dart';

/// Service to periodically refresh screen time usage data.
/// 
/// Runs hourly when app is active to keep usage data current.
/// Handles day rollover and permission state changes.
/// 
/// **Educational Note:**
/// Screen time accumulates throughout the day. Periodic updates ensure
/// users always see current usage. We balance accuracy vs battery/performance
/// by updating hourly instead of continuously.
class ScreenTimeRefreshService with WidgetsBindingObserver {
  ScreenTimeRefreshService({
    required ScreenTimeService screenTimeService,
  }) : _screenTimeService = screenTimeService;

  final ScreenTimeService _screenTimeService;
  Timer? _refreshTimer;
  DateTime? _lastRefreshDay;
  WidgetRef? _ref;

  /// Start periodic refresh (every hour)
  void startPeriodicRefresh(WidgetRef ref) {
    // Cancel existing timer if any
    stopPeriodicRefresh();
    
    developer.log(
      'Starting periodic screen time refresh (hourly)',
      name: 'ScreenTimeRefreshService',
    );

    // Initial refresh
    _refreshScreenTime(ref);

    // Set up hourly timer
    _refreshTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _refreshScreenTime(ref),
    );

    // keep ref for lifecycle-triggered refreshes
    _ref = ref;

    // register lifecycle observer so we can re-check permission on resume
    try {
      WidgetsBinding.instance.addObserver(this);
    } catch (_) {
      // WidgetsBinding may be unavailable in some test environments
    }
  }

  /// Stop periodic refresh
  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    
    developer.log(
      'Stopped periodic screen time refresh',
      name: 'ScreenTimeRefreshService',
    );
  }

  /// Manually trigger refresh (useful for testing or user-initiated refresh)
  Future<void> manualRefresh(WidgetRef ref) async {
    await _refreshScreenTime(ref);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_ref != null) {
        // schedule refresh on resume
        Future.microtask(() => _refreshScreenTime(_ref!));
      }
    }
  }

  /// Internal refresh logic
  Future<void> _refreshScreenTime(WidgetRef ref) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Check for day rollover
      if (_lastRefreshDay != null && _lastRefreshDay!.day != today.day) {
        developer.log(
          'Day rollover detected: ${_lastRefreshDay} -> $today',
          name: 'ScreenTimeRefreshService',
        );
        
        // Invalidate providers to reset for new day
        ref.invalidate(usedScreenTimeProvider);
        ref.invalidate(screenTimeStateProvider);
      }

      // Update last refresh day
      _lastRefreshDay = today;

      // Check permission status
      final hasPermission = await _screenTimeService.hasPermission();
      
      if (!hasPermission) {
        developer.log(
          'Permission not granted, skipping refresh',
          name: 'ScreenTimeRefreshService',
        );
        return;
      }

      // Invalidate provider to trigger fresh fetch
      ref.invalidate(usedScreenTimeProvider);
      ref.invalidate(screenTimeStateProvider);

      // Also ensure the latest screen time is persisted for today's entry
      // This will trigger an update to the daily habit entry for today
      final currentScreenTimeState = await ref.read(screenTimeStateProvider.future);
      final dailyRepo = ref.read(dailyHabitRepositoryProvider);
      final algorithmResult = ref.read(algorithmResultProvider);

      // Fetch the existing entry for today to preserve other fields
      final now = DateTime.now();
      final currentUserId = algorithmResult.userId; // Get user ID from algorithm result
      final existingEntry = await dailyRepo.getEntryForDate(userId: currentUserId, date: now);

      await dailyRepo.upsertEntry(
        userId: currentUserId, // Use the actual user ID
        date: now,
        minutesByCategory: existingEntry?.minutesByCategory ?? {},
        earnedScreenTime: currentScreenTimeState.earned,
        usedScreenTime: currentScreenTimeState.used,
        remainingScreenTime: currentScreenTimeState.remaining,
        powerModeUnlocked: algorithmResult.powerModeUnlocked,
        algorithmVersion: algorithmResult.version,
        manualAdjustmentMinutes: existingEntry?.manualAdjustmentMinutes ?? 0,
        ref: ref, // Pass the WidgetRef
      );
      
      developer.log(
        'Screen time data refreshed successfully and persisted',
        name: 'ScreenTimeRefreshService',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error during screen time refresh: $e',
        name: 'ScreenTimeRefreshService',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't throw - silent failure for background updates
    }
  }

  void dispose() {
    stopPeriodicRefresh();
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (_) {}
  }
}

/// Provider for screen time refresh service
final screenTimeRefreshServiceProvider = Provider<ScreenTimeRefreshService>((ref) {
  final service = ScreenTimeRefreshService(
    screenTimeService: ref.watch(screenTimeServiceProvider),
  );
  
  ref.onDispose(service.dispose);
  
  return service;
});

