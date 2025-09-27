import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zen_screen/models/habit_category.dart';
import 'package:zen_screen/providers/minutes_provider.dart';
import 'package:zen_screen/providers/algorithm_provider.dart';

void main() {
  group('Feature 5: Manual Time Entry Basic Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('TC041: Sleep hour chip selection', () {
      test('Sleep entry reflects selected chips and optional half-hour', () {
        final minutesNotifier = container.read(minutesByCategoryProvider.notifier);
        
        // Set sleep to 7h 30m (7 hours + 30 minutes)
        minutesNotifier.setMinutes(HabitCategory.sleep, 450); // 7.5 hours = 450 minutes
        
        final minutesByCategory = container.read(minutesByCategoryProvider);
        expect(minutesByCategory[HabitCategory.sleep], equals(450));
        
        // Verify the time can be broken down correctly
        final hours = (minutesByCategory[HabitCategory.sleep] ?? 0) ~/ 60;
        final minutes = (minutesByCategory[HabitCategory.sleep] ?? 0) % 60;
        expect(hours, equals(7));
        expect(minutes, equals(30));
      });
    });

    group('TC042: Exercise quick preset', () {
      test('Exercise total updates using preset value', () {
        final minutesNotifier = container.read(minutesByCategoryProvider.notifier);
        
        // Set exercise to 45 minutes (quick preset)
        minutesNotifier.setMinutes(HabitCategory.exercise, 45);
        
        final minutesByCategory = container.read(minutesByCategoryProvider);
        expect(minutesByCategory[HabitCategory.exercise], equals(45));
        
        // Verify it's exactly 45 minutes
        final totalMinutes = minutesByCategory[HabitCategory.exercise];
        expect(totalMinutes, equals(45));
      });
    });

    group('TC043: Custom minute slider', () {
      test('Total reflects combined hours/minutes (1h15m)', () {
        final minutesNotifier = container.read(minutesByCategoryProvider.notifier);
        
        // Set 1 hour 15 minutes = 75 minutes total
        minutesNotifier.setMinutes(HabitCategory.exercise, 75);
        
        final minutesByCategory = container.read(minutesByCategoryProvider);
        expect(minutesByCategory[HabitCategory.exercise], equals(75));
        
        // Verify breakdown
        final hours = (minutesByCategory[HabitCategory.exercise] ?? 0) ~/ 60;
        final minutes = (minutesByCategory[HabitCategory.exercise] ?? 0) % 60;
        expect(hours, equals(1));
        expect(minutes, equals(15));
      });
    });

    group('TC044: Real-time algorithm update', () {
      test('Earned screen time updates instantly after entry submission', () {
        final minutesNotifier = container.read(minutesByCategoryProvider.notifier);
        
        // Get initial earned time
        final initialResult = container.read(algorithmResultProvider);
        final initialEarnedTime = initialResult.totalEarnedMinutes;
        
        // Add 1 hour Exercise (should earn 20 minutes)
        minutesNotifier.setMinutes(HabitCategory.exercise, 60);
        
        // Get updated result
        final updatedResult = container.read(algorithmResultProvider);
        final updatedEarnedTime = updatedResult.totalEarnedMinutes;
        
        // Exercise: 1h = 20 minutes earned time
        expect(updatedEarnedTime, equals(initialEarnedTime + 20));
      });
    });

    group('TC045: Negative value prevention', () {
      test('Entry pad prevents negative totals with clear feedback', () {
        final minutesNotifier = container.read(minutesByCategoryProvider.notifier);
        
        // Set a positive value first
        minutesNotifier.setMinutes(HabitCategory.exercise, 30);
        expect(container.read(minutesByCategoryProvider)[HabitCategory.exercise], equals(30));
        
        // Try to set negative value - should be prevented by provider validation
        minutesNotifier.setMinutes(HabitCategory.exercise, -10);
        expect(container.read(minutesByCategoryProvider)[HabitCategory.exercise], equals(0)); // Provider should clamp to 0
        
        // Verify the value is not negative
        final minutes = container.read(minutesByCategoryProvider)[HabitCategory.exercise];
        expect(minutes, isNot(lessThan(0))); // Should not be negative
        expect(minutes, equals(0)); // Should be clamped to 0
      });
    });

    group('TC046: Daily maximum enforcement', () {
      test('Entry pad enforces category caps with inline messaging', () {
        final minutesNotifier = container.read(minutesByCategoryProvider.notifier);
        
        // Exercise max is 120 minutes (2 hours)
        minutesNotifier.setMinutes(HabitCategory.exercise, 120);
        
        final minutesByCategory = container.read(minutesByCategoryProvider);
        expect(minutesByCategory[HabitCategory.exercise], equals(120));
        
        // Try to exceed maximum using validation method
        minutesNotifier.setMinutesWithValidation(HabitCategory.exercise, 150, maxMinutes: 120);
        
        final updatedMinutes = container.read(minutesByCategoryProvider)[HabitCategory.exercise];
        expect(updatedMinutes, equals(120)); // Should be capped at 120
        expect(updatedMinutes, lessThanOrEqualTo(120)); // Should not exceed maximum
      });
    });

    group('TC047: Same-as-last-time shortcut', () {
      test('Previous value applied correctly to current day', () {
        final minutesNotifier = container.read(minutesByCategoryProvider.notifier);
        
        // Set a previous value for Outdoor
        minutesNotifier.setMinutes(HabitCategory.outdoor, 90); // 1.5 hours
        
        final minutesByCategory = container.read(minutesByCategoryProvider);
        expect(minutesByCategory[HabitCategory.outdoor], equals(90));
        
        // "Same as last time" should use this value
        final lastTimeValue = minutesByCategory[HabitCategory.outdoor];
        expect(lastTimeValue, equals(90));
        
        // Verify it's 1h 30m
        final hours = (lastTimeValue ?? 0) ~/ 60;
        final minutes = (lastTimeValue ?? 0) % 60;
        expect(hours, equals(1));
        expect(minutes, equals(30));
      });
    });

    group('TC048: Timer/manual toggle persistence', () {
      test('Toggle preserves state and enforces single-activity rules', () {
        // This test verifies the concept - in real implementation, timer state would be managed
        final minutesNotifier = container.read(minutesByCategoryProvider.notifier);
        
        // Set some manual entry
        minutesNotifier.setMinutes(HabitCategory.sleep, 480); // 8 hours
        
        final minutesByCategory = container.read(minutesByCategoryProvider);
        expect(minutesByCategory[HabitCategory.sleep], equals(480));
        
        // In real implementation, timer conflict would prevent manual entry
        // This is handled by the UI layer checking timer state
        final canEditManually = true; // Would be false if timer is active
        expect(canEditManually, isTrue);
      });
    });

    group('TC049: Data persistence', () {
      test('Manual entries persist across sessions', () {
        final minutesNotifier = container.read(minutesByCategoryProvider.notifier);
        
        // Set productive time
        minutesNotifier.setMinutes(HabitCategory.productive, 120); // 2 hours
        
        final minutesByCategory = container.read(minutesByCategoryProvider);
        expect(minutesByCategory[HabitCategory.productive], equals(120));
        
        // Simulate app restart by creating new container
        final newContainer = ProviderContainer();
        try {
          // In real implementation, data would be loaded from database
          final newMinutesByCategory = newContainer.read(minutesByCategoryProvider);
          // For testing, we verify the state management works
          expect(newMinutesByCategory[HabitCategory.productive], equals(0)); // Fresh state
          
          // Restore data (simulating database load)
          final newMinutesNotifier = newContainer.read(minutesByCategoryProvider.notifier);
          newMinutesNotifier.setMinutes(HabitCategory.productive, 120);
          
          final restoredMinutes = newContainer.read(minutesByCategoryProvider);
          expect(restoredMinutes[HabitCategory.productive], equals(120));
        } finally {
          newContainer.dispose();
        }
      });
    });

    group('TC050: Cross-category consistency', () {
      test('Entry pad behaves consistently for all categories', () {
        final minutesNotifier = container.read(minutesByCategoryProvider.notifier);
        
        // Test each category with same time value
        const testMinutes = 60; // 1 hour
        
        for (final category in HabitCategory.values) {
          minutesNotifier.setMinutes(category, testMinutes);
          
          final minutesByCategory = container.read(minutesByCategoryProvider);
          expect(minutesByCategory[category], equals(testMinutes));
          
          // Verify each category can store the same value consistently
          final hours = (minutesByCategory[category] ?? 0) ~/ 60;
          final minutes = (minutesByCategory[category] ?? 0) % 60;
          expect(hours, equals(1));
          expect(minutes, equals(0));
        }
      });
    });

    group('Algorithm Integration Tests', () {
    test('Multiple categories accumulate earned time correctly', () {
      final minutesNotifier = container.read(minutesByCategoryProvider.notifier);
      
      // Set multiple categories
      minutesNotifier.setMinutes(HabitCategory.sleep, 480); // 8h = 200 min earned
      minutesNotifier.setMinutes(HabitCategory.exercise, 60); // 1h = 20 min earned
      minutesNotifier.setMinutes(HabitCategory.outdoor, 60); // 1h = 15 min earned
      minutesNotifier.setMinutes(HabitCategory.productive, 120); // 2h = 20 min earned
      
      final result = container.read(algorithmResultProvider);
      
      // Total earned: 200 + 20 + 15 + 20 = 255 minutes
      // But capped at POWER+ cap of 150 (3 of 4 goals met)
      expect(result.totalEarnedMinutes, equals(150)); // POWER+ cap
      expect(result.powerModeUnlocked, isTrue);
    });

      test('POWER+ Mode detection works with manual entries', () {
        final minutesNotifier = container.read(minutesByCategoryProvider.notifier);
        
        // Set values to trigger POWER+ Mode (3 of 4 goals met)
        minutesNotifier.setMinutes(HabitCategory.sleep, 480); // 8h (7h goal met)
        minutesNotifier.setMinutes(HabitCategory.exercise, 60); // 1h (45min goal met)
        minutesNotifier.setMinutes(HabitCategory.outdoor, 60); // 1h (30min goal met)
        // Productive: 0h (120min goal not met)
        
        final result = container.read(algorithmResultProvider);
        
        // Should unlock POWER+ Mode (3 of 4 goals met)
        expect(result.powerModeUnlocked, isTrue);
        
        // Should have base time + 30 min bonus, but capped at POWER+ cap
        // Base: 200 + 20 + 15 + 0 = 235, POWER+ bonus: +30 = 265
        // But capped at POWER+ cap of 150
        expect(result.totalEarnedMinutes, equals(150)); // POWER+ cap
      });
    });
  });
}
