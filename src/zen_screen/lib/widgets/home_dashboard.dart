import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/algorithm_config.dart';
import '../models/habit_category.dart';
import '../providers/algorithm_provider.dart';
import '../utils/theme.dart';
import '../utils/app_keys.dart';
import '../widgets/zen_progress.dart';
import 'glass_card.dart';

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(algorithmResultProvider);
    final configAsync = ref.watch(algorithmConfigProvider);

    return configAsync.when(
      data: (config) {
        return Column(
          children: HabitCategory.values.map((category) {
            final minutesLogged = result.perCategoryLoggedMinutes[category] ?? 0;
            final goalMinutes = config.powerPlus.goals[category.id] ?? 1;
            final progress = (minutesLogged / goalMinutes).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spaceMD),
              child: _ActivityProgress(
                category: category,
                minutesLogged: minutesLogged,
                goalMinutes: goalMinutes,
                progress: progress,
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const Center(child: Text('Could not load configuration.')),
    );
  }
}

class _ActivityProgress extends StatelessWidget {
  const _ActivityProgress({
    required this.category,
    required this.minutesLogged,
    required this.goalMinutes,
    required this.progress,
  });

  final HabitCategory category;
  final int minutesLogged;
  final int goalMinutes;
  final double progress;

  String _formatMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(category.icon, color: category.primaryColor(context), size: 16),
            const SizedBox(width: AppTheme.spaceSM),
            Text(category.label, style: theme.textTheme.titleMedium),
            const Spacer(),
            Text(
              '${_formatMinutes(minutesLogged)} / ${_formatMinutes(goalMinutes)}',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textLight),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSM),
        ZenLinearProgressBar(progress: progress),
      ],
    );
  }
}
