import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/habit_category.dart';
import '../providers/auth_provider.dart';
import '../providers/repository_providers.dart';

part 'historical_data_provider.g.dart';

/// Provider to get yesterday's sleep data for "same as last night" functionality
@riverpod
Future<int> yesterdaySleepMinutes(YesterdaySleepMinutesRef ref) async {
  final repository = ref.read(dailyHabitRepositoryProvider);
  final authState = ref.read(authControllerProvider);
  
  // Return 0 if not authenticated
  if (authState is! Authenticated) {
    return 0;
  }
  
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  
  try {
    final entry = await repository.getEntryForDate(
      userId: authState.user.id, // ✅ Use authenticated user ID
      date: yesterday,
    );
    
    if (entry != null) {
      return entry.minutesByCategory[HabitCategory.sleep] ?? 0;
    }
    
    return 0;
  } catch (e) {
    // If there's an error getting yesterday's data, return 0
    return 0;
  }
}

/// Provider to get the most recent sleep data (yesterday or today)
@riverpod
Future<int> lastSleepMinutes(LastSleepMinutesRef ref) async {
  final repository = ref.read(dailyHabitRepositoryProvider);
  final authState = ref.read(authControllerProvider);
  
  // Return 0 if not authenticated
  if (authState is! Authenticated) {
    return 0;
  }
  
  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  
  try {
    // Try to get today's data first
    final todayEntry = await repository.getEntryForDate(
      userId: authState.user.id, // ✅ Use authenticated user ID
      date: today,
    );
    
    if (todayEntry != null && (todayEntry.minutesByCategory[HabitCategory.sleep] ?? 0) > 0) {
      return todayEntry.minutesByCategory[HabitCategory.sleep]!;
    }
    
    // If no data for today, try yesterday
    final yesterdayEntry = await repository.getEntryForDate(
      userId: authState.user.id, // ✅ Use authenticated user ID
      date: yesterday,
    );
    
    if (yesterdayEntry != null) {
      return yesterdayEntry.minutesByCategory[HabitCategory.sleep] ?? 0;
    }
    
    return 0;
  } catch (e) {
    // If there's an error getting data, return 0
    return 0;
  }
}

/// Provider to get historical data for any category
@riverpod
Future<Map<HabitCategory, int>> lastCategoryMinutes(LastCategoryMinutesRef ref, HabitCategory category) async {
  final repository = ref.read(dailyHabitRepositoryProvider);
  final authState = ref.read(authControllerProvider);
  
  // Return empty map if not authenticated
  if (authState is! Authenticated) {
    return {category: 0};
  }
  
  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  
  try {
    // Try to get today's data first
    final todayEntry = await repository.getEntryForDate(
      userId: authState.user.id, // ✅ Use authenticated user ID
      date: today,
    );
    
    if (todayEntry != null && (todayEntry.minutesByCategory[category] ?? 0) > 0) {
      return {category: todayEntry.minutesByCategory[category]!};
    }
    
    // If no data for today, try yesterday
    final yesterdayEntry = await repository.getEntryForDate(
      userId: authState.user.id, // ✅ Use authenticated user ID
      date: yesterday,
    );
    
    if (yesterdayEntry != null) {
      return {category: yesterdayEntry.minutesByCategory[category] ?? 0};
    }
    
    return {category: 0};
  } catch (e) {
    // If there's an error getting data, return 0
    return {category: 0};
  }
}

/// Provider to get 7-day historical data for sparklines
@riverpod
Future<List<int>> historicalData7Days(HistoricalData7DaysRef ref, HabitCategory category) async {
  final repository = ref.read(dailyHabitRepositoryProvider);
  final authState = ref.read(authControllerProvider);
  
  // Return empty list if not authenticated
  if (authState is! Authenticated) {
    return List.filled(7, 0);
  }
  
  final today = DateTime.now();
  final List<int> historicalData = [];
  
  try {
    // Get data for last 7 days (including today)
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final entry = await repository.getEntryForDate(
        userId: authState.user.id,
        date: date,
      );
      
      final minutes = entry?.minutesByCategory[category] ?? 0;
      historicalData.add(minutes);
    }
    
    return historicalData;
  } catch (e) {
    // If there's an error, return empty data
    return List.filled(7, 0);
  }
}

/// Provider to check if POWER+ Mode was achieved on a specific date
@riverpod
Future<bool> powerModeAchievedOnDate(PowerModeAchievedOnDateRef ref, DateTime date) async {
  final repository = ref.read(dailyHabitRepositoryProvider);
  final authState = ref.read(authControllerProvider);
  
  if (authState is! Authenticated) {
    return false;
  }
  
  try {
    final entry = await repository.getEntryForDate(
      userId: authState.user.id,
      date: date,
    );
    
    return entry?.powerModeUnlocked ?? false;
  } catch (e) {
    return false;
  }
}

/// Provider to get POWER+ Mode achievement streak
@riverpod
Future<int> powerModeStreak(PowerModeStreakRef ref) async {
  final authState = ref.read(authControllerProvider);
  
  if (authState is! Authenticated) {
    return 0;
  }
  
  final today = DateTime.now();
  int streak = 0;
  
  try {
    // Check consecutive days starting from today
    for (int i = 0; i < 30; i++) { // Check up to 30 days
      final date = today.subtract(Duration(days: i));
      final wasAchieved = await ref.read(powerModeAchievedOnDateProvider(date).future);
      
      if (wasAchieved) {
        streak++;
      } else {
        break; // Streak broken
      }
    }
    
    return streak;
  } catch (e) {
    return 0;
  }
}