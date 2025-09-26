import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit_category.dart';

class MinutesByCategoryNotifier extends StateNotifier<Map<HabitCategory, int>> {
  MinutesByCategoryNotifier()
      : super({
          for (final category in HabitCategory.values) category: 0,
        });

  void setMinutes(HabitCategory category, int minutes) {
    state = {
      ...state,
      category: minutes,
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
