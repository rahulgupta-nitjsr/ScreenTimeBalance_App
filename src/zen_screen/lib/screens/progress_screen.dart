import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/glass_card.dart';
import '../widgets/zen_progress.dart';
import '../widgets/zen_button.dart';
import '../utils/theme.dart';
import '../utils/app_router.dart';
import '../providers/navigation_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

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
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundGray.withOpacity(0.92),
                border: const Border(
                  bottom: BorderSide(
                    color: AppTheme.borderLight,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceMD),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.home);
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppTheme.textMedium,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spaceSM),
                      Text(
                        "Today's Progress",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = constraints.maxWidth > AppTheme.breakpointLarge
                      ? AppTheme.spaceXL
                      : AppTheme.spaceLG;
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: AppTheme.spaceXL,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassCard(
                          padding: const EdgeInsets.all(AppTheme.spaceXL),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Screen time summary',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: AppTheme.textLight,
                                    ),
                              ),
                              const SizedBox(height: AppTheme.spaceSM),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTimeCard(
                                      context: context,
                                      title: 'Earned',
                                      time: '1h 53m',
                                      color: AppTheme.primaryGreen,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spaceLG),
                                  Expanded(
                                    child: _buildTimeCard(
                                      context: context,
                                      title: 'Used',
                                      time: '30m',
                                      color: AppTheme.infoBlue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spaceLG),
                              ZenLinearProgressBar(
                                progress: 0.76,
                                label: 'Daily allowance used',
                                showLabel: true,
                                backgroundColor: AppTheme.borderLight,
                                progressColor: AppTheme.primaryGreen,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceXL),
                        _buildPowerModeStatus(context),
                        const SizedBox(height: AppTheme.spaceXL),
                        Text(
                          'Habits',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppTheme.spaceMD),
                        LayoutBuilder(
                          builder: (context, childConstraints) {
                            final isWide = childConstraints.maxWidth > AppTheme.breakpointLarge;
                            if (isWide) {
                              return Wrap(
                                spacing: AppTheme.spaceMD,
                                runSpacing: AppTheme.spaceMD,
                                children: [
                                  for (final habit in _habitProgressData)
                                    _buildHabitCard(
                                      context: context,
                                      icon: habit.icon,
                                      title: habit.title,
                                      progress: habit.progressLabel,
                                      progressValue: habit.progressValue,
                                      width: (childConstraints.maxWidth - AppTheme.spaceMD) / 2,
                                    ),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                for (final habit in _habitProgressData) ...[
                                  _buildHabitCard(
                                    context: context,
                                    icon: habit.icon,
                                    title: habit.title,
                                    progress: habit.progressLabel,
                                    progressValue: habit.progressValue,
                                    width: double.infinity,
                                  ),
                                  const SizedBox(height: AppTheme.spaceMD),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  Widget _buildTimeCard({
    required BuildContext context,
    required String title,
    required String time,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Text(
          time,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPowerModeStatus(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spaceLG),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.secondaryGreen,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: const Icon(
              Icons.bolt,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppTheme.spaceLG),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POWER+ Mode activated',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.secondaryGreen,
                      ),
                ),
                const SizedBox(height: AppTheme.spaceXS),
                Text(
                  '+30 bonus minutes earned today',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spaceSM),
                ZenButton.primary(
                  'Celebrate',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String progress,
    required double progressValue,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: GlassCard(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 28,
            ),
            const SizedBox(height: AppTheme.spaceMD),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spaceXS),
            Text(
              progress,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLight,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceMD),
            ZenCircularProgress(
              progress: progressValue,
              size: 96,
              progressColor: progressValue >= 1.0
                  ? AppTheme.secondaryGreen
                  : AppTheme.primaryGreen,
              backgroundColor: AppTheme.borderLight,
              center: Text(
                '${(progressValue * 100).round()}%',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitProgressData {
  const _HabitProgressData({
    required this.icon,
    required this.title,
    required this.progressLabel,
    required this.progressValue,
  });

  final IconData icon;
  final String title;
  final String progressLabel;
  final double progressValue;
}

const _habitProgressData = [
  _HabitProgressData(
    icon: Icons.bedtime,
    title: 'Sleep',
    progressLabel: '8h 0m / 8h 0m',
    progressValue: 1.0,
  ),
  _HabitProgressData(
    icon: Icons.fitness_center,
    title: 'Exercise',
    progressLabel: '45m / 45m',
    progressValue: 1.0,
  ),
  _HabitProgressData(
    icon: Icons.park,
    title: 'Outdoor',
    progressLabel: '30m / 30m',
    progressValue: 1.0,
  ),
  _HabitProgressData(
    icon: Icons.book,
    title: 'Productive',
    progressLabel: '2h 0m / 2h 0m',
    progressValue: 1.0,
  ),
];