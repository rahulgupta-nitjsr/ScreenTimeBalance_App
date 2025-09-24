import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_navigation.dart';
import '../utils/theme.dart';
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
                child: Column(
                  children: [
                    // Navigation header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/home');
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: AppTheme.textMedium,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Log Time',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 48), // Balance the back button
                        ],
                      ),
                    ),
                  ],
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
                    // Timer Display
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(32.0),
                        decoration: AppTheme.liquidGlassDecoration,
                        child: Column(
                          children: [
                            const Text(
                              '00:00:00',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Start timer logic
                                  },
                                  style: AppTheme.successButtonStyle,
                                  child: const Text(
                                    'Start Timer',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    // Stop timer logic
                                  },
                                  style: AppTheme.secondaryButtonStyle,
                                  child: const Text(
                                    'Stop',
                                    style: TextStyle(color: AppTheme.textDark),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Manual Entry Section
                    const Text(
                      'Manual Entry',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Habit Categories
                    _buildHabitCategory(
                      icon: Icons.bedtime,
                      title: 'Sleep',
                      subtitle: 'Log your sleep time',
                      minutes: 0,
                    ),
                    const SizedBox(height: 16),
                    _buildHabitCategory(
                      icon: Icons.fitness_center,
                      title: 'Exercise',
                      subtitle: 'Log your workout time',
                      minutes: 0,
                    ),
                    const SizedBox(height: 16),
                    _buildHabitCategory(
                      icon: Icons.park,
                      title: 'Outdoor',
                      subtitle: 'Log your outdoor activities',
                      minutes: 0,
                    ),
                    const SizedBox(height: 16),
                    _buildHabitCategory(
                      icon: Icons.book,
                      title: 'Productive',
                      subtitle: 'Log your productive work',
                      minutes: 0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  Widget _buildHabitCategory({
    required IconData icon,
    required String title,
    required String subtitle,
    required int minutes,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // Decrease time logic
                },
                icon: const Icon(Icons.remove_circle_outline),
                color: AppTheme.textLight,
              ),
              Text(
                '${minutes}m',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textDark,
                ),
              ),
              IconButton(
                onPressed: () {
                  // Increase time logic
                },
                icon: const Icon(Icons.add_circle_outline),
                color: AppTheme.primaryGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}