import 'package:flutter_test/flutter_test.dart';
import 'package:zen_screen/models/algorithm_config.dart';
import 'package:zen_screen/models/daily_habit_entry.dart';
import 'package:zen_screen/models/habit_category.dart';
import 'package:zen_screen/services/algorithm_service.dart';

void main() {
  group('Feature 4: Core Earning Algorithm - Integration Tests', () {
    late AlgorithmService algorithmService;
    late AlgorithmConfig testConfig;

    setUp(() {
      // Create test configuration matching the production JSON config
      testConfig = AlgorithmConfig(
        version: '1.0.0-integration-test',
        updatedAt: DateTime.now(),
        powerPlus: PowerPlusConfig(
          bonusMinutes: 30,
          requiredGoals: 3,
          goals: const {
            'sleep': 420,    // 7 hours
            'exercise': 45,   // 45 minutes
            'outdoor': 30,    // 30 minutes
            'productive': 120, // 2 hours
          },
        ),
        categories: {
          'sleep': CategoryConfig(
            label: 'Sleep',
            minutesPerHour: 25,
            maxMinutes: 540, // 9 hours
            penalties: PenaltyConfig(
              underMinutes: 360, // 6 hours
              overMinutes: 540,  // 9 hours
              penaltyMinutes: 20,
            ),
          ),
          'exercise': CategoryConfig(
            label: 'Exercise',
            minutesPerHour: 20,
            maxMinutes: 120, // 2 hours
          ),
          'outdoor': CategoryConfig(
            label: 'Outdoor',
            minutesPerHour: 15,
            maxMinutes: 120, // 2 hours
          ),
          'productive': CategoryConfig(
            label: 'Productive',
            minutesPerHour: 10,
            maxMinutes: 240, // 4 hours
          ),
        },
        dailyCaps: DailyCaps(
          baseMinutes: 120,    // 2 hours
          powerPlusMinutes: 150, // 2.5 hours
        ),
      );

      algorithmService = AlgorithmService(config: testConfig);
    });

    group('Complete Earning Scenarios', () {
      test('Scenario 1: Perfect day with all goals met', () {
        final minutesByCategory = {
          HabitCategory.sleep: 420,    // 7 hours (meets goal)
          HabitCategory.exercise: 60,  // 1 hour (meets goal)
          HabitCategory.outdoor: 45,   // 45 minutes (meets goal)
          HabitCategory.productive: 150, // 2.5 hours (meets goal)
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        // Base calculations:
        // Sleep: 7 * 25 = 175 minutes
        // Exercise: 1 * 20 = 20 minutes
        // Outdoor: 0.75 * 15 = 11.25 minutes (rounded to 11)
        // Productive: 2.5 * 10 = 25 minutes
        // Total: 175 + 20 + 11 + 25 = 231 minutes
        // POWER+ Mode: +30 minutes = 261 minutes
        // Capped at 150 minutes (POWER+ limit)

        expect(result.powerModeUnlocked, isTrue);
        expect(result.totalEarnedMinutes, equals(150)); // Capped at POWER+ limit
        expect(result.perCategoryEarned[HabitCategory.sleep], equals(175));
        expect(result.perCategoryEarned[HabitCategory.exercise], equals(20));
        expect(result.perCategoryEarned[HabitCategory.outdoor], equals(11));
        expect(result.perCategoryEarned[HabitCategory.productive], equals(25));
      });

      test('Scenario 2: Partial day with 2 goals met', () {
        final minutesByCategory = {
          HabitCategory.sleep: 360,    // 6 hours (does not meet 7-hour goal)
          HabitCategory.exercise: 30,   // 30 minutes (does not meet 45-min goal)
          HabitCategory.outdoor: 45,    // 45 minutes (meets goal)
          HabitCategory.productive: 150, // 2.5 hours (meets goal)
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        // Base calculations:
        // Sleep: 6 * 25 = 150 minutes
        // Exercise: 0.5 * 20 = 10 minutes
        // Outdoor: 0.75 * 15 = 11.25 minutes (rounded to 11)
        // Productive: 2.5 * 10 = 25 minutes
        // Total: 150 + 10 + 11 + 25 = 196 minutes
        // No POWER+ Mode (only 2 goals met)

        expect(result.powerModeUnlocked, isFalse);
        expect(result.totalEarnedMinutes, equals(120)); // Capped at base limit
        expect(result.perCategoryEarned[HabitCategory.sleep], equals(150));
        expect(result.perCategoryEarned[HabitCategory.exercise], equals(10));
        expect(result.perCategoryEarned[HabitCategory.outdoor], equals(11));
        expect(result.perCategoryEarned[HabitCategory.productive], equals(25));
      });

      test('Scenario 3: Minimal day with no goals met', () {
        final minutesByCategory = {
          HabitCategory.sleep: 300,    // 5 hours (penalty applies)
          HabitCategory.exercise: 15,   // 15 minutes
          HabitCategory.outdoor: 10,    // 10 minutes
          HabitCategory.productive: 30, // 30 minutes
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        // Base calculations:
        // Sleep: 5 * 25 = 125 minutes, minus 20 penalty = 105 minutes
        // Exercise: 0.25 * 20 = 5 minutes
        // Outdoor: 0.167 * 15 = 2.5 minutes (rounded to 3)
        // Productive: 0.5 * 10 = 5 minutes
        // Total: 105 + 5 + 3 + 5 = 118 minutes

        expect(result.powerModeUnlocked, isFalse);
        expect(result.totalEarnedMinutes, equals(118));
        expect(result.perCategoryEarned[HabitCategory.sleep], equals(105)); // With penalty
      });

      test('Scenario 4: Excessive day with all categories maxed', () {
        final minutesByCategory = {
          HabitCategory.sleep: 600,    // 10 hours (penalty applies)
          HabitCategory.exercise: 180,  // 3 hours (capped at 2)
          HabitCategory.outdoor: 180,   // 3 hours (capped at 2)
          HabitCategory.productive: 300, // 5 hours (capped at 4)
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        // Base calculations with caps:
        // Sleep: 9 * 25 = 225 minutes, minus 20 penalty = 205 minutes
        // Exercise: 2 * 20 = 40 minutes (capped)
        // Outdoor: 2 * 15 = 30 minutes (capped)
        // Productive: 4 * 10 = 40 minutes (capped)
        // Total: 205 + 40 + 30 + 40 = 315 minutes
        // All 4 goals met, so POWER+ Mode unlocked, capped at 150 minutes

        expect(result.powerModeUnlocked, isTrue); // All 4 goals met
        expect(result.totalEarnedMinutes, equals(150)); // Capped at POWER+ limit
        expect(result.perCategoryEarned[HabitCategory.sleep], equals(205)); // With penalty
        expect(result.perCategoryEarned[HabitCategory.exercise], equals(40)); // Capped
        expect(result.perCategoryEarned[HabitCategory.outdoor], equals(30)); // Capped
        expect(result.perCategoryEarned[HabitCategory.productive], equals(40)); // Capped
      });
    });

    group('POWER+ Mode Edge Cases', () {
      test('Should unlock POWER+ Mode with exactly 3 goals met', () {
        final minutesByCategory = {
          HabitCategory.sleep: 420,    // 7 hours (meets goal)
          HabitCategory.exercise: 45,   // 45 minutes (meets goal)
          HabitCategory.outdoor: 30,    // 30 minutes (meets goal)
          HabitCategory.productive: 60, // 1 hour (does not meet 2-hour goal)
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        expect(result.powerModeUnlocked, isTrue);
        expect(result.totalEarnedMinutes, greaterThan(120)); // Should exceed base cap
      });

      test('Should not unlock POWER+ Mode with exactly 2 goals met', () {
        final minutesByCategory = {
          HabitCategory.sleep: 420,    // 7 hours (meets goal)
          HabitCategory.exercise: 45,   // 45 minutes (meets goal)
          HabitCategory.outdoor: 15,    // 15 minutes (does not meet 30-min goal)
          HabitCategory.productive: 60, // 1 hour (does not meet 2-hour goal)
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        expect(result.powerModeUnlocked, isFalse);
        expect(result.totalEarnedMinutes, lessThanOrEqualTo(120)); // Should be capped at base
      });

      test('Should unlock POWER+ Mode with all 4 goals met', () {
        final minutesByCategory = {
          HabitCategory.sleep: 420,    // 7 hours (meets goal)
          HabitCategory.exercise: 60,   // 1 hour (meets goal)
          HabitCategory.outdoor: 45,     // 45 minutes (meets goal)
          HabitCategory.productive: 150, // 2.5 hours (meets goal)
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        expect(result.powerModeUnlocked, isTrue);
        expect(result.totalEarnedMinutes, equals(150)); // Should be at POWER+ cap
      });
    });

    group('DailyHabitEntry Integration', () {
      test('Should build DailyHabitEntry with correct algorithm version', () {
        final minutesByCategory = {
          HabitCategory.sleep: 420,
          HabitCategory.exercise: 60,
          HabitCategory.outdoor: 30,
          HabitCategory.productive: 120,
        };

        final entry = algorithmService.buildDailyEntry(
          id: 'test-entry-1',
          userId: 'test-user-1',
          date: DateTime(2025, 9, 26),
          minutesByCategory: minutesByCategory,
          usedScreenTime: 45,
        );

        expect(entry.id, equals('test-entry-1'));
        expect(entry.userId, equals('test-user-1'));
        expect(entry.date, equals(DateTime(2025, 9, 26)));
        expect(entry.minutesByCategory, equals(minutesByCategory));
        expect(entry.usedScreenTime, equals(45));
        expect(entry.algorithmVersion, equals('1.0.0-integration-test'));
        expect(entry.powerModeUnlocked, isTrue);
        expect(entry.earnedScreenTime, greaterThan(0));
      });

      test('Should handle negative used screen time gracefully', () {
        final minutesByCategory = {
          HabitCategory.exercise: 60,
        };

        expect(() {
          algorithmService.buildDailyEntry(
            id: 'test-entry-2',
            userId: 'test-user-2',
            date: DateTime(2025, 9, 26),
            minutesByCategory: minutesByCategory,
            usedScreenTime: -10, // Negative value
          );
        }, throwsA(isA<ArgumentError>()));
      });

      test('Should handle empty ID gracefully', () {
        final minutesByCategory = {
          HabitCategory.exercise: 60,
        };

        expect(() {
          algorithmService.buildDailyEntry(
            id: '', // Empty ID
            userId: 'test-user-3',
            date: DateTime(2025, 9, 26),
            minutesByCategory: minutesByCategory,
          );
        }, throwsA(isA<ArgumentError>()));
      });
    });

    group('Real-time Performance', () {
      test('Should handle rapid successive calculations efficiently', () {
        final baseMinutes = {
          HabitCategory.sleep: 420,
          HabitCategory.exercise: 45,
          HabitCategory.outdoor: 30,
          HabitCategory.productive: 120,
        };

        final stopwatch = Stopwatch()..start();
        
        // Perform 100 rapid calculations
        for (int i = 0; i < 100; i++) {
          final result = algorithmService.calculate(minutesByCategory: baseMinutes);
          expect(result.totalEarnedMinutes, greaterThan(0));
        }
        
        stopwatch.stop();

        // Should complete 100 calculations in reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Less than 1 second
      });

      test('Should maintain accuracy across multiple calculations', () {
        final minutesByCategory = {
          HabitCategory.sleep: 420,
          HabitCategory.exercise: 45,
          HabitCategory.outdoor: 30,
          HabitCategory.productive: 120,
        };

        final results = <AlgorithmResult>[];
        
        // Perform multiple calculations
        for (int i = 0; i < 10; i++) {
          final result = algorithmService.calculate(minutesByCategory: minutesByCategory);
          results.add(result);
        }

        // All results should be identical
        for (int i = 1; i < results.length; i++) {
          expect(results[i].totalEarnedMinutes, equals(results[0].totalEarnedMinutes));
          expect(results[i].powerModeUnlocked, equals(results[0].powerModeUnlocked));
          expect(results[i].algorithmVersion, equals(results[0].algorithmVersion));
        }
      });
    });

    group('Mathematical Precision', () {
      test('Should handle fractional hours correctly', () {
        final minutesByCategory = {
          HabitCategory.exercise: 30, // 0.5 hours
          HabitCategory.outdoor: 15,  // 0.25 hours
          HabitCategory.productive: 45, // 0.75 hours
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        // Exercise: 0.5 * 20 = 10 minutes
        // Outdoor: 0.25 * 15 = 3.75 minutes (rounded to 4)
        // Productive: 0.75 * 10 = 7.5 minutes (rounded to 8)
        // Total: 10 + 4 + 8 = 22 minutes

        expect(result.totalEarnedMinutes, equals(22));
        expect(result.perCategoryEarned[HabitCategory.exercise], equals(10));
        expect(result.perCategoryEarned[HabitCategory.outdoor], equals(4));
        expect(result.perCategoryEarned[HabitCategory.productive], equals(8));
      });

      test('Should round fractional minutes consistently', () {
        final minutesByCategory = {
          HabitCategory.outdoor: 20, // 0.333 hours = 5 minutes
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        // 0.333 * 15 = 5 minutes (exactly)
        expect(result.perCategoryEarned[HabitCategory.outdoor], equals(5));
      });
    });
  });
}
