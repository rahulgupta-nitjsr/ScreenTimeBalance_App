import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/algorithm_config.dart';
import '../models/habit_category.dart';
import '../providers/algorithm_provider.dart';
import '../utils/theme.dart';
import '../utils/app_keys.dart';

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(algorithmResultProvider);
    final configAsync = ref.watch(algorithmConfigProvider);

    final cap = configAsync.when(
      data: (config) => result.powerModeUnlocked ? config.dailyCaps.powerPlusMinutes : config.dailyCaps.baseMinutes,
      loading: () => result.powerModeUnlocked ? 150 : 120,
      error: (_, __) => result.powerModeUnlocked ? 150 : 120,
    );

    return Column(
      children: [
        _DonutChart(
          earned: result.totalEarnedMinutes,
          used: result.totalUsedMinutes,
          cap: cap,
        ),
        const SizedBox(height: AppTheme.spaceXL),
        Wrap(
          spacing: AppTheme.spaceMD,
          runSpacing: AppTheme.spaceMD,
          alignment: WrapAlignment.center,
          children: [
            for (final category in HabitCategory.values)
              _CategoryGauge(
                category: category,
                minutesLogged: result.perCategoryLoggedMinutes[category] ?? 0,
                minutesEarned: result.perCategoryEarned[category] ?? 0,
                goalMinutes: configAsync.maybeWhen(
                  data: (config) => config.powerPlus.goals[category.id],
                  orElse: () => null,
                ),
                categoryConfig: configAsync.maybeWhen(
                  data: (config) => config.categories[category.id],
                  orElse: () => null,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceLG),
        Text(
          result.powerModeUnlocked ? 'POWER+ Mode Active' : 'POWER+ Mode Locked',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: result.powerModeUnlocked ? AppTheme.secondaryGreen : AppTheme.textLight,
          ),
        ),
      ],
    );
  }
}

class _DonutChart extends StatelessWidget {
  const _DonutChart({
    required this.earned,
    required this.used,
    required this.cap,
  });

  final int earned;
  final int used;
  final int cap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedCap = cap <= 0 ? (earned + used) : cap;
    final earnedClamped = earned.clamp(0, normalizedCap);
    final usedAvailable = normalizedCap - earnedClamped;
    final usedClamped = used.clamp(0, usedAvailable);
    final remainingRaw = normalizedCap - (earnedClamped + usedClamped);
    final remaining = remainingRaw < 0 ? 0 : remainingRaw;

    final earnedFraction = normalizedCap == 0 ? 0.0 : earnedClamped / normalizedCap;
    final usedFraction = normalizedCap == 0 ? 0.0 : usedClamped / normalizedCap;
    final remainingFraction = normalizedCap == 0 ? 0.0 : remaining / normalizedCap;

    return Semantics(
      label: 'Daily screen time donut chart',
      child: SizedBox(
        key: AppKeys.dashboardDonutChart,
        width: 240,
        height: 240,
        child: Column(
          children: [
            Expanded(
              child: CustomPaint(
                painter: _DonutPainter(
                  earnedFraction: earnedFraction,
                  usedFraction: usedFraction,
                  remainingFraction: remainingFraction,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Semantics(
              label: 'Legend showing earned, used, and remaining screen time values',
              child: _DonutLegend(
                earned: earnedClamped,
                used: usedClamped,
                remaining: remaining,
                cap: normalizedCap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.earnedFraction,
    required this.usedFraction,
    required this.remainingFraction,
  });

  final double earnedFraction;
  final double usedFraction;
  final double remainingFraction;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final strokeWidth = 24.0;

    final basePaint = Paint()
      ..color = AppTheme.borderLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final earnedPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final usedPaint = Paint()
      ..color = AppTheme.textLight.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final remainingPaint = Paint()
      ..color = AppTheme.borderLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      2 * math.pi,
      false,
      basePaint,
    );

    double startAngle = -math.pi / 2;

    final earnedSweep = earnedFraction * 2 * math.pi;
    if (earnedSweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        earnedSweep,
        false,
        earnedPaint,
      );
      startAngle += earnedSweep;
    }

    final usedSweep = usedFraction * 2 * math.pi;
    if (usedSweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        usedSweep,
        false,
        usedPaint,
      );
      startAngle += usedSweep;
    }

    final remainingSweep = remainingFraction * 2 * math.pi;
    if (remainingSweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        remainingSweep,
        false,
        remainingPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) {
    return oldDelegate.earnedFraction != earnedFraction ||
        oldDelegate.usedFraction != usedFraction ||
        oldDelegate.remainingFraction != remainingFraction;
  }
}

class _DonutLegend extends StatelessWidget {
  const _DonutLegend({
    required this.earned,
    required this.used,
    required this.remaining,
    required this.cap,
  });

  final int earned;
  final int used;
  final int remaining;
  final int cap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: AppKeys.dashboardDonutLegend,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendDot(AppTheme.secondaryGreen),
            const SizedBox(width: AppTheme.spaceXS),
            Text(
              '${_format(earned)} earned',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceXS),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendDot(AppTheme.textLight.withOpacity(0.7)),
            const SizedBox(width: AppTheme.spaceXS),
            Text(
              '${_format(used)} used',
              style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textLight),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceXS),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendDot(AppTheme.borderLight),
            const SizedBox(width: AppTheme.spaceXS),
            Text(
              '${_format(remaining)} remaining · Cap ${_format(cap)}',
              style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textLight),
            ),
          ],
        ),
      ],
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  String _format(int minutes) {
    final safeMinutes = minutes < 0 ? 0 : minutes;
    final hours = safeMinutes ~/ 60;
    final mins = safeMinutes % 60;
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }
}

class _CategoryGauge extends StatelessWidget {
  const _CategoryGauge({
    required this.category,
    required this.minutesLogged,
    required this.minutesEarned,
    required this.goalMinutes,
    required this.categoryConfig,
  });

  final HabitCategory category;
  final int minutesLogged;
  final int minutesEarned;
  final int? goalMinutes;
  final CategoryConfig? categoryConfig;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hours = minutesLogged ~/ 60;
    final mins = minutesLogged % 60;
    final goalText = goalMinutes != null ? '${goalMinutes! ~/ 60}h ${goalMinutes! % 60}m goal' : 'Goal data pending';
    final capText = categoryConfig != null
        ? 'Cap ${(categoryConfig!.maxMinutes / 60).toStringAsFixed(1)}h'
        : '';

    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, color: category.primaryColor(context)),
          const SizedBox(height: AppTheme.spaceSM),
          Text(category.label, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppTheme.spaceSM),
          Text('${hours}h ${mins}m', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppTheme.spaceXS),
          Text('Earned $minutesEarned min', style: theme.textTheme.bodySmall),
          const SizedBox(height: AppTheme.spaceXS),
          Text(goalText, style: theme.textTheme.labelSmall),
          if (capText.isNotEmpty) Text(capText, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
