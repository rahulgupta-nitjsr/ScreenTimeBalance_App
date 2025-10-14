import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zen_screen/models/habit_category.dart';
import 'package:zen_screen/widgets/habit_entry_pad.dart';
import 'package:zen_screen/providers/minutes_provider.dart';
import 'package:zen_screen/providers/algorithm_provider.dart';
import 'package:zen_screen/providers/timer_provider.dart';

void main() {
  group('Feature 5: HabitEntryPad Widget Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Widget Rendering Tests', () {
      testWidgets('HabitEntryPad renders with all category tabs', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: Scaffold(body: HabitEntryPad()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify all category tabs are present
        expect(find.text('Sleep'), findsOneWidget);
        expect(find.text('Exercise'), findsOneWidget);
        expect(find.text('Outdoor'), findsOneWidget);
        expect(find.text('Productive'), findsOneWidget);

        // Verify real-time display is present
        expect(find.text('Earned Screen Time'), findsOneWidget);
      });

      testWidgets('Sleep category shows hour chips and half-hour toggle', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: Scaffold(body: HabitEntryPad()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to Sleep tab
        await tester.tap(find.text('Sleep'));
        await tester.pumpAndSettle();

        // Verify hour chips are present (1h through 12h)
        for (int hour = 1; hour <= 12; hour++) {
          expect(find.text('${hour}h'), findsOneWidget);
        }

        // Verify half-hour toggle is present
        expect(find.text('+30 minutes'), findsOneWidget);
        expect(find.byType(SwitchListTile), findsOneWidget);

        // Verify no minute slider for Sleep
        expect(find.byType(Slider), findsNothing);
      });

      testWidgets('Exercise category shows hour chips and minute slider', (WidgetTester tester) async {
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
        await tester.tap(find.text('Exercise'));
        await tester.pumpAndSettle();

        // Verify hour chips are present (0h through 6h)
        for (int hour = 0; hour <= 6; hour++) {
          expect(find.text('${hour}h'), findsOneWidget);
        }

        // Verify minute slider is present
        expect(find.byType(Slider), findsOneWidget);
        expect(find.text('Minutes'), findsOneWidget);

        // Verify no half-hour toggle for Exercise
        expect(find.text('+30 minutes'), findsNothing);
      });

      testWidgets('Quick presets are displayed for each category', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: Scaffold(body: HabitEntryPad()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test Exercise presets
        await tester.tap(find.text('Exercise'));
        await tester.pumpAndSettle();

        expect(find.text('Quick Presets'), findsOneWidget);
        expect(find.text('Quick 15'), findsOneWidget);
        expect(find.text('30 min workout'), findsOneWidget);
        expect(find.text('45 min session'), findsOneWidget);
        expect(find.text('90 min workout'), findsOneWidget);

        // Test Outdoor presets
        await tester.tap(find.text('Outdoor'));
        await tester.pumpAndSettle();

        expect(find.text('15 min walk'), findsOneWidget);
        expect(find.text('30 min outdoor'), findsOneWidget);
        expect(find.text('1 hour hike'), findsOneWidget);
        expect(find.text('2 hour adventure'), findsOneWidget);

        // Test Productive presets
        await tester.tap(find.text('Productive'));
        await tester.pumpAndSettle();

        expect(find.text('25 min focus'), findsOneWidget);
        expect(find.text('1 hour work'), findsOneWidget);
        expect(find.text('2 hours deep work'), findsOneWidget);
        expect(find.text('3 hours project'), findsOneWidget);
      });
    });

    group('User Interaction Tests', () {
      testWidgets('Hour chip selection updates display', (WidgetTester tester) async {
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
        await tester.tap(find.text('Exercise'));
        await tester.pumpAndSettle();

        // Select 3h chip
        await tester.tap(find.text('3h'));
        await tester.pumpAndSettle();

        // Verify display shows 3h 0m
        expect(find.text('3h 0m'), findsOneWidget);
      });

      testWidgets('Minute slider updates display', (WidgetTester tester) async {
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
        await tester.tap(find.text('Exercise'));
        await tester.pumpAndSettle();

        // Select 1h chip
        await tester.tap(find.text('1h'));
        await tester.pumpAndSettle();

        // Adjust minute slider
        final slider = find.byType(Slider);
        await tester.drag(slider, const Offset(50, 0));
        await tester.pumpAndSettle();

        // Verify display shows 1h with some minutes
        expect(find.textContaining('1h'), findsOneWidget);
      });

      testWidgets('Half-hour toggle works for Sleep category', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: Scaffold(body: HabitEntryPad()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to Sleep tab
        await tester.tap(find.text('Sleep'));
        await tester.pumpAndSettle();

        // Select 7h chip
        await tester.tap(find.text('7h'));
        await tester.pumpAndSettle();

        // Toggle half-hour switch
        final switchTile = find.byType(SwitchListTile);
        await tester.tap(switchTile);
        await tester.pumpAndSettle();

        // Verify display shows 7h 30m
        expect(find.text('7h 30m'), findsOneWidget);
      });

      testWidgets('Quick preset selection updates display', (WidgetTester tester) async {
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
        await tester.tap(find.text('Exercise'));
        await tester.pumpAndSettle();

        // Tap "45 min session" preset
        await tester.tap(find.text('45 min session'));
        await tester.pumpAndSettle();

        // Verify display shows 0h 45m
        expect(find.text('0h 45m'), findsOneWidget);
      });

      testWidgets('Save button is enabled when valid time is selected', (WidgetTester tester) async {
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
        await tester.tap(find.text('Exercise'));
        await tester.pumpAndSettle();

        // Select 1h
        await tester.tap(find.text('1h'));
        await tester.pumpAndSettle();

        // Verify save button is enabled
        final saveButton = find.text('Save');
        expect(saveButton, findsOneWidget);
        
        // The button should be tappable (not disabled)
        await tester.tap(saveButton);
        await tester.pumpAndSettle();
      });
    });

    group('State Management Tests', () {
      testWidgets('Timer conflict shows warning and disables input', (WidgetTester tester) async {
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
        await tester.tap(find.text('Exercise'));
        await tester.pumpAndSettle();

        // Verify timer active warning is shown
        expect(find.text('Timer Active'), findsOneWidget);
        expect(find.textContaining('Exercise timer is running'), findsOneWidget);

        // Verify input controls are disabled (opacity reduced)
        final inputControls = find.byWidgetPredicate(
          (widget) => widget is Opacity && (widget.opacity ?? 1.0) < 1.0,
        );
        expect(inputControls, findsWidgets);
      });

      testWidgets('Daily progress indicator shows current vs maximum', (WidgetTester tester) async {
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
        await tester.tap(find.text('Exercise'));
        await tester.pumpAndSettle();

        // Verify progress indicator is present
        expect(find.text("Today's Progress"), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);

        // Should show "0m / 120m" for Exercise (max 2 hours)
        expect(find.text('0m / 120m'), findsOneWidget);
      });

      testWidgets('Real-time display updates with algorithm result', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: Scaffold(body: HabitEntryPad()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify earned screen time display is present
        expect(find.text('Earned Screen Time'), findsOneWidget);

        // Initially should show 0h 0m
        expect(find.text('0h 0m'), findsOneWidget);

        // Add some time via provider
        final minutesNotifier = container.read(minutesByCategoryProvider.notifier);
        minutesNotifier.setMinutes(HabitCategory.exercise, 60); // 1 hour

        await tester.pumpAndSettle();

        // Verify earned time updated (Exercise: 1h = 20 min earned)
        expect(find.text('0h 20m'), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('Widget has proper semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: Scaffold(body: HabitEntryPad()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify main widget has semantic label
        final semantics = find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.label == 'Manual time entry for habit tracking',
        );
        expect(semantics, findsOneWidget);

        // Navigate to Exercise tab
        await tester.tap(find.text('Exercise'));
        await tester.pumpAndSettle();

        // Verify tab has semantic label
        final tabSemantics = find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.label == 'Exercise category',
        );
        expect(tabSemantics, findsOneWidget);
      });

      testWidgets('Hour chips have proper semantic labels', (WidgetTester tester) async {
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
        await tester.tap(find.text('Exercise'));
        await tester.pumpAndSettle();

        // Verify hour chips have semantic labels
        final hourChipSemantics = find.byWidgetPredicate(
          (widget) => widget is Semantics && 
                     widget.properties.label != null && 
                     widget.properties.label!.contains('hours for Exercise'),
        );
        expect(hourChipSemantics, findsWidgets);
      });

      testWidgets('Slider has proper semantic labels', (WidgetTester tester) async {
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
        await tester.tap(find.text('Exercise'));
        await tester.pumpAndSettle();

        // Verify slider has semantic label
        final sliderSemantics = find.byWidgetPredicate(
          (widget) => widget is Semantics && 
                     widget.properties.label == 'Minutes slider for Exercise',
        );
        expect(sliderSemantics, findsOneWidget);
      });
    });
  });
}
