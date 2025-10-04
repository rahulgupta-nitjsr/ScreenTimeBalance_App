import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit_category.dart';
import '../providers/algorithm_provider.dart';
import '../providers/historical_data_provider.dart';
import '../providers/daily_reset_provider.dart';
import '../utils/theme.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/glass_card.dart';
import '../widgets/habit_progress_card.dart';
import '../widgets/power_plus_celebration.dart';

/// Progress Screen - Feature 11 & 12 Implementation
/// 
/// **Learning Note for Product Developers:**
/// This screen demonstrates several key UX principles:
/// 
/// 1. **Visual Hierarchy:** Most important info (celebration) appears first
/// 2. **Progressive Disclosure:** Summary first, then detailed breakdowns
/// 3. **Gamification:** POWER+ Mode celebration motivates continued engagement
/// 4. **Real-time Feedback:** All data updates immediately as users log habits
/// 5. **Information Architecture:** Grid layout allows easy scanning of all categories
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  bool _showCelebration = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Check for daily reset (this will trigger reset if new day)
    ref.watch(dailyResetCheckProvider);
    
    // Watch real-time algorithm results
    final algorithmResult = ref.watch(algorithmResultProvider);
    final configAsync = ref.watch(algorithmConfigProvider);

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppTheme.spaceLG),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress Overview',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spaceXS),
                          Text(
                            'Track your daily habit goals',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Summary stats
                    _buildSummaryStats(context, algorithmResult),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceLG,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                              // POWER+ Mode Celebration (Feature 12)
                              if (algorithmResult.powerModeUnlocked && _showCelebration)
                                configAsync.when(
                                  data: (config) {
                                    // Mark POWER+ Mode as achieved today when showing celebration
                                    final powerModeAchieved = ref.read(powerModeAchievedTodayProvider.notifier);
                                    final celebrationShown = ref.read(dailyCelebrationShownProvider.notifier);
                                    
                                    // Only mark as achieved if not already marked
                                    if (!ref.read(powerModeAchievedTodayProvider)) {
                                      powerModeAchieved.markAchieved();
                                    }
                                    
                                    return PowerPlusCelebration(
                                      isUnlocked: true,
                                      bonusMinutes: config.powerPlus.bonusMinutes,
                                      onDismiss: () {
                                        setState(() {
                                          _showCelebration = false;
                                        });
                                        celebrationShown.markShown();
                                      },
                                    );
                                  },
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, __) => const SizedBox.shrink(),
                                ),

                      // POWER+ Progress Indicator (Feature 12)
                      configAsync.when(
                        data: (config) {
                          int completedGoals = 0;
                          for (final category in HabitCategory.values) {
                            final goalMinutes = config.powerPlus.goals[category.id];
                            final currentMinutes = 
                                algorithmResult.perCategoryLoggedMinutes[category] ?? 0;
                            if (goalMinutes != null && currentMinutes >= goalMinutes) {
                              completedGoals++;
                            }
                          }

                          return PowerPlusProgressIndicator(
                            completedGoals: completedGoals,
                            totalGoals: HabitCategory.values.length,
                            requiredGoals: config.powerPlus.requiredGoals,
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: AppTheme.spaceLG),

                      // Section Title: Habit Progress
                      Text(
                        'Daily Habit Goals',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceSM),
                      Text(
                        'Complete 3 of 4 goals to unlock POWER+ Mode',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceLG),

                      // Progress Cards Grid (Feature 11)
                      configAsync.when(
                        data: (config) => _buildProgressGrid(
                          context,
                          algorithmResult,
                          config,
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, stack) => Center(
                          child: Text(
                            'Error loading configuration: $error',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),

                              const SizedBox(height: AppTheme.spaceLG),

                              // POWER+ Mode Streak Section
                              _buildPowerModeStreakSection(context),

                              const SizedBox(height: AppTheme.spaceLG),

                              // Tips Section
                              _buildTipsSection(context, algorithmResult),

                      const SizedBox(height: AppTheme.spaceLG),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  /// Build the progress grid with all habit categories
  /// **Product Learning:** Grid layout allows users to scan all habits at once
  Widget _buildProgressGrid(
    BuildContext context,
    dynamic algorithmResult,
    dynamic config,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid: 1 column on narrow screens, 2 on wider screens
        final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
        final childAspectRatio = constraints.maxWidth > 600 ? 0.9 : 1.0;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppTheme.spaceMD,
          mainAxisSpacing: AppTheme.spaceMD,
          childAspectRatio: childAspectRatio,
          children: HabitCategory.values.map((category) {
            final categoryConfig = config.categories[category.id];
            final goalMinutes = config.powerPlus.goals[category.id] ?? 0;
            final currentMinutes = 
                algorithmResult.perCategoryLoggedMinutes[category] ?? 0;
            final earnedMinutes = 
                algorithmResult.perCategoryEarned[category] ?? 0;
            final maxMinutes = categoryConfig?.maxMinutes?.toInt() ?? 0;

            // Get real historical data for sparklines
            final historicalDataAsync = ref.watch(historicalData7DaysProvider(category));

            return historicalDataAsync.when(
              data: (trendData) => HabitProgressCard(
                category: category,
                currentMinutes: currentMinutes,
                goalMinutes: goalMinutes,
                earnedMinutes: earnedMinutes,
                maxMinutes: maxMinutes,
                showTrend: true,
                trendData: trendData,
              ),
              loading: () => HabitProgressCard(
                category: category,
                currentMinutes: currentMinutes,
                goalMinutes: goalMinutes,
                earnedMinutes: earnedMinutes,
                maxMinutes: maxMinutes,
                showTrend: false,
                trendData: const [],
              ),
              error: (_, __) => HabitProgressCard(
                category: category,
                currentMinutes: currentMinutes,
                goalMinutes: goalMinutes,
                earnedMinutes: earnedMinutes,
                maxMinutes: maxMinutes,
                showTrend: false,
                trendData: const [],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// Build summary stats in the header
  Widget _buildSummaryStats(BuildContext context, dynamic algorithmResult) {
    final theme = Theme.of(context);
    
    // Calculate completed goals based on actual goal requirements
    int completedGoals = 0;
    final configAsync = ref.watch(algorithmConfigProvider);
    
    configAsync.whenData((config) {
      completedGoals = HabitCategory.values.where((category) {
        final goalMinutes = config.powerPlus.goals[category.id] ?? 0;
        final currentMinutes = algorithmResult.perCategoryLoggedMinutes[category] ?? 0;
        return currentMinutes >= goalMinutes && goalMinutes > 0;
      }).length;
    });

    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$completedGoals/4',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: algorithmResult.powerModeUnlocked
                  ? AppTheme.secondaryGreen
                  : null,
            ),
          ),
          const SizedBox(height: AppTheme.spaceXS),
          Text(
            'Goals\nStarted',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppTheme.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build tips section with helpful guidance
  /// **Product Learning:** Contextual tips help users understand next actions
  Widget _buildTipsSection(BuildContext context, dynamic algorithmResult) {
    final theme = Theme.of(context);
    final completedGoals = HabitCategory.values.where((category) {
      return (algorithmResult.perCategoryLoggedMinutes[category] ?? 0) > 0;
    }).length;

    String tipText;
    IconData tipIcon;
    Color tipColor;

    if (algorithmResult.powerModeUnlocked) {
      tipText = 'Amazing! You\'ve unlocked POWER+ Mode. Keep up the great work!';
      tipIcon = Icons.celebration;
      tipColor = AppTheme.secondaryGreen;
    } else if (completedGoals >= 2) {
      tipText = 'You\'re close! Complete one more goal to unlock POWER+ Mode.';
      tipIcon = Icons.trending_up;
      tipColor = Colors.amber;
    } else if (completedGoals >= 1) {
      tipText = 'Good start! Complete ${3 - completedGoals} more goals for POWER+ Mode.';
      tipIcon = Icons.fitness_center;
      tipColor = Colors.blue;
    } else {
      tipText = 'Start logging your habits to track progress toward your goals!';
      tipIcon = Icons.play_arrow;
      tipColor = AppTheme.textLight;
    }

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceSM),
              decoration: BoxDecoration(
                color: tipColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              child: Icon(
                tipIcon,
                color: tipColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spaceMD),
            Expanded(
              child: Text(
                tipText,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build POWER+ Mode streak section
  Widget _buildPowerModeStreakSection(BuildContext context) {
    final theme = Theme.of(context);
    final streakAsync = ref.watch(powerModeStreakProvider);

    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: AppTheme.secondaryGreen,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spaceSM),
              Text(
                'POWER+ Streak',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMD),
          streakAsync.when(
            data: (streak) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  streak > 0 
                    ? 'You\'ve achieved POWER+ Mode for $streak day${streak == 1 ? '' : 's'} in a row!'
                    : 'Start your POWER+ Mode streak today!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceSM),
                if (streak > 0)
                  Row(
                    children: [
                      for (int i = 0; i < streak && i < 7; i++)
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (streak > 7)
                        Text(
                          ' +${streak - 7} more',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            loading: () => Text(
              'Loading streak...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLight,
              ),
            ),
            error: (_, __) => Text(
              'Unable to load streak data',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}