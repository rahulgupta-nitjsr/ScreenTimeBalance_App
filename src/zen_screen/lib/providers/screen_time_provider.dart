import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/screen_time_service.dart';
import 'algorithm_provider.dart';

/// Provides the ScreenTimeService instance.
/// 
/// This provider automatically selects the correct platform implementation
/// (Android or stub) and caches it for reuse.
final screenTimeServiceProvider = Provider<ScreenTimeService>((ref) {
  return ScreenTimeService.getInstance();
});

/// Provides the current usage permission status.
/// 
/// **Auto-refresh:** This provider automatically checks permission status.
/// Call `ref.refresh(hasUsagePermissionProvider)` to re-check after
/// returning from Settings.
final hasUsagePermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(screenTimeServiceProvider);
  return await service.hasPermission();
});

/// Provides today's screen time used in minutes (from Android OS).
/// 
/// Returns 0 if:
/// - Permission not granted
/// - Platform doesn't support usage stats
/// - Error occurs during fetch
/// 
/// **Performance:** This provider caches the result. To refresh (e.g., hourly),
/// call `ref.refresh(usedScreenTimeProvider)`.
final usedScreenTimeProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(screenTimeServiceProvider);
  
  // Check permission first
  final hasPermission = await ref.watch(hasUsagePermissionProvider.future);
  if (!hasPermission) {
    return 0;
  }
  
  // Fetch usage data
  return await service.getTodayUsedMinutes();
});

/// Combined screen time state containing earned, used, and remaining minutes.
/// 
/// **Educational Note:**
/// This is the single source of truth for all three screen time values.
/// UI components should watch this provider instead of managing multiple sources.
/// 
/// The provider automatically:
/// - Fetches earned time from the existing algorithm
/// - Fetches used time from Android OS
/// - Computes remaining time (with clamping to zero)
/// - Rebuilds UI when any value changes
class ScreenTimeState {
  const ScreenTimeState({
    required this.earned,
    required this.used,
    required this.remaining,
    required this.hasPermission,
    required this.isOemRestricted,
  });

  /// Minutes of screen time earned today (from habits)
  final int earned;
  
  /// Minutes of screen time used today (from Android OS)
  final int used;
  
  /// Minutes of screen time remaining (earned - used, never negative)
  final int remaining;
  
  /// Whether the app has permission to access usage statistics
  final bool hasPermission;
  
  /// Whether the device is OEM-restricted and usage stats unavailable
  final bool isOemRestricted;

  /// Check if user has exceeded their earned time
  bool get isOverBudget => earned > 0 && used > earned;

  /// Check if user is close to their limit (>80% used)
  bool get isNearLimit => earned > 0 && used >= (earned * 0.8);

  @override
  String toString() => 'ScreenTimeState(earned: $earned, used: $used, remaining: $remaining, hasPermission: $hasPermission)';
}

/// Provides the combined screen time state.
/// 
/// This provider watches both the earned time (from existing providers)
/// and the used time (from usage stats), then computes remaining time.
/// 
/// **Update latency:** < 100ms after earned time changes
/// **Clamping:** Remaining is always >= 0 (never negative)
final screenTimeStateProvider = FutureProvider<ScreenTimeState>((ref) async {
  final service = ref.watch(screenTimeServiceProvider);
  // Get permission status
  final hasPermission = await ref.watch(hasUsagePermissionProvider.future);
  
  // Get OEM restriction status
  final isOemRestricted = await service.isOemRestricted();

  // Get earned time from algorithm (synchronous)
  final earned = ref.watch(_earnedScreenTimeProvider);
  
  // Get used time from OS
  final used = hasPermission && !isOemRestricted
      ? await ref.watch(usedScreenTimeProvider.future)
      : 0;
  
  // Compute remaining time (never negative)
  final remaining = max(earned - used, 0);
  
  return ScreenTimeState(
    earned: earned,
    used: used,
    remaining: remaining,
    hasPermission: hasPermission,
    isOemRestricted: isOemRestricted,
  );
});

/// Provider for earned screen time from the algorithm.
/// 
/// Integrates with the existing algorithm_provider to get the actual
/// earned screen time based on today's logged habits.
final _earnedScreenTimeProvider = Provider<int>((ref) {
  final algorithmResult = ref.watch(algorithmResultProvider);
  return algorithmResult.totalEarnedMinutes;
});

/// Helper provider to request usage permission.
/// 
/// Call this from UI to open the Usage Access settings.
/// After user returns, refresh hasUsagePermissionProvider to check status.
final requestUsagePermissionProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(screenTimeServiceProvider);
  await service.requestPermission();
});

