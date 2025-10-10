import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Split Scene Illustration: Habits Grid → Unlocked Phone
/// Premium design showing clear value proposition with colorful habit icons
class HabitsToScreenTimeIllustration extends StatelessWidget {
  final double width;
  final double height;

  const HabitsToScreenTimeIllustration({
    super.key,
    this.width = 280,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left Panel: 2x2 Habit Icons Grid
          _HabitIconsGrid(),
          
          const SizedBox(width: 16),
          
          // Center: Arrow with "EARN" concept
          _FlowArrow(),
          
          const SizedBox(width: 16),
          
          // Right Panel: Unlocked Phone
          _UnlockedPhone(),
        ],
      ),
    );
  }
}

/// 2x2 Grid of colorful habit icons
class _HabitIconsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HabitIcon(
                icon: Icons.bedtime,
                color: const Color(0xFF6366F1), // Indigo for sleep
              ),
              _HabitIcon(
                icon: Icons.fitness_center,
                color: const Color(0xFFEC4899), // Pink for exercise
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HabitIcon(
                icon: Icons.park,
                color: const Color(0xFF10B981), // Green for outdoor
              ),
              _HabitIcon(
                icon: Icons.work,
                color: const Color(0xFFF59E0B), // Amber for productive
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual habit icon with circular gradient background
class _HabitIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _HabitIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.15),
          ],
        ),
      ),
      child: Icon(
        icon,
        size: 20,
        color: color,
      ),
    );
  }
}

/// Gradient arrow showing transformation
class _FlowArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 100,
      child: CustomPaint(
        painter: _ArrowPainter(),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    
    // Gradient paint for arrow
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          AppTheme.primaryGreen.withOpacity(0.5),
          AppTheme.primaryGreen,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    // Main arrow line
    final startX = 5.0;
    final endX = size.width - 15;
    
    canvas.drawLine(
      Offset(startX, centerY),
      Offset(endX, centerY),
      gradientPaint,
    );
    
    // Arrow head (filled)
    final arrowPath = Path();
    arrowPath.moveTo(endX + 10, centerY);
    arrowPath.lineTo(endX - 5, centerY - 8);
    arrowPath.lineTo(endX - 5, centerY + 8);
    arrowPath.close();
    
    final arrowFillPaint = Paint()
      ..color = AppTheme.primaryGreen
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(arrowPath, arrowFillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Phone with checkmark and glow effect
class _UnlockedPhone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          Container(
            width: 70,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryGreen.withOpacity(0.3),
                  AppTheme.primaryGreen.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // Phone outline
          Container(
            width: 45,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryGreen,
                width: 2.5,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.check_circle,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
            ),
          ),
          
          // Top notch
          Positioned(
            top: 15,
            child: Container(
              width: 15,
              height: 3,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

