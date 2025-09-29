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
                        GlassCard(
                          padding: const EdgeInsets.all(AppTheme.spaceXL),
                          child: Column(
                            children: const [
                              CircleAvatar(
                                radius: 48,
                                backgroundColor: AppTheme.primaryGreen,
                                child: Icon(Icons.person, size: 48, color: Colors.white),
                              ),
                              SizedBox(height: AppTheme.spaceLG),
                              Text(
                                'Ethan Carter',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              SizedBox(height: AppTheme.spaceSM),
                              Text(
                                'ethan.carter@example.com',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceXL),
                        GlassCard(
                          padding: const EdgeInsets.all(AppTheme.spaceLG),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Usage insights',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppTheme.spaceLG),
                              _buildStatItem(context, 'Days Active', '7 days', progress: 0.7),
                              const SizedBox(height: AppTheme.spaceMD),
                              _buildStatItem(context, 'Total Screen Time Earned', '12h 45m', progress: 0.64),
                              const SizedBox(height: AppTheme.spaceMD),
                              _buildStatItem(context, 'POWER+ Mode Unlocked', '5 times', progress: 1.0),
                              const SizedBox(height: AppTheme.spaceMD),
                              _buildStatItem(context, 'Current Streak', '3 days', progress: 0.3),
                            ],
                          ),
                        ),
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
                              ),
                              _buildSettingItem(
                                context,
                                icon: Icons.privacy_tip,
                                title: 'Privacy',
                                subtitle: 'Data and privacy settings',
                              ),
                              _buildSettingItem(
                                context,
                                icon: Icons.help_outline,
                                title: 'Help & Support',
                                subtitle: 'Get help and contact us',
                              ),
                              _buildSettingItem(
                                context,
                                icon: Icons.info_outline,
                                title: 'About',
                                subtitle: 'App version and info',
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
  }) {
    return Padding(
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
    );
  }
}