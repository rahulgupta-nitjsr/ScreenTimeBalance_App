import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../utils/theme.dart';
import '../providers/navigation_provider.dart';

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
                color: AppTheme.backgroundGray.withOpacity(0.8),
                border: const Border(
                  bottom: BorderSide(
                    color: AppTheme.borderLight,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.close,
                          color: AppTheme.textMedium,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'How It Works',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the close button
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Earning Time Section
                    _buildSection(
                      title: 'Earning Time',
                      content: 'Complete healthy habits to earn screen time. Each activity has different earning rates based on scientific research.',
                      icon: Icons.schedule,
                    ),
                    const SizedBox(height: 24),
                    
                    // Habits Section
                    _buildSection(
                      title: 'Habits',
                      content: 'Track four key habits: Sleep (8 hours), Exercise (45 min), Outdoor time (30 min), and Productive work (2 hours).',
                      icon: Icons.check_circle,
                    ),
                    const SizedBox(height: 24),
                    
                    // POWER+ Mode Section
                    _buildSection(
                      title: 'POWER+ Mode',
                      content: 'Achieve 3 out of 4 daily goals to unlock POWER+ Mode and earn 30 bonus minutes of screen time.',
                      icon: Icons.bolt,
                    ),
                    const SizedBox(height: 24),
                    
                    // Penalties Section
                    _buildSection(
                      title: 'Penalties',
                      content: 'Getting less than 6 hours of sleep may reduce your earned screen time. Prioritize healthy sleep habits.',
                      icon: Icons.warning,
                    ),
                    const SizedBox(height: 24),
                    
                    // Why This Works Section
                    _buildSection(
                      title: 'Why This Works',
                      content: 'This system uses positive reinforcement instead of restrictions, helping you build sustainable healthy habits while enjoying your screen time guilt-free.',
                      icon: Icons.psychology,
                    ),
                    const SizedBox(height: 32),
                    
                    // Earning Rates
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: AppTheme.liquidGlassDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Earning Rates',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildEarningRate('Sleep', '1 hour = 25 min screen time'),
                          _buildEarningRate('Exercise', '1 hour = 20 min screen time'),
                          _buildEarningRate('Outdoor', '1 hour = 15 min screen time'),
                          _buildEarningRate('Productive', '1 hour = 10 min screen time'),
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
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textMedium,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
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