import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/habit_category.dart';
import '../providers/repository_providers.dart';

part 'historical_data_provider.g.dart';

/// Provider to get yesterday's sleep data for "same as last night" functionality
@riverpod
Future<int> yesterdaySleepMinutes(YesterdaySleepMinutesRef ref) async {
  final repository = ref.read(dailyHabitRepositoryProvider);
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  
  try {
    final entry = await repository.getEntryForDate(
      userId: 'local-user',
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
  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  
  try {
    // Try to get today's data first
    final todayEntry = await repository.getEntryForDate(
      userId: 'local-user',
      date: today,
    );
    
    if (todayEntry != null && (todayEntry.minutesByCategory[HabitCategory.sleep] ?? 0) > 0) {
      return todayEntry.minutesByCategory[HabitCategory.sleep]!;
    }
    
    // If no data for today, try yesterday
    final yesterdayEntry = await repository.getEntryForDate(
      userId: 'local-user',
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
  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  
  try {
    // Try to get today's data first
    final todayEntry = await repository.getEntryForDate(
      userId: 'local-user',
      date: today,
    );
    
    if (todayEntry != null && (todayEntry.minutesByCategory[category] ?? 0) > 0) {
      return {category: todayEntry.minutesByCategory[category]!};
    }
    
    // If no data for today, try yesterday
    final yesterdayEntry = await repository.getEntryForDate(
      userId: 'local-user',
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
