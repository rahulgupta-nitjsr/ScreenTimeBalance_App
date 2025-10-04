import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../utils/theme.dart';
import '../widgets/glass_card.dart';
import '../providers/settings_provider.dart';

/// Notifications Settings Screen - Feature 14 Implementation
/// 
/// **Product Learning Note:**
/// Notification settings are about giving users control.
/// Best practices:
/// 1. Clear categories (what each notification is for)
/// 2. Granular control (not just all-or-nothing)
/// 3. Respect system settings
/// 4. Show examples of what notifications look like
/// 
/// **Implementation**: Settings now persist to database!
class SettingsNotificationsScreen extends ConsumerWidget {
  const SettingsNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(settingsControllerProvider);

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
              
              // Settings content
              Expanded(
                child: settingsAsync.when(
                  data: (settings) => SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.spaceLG),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GlassCard(
                          padding: const EdgeInsets.all(AppTheme.spaceLG),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notification Preferences',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spaceSM),
                              Text(
                                'Choose what notifications you want to receive',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textLight,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spaceLG),
                              
                              // Habit Reminders
                              _buildNotificationToggle(
                                context,
                                ref,
                                title: 'Habit Reminders',
                                subtitle: 'Get reminded to log your daily habits',
                                icon: Icons.notifications_active,
                                value: settings?.dailyReminders ?? true,
                                settingKey: 'dailyReminders',
                              ),
                              
                              const Divider(height: AppTheme.spaceLG),
                              
                              // POWER+ Mode Alerts
                              _buildNotificationToggle(
                                context,
                                ref,
                                title: 'POWER+ Mode Alerts',
                                subtitle: 'Get notified when you unlock POWER+ Mode',
                                icon: Icons.bolt,
                                value: settings?.powerModeAlerts ?? true,
                                settingKey: 'powerModeAlerts',
                              ),
                              
                              const Divider(height: AppTheme.spaceLG),
                              
                              // Daily Streak Reminders
                              _buildNotificationToggle(
                                context,
                                ref,
                                title: 'Daily Streak Reminders',
                                subtitle: 'Keep your streak alive with daily reminders',
                                icon: Icons.local_fire_department,
                                value: settings?.dailyStreakReminders ?? false,
                                settingKey: 'dailyStreakReminders',
                              ),
                              
                              const Divider(height: AppTheme.spaceLG),
                              
                              // Weekly Reports
                              _buildNotificationToggle(
                                context,
                                ref,
                                title: 'Weekly Reports',
                                subtitle: 'Get weekly summaries of your progress',
                                icon: Icons.bar_chart,
                                value: settings?.weeklyReports ?? false,
                                settingKey: 'weeklyReports',
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: AppTheme.spaceLG),
                        
                        // Info card
                        GlassCard(
                          padding: const EdgeInsets.all(AppTheme.spaceMD),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: AppTheme.primaryGreen,
                                size: 24,
                              ),
                              const SizedBox(width: AppTheme.spaceMD),
                              Expanded(
                                child: Text(
                                  'Your preferences are being saved! Notification scheduling coming in a future update.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: AppTheme.spaceMD),
                        Text(
                          'Error loading settings',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.spaceSM),
                        Text(
                          error.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header
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
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: AppTheme.spaceSM),
            Text(
              'Notifications',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build notification toggle item with persistence
  /// **Product Note**: Make toggles large and easy to tap (min 44x44 points)
  Widget _buildNotificationToggle(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required String settingKey,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () async {
        // Save setting immediately when row is tapped
        await ref.read(settingsControllerProvider.notifier).updateSetting(settingKey, !value);
      },
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
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXS),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: (newValue) async {
                // Save setting immediately
                await ref.read(settingsControllerProvider.notifier).updateSetting(settingKey, newValue);
              },
              activeColor: AppTheme.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }
}
