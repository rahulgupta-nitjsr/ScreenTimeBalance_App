import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../utils/theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/zen_button.dart';
import '../providers/auth_provider.dart';
import '../providers/repository_providers.dart';

/// Privacy Settings Screen - Feature 14 Implementation
/// 
/// **Product Learning Note:**
/// Privacy settings are crucial for user trust. Key principles:
/// 1. Transparency: Clearly explain what data is collected
/// 2. Control: Give users options to manage their data
/// 3. Compliance: Follow GDPR, CCPA, and other regulations
/// 4. Security: Show what measures are in place to protect data
/// 
/// **Note**: This is a foundational implementation.
/// Full privacy management will be expanded in future iterations.
class SettingsPrivacyScreen extends ConsumerWidget {
  const SettingsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spaceLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Data Collection section
                      GlassCard(
                        padding: const EdgeInsets.all(AppTheme.spaceLG),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.security,
                                  color: AppTheme.primaryGreen,
                                  size: 24,
                                ),
                                const SizedBox(width: AppTheme.spaceSM),
                                Text(
                                  'Data Collection',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spaceMD),
                            _buildPrivacyInfoItem(
                              context,
                              icon: Icons.check_circle,
                              title: 'What we collect',
                              description: 'Habit tracking data, screen time logs, and basic profile information',
                            ),
                            const SizedBox(height: AppTheme.spaceSM),
                            _buildPrivacyInfoItem(
                              context,
                              icon: Icons.storage,
                              title: 'Where it\'s stored',
                              description: 'Locally on your device and securely in Firebase Cloud',
                            ),
                            const SizedBox(height: AppTheme.spaceSM),
                            _buildPrivacyInfoItem(
                              context,
                              icon: Icons.lock,
                              title: 'How it\'s protected',
                              description: 'End-to-end encryption and secure authentication',
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppTheme.spaceLG),
                      
                      // Data Management section
                      GlassCard(
                        padding: const EdgeInsets.all(AppTheme.spaceLG),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.settings,
                                  color: AppTheme.primaryGreen,
                                  size: 24,
                                ),
                                const SizedBox(width: AppTheme.spaceSM),
                                Text(
                                  'Data Management',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spaceLG),
                            
                            // Export Data button
                            ZenButton.outline(
                              'Export My Data',
                              onPressed: () => _exportData(context, ref),
                            ),
                            
                            const SizedBox(height: AppTheme.spaceMD),
                            
                            // Delete Account button
                            ZenButton.secondary(
                              'Delete Account',
                              onPressed: () {
                                _showDeleteAccountDialog(context);
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppTheme.spaceLG),
                      
                      // Privacy Policy link
                      GlassCard(
                        padding: const EdgeInsets.all(AppTheme.spaceLG),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Legal & Compliance',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spaceMD),
                            _buildLegalLink(
                              context,
                              icon: Icons.description,
                              title: 'Privacy Policy',
                              onTap: () {
                                _showComingSoonDialog(context, 'Privacy Policy');
                              },
                            ),
                            _buildLegalLink(
                              context,
                              icon: Icons.gavel,
                              title: 'Terms of Service',
                              onTap: () {
                                _showComingSoonDialog(context, 'Terms of Service');
                              },
                            ),
                            _buildLegalLink(
                              context,
                              icon: Icons.shield,
                              title: 'Data Protection Rights',
                              onTap: () {
                                _showComingSoonDialog(context, 'Data Protection Rights');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
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
              'Privacy & Data',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build privacy info item
  Widget _buildPrivacyInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryGreen),
        const SizedBox(width: AppTheme.spaceSM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spaceXS),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build legal link
  Widget _buildLegalLink(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSM),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.textMedium),
            const SizedBox(width: AppTheme.spaceSM),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }

  /// Export user data to CSV
  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final authState = ref.read(authControllerProvider);
    if (authState is! Authenticated) {
      _showErrorDialog(context, 'Please sign in to export data');
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(child: Text('Exporting your data...')),
          ],
        ),
      ),
    );

    try {
      // Get all user data
      final repository = ref.read(dailyHabitRepositoryProvider);
      final entries = await repository.getAllEntries(userId: authState.user.id);

      // Export to CSV
      final exportService = ref.read(dataExportServiceProvider);
      final filePath = await exportService.exportHabitData(
        userId: authState.user.id,
        entries: entries,
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show success dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export Successful!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your data has been exported successfully.'),
                const SizedBox(height: 16),
                Text(
                  'File saved to:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  filePath,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'You can open this file in Excel, Google Sheets, or any spreadsheet application.',
                  style: TextStyle(fontSize: 12),
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
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error dialog
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to export data: $e');
      }
    }
  }

  /// Show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show coming soon dialog
  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$feature Coming Soon'),
        content: Text(
          '$feature will be available in a future update. Thank you for your patience!',
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

  /// Show delete account confirmation dialog
  /// **Product Note**: Account deletion is serious - require multiple confirmations
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion feature coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

