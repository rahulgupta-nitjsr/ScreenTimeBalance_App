import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/habit_category.dart';
import '../utils/theme.dart';

/// A card that displays progress for a single habit category with a circular indicator
/// 
/// **Learning Note for Product Developers:**
/// This widget demonstrates several UX principles:
/// 1. **Visual Hierarchy:** Progress circle draws attention first, then details
/// 2. **Color Psychology:** Green for complete, amber for in-progress, gray for incomplete
/// 3. **Information Density:** Shows multiple data points without overwhelming the user
/// 4. **Feedback Loop:** Immediate visual indication of progress creates motivation
class HabitProgressCard extends StatelessWidget {
  const HabitProgressCard({
    super.key,
    required this.category,
    required this.currentMinutes,
    required this.goalMinutes,
    required this.earnedMinutes,
    this.maxMinutes,
    this.showTrend = false,
    this.trendData,
  });

  final HabitCategory category;
  final int currentMinutes;
  final int goalMinutes;
  final int earnedMinutes;
  final int? maxMinutes;
  final bool showTrend;
  final List<int>? trendData; // Last 7 days of data for sparkline

  /// Calculate completion percentage (0.0 to 1.0)
  double get _progress {
    if (goalMinutes <= 0) return 0.0;
    final progress = currentMinutes / goalMinutes;
    return progress.clamp(0.0, 1.0);
  }

  /// Get color based on progress level
  /// **UX Learning:** Color coding helps users quickly understand status without reading text
  Color _getProgressColor(BuildContext context) {
    if (_progress >= 1.0) return AppTheme.secondaryGreen; // Complete
    if (_progress >= 0.5) return Colors.amber; // In progress
    return AppTheme.borderLight; // Not started
  }

  /// Get status text based on progress
  String get _statusText {
    if (_progress >= 1.0) return 'Goal Complete! 🎉';
    if (_progress >= 0.5) return 'Keep Going!';
    return 'Get Started';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = _getProgressColor(context);
    final hours = currentMinutes ~/ 60;
    final mins = currentMinutes % 60;
    final goalHours = goalMinutes ~/ 60;
    final goalMins = goalMinutes % 60;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(
          color: _progress >= 1.0 
              ? AppTheme.secondaryGreen.withOpacity(0.3)
              : Colors.white.withOpacity(0.08),
          width: _progress >= 1.0 ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category icon and name
            Row(
              children: [
                Icon(
                  category.icon,
                  color: category.primaryColor(context),
                  size: 24,
                ),
                const SizedBox(width: AppTheme.spaceSM),
                Expanded(
                  child: Text(
                    category.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_progress >= 1.0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceSM,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    ),
                    child: Text(
                      '✓ Done',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.secondaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceLG),

            // Circular progress indicator with center text
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress circle
                  CustomPaint(
                    size: const Size(120, 120),
                    painter: _CircularProgressPainter(
                      progress: _progress,
                      color: progressColor,
                      backgroundColor: AppTheme.borderLight,
                    ),
                  ),
                  // Center text showing percentage
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                      Text(
                        _statusText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceMD),

            // Current vs Goal
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${hours}h ${mins}m',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ' / ${goalHours}h ${goalMins}m',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceXS),

            // Earned screen time
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMD,
                vertical: AppTheme.spaceXS,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              child: Text(
                'Earned: $earnedMinutes min screen time',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Maximum cap indicator (if applicable)
            if (maxMinutes != null && maxMinutes! > 0) ...[
              const SizedBox(height: AppTheme.spaceXS),
              Text(
                'Cap: ${maxMinutes! ~/ 60}h ${maxMinutes! % 60}m max',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
            ],

            // Sparkline trend (if data available)
            if (showTrend && trendData != null && trendData!.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spaceMD),
              _buildSparkline(context, trendData!),
            ],
          ],
        ),
      ),
    );
  }

  /// Build a mini sparkline showing trend over last 7 days
  /// **Learning Note:** Sparklines provide context without taking up much space
  Widget _buildSparkline(BuildContext context, List<int> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '7-Day Trend',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.textLight,
          ),
        ),
        const SizedBox(height: AppTheme.spaceXS),
        SizedBox(
          height: 30,
          child: CustomPaint(
            size: const Size(double.infinity, 30),
            painter: _SparklinePainter(
              data: data,
              color: category.primaryColor(context),
              goalMinutes: goalMinutes,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for circular progress indicator
/// **Technical Learning:** CustomPainter allows us to draw custom graphics efficiently
class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final strokeWidth = 12.0;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final startAngle = -math.pi / 2; // Start from top
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

/// Custom painter for sparkline trend visualization
/// **Product Learning:** Sparklines show trends without taking up much space - great for dashboards
class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.data,
    required this.color,
    required this.goalMinutes,
  });

  final List<int> data;
  final Color color;
  final int goalMinutes;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || data.length < 2) return;

    final maxValue = data.reduce(math.max).toDouble();
    final minValue = data.reduce(math.min).toDouble();
    final range = maxValue - minValue;
    
    // If all values are the same, use a default range
    final normalizedRange = range == 0 ? maxValue : range;

    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepWidth = size.width / (data.length - 1);

    for (var i = 0; i < data.length; i++) {
      final x = i * stepWidth;
      final normalizedValue = normalizedRange == 0 
          ? 0.5 
          : (data[i] - minValue) / normalizedRange;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw dots for each data point
      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()
          ..color = data[i] >= goalMinutes ? Colors.green : color
          ..style = PaintingStyle.fill,
      );
    }

    canvas.drawPath(path, paint);

    // Draw goal line if within range
    if (goalMinutes > 0 && goalMinutes >= minValue && goalMinutes <= maxValue) {
      final goalY = size.height - ((goalMinutes - minValue) / normalizedRange * size.height);
      final goalPaint = Paint()
        ..color = Colors.green.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(0, goalY),
        Offset(size.width, goalY),
        goalPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.color != color ||
        oldDelegate.goalMinutes != goalMinutes;
  }
}

