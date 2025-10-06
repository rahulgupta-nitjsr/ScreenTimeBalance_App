import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/zen_button.dart';

/// Error Boundary Widget
/// 
/// **Product Learning:**
/// Error boundaries prevent the entire app from crashing when one widget fails.
/// Instead of a blank screen, users see a helpful error message and recovery options.
/// 
/// This is inspired by React's Error Boundaries - a proven pattern for resilience.
class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
    this.fallback,
  });

  final Widget child;
  final void Function(Object error, StackTrace stackTrace)? onError;
  final Widget Function(Object error, StackTrace stackTrace)? fallback;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null && _stackTrace != null) {
      return widget.fallback?.call(_error!, _stackTrace!) ??
          DefaultErrorWidget(
            error: _error!,
            stackTrace: _stackTrace!,
            onRetry: () {
              setState(() {
                _error = null;
                _stackTrace = null;
              });
            },
          );
    }

    ErrorWidget.builder = (FlutterErrorDetails details) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _error = details.exception;
            _stackTrace = details.stack;
          });
          widget.onError?.call(details.exception, details.stack ?? StackTrace.current);
        }
      });
      return widget.child;
    };
    return widget.child;
  }
}

/// Default error display widget
/// 
/// **Product Learning:**
/// When showing errors to users:
/// 1. Be honest but not technical
/// 2. Provide clear recovery actions
/// 3. Make it visually calming (not scary red screens)
/// 4. Give users control (retry, report, dismiss)
class DefaultErrorWidget extends StatelessWidget {
  const DefaultErrorWidget({
    super.key,
    required this.error,
    required this.stackTrace,
    this.onRetry,
    this.onReport,
  });

  final Object error;
  final StackTrace stackTrace;
  final VoidCallback? onRetry;
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLG),
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceLG),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Error Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spaceLG),

                    // Title
                    const Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppTheme.spaceMD),

                    // Message
                    Text(
                      _getUserFriendlyMessage(error),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppTheme.spaceLG),

                    // Action Buttons
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (onRetry != null)
                          ZenButton.primary(
                            'Try Again',
                            onPressed: onRetry,
                            trailing: const Icon(Icons.refresh),
                          ),
                        if (onRetry != null && onReport != null)
                          const SizedBox(height: AppTheme.spaceSM),
                        if (onReport != null)
                          OutlinedButton.icon(
                            onPressed: onReport,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                              ),
                            ),
                            icon: const Icon(Icons.bug_report),
                            label: const Text('Report Issue'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getUserFriendlyMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socket') || 
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Unable to connect to the internet. Please check your connection and try again.';
    }

    // Database errors
    if (errorString.contains('database') || 
        errorString.contains('sql')) {
      return 'There was a problem accessing your data. Your information is safe - please try again.';
    }

    // Permission errors
    if (errorString.contains('permission')) {
      return 'ZenScreen needs certain permissions to work properly. Please check your app settings.';
    }

    // Authentication errors
    if (errorString.contains('auth') || 
        errorString.contains('sign in')) {
      return 'There was a problem with your sign-in. Please try signing in again.';
    }

    // Generic fallback
    return 'We encountered an unexpected issue. Don\'t worry - your data is safe. Please try again.';
  }
}

/// Inline error widget for smaller components
/// 
/// **Product Learning:**
/// Not all errors need a full-screen takeover. For widget-level errors,
/// use inline error displays that don't disrupt the entire user experience.
class InlineErrorWidget extends StatelessWidget {
  const InlineErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade300,
                size: 20,
              ),
              const SizedBox(width: AppTheme.spaceSM),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.red.shade200,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppTheme.spaceSM),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade300,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

