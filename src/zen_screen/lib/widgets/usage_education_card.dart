import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/screen_time_provider.dart';

/// Non-blocking education card shown when usage permission is not granted.
/// 
/// Displayed inline in the UI (e.g., Home screen) as a subtle reminder.
/// User can dismiss it temporarily or tap to enable permission.
/// 
/// **Difference from Dialog:**
/// - Dialog: Blocking, shown once on first launch
/// - Card: Non-blocking, shown persistently until permission granted
/// 
/// **Educational Note:**
/// This follows the "progressive disclosure" pattern: intrusive prompt first,
/// then subtle reminders. Respects user choice while encouraging adoption.
class UsageEducationCard extends ConsumerWidget {
  const UsageEducationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.phone_android,
                    color: theme.colorScheme.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Track Your Screen Time',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'See how much time you\'ve used today',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Enable usage tracking to see your actual screen time alongside earned time. '
              'This helps you make informed decisions about your remaining balance.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You can enable this anytime from Settings'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Maybe Later'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: () => _enableUsageTracking(context, ref),
                  icon: const Icon(Icons.settings),
                  label: const Text('Enable in Settings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enableUsageTracking(BuildContext context, WidgetRef ref) async {
    // Open Usage Access settings
    final service = ref.read(screenTimeServiceProvider);
    await service.openUsageSettings();

    // Show helpful toast
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Find "ZenScreen" and toggle "Permit usage access"'),
          duration: Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// Compact version of the education card for limited space.
/// 
/// Shows a single-line banner with an action button.
/// Useful for top-of-screen notifications or compact layouts.
class CompactUsageEducationBanner extends ConsumerWidget {
  const CompactUsageEducationBanner({super.key, this.message, this.onTap});

  final String? message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.secondary.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message ?? 'Enable usage tracking to see screen time used',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          TextButton(
            onPressed: onTap ?? () => _enableUsageTracking(context, ref),
            child: Text(onTap == null ? 'Enable' : 'Check'),
          ),
        ],
      ),
    );
  }

  Future<void> _enableUsageTracking(BuildContext context, WidgetRef ref) async {
    final service = ref.read(screenTimeServiceProvider);
    await service.openUsageSettings();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enable "Permit usage access" for ZenScreen'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
}

