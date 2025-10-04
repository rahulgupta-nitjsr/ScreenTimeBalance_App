import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../utils/theme.dart';
import '../utils/app_router.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/glass_card.dart';
import '../widgets/zen_button.dart';
import '../widgets/zen_progress.dart';
import '../widgets/sync_status_indicator.dart';
import '../widgets/sync_stats_widget.dart';
import '../providers/auth_provider.dart';
import '../providers/repository_providers.dart';
import '../providers/historical_data_provider.dart';
import '../providers/algorithm_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundLight,
              AppTheme.backgroundLight,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight.withOpacity(0.92),
                border: const Border(
                  bottom: BorderSide(color: AppTheme.borderLight, width: 1),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceMD),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: AppTheme.textMedium,
                      ),
                      Expanded(
                        child: Text(
                          'Profile',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SyncStatusButton(),
                    ],
                  ),
                ),
              ),
            ),
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
                      children: [
                        const SizedBox(height: AppTheme.spaceXL),
                        _buildProfileCard(context, ref),
                        const SizedBox(height: AppTheme.spaceXL),
                        _buildUsageInsights(context, ref),
                        const SizedBox(height: AppTheme.spaceXL),
                        GlassCard(
                          padding: const EdgeInsets.all(AppTheme.spaceLG),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Settings',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppTheme.spaceLG),
                              _buildSettingItem(
                                context,
                                icon: Icons.notifications,
                                title: 'Notifications',
                                subtitle: 'Manage habit reminders',
                                onTap: () => context.push(AppRoutes.settingsNotifications),
                              ),
                              _buildSettingItem(
                                context,
                                icon: Icons.privacy_tip,
                                title: 'Privacy',
                                subtitle: 'Data and privacy settings',
                                onTap: () => context.push(AppRoutes.settingsPrivacy),
                              ),
                              _buildSettingItem(
                                context,
                                icon: Icons.help_outline,
                                title: 'Help & Support',
                                subtitle: 'Get help and contact us',
                                onTap: () => _showComingSoon(context, 'Help & Support'),
                              ),
                              _buildSettingItem(
                                context,
                                icon: Icons.info_outline,
                                title: 'About',
                                subtitle: 'App version and info',
                                onTap: () => _showAboutDialog(context),
                              ),
                              const SizedBox(height: AppTheme.spaceLG),
                              
                              // Sync Status Section
                              Text(
                                'Data Sync',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spaceMD),
                              const SyncStatsWidget(),
                              const SizedBox(height: AppTheme.spaceLG),
                              
                              ZenButton.secondary(
                                'Sign Out',
                                onPressed: () async {
                                  // Trigger final sync before sign out
                                  try {
                                    final syncService = ref.read(syncServiceProvider);
                                    await syncService.manualSync();
                                  } catch (e) {
                                    print('Final sync failed: $e');
                                  }
                                  
                                  await ref.read(authControllerProvider.notifier).signOut();
                                  if (context.mounted) {
                                    context.go(AppRoutes.welcome);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceXL),
                        SizedBox(
                          width: double.infinity,
                          child: ZenButton.secondary(
                            'Log Out',
                            onPressed: () {},
                          ),
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

  /// Build profile card with real user data
  /// **Product Note**: Always show real data, not placeholder data
  Widget _buildProfileCard(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userRepository = ref.watch(userRepositoryProvider);
    final userAsync = userRepository.getById(
      authState is Authenticated ? authState.user.id : '',
    );

    return FutureBuilder(
      future: userAsync,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final displayName = user?.displayName ?? (authState is Authenticated ? authState.user.displayName : 'Guest User');
        final email = user?.email ?? (authState is Authenticated ? authState.user.email : 'guest@zenscreen.app');
        
        return GlassCard(
          padding: const EdgeInsets.all(AppTheme.spaceXL),
          child: Column(
            children: [
              // Avatar (we'll add upload functionality later)
              CircleAvatar(
                radius: 48,
                backgroundColor: AppTheme.primaryGreen,
                backgroundImage: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user?.avatarUrl == null || user!.avatarUrl!.isEmpty
                    ? const Icon(Icons.person, size: 48, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: AppTheme.spaceLG),
              Text(
                displayName ?? 'ZenScreen User',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: AppTheme.spaceSM),
              Text(
                email ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textMedium,
                ),
              ),
              const SizedBox(height: AppTheme.spaceLG),
              // Edit Profile Button
              SizedBox(
                width: double.infinity,
                child: ZenButton.outline(
                  'Edit Profile',
                  onPressed: () {
                    context.push(AppRoutes.editProfile);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build usage insights with real data from database
  /// **Product Note**: Real usage data motivates users to continue using the app
  Widget _buildUsageInsights(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    
    if (authState is! Authenticated) {
      return const SizedBox.shrink();
    }

    // Get historical data
    final streakAsync = ref.watch(powerModeStreakProvider);
    final repository = ref.read(dailyHabitRepositoryProvider);
    
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Usage insights',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton.icon(
                onPressed: () {
                  context.push(AppRoutes.history);
                },
                icon: const Icon(Icons.history, size: 18),
                label: const Text('View History'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLG),
          // Days Active
          FutureBuilder(
            future: _getDaysActive(repository, authState.user.id),
            builder: (context, snapshot) {
              final daysActive = snapshot.data ?? 0;
              return _buildStatItem(
                context,
                'Days Active',
                '$daysActive day${daysActive == 1 ? '' : 's'}',
                progress: (daysActive / 7).clamp(0.0, 1.0),
              );
            },
          ),
          const SizedBox(height: AppTheme.spaceMD),
          // Total Screen Time Earned
          FutureBuilder(
            future: _getTotalEarnedTime(repository, ref, authState.user.id),
            builder: (context, snapshot) {
              final totalMinutes = snapshot.data ?? 0;
              final hours = totalMinutes ~/ 60;
              final minutes = totalMinutes % 60;
              return _buildStatItem(
                context,
                'Total Screen Time Earned',
                '${hours}h ${minutes}m',
                progress: (totalMinutes / 720).clamp(0.0, 1.0), // Out of 12 hours max
              );
            },
          ),
          const SizedBox(height: AppTheme.spaceMD),
          // POWER+ Mode Unlocked
          FutureBuilder(
            future: _getPowerModeDays(repository, authState.user.id),
            builder: (context, snapshot) {
              final powerDays = snapshot.data ?? 0;
              return _buildStatItem(
                context,
                'POWER+ Mode Unlocked',
                '$powerDays time${powerDays == 1 ? '' : 's'}',
                progress: powerDays > 0 ? 1.0 : 0.0,
              );
            },
          ),
          const SizedBox(height: AppTheme.spaceMD),
          // Current Streak
          streakAsync.when(
            data: (streak) => _buildStatItem(
              context,
              'Current Streak',
              '$streak day${streak == 1 ? '' : 's'}',
              progress: (streak / 7).clamp(0.0, 1.0),
            ),
            loading: () => _buildStatItem(
              context,
              'Current Streak',
              'Loading...',
              progress: 0.0,
            ),
            error: (_, __) => _buildStatItem(
              context,
              'Current Streak',
              '0 days',
              progress: 0.0,
            ),
          ),
        ],
      ),
    );
  }

  /// Get number of days user has been active
  Future<int> _getDaysActive(dynamic repository, String userId) async {
    try {
      final entries = await repository.getAllEntries(userId);
      return entries.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get total earned time across all days
  Future<int> _getTotalEarnedTime(dynamic repository, WidgetRef ref, String userId) async {
    try {
      final entries = await repository.getAllEntries(userId);
      int total = 0;
      
      final configAsync = ref.read(algorithmConfigProvider);
      await configAsync.whenData((config) {
        for (final entry in entries) {
          // Calculate earned time for this entry
          for (final category in entry.minutesByCategory.entries) {
            final categoryConfig = config.categories[category.key.id];
            if (categoryConfig != null) {
            final earned = (category.value * categoryConfig.minutesPerHour / 60).round();
            final capped = earned.clamp(0, categoryConfig.maxMinutes).round() as int;
              total += capped;
            }
          }
          
          // Add POWER+ bonus
          if (entry.powerModeUnlocked) {
            total += config.powerPlus.bonusMinutes;
          }
        }
      });
      
      return total;
    } catch (e) {
      return 0;
    }
  }

  /// Get number of days with POWER+ Mode unlocked
  Future<int> _getPowerModeDays(dynamic repository, String userId) async {
    try {
      final entries = await repository.getAllEntries(userId);
      return entries.where((entry) => entry.powerModeUnlocked).length;
    } catch (e) {
      return 0;
    }
  }

  Widget _buildStatItem(BuildContext context, String title, String value, {required double progress}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textMedium,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceXS),
        ZenLinearProgressBar(
          progress: progress,
          height: 8,
          backgroundColor: AppTheme.borderLight,
          progressColor: progress >= 1 ? AppTheme.secondaryGreen : AppTheme.primaryGreen,
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSM),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
            ),
            const SizedBox(width: AppTheme.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXS),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppTheme.textLight, size: 16),
          ],
        ),
      ),
    );
  }

  /// Show coming soon message
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show about dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About ZenScreen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Version 1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'ZenScreen helps you earn screen time through healthy habits.',
            ),
            const SizedBox(height: 12),
            const Text(
              '© 2025 ZenScreen. All rights reserved.',
              style: TextStyle(fontSize: 12, color: AppTheme.textLight),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}