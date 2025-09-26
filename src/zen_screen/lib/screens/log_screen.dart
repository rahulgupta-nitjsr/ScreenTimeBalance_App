import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/glass_card.dart';
import '../widgets/zen_button.dart';
import '../widgets/zen_progress.dart';
import '../widgets/zen_input_field.dart';
import '../utils/theme.dart';
import '../utils/app_router.dart';
import '../providers/navigation_provider.dart';

class LogScreen extends ConsumerWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                        Text(
                          'Manual Entry',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppTheme.spaceMD),
                        Column(
                          children: [
                            _buildHabitCategory(
                              context,
                              icon: Icons.bedtime,
                              title: 'Sleep',
                              subtitle: 'Log your sleep time',
                              minutes: 480,
                            ),
                            const SizedBox(height: AppTheme.spaceMD),
                            _buildHabitCategory(
                              context,
                              icon: Icons.fitness_center,
                              title: 'Exercise',
                              subtitle: 'Log your workout time',
                              minutes: 60,
                            ),
                            const SizedBox(height: AppTheme.spaceMD),
                            _buildHabitCategory(
                              context,
                              icon: Icons.park,
                              title: 'Outdoor',
                              subtitle: 'Log your outdoor activities',
                              minutes: 30,
                            ),
                            const SizedBox(height: AppTheme.spaceMD),
                            _buildHabitCategory(
                              context,
                              icon: Icons.book,
                              title: 'Productive',
                              subtitle: 'Log your productive work',
                              minutes: 120,
                            ),
                          ],
                        ),
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

  Widget _buildHabitCategory(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required int minutes,
  }) {
    final hours = (minutes / 60).floor();
    final remaining = minutes % 60;
    final display = hours > 0 ? '${hours}h ${remaining}m' : '${remaining}m';

    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTheme.spaceXS),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: display,
                  style: Theme.of(context).textTheme.labelLarge,
                  children: const [
                    TextSpan(
                      text: ' today',
                      style: TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMD),
          ZenLinearProgressBar(
            progress: (minutes / 60).clamp(0, 1),
            height: 10,
            backgroundColor: AppTheme.borderLight,
            progressColor: minutes >= 60 ? AppTheme.secondaryGreen : AppTheme.primaryGreen,
          ),
          const SizedBox(height: AppTheme.spaceMD),
          Row(
            children: [
              Expanded(
                child: ZenInputField(
                  label: 'Add minutes',
                  hint: '15',
                  keyboardType: TextInputType.number,
                  suffix: const Padding(
                    padding: EdgeInsets.only(top: 12, right: 12),
                    child: Text('min'),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spaceMD),
              ZenButton.primary(
                '+15',
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}