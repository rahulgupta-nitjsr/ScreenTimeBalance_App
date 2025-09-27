import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit_category.dart';
import 'algorithm_provider.dart';

class MinutesByCategoryNotifier extends StateNotifier<Map<HabitCategory, int>> {
  MinutesByCategoryNotifier()
      : super({
          for (final category in HabitCategory.values) category: 0,
        });

  void setMinutes(HabitCategory category, int minutes) {
    // Validate: prevent negative values and ensure non-negative input
    final validatedMinutes = minutes < 0 ? 0 : minutes;
    
    state = {
      ...state,
      category: validatedMinutes,
    };
  }

  void setMinutesWithValidation(HabitCategory category, int minutes, {int? maxMinutes}) {
    // Validate: prevent negative values
    final validatedMinutes = minutes < 0 ? 0 : minutes;
    
    // Validate: enforce category maximum if provided
    final finalMinutes = maxMinutes != null 
        ? (validatedMinutes > maxMinutes ? maxMinutes : validatedMinutes)
        : validatedMinutes;
    
    state = {
      ...state,
      category: finalMinutes,
    };
  }

  void setAll(Map<HabitCategory, int> values) {
    state = {
      for (final category in HabitCategory.values) category: values[category] ?? 0,
    };
  }

  void incrementMinutes(HabitCategory category, int delta) {
    final current = state[category] ?? 0;
    setMinutes(category, current + delta);
  }

  void resetAll() {
    state = {
      for (final category in HabitCategory.values) category: 0,
    };
  }
}

final minutesByCategoryProvider = StateNotifierProvider<MinutesByCategoryNotifier, Map<HabitCategory, int>>((ref) {
  return MinutesByCategoryNotifier();
});
