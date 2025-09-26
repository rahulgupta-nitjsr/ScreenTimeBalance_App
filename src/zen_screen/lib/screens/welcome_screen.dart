import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_router.dart';
import '../utils/app_keys.dart';
import '../utils/theme.dart';
import '../providers/navigation_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/zen_button.dart';

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
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceLG),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: SingleChildScrollView(
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spaceXL,
                          vertical: AppTheme.space2XL,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Welcome to ZenScreen',
                              style: Theme.of(context).textTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spaceMD),
                            Text(
                              'Unlock your potential where healthy habits meet rewarding screen time. Our science-backed approach helps you achieve balance and focus, one habit at a time.',
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spaceXL),
                            SizedBox(
                              width: double.infinity,
                              child: ZenButton.primary(
                                'Get Started',
                                key: AppKeys.welcomeGetStartedButton,
                                onPressed: () {
                                  ref.read(navigationHistoryProvider.notifier).pushRoute(AppRoutes.home);
                                  context.go(AppRoutes.home);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
