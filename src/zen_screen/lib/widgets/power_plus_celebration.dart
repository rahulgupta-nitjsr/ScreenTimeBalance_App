import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../utils/theme.dart';

/// A celebration widget that displays when POWER+ Mode is unlocked
/// 
/// **Learning Note for Product Developers:**
/// This widget demonstrates gamification principles:
/// 1. **Immediate Feedback:** Celebration appears as soon as goal is achieved
/// 2. **Visual Reward:** Animation and colors create a sense of accomplishment
/// 3. **Clear Benefit:** Shows the concrete reward (bonus time)
/// 4. **Positive Reinforcement:** Encourages continued engagement
class PowerPlusCelebration extends StatefulWidget {
  const PowerPlusCelebration({
    super.key,
    required this.isUnlocked,
    required this.bonusMinutes,
    this.onDismiss,
    this.showFullCelebration = true,
  });

  final bool isUnlocked;
  final int bonusMinutes;
  final VoidCallback? onDismiss;
  final bool showFullCelebration; // If false, shows compact badge only

  @override
  State<PowerPlusCelebration> createState() => _PowerPlusCelebrationState();
}

class _PowerPlusCelebrationState extends State<PowerPlusCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    if (widget.isUnlocked && widget.showFullCelebration) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(PowerPlusCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isUnlocked && !oldWidget.isUnlocked && widget.showFullCelebration) {
      _controller.forward();
    } else if (!widget.isUnlocked && oldWidget.isUnlocked) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isUnlocked) {
      return _buildLockedBadge(context);
    }

    if (!widget.showFullCelebration) {
      return _buildCompactBadge(context);
    }

    return _buildFullCelebration(context);
  }

  /// Full celebration banner with animation
  Widget _buildFullCelebration(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMD,
                vertical: AppTheme.spaceSM,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryGreen.withOpacity(0.9),
                    AppTheme.secondaryGreen.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Animated particles in background
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ParticlePainter(
                        animation: _controller,
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spaceLG),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Badge icon with pulse animation
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spaceMD),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.energy_savings_leaf,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceMD),
                        
                        // Title
                        Text(
                          'POWER+ MODE UNLOCKED!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spaceXS),
                        
                        // Subtitle
                        Text(
                          '3 of 4 daily goals completed! 🎉',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spaceMD),
                        
                        // Bonus time display
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spaceLG,
                            vertical: AppTheme.spaceMD,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: AppTheme.spaceXS),
                              Text(
                                '+${widget.bonusMinutes} minutes bonus',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Dismiss button
                        if (widget.onDismiss != null) ...[
                          const SizedBox(height: AppTheme.spaceMD),
                          TextButton(
                            onPressed: widget.onDismiss,
                            child: Text(
                              'Awesome!',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Compact badge for persistent display
  Widget _buildCompactBadge(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMD,
        vertical: AppTheme.spaceSM,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withOpacity(0.8),
            AppTheme.secondaryGreen.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.energy_savings_leaf,
            size: 20,
            color: Colors.white,
          ),
          const SizedBox(width: AppTheme.spaceXS),
          Text(
            'POWER+ Active',
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppTheme.spaceXS),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceXS,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Text(
              '+${widget.bonusMinutes}m',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Locked badge showing progress toward POWER+ Mode
  Widget _buildLockedBadge(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMD,
        vertical: AppTheme.spaceSM,
      ),
      decoration: BoxDecoration(
        color: AppTheme.borderLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: AppTheme.borderLight.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline,
            size: 16,
            color: AppTheme.textLight,
          ),
          const SizedBox(width: AppTheme.spaceXS),
          Text(
            'POWER+ Locked',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(width: AppTheme.spaceXS),
          Text(
            '(Complete 3 of 4 goals)',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppTheme.textLight.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for animated particles in celebration background
/// **Technical Learning:** CustomPainter with animation creates engaging visual effects
class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.animation}) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent particles

    // Draw 20 particles at different positions
    for (var i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 2 + random.nextDouble() * 3;
      
      // Animate particles with varying speeds
      final animatedY = y - (animation.value * 50 * (1 + random.nextDouble()));
      final opacity = (1 - animation.value).clamp(0.0, 1.0);

      canvas.drawCircle(
        Offset(x, animatedY % size.height),
        radius,
        paint..color = Colors.white.withOpacity(opacity * 0.3),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}

/// A widget that shows how many goals are completed toward POWER+ Mode
/// **Product Learning:** Progress indicators help users understand how close they are to rewards
class PowerPlusProgressIndicator extends StatelessWidget {
  const PowerPlusProgressIndicator({
    super.key,
    required this.completedGoals,
    required this.totalGoals,
    required this.requiredGoals,
  });

  final int completedGoals;
  final int totalGoals;
  final int requiredGoals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = completedGoals >= requiredGoals;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppTheme.primaryGreen.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: isUnlocked
              ? AppTheme.primaryGreen.withOpacity(0.3)
              : AppTheme.borderLight.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isUnlocked ? Icons.energy_savings_leaf : Icons.lock_outline,
                color: isUnlocked ? AppTheme.secondaryGreen : AppTheme.textLight,
                size: 20,
              ),
              const SizedBox(width: AppTheme.spaceXS),
              Text(
                'POWER+ Mode Status',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isUnlocked ? AppTheme.secondaryGreen : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSM),
          
          // Progress dots
          Row(
            children: List.generate(totalGoals, (index) {
              final isCompleted = index < completedGoals;
              return Padding(
                padding: EdgeInsets.only(
                  right: index < totalGoals - 1 ? AppTheme.spaceXS : 0,
                ),
                child: Container(
                  width: 32,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.secondaryGreen
                        : AppTheme.borderLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppTheme.spaceXS),
          
          Text(
            isUnlocked
                ? '✓ All goals met! Bonus time added.'
                : '$completedGoals of $requiredGoals goals needed',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isUnlocked ? AppTheme.secondaryGreen : AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

