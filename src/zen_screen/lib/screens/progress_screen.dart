import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit_category.dart';
import '../models/algorithm_result.dart';
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

  /// Build elegant earned screen time summary
  Widget _buildEarnedScreenTimeSummary(BuildContext context, dynamic algorithmResult) {
    final theme = Theme.of(context);
    final earnedMinutes = algorithmResult.totalEarnedMinutes;
    final hours = earnedMinutes ~/ 60;
    final mins = earnedMinutes % 60;
    
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spaceLG),
      child: Column(
        children: [
          // Elegant header text
          Text(
            'Your Reward',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textLight,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: AppTheme.spaceXS),
          
          // Big earned time display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$hours',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryGreen,
                ),
              ),
              Text(
                'h ',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.secondaryGreen.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$mins',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryGreen,
                ),
              ),
              Text(
                'm',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.secondaryGreen.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceXS),
          
          // Motivational subtext
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceMD,
              vertical: AppTheme.spaceXS,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            ),
            child: Text(
              'Screen Time Earned',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.secondaryGreen,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
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