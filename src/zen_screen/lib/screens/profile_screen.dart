import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/glass_card.dart';
import '../widgets/zen_button.dart';
import '../widgets/zen_input_field.dart';
import '../widgets/zen_progress.dart';
import '../utils/theme.dart';
import '../utils/app_router.dart';
import '../providers/navigation_provider.dart';

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
            // Header
            Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight.withOpacity(0.92),
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
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppTheme.textMedium,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Profile',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
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
                      children: [
                        const SizedBox(height: AppTheme.spaceXL),
                        GlassCard(
                          padding: const EdgeInsets.all(AppTheme.spaceXL),
                          child: Column(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryBackgroundGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 48,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spaceLG),
                              const Text(
                                'Ethan Carter',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spaceSM),
                              const Text(
                                'ethan.carter@example.com',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textMedium,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spaceLG),
                              Row(
                                children: [
                                  const Expanded(
                                    child: ZenInputField(
                                      label: 'Display name',
                                      hint: 'Ethan Carter',
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spaceMD),
                                  ZenButton.outline(
                                    'Update',
                                    onPressed: () {},
                                  ),
                                ],
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
                              _buildStatItem(
                                context,
                                'Days Active',
                                '7 days',
                                progress: 0.7,
                              ),
                              const SizedBox(height: AppTheme.spaceMD),
                              _buildStatItem(
                                context,
                                'Total Screen Time Earned',
                                '12h 45m',
                                progress: 0.64,
                              ),
                              const SizedBox(height: AppTheme.spaceMD),
                              _buildStatItem(
                                context,
                                'POWER+ Mode Unlocked',
                                '5 times',
                                progress: 1.0,
                              ),
                              const SizedBox(height: AppTheme.spaceMD),
                              _buildStatItem(
                                context,
                                'Current Streak',
                                '3 days',
                                progress: 0.3,
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
                                'Settings',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppTheme.spaceLG),
                              _buildSettingItem(
                                context,
                                icon: Icons.notifications,
                                title: 'Notifications',
                                subtitle: 'Manage habit reminders',
                                onTap: () {},
                              ),
                              _buildSettingItem(
                                context,
                                icon: Icons.privacy_tip,
                                title: 'Privacy',
                                subtitle: 'Data and privacy settings',
                                onTap: () {},
                              ),
                              _buildSettingItem(
                                context,
                                icon: Icons.help_outline,
                                title: 'Help & Support',
                                subtitle: 'Get help and contact us',
                                onTap: () {},
                              ),
                              _buildSettingItem(
                                context,
                                icon: Icons.info_outline,
                                title: 'About',
                                subtitle: 'App version and info',
                                onTap: () {},
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
    required VoidCallback onTap,
  }) {
    return GlassCard(
      opacity: 0.9,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceLG,
        vertical: AppTheme.spaceMD,
      ),
      child: InkWell(
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
                child: Icon(
                  icon,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
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
              const Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textLight,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}