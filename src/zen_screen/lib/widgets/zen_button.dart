import 'dart:async';
import 'package:flutter/material.dart';

import '../utils/theme.dart';

enum ZenButtonVariant {
  primary,
  secondary,
  outline,
  success,
}

/// Common button widget that enforces the design system styles.
class ZenButton extends StatefulWidget {
  const ZenButton.primary(
    this.label, {
    super.key,
    required this.onPressed,
    this.leading,
    this.trailing,
    this.debounceMs = 300,
  }) : variant = ZenButtonVariant.primary;

  const ZenButton.secondary(
    this.label, {
    super.key,
    required this.onPressed,
    this.leading,
    this.trailing,
    this.debounceMs = 300,
  }) : variant = ZenButtonVariant.secondary;

  const ZenButton.outline(
    this.label, {
    super.key,
    required this.onPressed,
    this.leading,
    this.trailing,
    this.debounceMs = 300,
  }) : variant = ZenButtonVariant.outline;

  const ZenButton.success(
    this.label, {
    super.key,
    required this.onPressed,
    this.leading,
    this.trailing,
    this.debounceMs = 300,
  }) : variant = ZenButtonVariant.success;

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Widget? trailing;
  final ZenButtonVariant variant;
  final int debounceMs;

  @override
  State<ZenButton> createState() => _ZenButtonState();
}

class _ZenButtonState extends State<ZenButton> {
  Timer? _debounceTimer;
  bool _isPressed = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _handlePress() {
    if (_isPressed || widget.onPressed == null) return;
    
    _isPressed = true;
    widget.onPressed!();
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: widget.debounceMs), () {
      if (mounted) {
        setState(() {
          _isPressed = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = switch (widget.variant) {
      ZenButtonVariant.primary => AppTheme.primaryButtonStyle,
      ZenButtonVariant.secondary => AppTheme.secondaryButtonStyle,
      ZenButtonVariant.outline => AppTheme.outlineButtonStyle,
      ZenButtonVariant.success => AppTheme.successButtonStyle,
    };

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.leading != null) ...[
          widget.leading!,
          const SizedBox(width: AppTheme.spaceSM),
        ],
        Flexible(
          child: Text(
            widget.label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.trailing != null) ...[
          const SizedBox(width: AppTheme.spaceSM),
          widget.trailing!,
        ],
      ],
    );

    return ElevatedButton(
      style: style,
      onPressed: _isPressed ? null : _handlePress,
      child: child,
    );
  }
}

