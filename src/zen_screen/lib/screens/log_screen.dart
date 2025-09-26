import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/habit_category.dart';
import '../providers/algorithm_provider.dart';
import '../providers/minutes_provider.dart';
import '../utils/app_router.dart';
import '../utils/theme.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/glass_card.dart';
import '../widgets/habit_entry_pad.dart';
import '../widgets/zen_button.dart';

class LogScreen extends ConsumerStatefulWidget {
  const LogScreen({super.key});

  @override
  ConsumerState<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends ConsumerState<LogScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(algorithmResultProvider);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundGray,
              AppTheme.backgroundGray,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundGray.withOpacity(0.92),
                border: const Border(
                  bottom: BorderSide(
                    color: AppTheme.borderLight,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceMD),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.home);
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppTheme.textMedium,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Log Time',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = constraints.maxWidth > AppTheme.breakpointLarge
                      ? AppTheme.spaceXL
                      : AppTheme.spaceLG;
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: AppTheme.spaceXL,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: GlassCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spaceXL,
                              vertical: AppTheme.spaceLG,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '00:00:00',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontFamily: 'Spline Sans',
                                        letterSpacing: 2,
                                      ),
                                ),
                                const SizedBox(height: AppTheme.spaceSM),
                                Text(
                                  'Sleep Timer',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: AppTheme.spaceLG),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ZenButton.success(
                                      'Start Timer',
                                      onPressed: () {},
                                    ),
                                    const SizedBox(width: AppTheme.spaceMD),
                                    ZenButton.secondary(
                                      'Stop',
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceXL),
                        TabBar(
                          controller: _tabController,
                          labelColor: AppTheme.primaryGreen,
                          unselectedLabelColor: AppTheme.textLight,
                          indicatorColor: AppTheme.primaryGreen,
                          tabs: const [
                            Tab(text: 'Timer'),
                            Tab(text: 'Manual Entry'),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spaceMD),
                        SizedBox(
                          height: 420,
                          child: TabBarView(
                            controller: _tabController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildTimerCard(context),
                              const HabitEntryPad(),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceXL),
                        GlassCard(
                          child: Column(
                            children: [
                              Text(
                                'Today\'s Totals',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppTheme.spaceMD),
                              _buildTotalsList(context),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceXL),
                        if (result.powerModeUnlocked)
                          _buildPowerModeSummary(context, result.totalEarnedMinutes)
                        else
                          _buildProgressSummary(context, result.totalEarnedMinutes),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  Widget _buildPowerModeSummary(BuildContext context, int earnedMinutes) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        children: [
          Icon(Icons.rocket_launch, color: AppTheme.secondaryGreen),
          const SizedBox(height: AppTheme.spaceSM),
          Text('POWER+ Mode Unlocked!', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppTheme.spaceXS),
          Text('Total earned today: ${earnedMinutes ~/ 60}h ${earnedMinutes % 60}m'),
        ],
      ),
    );
  }

  Widget _buildProgressSummary(BuildContext context, int earnedMinutes) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        children: [
          Icon(Icons.hourglass_bottom, color: AppTheme.primaryGreen),
          const SizedBox(height: AppTheme.spaceSM),
          Text('Total earned today: ${earnedMinutes ~/ 60}h ${earnedMinutes % 60}m',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: AppTheme.spaceXS),
          const Text('Keep logging habits to unlock POWER+ mode!'),
        ],
      ),
    );
  }

  Widget _buildTimerCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceXL,
        vertical: AppTheme.spaceLG,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '00:00:00',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Spline Sans',
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(height: AppTheme.spaceSM),
          Text(
            'Timer coming soon',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppTheme.spaceLG),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ZenButton.success('Start', onPressed: () {}),
              const SizedBox(width: AppTheme.spaceMD),
              ZenButton.secondary('Stop', onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsList(BuildContext context) {
    final minutesByCategory = ref.watch(minutesByCategoryProvider);
    return Column(
      children: [
        for (final category in HabitCategory.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXS),
            child: Row(
              children: [
                Icon(category.icon, size: 20, color: category.primaryColor(context)),
                const SizedBox(width: AppTheme.spaceSM),
                Expanded(child: Text(category.label)),
                Text(_formatMinutes(minutesByCategory[category] ?? 0)),
              ],
            ),
          ),
      ],
    );
  }

  String _formatMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }
}