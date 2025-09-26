import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_router.dart';
import '../utils/theme.dart';
import '../providers/navigation_provider.dart';

/// Navigation item data structure
class NavigationItem {
  final IconData icon;
  final String label;
  final String route;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

/// Bottom navigation widget with proper state management
class BottomNavigation extends ConsumerWidget {
  const BottomNavigation({super.key});

  /// Navigation items configuration
  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      label: 'Home',
      route: AppRoutes.home,
    ),
    NavigationItem(
      icon: Icons.add_circle_outline,
      label: 'Log',
      route: AppRoutes.log,
    ),
    NavigationItem(
      icon: Icons.show_chart_outlined,
      label: 'Progress',
      route: AppRoutes.progress,
    ),
    NavigationItem(
      icon: Icons.person_outline,
      label: 'Profile',
      route: AppRoutes.profile,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        border: const Border(
          top: BorderSide(
            color: AppTheme.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Container(
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _navigationItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isActive = currentIndex == index;

            return _buildNavItem(
              context: context,
              ref: ref,
              item: item,
              index: index,
              isActive: isActive,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required WidgetRef ref,
    required NavigationItem item,
    required int index,
    required bool isActive,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavItemTap(context, ref, item, index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  item.icon,
                  size: 24,
                  color: isActive 
                    ? AppTheme.primaryGreen 
                    : AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                  color: isActive 
                    ? AppTheme.primaryGreen 
                    : AppTheme.textLight,
                  letterSpacing: 0.5,
                  fontFamily: 'Spline Sans',
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNavItemTap(
    BuildContext context,
    WidgetRef ref,
    NavigationItem item,
    int index,
  ) {
    // Update navigation index
    ref.read(navigationIndexProvider.notifier).setIndex(index);

    // Update navigation history
    ref.read(navigationHistoryProvider.notifier).pushRoute(item.route);

    final goRouter = GoRouter.maybeOf(context);
    if (goRouter != null) {
      goRouter.go(item.route);
    } else {
      Navigator.of(context).pushNamed(item.route);
    }
  }
}
