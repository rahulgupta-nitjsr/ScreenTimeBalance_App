import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/glass_card.dart';
import '../widgets/zen_button.dart';
import '../widgets/zen_progress.dart';
import '../utils/app_router.dart';
import '../utils/app_keys.dart';
import '../utils/theme.dart';
import '../providers/navigation_provider.dart';
import '../widgets/home_dashboard.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundGray,
              AppTheme.backgroundGray,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background blur elements
            Positioned(
              top: -40,
              left: MediaQuery.of(context).size.width / 2 - 120,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceLG),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GlassCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spaceXL,
                            vertical: AppTheme.spaceLG,
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Earned screen time',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textLight,
                                    ),
                              ),
                              const SizedBox(height: AppTheme.spaceSM),
                              Text(
                                '1h 23m',
                                style: Theme.of(context).textTheme.headlineLarge,
                              ),
                              const SizedBox(height: AppTheme.spaceMD),
                              _buildPowerModeIndicator(context),
                              const SizedBox(height: AppTheme.spaceLG),
                              ZenLinearProgressBar(
                                progress: 0.64,
                                showLabel: true,
                                label: 'Daily Progress',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceXL),
                        const HomeDashboard(),
                        const SizedBox(height: AppTheme.space2XL),
                        _buildActionButtons(context, ref),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  Widget _buildPowerModeIndicator(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppTheme.secondaryGreen,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'POWER+ Mode: Active',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ZenButton.success(
            'Log Time',
            key: AppKeys.homeLogTimeButton,
            onPressed: () {
              ref.read(navigationIndexProvider.notifier).setIndex(1);
              ref.read(navigationHistoryProvider.notifier).pushRoute(AppRoutes.log);
              context.go(AppRoutes.log);
            },
          ),
        ),
        const SizedBox(height: AppTheme.spaceMD),
        SizedBox(
          width: double.infinity,
          child: ZenButton.secondary(
            'See Progress',
            key: AppKeys.homeSeeProgressButton,
            onPressed: () {
              ref.read(navigationIndexProvider.notifier).setIndex(2);
              ref.read(navigationHistoryProvider.notifier).pushRoute(AppRoutes.progress);
              context.go(AppRoutes.progress);
            },
          ),
        ),
      ],
    );
  }
}
