import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/habit_category.dart';
import '../providers/auth_provider.dart';
import '../providers/repository_providers.dart';
import '../providers/algorithm_provider.dart';
import '../utils/theme.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/glass_card.dart';

/// History Screen - Feature 13 Implementation
/// 
/// **Product Learning Note:**
/// This screen shows the user's past 7 days of habit tracking data.
/// Why 7 days? It's a complete week cycle that users can understand and relate to.
/// 
/// **Key UX Principles:**
/// 1. **Timeline View**: Most recent at top (reverse chronological)
/// 2. **Visual Hierarchy**: Today is prominent, past days are slightly muted
/// 3. **Data Density**: Show enough detail to be useful, not overwhelming
/// 4. **Achievement Highlighting**: POWER+ Mode days are celebrated
/// 5. **Empty States**: Graceful handling of days with no data
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

    // Ensure user is authenticated
    if (authState is! Authenticated) {
      return Scaffold(
        body: Center(
          child: Text(
            'Please sign in to view history',
            style: theme.textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundLight,
              AppTheme.backgroundGray,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Historical data list
              Expanded(
                child: _buildHistoricalDataList(context, ref, authState.user.id),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  /// Build the header section
  /// **Product Note**: Headers orient users - they should always know where they are
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight.withOpacity(0.92),
        border: const Border(
          bottom: BorderSide(color: AppTheme.borderLight, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: AppTheme.primaryGreen,
                  size: 28,
                ),
                const SizedBox(width: AppTheme.spaceSM),
                Expanded(
                  child: Text(
                    'History',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceXS),
            Text(
              'Past 7 days of habit tracking',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the list of historical data (past 7 days)
  /// **Product Note**: Lists should be scannable - users should quickly find what they need
  Widget _buildHistoricalDataList(BuildContext context, WidgetRef ref, String userId) {
    final today = DateTime.now();
    final repository = ref.read(dailyHabitRepositoryProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spaceLG),
      itemCount: 7, // Show past 7 days
      itemBuilder: (context, index) {
        final date = today.subtract(Duration(days: index));
        
        return FutureBuilder(
          future: repository.getEntryForDate(userId: userId, date: date),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildDayCardSkeleton(context, date);
            }

            final entry = snapshot.data;
            return _buildDayCard(context, ref, date, entry, isToday: index == 0);
          },
        );
      },
    );
  }

  /// Build a skeleton loader while data is loading
  /// **Product Note**: Loading states prevent users from feeling like the app is broken
  Widget _buildDayCardSkeleton(BuildContext context, DateTime date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceMD),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
              ),
              const SizedBox(height: AppTheme.spaceSM),
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a card for a specific day's data
  /// **Product Note**: Each card tells a complete story of that day
  Widget _buildDayCard(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
    dynamic entry,
    {required bool isToday}
  ) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, MMM d'); // e.g., "Monday, Jan 3"
    final hasData = entry != null;

    // Calculate total earned time for this day
    int totalEarnedMinutes = 0;
    if (hasData) {
      final configAsync = ref.read(algorithmConfigProvider);
      configAsync.whenData((config) {
        // Recalculate earned time based on logged minutes
        for (final category in HabitCategory.values) {
          final loggedMinutes = entry.minutesByCategory[category] ?? 0;
          final categoryConfig = config.categories[category.id];
          
          if (categoryConfig != null && loggedMinutes > 0) {
            final earnedForCategory = (loggedMinutes * categoryConfig.minutesPerHour / 60).round();
            final cappedEarned = earnedForCategory.clamp(0, categoryConfig.maxMinutes).round() as int;
            totalEarnedMinutes += cappedEarned;
          }
        }
        
        // Add POWER+ bonus if unlocked
        if (entry.powerModeUnlocked) {
          totalEarnedMinutes += config.powerPlus.bonusMinutes;
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceMD),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header with POWER+ badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isToday ? 'Today' : dateFormat.format(date),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isToday ? AppTheme.primaryGreen : AppTheme.textDark,
                            ),
                          ),
                          if (hasData && entry.powerModeUnlocked) ...[
                            const SizedBox(width: AppTheme.spaceSM),
                            _buildPowerPlusBadge(context),
                          ],
                        ],
                      ),
                      if (isToday)
                        Text(
                          dateFormat.format(date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                    ],
                  ),
                  // Earned screen time for the day
                  if (hasData)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_formatMinutes(totalEarnedMinutes)}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        Text(
                          'earned',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: AppTheme.spaceMD),

              // Habits breakdown or empty state
              if (!hasData)
                _buildEmptyState(context)
              else
                _buildHabitsBreakdown(context, entry),
            ],
          ),
        ),
      ),
    );
  }

  /// Build POWER+ Mode badge
  /// **Product Note**: Visual badges are more impactful than text
  Widget _buildPowerPlusBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceSM,
        vertical: AppTheme.spaceXS,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryGreen,
            AppTheme.primaryGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bolt,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          const Text(
            'POWER+',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state for days with no data
  /// **Product Note**: Empty states should be helpful, not discouraging
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.borderLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.textLight,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spaceSM),
          Expanded(
            child: Text(
              'No habits logged on this day',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build habits breakdown showing each category
  /// **Product Note**: Breaking down data helps users understand their behavior
  Widget _buildHabitsBreakdown(BuildContext context, dynamic entry) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habits Logged',
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppTheme.textMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spaceSM),
        ...HabitCategory.values.map((category) {
          final minutes = entry.minutesByCategory[category] ?? 0;
          
          if (minutes == 0) return const SizedBox.shrink();
          
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spaceXS),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(category),
                  size: 18,
                  color: _getCategoryColor(category),
                ),
                const SizedBox(width: AppTheme.spaceSM),
                Expanded(
                  child:                   Text(
                    category.label,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Text(
                  _formatMinutes(minutes),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Get icon for a habit category
  IconData _getCategoryIcon(HabitCategory category) {
    switch (category) {
      case HabitCategory.sleep:
        return Icons.bedtime;
      case HabitCategory.exercise:
        return Icons.fitness_center;
      case HabitCategory.outdoor:
        return Icons.park;
      case HabitCategory.productive:
        return Icons.book;
    }
  }

  /// Get color for a habit category
  Color _getCategoryColor(HabitCategory category) {
    switch (category) {
      case HabitCategory.sleep:
        return Colors.indigo;
      case HabitCategory.exercise:
        return Colors.orange;
      case HabitCategory.outdoor:
        return Colors.green;
      case HabitCategory.productive:
        return Colors.blue;
    }
  }

  /// Format minutes to human-readable string
  /// **Product Note**: Always format data for humans, not machines
  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainingMinutes}m';
  }
}

