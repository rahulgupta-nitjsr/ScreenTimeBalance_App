import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/theme.dart';

/// GlassCard renders content with the liquid glass aesthetic while keeping the
/// blur localized so the entire screen never becomes unreadable.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.opacity,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? opacity;

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppTheme.glassBlurSigma,
          sigmaY: AppTheme.glassBlurSigma,
        ),
        child: DecoratedBox(
          decoration: AppTheme.glassDecoration(opacity: opacity),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppTheme.spaceLG),
            child: child,
          ),
        ),
      ),
    );

    if (onTap == null) {
      return Container(
        margin: margin,
        decoration: const BoxDecoration(),
        child: content,
      );
    }

    return Container(
      margin: margin,
      decoration: const BoxDecoration(),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          onTap: onTap,
          highlightColor: Colors.white.withOpacity(0.08),
          splashColor: AppTheme.primaryGreen.withOpacity(0.12),
          child: content,
        ),
      ),
    );
  }
}

