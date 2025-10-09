import 'habit_category.dart';

/// Result of the algorithm calculation
class AlgorithmResult {
  final int totalEarnedMinutes;
  final bool powerModeUnlocked;
  final Map<HabitCategory, CategoryResult> categoryResults;
  final Map<HabitCategory, int> perCategoryLoggedMinutes;
  final Map<HabitCategory, int> perCategoryEarned;

  const AlgorithmResult({
    required this.totalEarnedMinutes,
    required this.powerModeUnlocked,
    required this.categoryResults,
    required this.perCategoryLoggedMinutes,
    required this.perCategoryEarned,
  });

  /// Create an empty result
  factory AlgorithmResult.empty() {
    return AlgorithmResult(
      totalEarnedMinutes: 0,
      powerModeUnlocked: false,
      categoryResults: {},
      perCategoryLoggedMinutes: {},
      perCategoryEarned: {},
    );
  }
}

/// Result for a specific category
class CategoryResult {
  final int loggedMinutes;
  final int earnedMinutes;
  final int maxMinutes;
  final double progressPercentage;
  final bool goalAchieved;

  const CategoryResult({
    required this.loggedMinutes,
    required this.earnedMinutes,
    required this.maxMinutes,
    required this.progressPercentage,
    required this.goalAchieved,
  });
}
