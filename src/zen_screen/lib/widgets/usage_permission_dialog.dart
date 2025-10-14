import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/screen_time_provider.dart';

/// Blocking permission dialog for Usage Access.
/// 
/// Shown once on app launch when permission is not granted.
/// Explains the feature benefits and guides user to Settings.
/// 
/// **User Flow:**
/// 1. Dialog appears (blocking, can't dismiss without action)
/// 2. User reads benefits and explanation
/// 3. User taps "Enable Permission" → app opens Settings
/// 4. User grants permission in Settings
/// 5. User returns to app → dialog checks and dismisses if granted
/// 
/// **Educational Note:**
/// Blocking dialogs should be used sparingly and only for critical features.
/// We use it here because screen time tracking is core to the app's value prop.
class UsagePermissionDialog extends ConsumerStatefulWidget {
  const UsagePermissionDialog({super.key});

  @override
  ConsumerState<UsagePermissionDialog> createState() => _UsagePermissionDialogState();
}

class _UsagePermissionDialogState extends ConsumerState<UsagePermissionDialog> {
  bool _showDetailedExplanation = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return WillPopScope(
      // Prevent dismissal by back button - must take action
      onWillPop: () async => false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.insights,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Enable Screen Time Tracking',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ZenScreen needs permission to track your device usage.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              _buildBenefit(
                context,
                Icons.visibility,
                'See your actual screen time used today',
              ),
              _buildBenefit(
                context,
                Icons.account_balance_wallet,
                'Compare usage with your earned time budget',
              ),
              _buildBenefit(
                context,
                Icons.insights,
                'Make informed decisions about remaining time',
              ),
              if (_showDetailedExplanation) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why this permission?',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Android requires special permission to access usage statistics. '
                        'This data stays on your device and is used only to show you '
                        'how much screen time you\'ve used today alongside the time '
                        'you\'ve earned through healthy habits.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _buildInstructionBox(context),
            ],
          ),
        ),
        actions: [
          if (!_showDetailedExplanation)
            TextButton(
              onPressed: () {
                setState(() {
                  _showDetailedExplanation = true;
                });
              },
              child: const Text('Learn More'),
            ),
          TextButton(
            onPressed: () => _skipForNow(context),
            child: Text(
              'Skip for Now',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: () => _enablePermission(context),
            icon: const Icon(Icons.settings),
            label: const Text('Enable Permission'),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionBox(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'How to enable:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '1. Tap "Enable Permission" below\n'
            '2. Find "ZenScreen" in the list\n'
            '3. Toggle "Permit usage access" ON\n'
            '4. Return to the app',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _enablePermission(BuildContext context) async {
    // Open Usage Access settings
    final service = ref.read(screenTimeServiceProvider);
    await service.openUsageSettings();

    // Show toast with instructions
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tap "ZenScreen" and enable "Permit usage access"'),
          duration: Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    // Don't close dialog yet - will close when user returns and permission is checked
  }

  void _skipForNow(BuildContext context) {
    // Allow skipping, but show will re-appear later or show education card
    Navigator.of(context).pop();
    
    // Show info that feature will be limited
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You can enable usage tracking anytime in Settings'),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Helper function to show the permission dialog.
/// 
/// Call this from app initialization or home screen.
/// Checks permission first and only shows if not granted.
Future<void> showUsagePermissionDialogIfNeeded(
  BuildContext context,
  WidgetRef ref,
) async {
  final hasPermission = await ref.read(hasUsagePermissionProvider.future);
  
  if (!hasPermission && context.mounted) {
    await showDialog(
      context: context,
      barrierDismissible: false, // Must take action
      builder: (context) => const UsagePermissionDialog(),
    );
  }
}

