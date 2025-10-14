import 'habit_category.dart';

/// Result of the algorithm calculation
class AlgorithmResult {
  final int totalEarnedMinutes;
  final bool powerModeUnlocked;
  final Map<HabitCategory, CategoryResult> categoryResults;
  final Map<HabitCategory, int> perCategoryLoggedMinutes;
  final Map<HabitCategory, int> perCategoryEarned;
  final String userId; // Add userId property
  final String algorithmVersion; // Add algorithmVersion property

  const AlgorithmResult({
    required this.totalEarnedMinutes,
    required this.powerModeUnlocked,
    required this.categoryResults,
    required this.perCategoryLoggedMinutes,
    required this.perCategoryEarned,
    this.userId = 'default_user_id', // Add userId to constructor with default
    this.algorithmVersion = '1.0.0', // Add algorithmVersion to constructor with default
  });

  /// Create an empty result
  factory AlgorithmResult.empty({
    String userId = 'default_user_id', // Add userId parameter to factory
    String algorithmVersion = '1.0.0', // Add algorithmVersion parameter to factory
  }) {
    return AlgorithmResult(
      totalEarnedMinutes: 0,
      powerModeUnlocked: false,
      categoryResults: {},
      perCategoryLoggedMinutes: {},
      perCategoryEarned: {},
      userId: userId,
      algorithmVersion: algorithmVersion,
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
