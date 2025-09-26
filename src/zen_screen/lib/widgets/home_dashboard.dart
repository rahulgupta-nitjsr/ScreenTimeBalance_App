import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/algorithm_config.dart';
import '../models/habit_category.dart';
import '../providers/algorithm_provider.dart';
import '../utils/theme.dart';

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
        _DonutChart(earned: result.totalEarnedMinutes, used: 0, cap: cap),
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
    final earnedFraction = cap == 0 ? 0.0 : earned / cap;
    final usedFraction = cap == 0 ? 0.0 : used / cap;
    return SizedBox(
      width: 220,
      height: 220,
      child: CustomPaint(
        painter: _DonutPainter(
          earnedFraction: earnedFraction.clamp(0, 1),
          usedFraction: usedFraction.clamp(0, 1),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${earned ~/ 60}h ${earned % 60}m', style: theme.textTheme.headlineLarge),
              const SizedBox(height: AppTheme.spaceXS),
              Text('Earned', style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppTheme.spaceXS),
              Text('Cap: ${cap ~/ 60}h ${cap % 60}m', style: theme.textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.earnedFraction, required this.usedFraction});

  final double earnedFraction;
  final double usedFraction;

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
      ..color = AppTheme.textLight
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

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      earnedFraction * 2 * math.pi,
      false,
      earnedPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      usedFraction * 2 * math.pi,
      false,
      usedPaint,
    );
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) {
    return oldDelegate.earnedFraction != earnedFraction || oldDelegate.usedFraction != usedFraction;
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
