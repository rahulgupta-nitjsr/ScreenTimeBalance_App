import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_router.dart';
import '../utils/theme.dart';
import '../providers/navigation_provider.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundLight,
              AppTheme.backgroundLight,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background blur elements
            Positioned(
              top: -200,
              left: -200,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -200,
              right: -200,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFA8C5FF).withOpacity(0.1),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Liquid glass card
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.all(32.0),
                        decoration: AppTheme.liquidGlassDecoration,
                        child: Column(
                            children: [
                              Text(
                                'Welcome to ZenScreen',
                                style: Theme.of(context).textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Unlock your potential where healthy habits meet rewarding screen time. Our science-backed approach helps you achieve balance and focus, one habit at a time.',
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Update navigation state
                                    ref.read(navigationHistoryProvider.notifier).pushRoute(AppRoutes.home);
                                    
                                    // Navigate using GoRouter
                                    context.go(AppRoutes.home);
                                  },
                                  style: AppTheme.primaryButtonStyle,
                                  child: Text(
                                    'Get Started',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
