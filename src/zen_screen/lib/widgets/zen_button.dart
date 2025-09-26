import 'package:flutter/material.dart';

import '../utils/theme.dart';

enum ZenButtonVariant {
  primary,
  secondary,
  outline,
  success,
}

/// Common button widget that enforces the design system styles.
class ZenButton extends StatelessWidget {
  const ZenButton.primary(
    this.label, {
    super.key,
    required this.onPressed,
    this.leading,
    this.trailing,
  }) : variant = ZenButtonVariant.primary;

  const ZenButton.secondary(
    this.label, {
    super.key,
    required this.onPressed,
    this.leading,
    this.trailing,
  }) : variant = ZenButtonVariant.secondary;

  const ZenButton.outline(
    this.label, {
    super.key,
    required this.onPressed,
    this.leading,
    this.trailing,
  }) : variant = ZenButtonVariant.outline;

  const ZenButton.success(
    this.label, {
    super.key,
    required this.onPressed,
    this.leading,
    this.trailing,
  }) : variant = ZenButtonVariant.success;

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Widget? trailing;
  final ZenButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final style = switch (variant) {
      ZenButtonVariant.primary => AppTheme.primaryButtonStyle,
      ZenButtonVariant.secondary => AppTheme.secondaryButtonStyle,
      ZenButtonVariant.outline => AppTheme.outlineButtonStyle,
      ZenButtonVariant.success => AppTheme.successButtonStyle,
    };

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppTheme.spaceSM),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppTheme.spaceSM),
          trailing!,
        ],
      ],
    );

    return ElevatedButton(
      style: style,
      onPressed: onPressed,
      child: child,
    );
  }
}

