import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/theme.dart';

/// Shared linear progress bar with design system styling.
class ZenLinearProgressBar extends StatelessWidget {
  const ZenLinearProgressBar({
    super.key,
    required this.progress,
    this.height = 12,
    this.backgroundColor,
    this.progressColor,
    this.showLabel = false,
    this.label,
  });

  final double progress; // 0.0 - 1.0
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool showLabel;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final double clamped = progress.clamp(0, 1).toDouble();
    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: clamped,
        minHeight: height,
        backgroundColor: backgroundColor ?? AppTheme.borderLight,
        valueColor: AlwaysStoppedAnimation<Color>(
          progressColor ?? AppTheme.primaryGreen,
        ),
      ),
    );

    if (!showLabel) return bar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: AppTheme.spaceXS),
        ],
        bar,
      ],
    );
  }
}

/// Circular progress indicator following the habit completion visuals.
class ZenCircularProgress extends StatelessWidget {
  const ZenCircularProgress({
    super.key,
    required this.progress,
    this.size = 96,
    this.strokeWidth = 4,
    this.backgroundColor,
    this.progressColor,
    this.center,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final double clamped = progress.clamp(0, 1).toDouble();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: _CircularProgressPainter(
              progress: clamped,
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor ?? AppTheme.borderLight,
              progressColor: progressColor ?? AppTheme.primaryGreen,
            ),
          ),
          if (center != null) center!,
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint basePaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2;
    final sweepAngle = progress * 2 * math.pi;

    canvas.drawArc(rect.deflate(strokeWidth / 2), 0, 2 * math.pi, false, basePaint);
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}

