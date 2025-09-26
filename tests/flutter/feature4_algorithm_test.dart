import 'package:flutter_test/flutter_test.dart';
import 'package:zen_screen/models/algorithm_config.dart';
import 'package:zen_screen/models/habit_category.dart';
import 'package:zen_screen/services/algorithm_service.dart';

void main() {
  group('Feature 4: Core Earning Algorithm - Unit Tests', () {
    late AlgorithmService algorithmService;
    late AlgorithmConfig testConfig;

    setUp(() {
      // Create test configuration matching the JSON config
      testConfig = AlgorithmConfig(
        version: '1.0.0-test',
        updatedAt: DateTime.now(),
        powerPlus: PowerPlusConfig(
          bonusMinutes: 30,
          requiredGoals: 3,
          goals: const {
            'sleep': 420,    // 7 hours
            'exercise': 45,  // 45 minutes
            'outdoor': 30,   // 30 minutes
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

    group('TC033: Sleep time earning calculation', () {
      test('8 hours sleep should earn 200 minutes (8 * 25)', () {
        final minutesByCategory = {
          HabitCategory.sleep: 480, // 8 hours
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        expect(result.totalEarnedMinutes, equals(200));
        expect(result.perCategoryEarned[HabitCategory.sleep], equals(200));
        expect(result.powerModeUnlocked, isFalse);
      });

      test('6 hours sleep should earn 150 minutes (6 * 25)', () {
        final minutesByCategory = {
          HabitCategory.sleep: 360, // 6 hours
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        expect(result.totalEarnedMinutes, equals(150));
        expect(result.perCategoryEarned[HabitCategory.sleep], equals(150));
      });

      test('Less than 6 hours sleep should apply penalty', () {
        final minutesByCategory = {
          HabitCategory.sleep: 300, // 5 hours
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        // 5 hours = 125 minutes earned, minus 20 penalty = 105 minutes
        expect(result.totalEarnedMinutes, equals(105));
        expect(result.perCategoryEarned[HabitCategory.sleep], equals(105));
      });

      test('More than 9 hours sleep should apply penalty', () {
        final minutesByCategory = {
          HabitCategory.sleep: 600, // 10 hours
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        // 9 hours = 225 minutes earned, minus 20 penalty = 205 minutes
        expect(result.totalEarnedMinutes, equals(205));
        expect(result.perCategoryEarned[HabitCategory.sleep], equals(205));
      });
    });

    group('TC034: Exercise time earning calculation', () {
      test('1 hour exercise should earn 20 minutes', () {
        final minutesByCategory = {
          HabitCategory.exercise: 60, // 1 hour
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        expect(result.totalEarnedMinutes, equals(20));
        expect(result.perCategoryEarned[HabitCategory.exercise], equals(20));
      });

      test('2 hours exercise should earn 40 minutes (capped at max)', () {
        final minutesByCategory = {
          HabitCategory.exercise: 120, // 2 hours
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        expect(result.totalEarnedMinutes, equals(40));
        expect(result.perCategoryEarned[HabitCategory.exercise], equals(40));
      });

      test('3 hours exercise should still earn 40 minutes (capped)', () {
        final minutesByCategory = {
          HabitCategory.exercise: 180, // 3 hours
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        expect(result.totalEarnedMinutes, equals(40));
        expect(result.perCategoryEarned[HabitCategory.exercise], equals(40));
      });
    });

    group('TC035: Outdoor time earning calculation', () {
      test('1 hour outdoor should earn 15 minutes', () {
        final minutesByCategory = {
          HabitCategory.outdoor: 60, // 1 hour
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        expect(result.totalEarnedMinutes, equals(15));
        expect(result.perCategoryEarned[HabitCategory.outdoor], equals(15));
      });

      test('2 hours outdoor should earn 30 minutes (capped at max)', () {
        final minutesByCategory = {
          HabitCategory.outdoor: 120, // 2 hours
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        expect(result.totalEarnedMinutes, equals(30));
        expect(result.perCategoryEarned[HabitCategory.outdoor], equals(30));
      });
    });

    group('TC036: Productive time earning calculation', () {
      test('1 hour productive should earn 10 minutes', () {
        final minutesByCategory = {
          HabitCategory.productive: 60, // 1 hour
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        expect(result.totalEarnedMinutes, equals(10));
        expect(result.perCategoryEarned[HabitCategory.productive], equals(10));
      });

      test('4 hours productive should earn 40 minutes (capped at max)', () {
        final minutesByCategory = {
          HabitCategory.productive: 240, // 4 hours
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        expect(result.totalEarnedMinutes, equals(40));
        expect(result.perCategoryEarned[HabitCategory.productive], equals(40));
      });
    });

    group('TC037: POWER+ Mode detection', () {
      test('Should unlock POWER+ Mode with 3 of 4 goals met', () {
        final minutesByCategory = {
          HabitCategory.sleep: 420,    // 7 hours (meets goal)
          HabitCategory.exercise: 45,  // 45 minutes (meets goal)
          HabitCategory.outdoor: 30,   // 30 minutes (meets goal)
          HabitCategory.productive: 60, // 1 hour (does not meet 2-hour goal)
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        expect(result.powerModeUnlocked, isTrue);
        expect(result.totalEarnedMinutes, greaterThan(0));
      });

      test('Should not unlock POWER+ Mode with only 2 of 4 goals met', () {
        final minutesByCategory = {
          HabitCategory.sleep: 420,    // 7 hours (meets goal)
          HabitCategory.exercise: 45,  // 45 minutes (meets goal)
          HabitCategory.outdoor: 15,   // 15 minutes (does not meet 30-min goal)
          HabitCategory.productive: 60, // 1 hour (does not meet 2-hour goal)
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        expect(result.powerModeUnlocked, isFalse);
      });
    });

    group('TC038: POWER+ Mode bonus calculation', () {
      test('Should add 30-minute bonus when POWER+ Mode is unlocked', () {
        final minutesByCategory = {
          HabitCategory.sleep: 420,    // 7 hours (meets goal)
          HabitCategory.exercise: 45,  // 45 minutes (meets goal)
          HabitCategory.outdoor: 30,   // 30 minutes (meets goal)
          HabitCategory.productive: 120, // 2 hours (meets goal)
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        expect(result.powerModeUnlocked, isTrue);
        
        // Base calculation: Sleep(175) + Exercise(15) + Outdoor(7.5) + Productive(20) = 217.5
        // Round to 218, plus 30 bonus = 248, but capped at 150
        expect(result.totalEarnedMinutes, equals(150)); // Capped at POWER+ limit
      });
    });

    group('TC039: Daily cap/penalty enforcement', () {
      test('Should enforce daily cap of 120 minutes without POWER+ Mode', () {
        final minutesByCategory = {
          HabitCategory.sleep: 600,    // 10 hours (capped at 9, so 225 min)
          HabitCategory.exercise: 120, // 2 hours (40 min)
          HabitCategory.outdoor: 120,  // 2 hours (30 min)
          HabitCategory.productive: 240, // 4 hours (40 min)
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        // Total would be 225 + 40 + 30 + 40 = 335, but capped at 120
        expect(result.totalEarnedMinutes, equals(120));
        expect(result.powerModeUnlocked, isFalse);
      });

      test('Should enforce daily cap of 150 minutes with POWER+ Mode', () {
        final minutesByCategory = {
          HabitCategory.sleep: 420,    // 7 hours (meets goal)
          HabitCategory.exercise: 45,  // 45 minutes (meets goal)
          HabitCategory.outdoor: 30,   // 30 minutes (meets goal)
          HabitCategory.productive: 120, // 2 hours (meets goal)
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        expect(result.powerModeUnlocked, isTrue);
        expect(result.totalEarnedMinutes, lessThanOrEqualTo(150));
      });
    });

    group('Edge Cases', () {
      test('Zero time logged should return 0 earned time', () {
        final minutesByCategory = <HabitCategory, int>{};

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        expect(result.totalEarnedMinutes, equals(0));
        expect(result.powerModeUnlocked, isFalse);
      });

      test('Negative values should be treated as zero', () {
        final minutesByCategory = {
          HabitCategory.exercise: -10,
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        expect(result.totalEarnedMinutes, equals(0));
        expect(result.perCategoryEarned[HabitCategory.exercise], equals(0));
      });

      test('Very large values should be capped appropriately', () {
        final minutesByCategory = {
          HabitCategory.exercise: 10000, // Way over the 2-hour cap
        };

        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);

        expect(result.perCategoryEarned[HabitCategory.exercise], equals(40)); // Capped at 2 hours
      });
    });

    group('Performance Tests', () {
      test('TC040: Real-time calculation updates should be fast', () {
        final minutesByCategory = {
          HabitCategory.sleep: 420,
          HabitCategory.exercise: 45,
          HabitCategory.outdoor: 30,
          HabitCategory.productive: 120,
        };

        final stopwatch = Stopwatch()..start();
        final result = algorithmService.calculate(minutesByCategory: minutesByCategory);
        stopwatch.stop();

        // Should complete within 100ms (100,000 microseconds)
        expect(stopwatch.elapsedMicroseconds, lessThan(100000));
        expect(result.totalEarnedMinutes, greaterThan(0));
      });
    });
  });
}
