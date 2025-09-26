import 'package:flutter/material.dart';

enum HabitCategory { sleep, exercise, outdoor, productive }

extension HabitCategoryX on HabitCategory {
  String get id => switch (this) {
        HabitCategory.sleep => 'sleep',
        HabitCategory.exercise => 'exercise',
        HabitCategory.outdoor => 'outdoor',
        HabitCategory.productive => 'productive',
      };

  String get label => switch (this) {
        HabitCategory.sleep => 'Sleep',
        HabitCategory.exercise => 'Exercise',
        HabitCategory.outdoor => 'Outdoor',
        HabitCategory.productive => 'Productive',
      };

  IconData get icon => switch (this) {
        HabitCategory.sleep => Icons.bedtime,
        HabitCategory.exercise => Icons.fitness_center,
        HabitCategory.outdoor => Icons.park,
        HabitCategory.productive => Icons.menu_book,
      };

  Color primaryColor(BuildContext context) {
    switch (this) {
      case HabitCategory.sleep:
        return const Color(0xFF3A86FF);
      case HabitCategory.exercise:
        return const Color(0xFFFB5607);
      case HabitCategory.outdoor:
        return const Color(0xFF2EC4B6);
      case HabitCategory.productive:
        return const Color(0xFF8338EC);
    }
  }

  static HabitCategory fromId(String id) {
    return HabitCategory.values.firstWhere(
      (category) => category.id == id,
      orElse: () => HabitCategory.sleep,
    );
  }
}

const List<HabitCategory> orderedHabitCategories = [
  HabitCategory.sleep,
  HabitCategory.exercise,
  HabitCategory.outdoor,
  HabitCategory.productive,
];
