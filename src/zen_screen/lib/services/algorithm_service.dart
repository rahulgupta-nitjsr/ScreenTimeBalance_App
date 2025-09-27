import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/algorithm_config.dart';
import '../models/daily_habit_entry.dart';
import '../models/habit_category.dart';

class AlgorithmResult {
  AlgorithmResult({
    required this.totalEarnedMinutes,
    required this.powerModeUnlocked,
    required this.perCategoryEarned,
    required this.perCategoryLoggedMinutes,
    required this.algorithmVersion,
  });

  final int totalEarnedMinutes;
  final bool powerModeUnlocked;
  final Map<HabitCategory, int> perCategoryEarned;
  final Map<HabitCategory, int> perCategoryLoggedMinutes;
  final String algorithmVersion;
}

class AlgorithmService {
  AlgorithmService({required AlgorithmConfig config}) : _config = config;

  AlgorithmConfig _config;

  void updateConfig(AlgorithmConfig config) {
    _config = config;
  }

  AlgorithmResult calculate({
    required Map<HabitCategory, int> minutesByCategory,
  }) {
    final stopwatch = Stopwatch()..start();
    
    final perCategoryEarned = <HabitCategory, int>{};
    final thresholds = _config.powerPlus.goals;
    int qualifiedGoals = 0;
    int totalEarned = 0;

    for (final category in HabitCategory.values) {
      final config = _config.categories[category.id];
      if (config == null) continue;

      // Handle negative values and ensure non-negative input
      final minutes = max(0, minutesByCategory[category] ?? 0);
      final cappedMinutes = min(minutes, config.maxMinutes);
      final earned = ((cappedMinutes / 60) * config.minutesPerHour).round();

      perCategoryEarned[category] = earned;
      totalEarned += earned;

      final thresholdMinutes = thresholds[category.id];
      if (thresholdMinutes != null && minutes >= thresholdMinutes) {
        qualifiedGoals += 1;
      }

      final penalty = config.penalties;
      if (penalty != null) {
        if (minutes < penalty.underMinutes || minutes > penalty.overMinutes) {
          final penaltyAmount = min(earned, penalty.penaltyMinutes);
          perCategoryEarned[category] = max(0, earned - penaltyAmount);
          totalEarned = max(0, totalEarned - penaltyAmount);
        }
      }
    }

    final bool powerModeUnlocked = qualifiedGoals >= _config.powerPlus.requiredGoals;
    if (powerModeUnlocked) {
      totalEarned += _config.powerPlus.bonusMinutes;
    }

    final cap = powerModeUnlocked ? _config.dailyCaps.powerPlusMinutes : _config.dailyCaps.baseMinutes;
    totalEarned = min(totalEarned, cap);

    stopwatch.stop();
    
    // Performance monitoring in debug mode
    if (kDebugMode && stopwatch.elapsedMicroseconds > 1000) {
      print('⚠️ Algorithm calculation took ${stopwatch.elapsedMicroseconds}μs (threshold: 1000μs)');
    }

    return AlgorithmResult(
      totalEarnedMinutes: totalEarned,
      powerModeUnlocked: powerModeUnlocked,
      perCategoryEarned: perCategoryEarned,
      perCategoryLoggedMinutes: Map<HabitCategory, int>.from(minutesByCategory),
      algorithmVersion: _config.version,
    );
  }

  DailyHabitEntry buildDailyEntry({
    required String id,
    required String userId,
    required DateTime date,
    required Map<HabitCategory, int> minutesByCategory,
    int usedScreenTime = 0,
  }) {
    // Validate inputs
    if (id.isEmpty) throw ArgumentError('ID cannot be empty');
    if (userId.isEmpty) throw ArgumentError('User ID cannot be empty');
    if (usedScreenTime < 0) throw ArgumentError('Used screen time cannot be negative');
    
    final result = calculate(minutesByCategory: minutesByCategory);
    final now = DateTime.now();
    return DailyHabitEntry(
      id: id,
      userId: userId,
      date: date,
      minutesByCategory: minutesByCategory,
      earnedScreenTime: result.totalEarnedMinutes,
      usedScreenTime: usedScreenTime,
      manualAdjustmentMinutes: 0,
      powerModeUnlocked: result.powerModeUnlocked,
      algorithmVersion: result.algorithmVersion,
      createdAt: now,
      updatedAt: now,
    );
  }
}
