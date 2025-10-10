import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_router.dart';
import '../utils/theme.dart';
import '../providers/navigation_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/zen_button.dart';
import '../widgets/habits_to_screentime_illustration.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isAuthenticated = authState is Authenticated;
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
                          horizontal: AppTheme.spaceLG,
                          vertical: AppTheme.space2XL,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header - Premium hierarchy with gradient
                            const SizedBox(height: AppTheme.spaceLG),
                            if (isAuthenticated) ...[
                              Text(
                                'Welcome back',
                                style: const TextStyle(
                                  fontFamily: 'Spline Sans',
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ] else ...[
                              // "Welcome to" - Light and subtle
                              Text(
                                'Welcome to',
                                style: const TextStyle(
                                  fontFamily: 'Spline Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.textLight,
                                  letterSpacing: 0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppTheme.spaceXS),
                              
                              // "ZenScreen" - Bold with gradient - MAXIMUM IMPACT
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [
                                    AppTheme.primaryGreen,
                                    AppTheme.primaryGreenDark,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ).createShader(bounds),
                                child: Text(
                                  'ZenScreen',
                                  style: const TextStyle(
                                    fontFamily: 'Spline Sans',
                                    fontSize: 44,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -1.0,
                                    height: 1.1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppTheme.spaceXL),
                            
                            // Hero Illustration - Split Scene Design
                            if (!isAuthenticated) ...[
                              const HabitsToScreenTimeIllustration(
                                width: 280,
                                height: 140,
                              ),
                              const SizedBox(height: AppTheme.spaceXL),
                            ],
                            
                            // Buttons with better touch targets
                            if (isAuthenticated) ...[
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ZenButton.primary(
                                  'Continue to Dashboard',
                                  onPressed: () {
                                    ref
                                        .read(navigationHistoryProvider.notifier)
                                        .pushRoute(AppRoutes.home);
                                    context.go(AppRoutes.home);
                                  },
                                ),
                              ),
                            ] else ...[
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ZenButton.primary(
                                  'Sign In',
                                  onPressed: () => context.go(AppRoutes.login),
                                ),
                              ),
                              const SizedBox(height: AppTheme.spaceMD),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ZenButton.secondary(
                                  'Create Account',
                                  onPressed: () => context.go(AppRoutes.register),
                                ),
                              ),
                            ],
                            
                            // Footer tagline - Direct value proposition
                            if (!isAuthenticated) ...[
                              const SizedBox(height: AppTheme.space2XL),
                              RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Spline Sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.textMedium,
                                    letterSpacing: 0.2,
                                    height: 1.4,
                                  ),
                                  children: [
                                    TextSpan(text: 'Build habits '),
                                    TextSpan(
                                      text: '→',
                                      style: TextStyle(
                                        color: AppTheme.primaryGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(text: ' Unlock rewards'),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: AppTheme.spaceLG),
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
