import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_navigation.dart';
import '../utils/theme.dart';
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
                color: AppTheme.backgroundGray.withOpacity(0.8),
                border: const Border(
                  bottom: BorderSide(
                    color: AppTheme.borderLight,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/home');
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: AppTheme.textMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Today's Progress",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Screen time summary
                    _buildScreenTimeSummary(context),
                    const SizedBox(height: 32),
                    
                    // POWER+ Mode status
                    _buildPowerModeStatus(context),
                    const SizedBox(height: 32),
                    
                    // Habits progress
                    Text(
                      'Habits',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    
                    // Habit cards
                    _buildHabitCard(
                      context: context,
                      icon: Icons.bedtime,
                      title: 'Sleep',
                      progress: '8h 0m / 8h 0m',
                      progressValue: 1.0,
                    ),
                    const SizedBox(height: 16),
                    _buildHabitCard(
                      context: context,
                      icon: Icons.fitness_center,
                      title: 'Exercise',
                      progress: '45m / 45m',
                      progressValue: 1.0,
                    ),
                    const SizedBox(height: 16),
                    _buildHabitCard(
                      context: context,
                      icon: Icons.park,
                      title: 'Outdoor',
                      progress: '30m / 30m',
                      progressValue: 1.0,
                    ),
                    const SizedBox(height: 16),
                    _buildHabitCard(
                      context: context,
                      icon: Icons.book,
                      title: 'Productive',
                      progress: '2h 0m / 2h 0m',
                      progressValue: 1.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  Widget _buildScreenTimeSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: AppTheme.liquidGlassDecoration,
      child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeCard(
                  context: context,
                  title: 'Earned Screen Time',
                  time: '1h 53m',
                  color: AppTheme.primaryGreen,
                ),
                _buildTimeCard(
                  context: context,
                  title: 'Used Screen Time',
                  time: '30m',
                  color: AppTheme.textLight,
                ),
              ],
            ),
          ],
        ),
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textLight,
          ),
          textAlign: TextAlign.center,
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
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.secondaryGreen.withOpacity(0.1),
            AppTheme.primaryGreen.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: AppTheme.secondaryGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.secondaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.bolt,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POWER+ Mode Unlocked!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+30 bonus minutes earned',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMedium,
                  ),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      progress,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressValue >= 1.0 
                        ? AppTheme.secondaryGreen 
                        : AppTheme.primaryGreen,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}