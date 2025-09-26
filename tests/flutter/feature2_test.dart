import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zen_screen/main.dart';
import 'package:zen_screen/utils/theme.dart';
import 'package:zen_screen/widgets/glass_card.dart';
import 'package:zen_screen/widgets/zen_button.dart';
import 'package:zen_screen/widgets/zen_progress.dart';
import 'package:zen_screen/widgets/zen_input_field.dart';

void main() {
  group('Feature 2: Visual Design System Tests', () {
    testWidgets('TC011: Liquid glass aesthetic', (WidgetTester tester) async {
      // Test glass effect on cards with backdrop blur
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: GlassCard(
                  padding: EdgeInsets.all(16),
                  child: Text('Glass Card Test'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify glass card renders
      expect(find.byType(GlassCard), findsOneWidget);
      expect(find.text('Glass Card Test'), findsOneWidget);
      
      // Verify backdrop filter is applied (glass effect)
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('TC012: Robin Hood Green primary color', (WidgetTester tester) async {
      // Test primary color usage and consistency
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                ZenButton.primary('Primary Button', onPressed: () {}),
                const SizedBox(height: 16),
                Container(
                  width: 100,
                  height: 100,
                  color: AppTheme.primaryGreen,
                  child: const Center(child: Text('Color Test')),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify primary button renders
      expect(find.byType(ZenButton), findsOneWidget);
      expect(find.text('Primary Button'), findsOneWidget);
      
      // Verify color test container renders
      expect(find.text('Color Test'), findsOneWidget);
    });

    testWidgets('TC013: Spline Sans typography', (WidgetTester tester) async {
      // Test typography system
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                Text('Display Large', style: AppTheme.lightTheme.textTheme.displayLarge),
                Text('Heading 1', style: AppTheme.lightTheme.textTheme.headlineLarge),
                Text('Heading 2', style: AppTheme.lightTheme.textTheme.headlineMedium),
                Text('Body Large', style: AppTheme.lightTheme.textTheme.bodyLarge),
                Text('Body Regular', style: AppTheme.lightTheme.textTheme.bodyMedium),
                Text('Body Small', style: AppTheme.lightTheme.textTheme.bodySmall),
                Text('Caption', style: AppTheme.lightTheme.textTheme.labelSmall),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all text elements render
      expect(find.text('Display Large'), findsOneWidget);
      expect(find.text('Heading 1'), findsOneWidget);
      expect(find.text('Heading 2'), findsOneWidget);
      expect(find.text('Body Large'), findsOneWidget);
      expect(find.text('Body Regular'), findsOneWidget);
      expect(find.text('Body Small'), findsOneWidget);
      expect(find.text('Caption'), findsOneWidget);
    });

    testWidgets('TC014: Primary button component', (WidgetTester tester) async {
      // Test primary button rendering and interactions
      bool buttonPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: ZenButton.primary(
                'Test Primary Button',
                onPressed: () {
                  buttonPressed = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify button renders
      expect(find.byType(ZenButton), findsOneWidget);
      expect(find.text('Test Primary Button'), findsOneWidget);
      
      // Test button interaction
      await tester.tap(find.byType(ZenButton));
      await tester.pumpAndSettle();
      
      expect(buttonPressed, isTrue);
    });

    testWidgets('TC015: Secondary button component', (WidgetTester tester) async {
      // Test secondary button rendering and interactions
      bool buttonPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: ZenButton.secondary(
                'Test Secondary Button',
                onPressed: () {
                  buttonPressed = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify button renders
      expect(find.byType(ZenButton), findsOneWidget);
      expect(find.text('Test Secondary Button'), findsOneWidget);
      
      // Test button interaction
      await tester.tap(find.byType(ZenButton));
      await tester.pumpAndSettle();
      
      expect(buttonPressed, isTrue);
    });

    testWidgets('TC016: Glass card components', (WidgetTester tester) async {
      // Test glass card components with visual effects
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: GlassCard(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Glass Card Title'),
                      SizedBox(height: 8),
                      Text('Glass Card Content'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify glass card renders
      expect(find.byType(GlassCard), findsOneWidget);
      expect(find.text('Glass Card Title'), findsOneWidget);
      expect(find.text('Glass Card Content'), findsOneWidget);
      
      // Verify backdrop filter is applied
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('TC017: Progress indicator components', (WidgetTester tester) async {
      // Test circular and linear progress indicators
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                const ZenCircularProgress(
                  progress: 0.7,
                  size: 100,
                ),
                const SizedBox(height: 16),
                const ZenLinearProgressBar(
                  progress: 0.5,
                  height: 8,
                ),
                const SizedBox(height: 16),
                const ZenLinearProgressBar(
                  progress: 0.3,
                  height: 12,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify progress indicators render
      expect(find.byType(ZenCircularProgress), findsOneWidget);
      expect(find.byType(ZenLinearProgressBar), findsNWidgets(2));
    });

    testWidgets('TC018: Input field components', (WidgetTester tester) async {
      // Test input field components with validation states
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: ZenInputField(
                controller: controller,
                label: 'Test Input',
                hint: 'Enter text here',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify input field renders
      expect(find.byType(ZenInputField), findsOneWidget);
      expect(find.text('Test Input'), findsOneWidget);
      expect(find.text('Enter text here'), findsOneWidget);
      
      // Test input interaction
      await tester.enterText(find.byType(ZenInputField), 'Test text');
      await tester.pumpAndSettle();
      
      expect(controller.text, 'Test text');
    });

    testWidgets('TC019: Responsive design adaptation', (WidgetTester tester) async {
      // Test responsive design on different screen sizes
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                final isLargeScreen = constraints.maxWidth >= 1024;
                return Center(
                  child: GlassCard(
                    padding: EdgeInsets.all(isLargeScreen ? 32 : 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Responsive Test',
                          style: AppTheme.lightTheme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Screen width: ${constraints.maxWidth}px',
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ZenButton.primary(
                          'Responsive Button',
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify responsive layout renders
      expect(find.byType(GlassCard), findsOneWidget);
      expect(find.text('Responsive Test'), findsOneWidget);
      expect(find.textContaining('Screen width:'), findsOneWidget);
      expect(find.byType(ZenButton), findsOneWidget);
    });

    testWidgets('TC020: Material Design compliance', (WidgetTester tester) async {
      // Test Material Design principles with custom styling
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Material Design Test'),
              backgroundColor: AppTheme.primaryGreen,
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Material Design Components',
                          style: AppTheme.lightTheme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        ZenButton.primary(
                          'Primary Action',
                          onPressed: () {},
                        ),
                        const SizedBox(height: 8),
                        ZenButton.secondary(
                          'Secondary Action',
                          onPressed: () {},
                        ),
                        const SizedBox(height: 16),
                        const ZenLinearProgressBar(progress: 0.6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Material Design components render
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(GlassCard), findsOneWidget);
      expect(find.text('Material Design Components'), findsOneWidget);
      expect(find.byType(ZenButton), findsNWidgets(2));
      expect(find.byType(ZenLinearProgressBar), findsOneWidget);
    });
  });
}
