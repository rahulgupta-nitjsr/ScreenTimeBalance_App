import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/zen_button.dart';

class HowItWorksScreen extends ConsumerWidget {
  const HowItWorksScreen({super.key});

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
            // Header
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
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.close,
                          color: AppTheme.textMedium,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'How It Works',
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
                        Wrap(
                          spacing: AppTheme.spaceMD,
                          runSpacing: AppTheme.spaceMD,
                          children: [
                            _buildSection(
                              context,
                              title: 'Earning Time',
                              content:
                                  'Complete healthy habits to earn screen time. Each activity has different earning rates based on scientific research.',
                              icon: Icons.schedule,
                            ),
                            _buildSection(
                              context,
                              title: 'Habits',
                              content:
                                  'Track four key habits: Sleep (8 hours), Exercise (45 min), Outdoor time (30 min), and Productive work (2 hours).',
                              icon: Icons.check_circle,
                            ),
                            _buildSection(
                              context,
                              title: 'POWER+ Mode',
                              content:
                                  'Achieve 3 out of 4 daily goals to unlock POWER+ Mode and earn 30 bonus minutes of screen time.',
                              icon: Icons.bolt,
                            ),
                            _buildSection(
                              context,
                              title: 'Penalties',
                              content:
                                  'Getting less than 6 hours of sleep may reduce your earned screen time. Prioritize healthy sleep habits.',
                              icon: Icons.warning,
                            ),
                            _buildSection(
                              context,
                              title: 'Why This Works',
                              content:
                                  'This system uses positive reinforcement instead of restrictions, helping you build sustainable healthy habits while enjoying your screen time guilt-free.',
                              icon: Icons.psychology,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spaceXL),
                        GlassCard(
                          padding: const EdgeInsets.all(AppTheme.spaceLG),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Earning Rates',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppTheme.spaceLG),
                              _buildEarningRate('Sleep', '1 hour = 25 min screen time'),
                              _buildEarningRate('Exercise', '1 hour = 20 min screen time'),
                              _buildEarningRate('Outdoor', '1 hour = 15 min screen time'),
                              _buildEarningRate('Productive', '1 hour = 10 min screen time'),
                              const SizedBox(height: AppTheme.spaceLG),
                              ZenButton.primary(
                                'View Algorithm Details',
                                onPressed: () {},
                              ),
                            ],
                          ),
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
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
  }) {
    return SizedBox(
      width: 240,
      child: GlassCard(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 28,
            ),
            const SizedBox(height: AppTheme.spaceMD),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningRate(String habit, String rate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            habit,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textDark,
            ),
          ),
          Text(
            rate,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}