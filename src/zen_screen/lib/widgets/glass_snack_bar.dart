import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Glass-styled snack bars for user feedback
/// 
/// **Product Learning:**
/// Snack bars should match your app's visual language. These glass-styled
/// snack bars maintain visual consistency while providing clear feedback.
class GlassSnackBar {
  /// Create a success snack bar
  static SnackBar success(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    return _buildSnackBar(
      context: context,
      title: title,
      message: message,
      icon: Icons.check_circle,
      color: AppTheme.primaryGreen,
      duration: duration,
    );
  }

  /// Create an error snack bar
  static SnackBar error(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    return _buildSnackBar(
      context: context,
      title: title,
      message: message,
      icon: Icons.error_outline,
      color: Colors.red,
      duration: duration,
    );
  }

  /// Create a warning snack bar
  static SnackBar warning(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    return _buildSnackBar(
      context: context,
      title: title,
      message: message,
      icon: Icons.warning_amber,
      color: Colors.orange,
      duration: duration,
    );
  }

  /// Create an info snack bar
  static SnackBar info(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    return _buildSnackBar(
      context: context,
      title: title,
      message: message,
      icon: Icons.info_outline,
      color: Colors.blue,
      duration: duration,
    );
  }

  static SnackBar _buildSnackBar({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    required Duration duration,
  }) {
    return SnackBar(
      content: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: AppTheme.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: color.withOpacity(0.15),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      duration: duration,
      margin: const EdgeInsets.all(AppTheme.spaceMD),
    );
  }
}

