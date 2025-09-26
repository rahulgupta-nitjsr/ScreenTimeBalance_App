import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/theme.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/glass_card.dart';
import '../widgets/zen_progress.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress Overview',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppTheme.spaceLG),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        GlassCard(
                          child: Column(
                            children: const [
                              SizedBox(height: AppTheme.spaceLG),
                              ZenLinearProgressBar(
                                progress: 0.75,
                                showLabel: true,
                                label: 'Daily Goals',
                              ),
                              SizedBox(height: AppTheme.spaceLG),
                              ZenCircularProgress(progress: 0.6),
                              SizedBox(height: AppTheme.spaceLG),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}