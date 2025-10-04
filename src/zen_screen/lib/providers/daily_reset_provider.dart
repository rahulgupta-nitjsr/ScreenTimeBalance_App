import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_reset_provider.g.dart';

/// Provider to track the current day for daily reset logic
@riverpod
class CurrentDay extends _$CurrentDay {
  @override
  DateTime build() {
    // Initialize with today's date (date only, no time)
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Check if a new day has started and update if necessary
  bool checkAndUpdateDay() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    if (todayDate.isAfter(state)) {
      state = todayDate;
      return true; // New day detected
    }
    
    return false; // Same day
  }

  /// Force reset to current day (useful for testing)
  void resetToToday() {
    final today = DateTime.now();
    state = DateTime(today.year, today.month, today.day);
  }
}

/// Provider to track if POWER+ Mode has been achieved today
@riverpod
class PowerModeAchievedToday extends _$PowerModeAchievedToday {
  @override
  bool build() => false;

  /// Mark POWER+ Mode as achieved today
  void markAchieved() {
    state = true;
  }

  /// Reset achievement status (called on daily reset)
  void resetAchievement() {
    state = false;
  }
}

/// Provider to track daily celebration shown status
@riverpod
class DailyCelebrationShown extends _$DailyCelebrationShown {
  @override
  bool build() => false;

  /// Mark that celebration has been shown today
  void markShown() {
    state = true;
  }

  /// Reset celebration status (called on daily reset)
  void resetCelebration() {
    state = false;
  }
}

/// Service class to handle daily reset logic
class DailyResetService {
  /// Check if it's a new day and reset daily states if necessary
  static bool checkDailyReset(Ref ref) {
    final currentDay = ref.read(currentDayProvider.notifier);
    final powerModeAchieved = ref.read(powerModeAchievedTodayProvider.notifier);
    final celebrationShown = ref.read(dailyCelebrationShownProvider.notifier);
    
    final isNewDay = currentDay.checkAndUpdateDay();
    
    if (isNewDay) {
      // Reset daily states for new day
      powerModeAchieved.resetAchievement();
      celebrationShown.resetCelebration();
      
      // TODO: Reset any other daily states here
      // - Daily habit entries
      // - Timer sessions
      // - Achievement badges
      // - etc.
      
      return true;
    }
    
    return false;
  }

  /// Force daily reset (useful for testing or manual reset)
  static void forceDailyReset(Ref ref) {
    final currentDay = ref.read(currentDayProvider.notifier);
    final powerModeAchieved = ref.read(powerModeAchievedTodayProvider.notifier);
    final celebrationShown = ref.read(dailyCelebrationShownProvider.notifier);
    
    currentDay.resetToToday();
    powerModeAchieved.resetAchievement();
    celebrationShown.resetCelebration();
  }
}

/// Provider that automatically checks for daily reset when accessed
@riverpod
bool dailyResetCheck(DailyResetCheckRef ref) {
  // This provider will rebuild whenever currentDay changes
  final currentDay = ref.watch(currentDayProvider);
  
  // Check for daily reset
  DailyResetService.checkDailyReset(ref);
  
  // Return whether it's a new day (for components that need to react)
  return currentDay == DateTime.now();
}
