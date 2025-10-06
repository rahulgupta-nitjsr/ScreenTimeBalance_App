import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/theme.dart';
import '../services/undo_service.dart';

/// Banner that appears after an edit allowing the user to undo
/// 
/// **Product Learning:**
/// Undo is a powerful trust-building feature. Users feel safer making changes
/// when they know they can reverse them. The 5-minute window is long enough
/// to catch mistakes but short enough to prevent abuse.
class UndoBanner extends ConsumerStatefulWidget {
  const UndoBanner({
    super.key,
    required this.undoService,
    required this.onUndoComplete,
  });

  final UndoService undoService;
  final VoidCallback onUndoComplete;

  @override
  ConsumerState<UndoBanner> createState() => _UndoBannerState();
}

class _UndoBannerState extends ConsumerState<UndoBanner> {
  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  bool _isUndoing = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    if (!widget.undoService.canUndo) return;

    _remainingSeconds = widget.undoService.remainingUndoSeconds;

    if (_remainingSeconds <= 0) {
      // Window expired, don't show banner
      return;
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        // Dismiss banner when time expires
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  Future<void> _handleUndo() async {
    if (_isUndoing) return;

    setState(() {
      _isUndoing = true;
    });

    try {
      final result = await widget.undoService.performUndo();
      
      if (!mounted) return;

      if (result.success) {
        // Close banner
        Navigator.of(context).pop();
        
        // Notify parent to refresh UI
        widget.onUndoComplete();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.primaryGreen),
                SizedBox(width: AppTheme.spaceSM),
                Text('Change undone successfully'),
              ],
            ),
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.15),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Failed to undo'),
            backgroundColor: Colors.red.withOpacity(0.15),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUndoing = false;
        });
      }
    }
  }

  void _handleDismiss() {
    _countdownTimer?.cancel();
    Navigator.of(context).pop();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.undoService.canUndo || _remainingSeconds <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(AppTheme.spaceMD),
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.backgroundElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Undo icon
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceSM),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: const Icon(
              Icons.undo,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spaceMD),
          
          // Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Change saved',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Undo available for ${_formatTime(_remainingSeconds)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMedium.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          // Undo button
          if (_isUndoing)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppTheme.primaryGreen),
              ),
            )
          else
            TextButton(
              onPressed: _handleUndo,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMD,
                  vertical: AppTheme.spaceSM,
                ),
              ),
              child: const Text(
                'UNDO',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          
          // Dismiss button
          IconButton(
            onPressed: _handleDismiss,
            icon: const Icon(Icons.close, size: 18),
            color: AppTheme.textMedium,
            padding: const EdgeInsets.all(AppTheme.spaceXS),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

/// Show undo banner after an edit
void showUndoBanner(
  BuildContext context, {
  required UndoService undoService,
  required VoidCallback onUndoComplete,
}) {
  if (!undoService.canUndo) return;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    isDismissible: true,
    builder: (context) => UndoBanner(
      undoService: undoService,
      onUndoComplete: onUndoComplete,
    ),
  );
}

