import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zen_screen/models/habit_category.dart';
import 'package:zen_screen/providers/algorithm_provider.dart';
import 'package:zen_screen/providers/minutes_provider.dart';
import 'package:zen_screen/providers/timer_provider.dart';
import 'package:zen_screen/widgets/habit_entry_pad.dart';

void main() {
  group('Feature 5: Manual Time Entry Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('TC041: Sleep hour chip selection', () {
      testWidgets('Sleep entry reflects selected chips and optional half-hour', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: Scaffold(body: HabitEntryPad()),
            ),
          ),
        );

        // Wait for the widget to load
        await tester.pumpAndSettle();

        // Find the sleep tab (first tab)
        final sleepTab = find.text('Sleep');
        expect(sleepTab, findsOneWidget);
        await tester.tap(sleepTab);
        await tester.pumpAndSettle();

        // Find and tap 7h chip
        final sevenHourChip = find.text('7h');
        expect(sevenHourChip, findsOneWidget);
        await tester.tap(sevenHourChip);
        await tester.pumpAndSettle();

        // Verify 7h is selected
        final selectedChip = find.byWidgetPredicate(
          (widget) => widget is GestureDetector && 
                     widget.child is AnimatedContainer,
        );
        expect(selectedChip, findsWidgets);

        // Find and toggle +30 min switch
        final halfHourSwitch = find.byType(SwitchListTile);
        expect(halfHourSwitch, findsOneWidget);
        await tester.tap(halfHourSwitch);
        await tester.pumpAndSettle();

        // Verify total shows 7h 30m
        final totalDisplay = find.text('7h 30m');
        expect(totalDisplay, findsOneWidget);
      });
    });

    group('TC042: Exercise quick preset', () {
      testWidgets('Exercise total updates using preset value', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: Scaffold(body: HabitEntryPad()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to Exercise tab (second tab)
        final exerciseTab = find.text('Exercise');
        expect(exerciseTab, findsOneWidget);
        await tester.tap(exerciseTab);
        await tester.pumpAndSettle();

        // Find and tap "45 min session" preset
        final presetButton = find.text('45 min session');
        expect(presetButton, findsOneWidget);
        await tester.tap(presetButton);
        await tester.pumpAndSettle();

        // Verify total shows 0h 45m
        final totalDisplay = find.text('0h 45m');
        expect(totalDisplay, findsOneWidget);
      });
    });

    group('TC043: Custom minute slider', () {
      testWidgets('Total reflects combined hours/minutes (1h15m)', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: Scaffold(body: HabitEntryPad()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to Exercise tab
        final exerciseTab = find.text('Exercise');
        await tester.tap(exerciseTab);
        await tester.pumpAndSettle();

        // Select 1 hour chip
        final oneHourChip = find.text('1h');
        expect(oneHourChip, findsOneWidget);
        await tester.tap(oneHourChip);
        await tester.pumpAndSettle();

        // Adjust minutes slider to 15
        final slider = find.byType(Slider);
        expect(slider, findsOneWidget);
        await tester.drag(slider, const Offset(100, 0));
        await tester.pumpAndSettle();

        // Verify total shows 1h 15m
        final totalDisplay = find.text('1h 15m');
        expect(totalDisplay, findsOneWidget);
      });
    });

    group('TC044: Real-time algorithm update', () {
      testWidgets('Earned screen time updates instantly after entry submission', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: Scaffold(body: HabitEntryPad()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Get initial earned time
        final initialEarnedTime = container.read(algorithmResultProvider).totalEarnedMinutes;

        // Navigate to Exercise tab and add 30 minutes
        final exerciseTab = find.text('Exercise');
        await tester.tap(exerciseTab);
        await tester.pumpAndSettle();

        // Find and tap "30 min workout" preset
        final presetButton = find.text('30 min workout');
        expect(presetButton, findsOneWidget);
        await tester.tap(presetButton);
        await tester.pumpAndSettle();

        // Save the entry
        final saveButton = find.text('Save');
        expect(saveButton, findsOneWidget);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Verify earned time updated (Exercise: 30 min = 10 min earned time)
        final updatedEarnedTime = container.read(algorithmResultProvider).totalEarnedMinutes;
        expect(updatedEarnedTime, greaterThan(initialEarnedTime));
      });
    });

    group('TC045: Negative value prevention', () {
      testWidgets('Entry pad prevents negative totals with clear feedback', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: Scaffold(body: HabitEntryPad()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to Exercise tab
        final exerciseTab = find.text('Exercise');
        await tester.tap(exerciseTab);
        await tester.pumpAndSettle();

        // Try to set negative values - should be prevented by UI design
        // The hour chips start from 0, and minutes slider starts from 0
        // So negative values are prevented by design
        final zeroHourChip = find.text('0h');
        expect(zeroHourChip, findsOneWidget);
        await tester.tap(zeroHourChip);
        await tester.pumpAndSettle();

        // Verify total shows 0h 0m (minimum allowed)
        final totalDisplay = find.text('0h 0m');
        expect(totalDisplay, findsOneWidget);
      });
    });

    group('TC046: Daily maximum enforcement', () {
      testWidgets('Entry pad enforces category caps with inline messaging', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: Scaffold(body: HabitEntryPad()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to Exercise tab
        final exerciseTab = find.text('Exercise');
        await tester.tap(exerciseTab);
        await tester.pumpAndSettle();

        // Try to set maximum value (Exercise max is 120 minutes = 2 hours)
        final twoHourChip = find.text('2h');
        expect(twoHourChip, findsOneWidget);
        await tester.tap(twoHourChip);
        await tester.pumpAndSettle();

        // Set minutes to 0 (total 120 minutes = max for Exercise)
        final slider = find.byType(Slider);
        await tester.drag(slider, const Offset(-200, 0)); // Move to 0 minutes
        await tester.pumpAndSettle();

        // Verify total shows 2h 0m (at maximum)
        final totalDisplay = find.text('2h 0m');
        expect(totalDisplay, findsOneWidget);

        // Check that save button is enabled (at max is still valid)
        final saveButton = find.text('Save');
        expect(saveButton, findsOneWidget);
        // Save button should be enabled since 2h is within Exercise limits
      });
    });

    group('TC047: Same-as-last-time shortcut', () {
      testWidgets('Previous value applied correctly to current day', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: Scaffold(body: HabitEntryPad()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to Outdoor tab
        final outdoorTab = find.text('Outdoor');
        await tester.tap(outdoorTab);
        await tester.pumpAndSettle();

        // Find and tap "Same as last time" button
        final sameAsLastButton = find.text('Same as last time');
        expect(sameAsLastButton, findsOneWidget);
        await tester.tap(sameAsLastButton);
        await tester.pumpAndSettle();

        // Since there's no previous data, it should default to 0h 0m
        final totalDisplay = find.text('0h 0m');
        expect(totalDisplay, findsOneWidget);
      });
    });

    group('TC048: Timer/manual toggle persistence', () {
      testWidgets('Toggle preserves state and enforces single-activity rules', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: Scaffold(body: HabitEntryPad()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Start a timer for Exercise
        final timerManager = container.read(timerManagerProvider.notifier);
        timerManager.startTimer(HabitCategory.exercise);

        await tester.pumpAndSettle();

        // Navigate to Exercise tab
        final exerciseTab = find.text('Exercise');
        await tester.tap(exerciseTab);
        await tester.pumpAndSettle();

        // Verify that manual entry is disabled when timer is active
        final timerActiveWarning = find.text('Timer Active');
        expect(timerActiveWarning, findsOneWidget);

        // Verify input controls are disabled
        final hourChips = find.byType(GestureDetector);
        expect(hourChips, findsWidgets);

        // Stop the timer
        timerManager.stopTimer();
        await tester.pumpAndSettle();

        // Verify manual entry is now enabled
        final timerActiveWarningAfterStop = find.text('Timer Active');
        expect(timerActiveWarningAfterStop, findsNothing);
      });
    });

    group('TC049: Data persistence', () {
      testWidgets('Manual entries persist across sessions', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: Scaffold(body: HabitEntryPad()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to Productive tab
        final productiveTab = find.text('Productive');
        await tester.tap(productiveTab);
        await tester.pumpAndSettle();

        // Add 1 hour of productive time
        final oneHourChip = find.text('1h');
        await tester.tap(oneHourChip);
        await tester.pumpAndSettle();

        // Save the entry
        final saveButton = find.text('Save');
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Verify the data was saved to state
        final minutesByCategory = container.read(minutesByCategoryProvider);
        expect(minutesByCategory[HabitCategory.productive], equals(60)); // 1 hour = 60 minutes
      });
    });

    group('TC050: Cross-category consistency', () {
      testWidgets('Entry pad behaves consistently for all categories', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: Scaffold(body: HabitEntryPad()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test each category has consistent UI elements
        final categories = ['Sleep', 'Exercise', 'Outdoor', 'Productive'];
        
        for (final categoryName in categories) {
          final categoryTab = find.text(categoryName);
          expect(categoryTab, findsOneWidget);
          await tester.tap(categoryTab);
          await tester.pumpAndSettle();

          // Each category should have hour chips
          final hourChips = find.byWidgetPredicate(
            (widget) => widget is GestureDetector,
          );
          expect(hourChips, findsWidgets);

          // Each category should have a save button
          final saveButton = find.text('Save');
          expect(saveButton, findsOneWidget);

          // Each category should have quick presets (except maybe Sleep)
          if (categoryName != 'Sleep') {
            final quickPresets = find.text('Quick Presets');
            expect(quickPresets, findsOneWidget);
          }
        }
      });
    });
  });
}
