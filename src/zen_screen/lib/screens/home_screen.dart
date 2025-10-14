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
import '../providers/algorithm_provider.dart';
import '../services/algorithm_service.dart';
import '../providers/screen_time_provider.dart';
import '../widgets/screen_time_display.dart';
import '../widgets/usage_education_card.dart';
import '../models/algorithm_result.dart';

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
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth > AppTheme.breakpointLarge
                  ? AppTheme.spaceXL
                  : AppTheme.spaceLG;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: AppTheme.spaceLG,
                ),
                child: Column(
                  children: [
                    _buildSummaryCard(context, ref, constraints.maxWidth),
                    const SizedBox(height: AppTheme.spaceLG),
                    Expanded(
                      child: GlassCard(
                        padding: EdgeInsets.all(
                          constraints.maxWidth > AppTheme.breakpointLarge
                              ? AppTheme.spaceLG
                              : AppTheme.spaceMD,
                        ),
                        child: const HomeDashboard(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  Widget _buildSummaryCard(BuildContext context, WidgetRef ref, double maxWidth) {
    final algorithmResult = ref.watch(algorithmResultProvider);
    final screenTimeState = ref.watch(screenTimeStateProvider);
    final isCompact = maxWidth < 420;

    Widget buildActions() {
      return SizedBox(
        width: isCompact ? double.infinity : 148,
        child: Column(
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
            const SizedBox(height: AppTheme.spaceSM),
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
        ),
      );
    }

    // Build screen time display based on state
    Widget buildScreenTimeDisplay() {
      return screenTimeState.when(
        data: (state) {
          // Show education card if permission not granted
          if (!state.hasPermission) {
            return Column(
              children: [
                const CompactUsageEducationBanner(),
                const SizedBox(height: AppTheme.spaceMD),
                // Show only earned time when permission not granted
                ScreenTimeDisplay(
                  label: 'Earned',
                  minutes: state.earned,
                  color: AppTheme.primaryGreen,
                  icon: Icons.emoji_events,
                ),
              ],
            );
          } else if (state.isOemRestricted) {
            return Column(
              children: [
                CompactUsageEducationBanner(
                  message: 'Usage data may be restricted by your device. Tap to check settings.',
                  onTap: () => ref.read(screenTimeServiceProvider).openUsageSettings(),
                ),
                const SizedBox(height: AppTheme.spaceMD),
                ScreenTimeDisplay(
                  label: 'Earned',
                  minutes: state.earned,
                  color: AppTheme.primaryGreen,
                  icon: Icons.emoji_events,
                ),
              ],
            );
          }
          
          // Show all three values when permission granted
          return Column(
            children: [
              Text(
                'Screen Time Today',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textLight,
                    ),
              ),
              const SizedBox(height: AppTheme.spaceSM),
              ScreenTimeTripleDisplay(
                earned: state.earned,
                used: state.used,
                remaining: state.remaining,
              ),
            ],
          );
        },
        loading: () => const ScreenTimeTripleDisplay(
          earned: 0,
          used: 0,
          remaining: 0,
          isLoading: true,
        ),
        error: (_, __) => ScreenTimeDisplay(
          label: 'Earned',
          minutes: algorithmResult.totalEarnedMinutes,
          color: AppTheme.primaryGreen,
          icon: Icons.emoji_events,
        ),
      );
    }

    final summaryContent = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildScreenTimeDisplay(),
        const SizedBox(height: AppTheme.spaceSM),
        _buildPowerModeIndicator(context, ref),
      ],
    );

    return GlassCard(
      padding: EdgeInsets.symmetric(
        horizontal: maxWidth > AppTheme.breakpointLarge
            ? AppTheme.spaceXL
            : AppTheme.spaceLG,
        vertical: AppTheme.spaceLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Today',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.textLight,
                ),
          ),
          const SizedBox(height: AppTheme.spaceSM),
          if (isCompact) ...[
            summaryContent,
            const SizedBox(height: AppTheme.spaceMD),
            buildActions(),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: summaryContent),
                const SizedBox(width: AppTheme.spaceLG),
                buildActions(),
              ],
            ),
          const SizedBox(height: AppTheme.spaceLG),
          ZenLinearProgressBar(
            progress: _calculateProgress(ref, algorithmResult),
            showLabel: true,
            label: 'Daily Progress',
          ),
        ],
      ),
    );
  }

  Widget _buildPowerModeIndicator(BuildContext context, WidgetRef ref) {
    final algorithmResult = ref.watch(algorithmResultProvider);
    final isActive = algorithmResult.powerModeUnlocked;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.secondaryGreen : AppTheme.textLight,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isActive ? 'POWER+ Mode: Active' : 'POWER+ Mode: Locked',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isActive ? AppTheme.textDark : AppTheme.textLight,
              ),
        ),
      ],
    );
  }

  String _formatMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  double _calculateProgress(WidgetRef ref, AlgorithmResult result) {
    final config = ref.read(algorithmConfigProvider).value;
    if (config == null) return 0.0;

    final cap = result.powerModeUnlocked
        ? config.dailyCaps.powerPlusMinutes
        : config.dailyCaps.baseMinutes;

    if (cap <= 0) return 0.0;
    return (result.totalEarnedMinutes / cap).clamp(0.0, 1.0);
  }
}
