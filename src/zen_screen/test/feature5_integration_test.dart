import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zen_screen/models/habit_category.dart';
import 'package:zen_screen/providers/algorithm_provider.dart';
import 'package:zen_screen/providers/minutes_provider.dart';
import 'package:zen_screen/providers/timer_provider.dart';
import 'package:zen_screen/widgets/habit_entry_pad.dart';
import 'package:zen_screen/screens/log_screen.dart';

void main() {
  group('Feature 5: Manual Time Entry Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Integration with Algorithm System', () {
      testWidgets('Manual entry triggers real-time algorithm calculation', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: LogScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to Manual Entry tab
        final manualEntryTab = find.text('Manual Entry');
        expect(manualEntryTab, findsOneWidget);
        await tester.tap(manualEntryTab);
        await tester.pumpAndSettle();

        // Navigate to Sleep tab
        final sleepTab = find.text('Sleep');
        await tester.tap(sleepTab);
        await tester.pumpAndSettle();

        // Set sleep to 8 hours
        final eightHourChip = find.text('8h');
        expect(eightHourChip, findsOneWidget);
        await tester.tap(eightHourChip);
        await tester.pumpAndSettle();

        // Save the entry
        final saveButton = find.text('Save');
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Verify algorithm result updated
        final algorithmResult = container.read(algorithmResultProvider);
        expect(algorithmResult.totalEarnedMinutes, greaterThan(0));

        // Sleep: 8h = 8 * 25 = 200 minutes earned time
        expect(algorithmResult.totalEarnedMinutes, equals(200));
      });

      testWidgets('Multiple categories accumulate correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: LogScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to Manual Entry tab
        final manualEntryTab = find.text('Manual Entry');
        await tester.tap(manualEntryTab);
        await tester.pumpAndSettle();

        // Add 1 hour Exercise (1h = 20 min earned)
        final exerciseTab = find.text('Exercise');
        await tester.tap(exerciseTab);
        await tester.pumpAndSettle();

        final oneHourChip = find.text('1h');
        await tester.tap(oneHourChip);
        await tester.pumpAndSettle();

        final saveButton = find.text('Save');
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Add 1 hour Outdoor (1h = 15 min earned)
        final outdoorTab = find.text('Outdoor');
        await tester.tap(outdoorTab);
        await tester.pumpAndSettle();

        await tester.tap(oneHourChip); // 1h
        await tester.pumpAndSettle();

        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Verify total earned time: 20 + 15 = 35 minutes
        final algorithmResult = container.read(algorithmResultProvider);
        expect(algorithmResult.totalEarnedMinutes, equals(35));
      });

      testWidgets('POWER+ Mode detection works with manual entries', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: LogScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to Manual Entry tab
        final manualEntryTab = find.text('Manual Entry');
        await tester.tap(manualEntryTab);
        await tester.pumpAndSettle();

        // Add enough time to trigger POWER+ Mode (3 of 4 goals)
        // Sleep: 8h (7h goal met)
        final sleepTab = find.text('Sleep');
        await tester.tap(sleepTab);
        await tester.pumpAndSettle();

        final eightHourChip = find.text('8h');
        await tester.tap(eightHourChip);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Exercise: 1h (45min goal met)
        final exerciseTab = find.text('Exercise');
        await tester.tap(exerciseTab);
        await tester.pumpAndSettle();

        await tester.tap(eightHourChip); // 1h
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Outdoor: 1h (30min goal met)
        final outdoorTab = find.text('Outdoor');
        await tester.tap(outdoorTab);
        await tester.pumpAndSettle();

        await tester.tap(eightHourChip); // 1h
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Verify POWER+ Mode is unlocked
        final algorithmResult = container.read(algorithmResultProvider);
        expect(algorithmResult.powerModeUnlocked, isTrue);
        
        // Should have base time + 30 min bonus
        // Sleep: 8h * 25 = 200, Exercise: 1h * 20 = 20, Outdoor: 1h * 15 = 15
        // Base: 200 + 20 + 15 = 235, POWER+ bonus: +30 = 265
        expect(algorithmResult.totalEarnedMinutes, equals(265));
      });
    });

    group('Integration with Timer System', () {
      testWidgets('Manual entry disabled when timer active for same category', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: LogScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Start a timer for Exercise
        final timerManager = container.read(timerManagerProvider.notifier);
        timerManager.startTimer(HabitCategory.exercise);

        await tester.pumpAndSettle();

        // Navigate to Manual Entry tab
        final manualEntryTab = find.text('Manual Entry');
        await tester.tap(manualEntryTab);
        await tester.pumpAndSettle();

        // Navigate to Exercise tab
        final exerciseTab = find.text('Exercise');
        await tester.tap(exerciseTab);
        await tester.pumpAndSettle();

        // Verify manual entry is disabled with warning
        final timerActiveWarning = find.text('Timer Active');
        expect(timerActiveWarning, findsOneWidget);

        final exerciseTimerWarning = find.textContaining('Exercise timer is running');
        expect(exerciseTimerWarning, findsOneWidget);
      });

      testWidgets('Manual entry works when timer active for different category', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: LogScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Start a timer for Sleep
        final timerManager = container.read(timerManagerProvider.notifier);
        timerManager.startTimer(HabitCategory.sleep);

        await tester.pumpAndSettle();

        // Navigate to Manual Entry tab
        final manualEntryTab = find.text('Manual Entry');
        await tester.tap(manualEntryTab);
        await tester.pumpAndSettle();

        // Navigate to Exercise tab (different from active timer)
        final exerciseTab = find.text('Exercise');
        await tester.tap(exerciseTab);
        await tester.pumpAndSettle();

        // Verify manual entry is NOT disabled (no warning)
        final timerActiveWarning = find.text('Timer Active');
        expect(timerActiveWarning, findsNothing);

        // Should be able to add Exercise time manually
        final oneHourChip = find.text('1h');
        expect(oneHourChip, findsOneWidget);
        await tester.tap(oneHourChip);
        await tester.pumpAndSettle();

        final saveButton = find.text('Save');
        expect(saveButton, findsOneWidget);
      });
    });

    group('Data Persistence Integration', () {
      testWidgets('Manual entries persist across widget rebuilds', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: LogScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to Manual Entry tab
        final manualEntryTab = find.text('Manual Entry');
        await tester.tap(manualEntryTab);
        await tester.pumpAndSettle();

        // Add 2 hours of Productive time
        final productiveTab = find.text('Productive');
        await tester.tap(productiveTab);
        await tester.pumpAndSettle();

        final twoHourChip = find.text('2h');
        await tester.tap(twoHourChip);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Verify data is in provider
        final minutesByCategory = container.read(minutesByCategoryProvider);
        expect(minutesByCategory[HabitCategory.productive], equals(120)); // 2 hours = 120 minutes

        // Rebuild widget (simulate app restart)
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: LogScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate back to Manual Entry
        await tester.tap(find.text('Manual Entry'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Productive'));
        await tester.pumpAndSettle();

        // Verify the data persisted (should show 2h in the UI)
        final twoHourDisplay = find.text('2h 0m');
        expect(twoHourDisplay, findsOneWidget);
      });
    });

    group('UI State Management Integration', () {
      testWidgets('Tab switching preserves manual entry state', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: LogScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to Manual Entry tab
        final manualEntryTab = find.text('Manual Entry');
        await tester.tap(manualEntryTab);
        await tester.pumpAndSettle();

        // Navigate to Exercise tab and set 1h
        final exerciseTab = find.text('Exercise');
        await tester.tap(exerciseTab);
        await tester.pumpAndSettle();

        final oneHourChip = find.text('1h');
        await tester.tap(oneHourChip);
        await tester.pumpAndSettle();

        // Switch to Timer tab
        final timerTab = find.text('Timer');
        await tester.tap(timerTab);
        await tester.pumpAndSettle();

        // Switch back to Manual Entry tab
        await tester.tap(find.text('Manual Entry'));
        await tester.pumpAndSettle();

        // Navigate back to Exercise tab
        await tester.tap(find.text('Exercise'));
        await tester.pumpAndSettle();

        // Verify the 1h selection is preserved
        final oneHourDisplay = find.text('1h 0m');
        expect(oneHourDisplay, findsOneWidget);
      });

      testWidgets('Real-time display updates across all tabs', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: LogScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Get initial earned time
        final initialEarnedTime = container.read(algorithmResultProvider).totalEarnedMinutes;

        // Navigate to Manual Entry tab
        final manualEntryTab = find.text('Manual Entry');
        await tester.tap(manualEntryTab);
        await tester.pumpAndSettle();

        // Add 1 hour Exercise
        final exerciseTab = find.text('Exercise');
        await tester.tap(exerciseTab);
        await tester.pumpAndSettle();

        final oneHourChip = find.text('1h');
        await tester.tap(oneHourChip);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Switch to Timer tab
        await tester.tap(find.text('Timer'));
        await tester.pumpAndSettle();

        // Verify earned time display updated in Timer tab
        final earnedTimeDisplay = find.textContaining('Total earned today');
        expect(earnedTimeDisplay, findsOneWidget);

        // Verify the earned time increased (Exercise: 1h = 20 min earned)
        final updatedEarnedTime = container.read(algorithmResultProvider).totalEarnedMinutes;
        expect(updatedEarnedTime, equals(initialEarnedTime + 20));
      });
    });
  });
}
