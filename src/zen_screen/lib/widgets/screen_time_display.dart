import 'package:flutter/material.dart';

import '../utils/theme.dart';

/// Reusable widget for displaying a single screen time value.
/// 
/// Shows a label (e.g., "EARNED") and the time value formatted as "Xh Ym".
/// Used consistently across Home and Progress screens.
/// 
/// **Educational Note:**
/// Extracting this into a reusable component ensures consistency
/// and makes it easier to update styling across the app.
class ScreenTimeDisplay extends StatelessWidget {
  const ScreenTimeDisplay({
    super.key,
    required this.label,
    required this.minutes,
    this.color,
    this.icon,
    this.isLoading = false,
  });

  /// Label text shown above the time value (e.g., "EARNED", "USED", "REMAINING")
  final String label;
  
  /// Time value in minutes to display
  final int minutes;
  
  /// Optional color for the time value text (defaults to primary)
  final Color? color;
  
  /// Optional icon shown before the label
  final IconData? icon;
  
  /// Whether to show loading skeleton instead of actual value
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayColor = color ?? theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label with optional icon
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: AppTheme.textLight,
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label.toUpperCase(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceXS),
        
        // Time value or loading skeleton
        if (isLoading)
          Container(
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
          )
        else
          Text(
            _formatMinutes(minutes),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: displayColor,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  /// Format minutes as "Xh Ym", "Xh", or "Ym" depending on the value.
  /// 
  /// Examples:
  /// - 0 minutes → "0m"
  /// - 45 minutes → "45m"
  /// - 60 minutes → "1h"
  /// - 90 minutes → "1h 30m"
  String _formatMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }
}

/// Compact horizontal layout showing three screen time values.
/// 
/// Used in summary cards to display Earned, Used, and Remaining
/// in a clean, scannable format with dividers.
class ScreenTimeTripleDisplay extends StatelessWidget {
  const ScreenTimeTripleDisplay({
    super.key,
    required this.earned,
    required this.used,
    required this.remaining,
    this.isLoading = false,
  });

  final int earned;
  final int used;
  final int remaining;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            child: ScreenTimeDisplay(
              label: 'Earned',
              minutes: earned,
              color: AppTheme.primaryGreen,
              icon: Icons.emoji_events,
              isLoading: isLoading,
            ),
          ),
          VerticalDivider(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            thickness: 1,
            width: 32,
          ),
          Flexible(
            child: ScreenTimeDisplay(
              label: 'Used',
              minutes: used,
              color: Colors.amber[700],
              icon: Icons.access_time,
              isLoading: isLoading,
            ),
          ),
          VerticalDivider(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            thickness: 1,
            width: 32,
          ),
          Flexible(
            child: ScreenTimeDisplay(
              label: 'Remaining',
              minutes: remaining,
              color: Colors.blue[600],
              icon: Icons.hourglass_bottom,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

