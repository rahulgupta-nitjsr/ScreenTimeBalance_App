import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit_category.dart';
import '../models/algorithm_result.dart';
import '../providers/algorithm_provider.dart';
import '../providers/historical_data_provider.dart';
import '../providers/daily_reset_provider.dart';
import '../providers/screen_time_provider.dart';
import '../utils/theme.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/glass_card.dart';
import '../widgets/habit_progress_card.dart';
import '../widgets/power_plus_celebration.dart';
import '../widgets/screen_time_display.dart';
import '../widgets/usage_education_card.dart';

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

              // Main content - 2x2 grid and earned summary (no scrolling)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceLG,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 2x2 Activity Grid (takes most space)
                      Expanded(
                        child: configAsync.when(
                          data: (config) => _buildProgressGrid(
                            context,
                            algorithmResult,
                            config,
                          ),
                          loading: () => const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          error: (error, _) => Center(
                            child: Text(
                              'Error loading progress',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textLight,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppTheme.spaceMD),
                      
                      // Earned Screen Time Summary (bottom)
                      _buildEarnedScreenTimeSummary(context, algorithmResult),
                      
                      const SizedBox(height: AppTheme.spaceMD),
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

  /// Build screen time summary with earned, used, and remaining
  /// Feature 17: Shows comprehensive screen time balance
  Widget _buildEarnedScreenTimeSummary(BuildContext context, dynamic algorithmResult) {
    final theme = Theme.of(context);
    final screenTimeState = ref.watch(screenTimeStateProvider);
    
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spaceLG),
      child: screenTimeState.when(
        data: (state) {
          // Show education message if permission not granted
          if (!state.hasPermission) {
            return Column(
              children: [
                Text(
                  'Your Reward',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textLight,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMD),
                ScreenTimeDisplay(
                  label: 'Earned',
                  minutes: state.earned,
                  color: AppTheme.secondaryGreen,
                  icon: Icons.emoji_events,
                ),
                const SizedBox(height: AppTheme.spaceMD),
                Text(
                  'Enable usage tracking to see Used and Remaining',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLight,
                  ),
                  textAlign: TextAlign.center,
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
                  color: AppTheme.secondaryGreen,
                  icon: Icons.emoji_events,
                ),
                const SizedBox(height: AppTheme.spaceMD),
                Text(
                  'Usage data unavailable due to device restrictions.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }
          
          // Show all three values when permission granted
          return Column(
            children: [
              Text(
                'Screen Time Balance',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textLight,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: AppTheme.spaceMD),
              ScreenTimeTripleDisplay(
                earned: state.earned,
                used: state.used,
                remaining: state.remaining,
              ),
              const SizedBox(height: AppTheme.spaceXS),
              Text(
                'Based on your habits and device usage',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
            ],
          );
        },
        loading: () => Column(
          children: [
            Text(
              'Screen Time Balance',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textLight,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: AppTheme.spaceMD),
            const ScreenTimeTripleDisplay(
              earned: 0,
              used: 0,
              remaining: 0,
              isLoading: true,
            ),
          ],
        ),
        error: (_, __) => Column(
          children: [
            Text(
              'Your Reward',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textLight,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: AppTheme.spaceMD),
            ScreenTimeDisplay(
              label: 'Earned',
              minutes: algorithmResult.totalEarnedMinutes,
              color: AppTheme.secondaryGreen,
              icon: Icons.emoji_events,
            ),
          ],
        ),
      ),
    );
  }

  /// Build the progress grid with all habit categories
  /// **Product Learning:** 2x2 grid layout allows users to see all habits at once without scrolling
  Widget _buildProgressGrid(
    BuildContext context,
    dynamic algorithmResult,
    dynamic config,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppTheme.spaceMD,
      mainAxisSpacing: AppTheme.spaceMD,
      childAspectRatio: 0.9,
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
            isCompact: true, // Use compact mode for 2x2 grid
          ),
          loading: () => HabitProgressCard(
            category: category,
            currentMinutes: currentMinutes,
            goalMinutes: goalMinutes,
            earnedMinutes: earnedMinutes,
            maxMinutes: maxMinutes,
            showTrend: false,
            trendData: const [],
            isCompact: true,
          ),
          error: (_, __) => HabitProgressCard(
            category: category,
            currentMinutes: currentMinutes,
            goalMinutes: goalMinutes,
            earnedMinutes: earnedMinutes,
            maxMinutes: maxMinutes,
            showTrend: false,
            trendData: const [],
            isCompact: true,
          ),
        );
      }).toList(),
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
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryGreen,
            ),
          ),
          const SizedBox(height: AppTheme.spaceXS),
          Text(
            'Goals Complete',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}