import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/error_messages.dart';

/// Widget for displaying errors with user-friendly messages
///
/// Features:
/// - User-friendly error messages
/// - Helpful hints for common errors
/// - Retry button for recoverable errors
/// - Suggested actions for errors requiring user action
class ErrorDisplay extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final String? customMessage;

  const ErrorDisplay({
    super.key,
    required this.error,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorCode = _extractErrorCode(error);
    final message = customMessage ??
        ErrorMessages.getFriendlyMessage(
          errorCode,
          fallback: error.toString(),
        );
    final hint = ErrorMessages.getHint(errorCode);
    final isRecoverable = ErrorMessages.isRecoverable(errorCode);
    final suggestedAction = ErrorMessages.getSuggestedAction(errorCode);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Icon(
              isRecoverable ? Icons.cloud_off : Icons.error_outline,
              size: 64,
              color: AppTheme.lossRed,
            ),
            const SizedBox(height: 24),

            // Error Message
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lossRed,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            // Hint
            if (hint != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.warningYellow.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppTheme.warningYellow,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            if (onRetry != null || suggestedAction != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onRetry != null && isRecoverable)
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: Text(suggestedAction ?? 'Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.profitGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String? _extractErrorCode(Object error) {
    final errorString = error.toString();

    // Try to extract error code from common patterns
    if (errorString.contains('TIMEOUT')) return 'TIMEOUT';
    if (errorString.contains('CONNECTION')) return 'CONNECTION_ERROR';
    if (errorString.contains('NETWORK')) return 'NETWORK_ERROR';
    if (errorString.contains('INSUFFICIENT_BALANCE'))
      return 'INSUFFICIENT_BALANCE';
    if (errorString.contains('BOT_RUNNING') ||
        errorString.contains('bot is already running')) return 'BOT_RUNNING';
    if (errorString.contains('POSITION_NOT_FOUND')) return 'POSITION_NOT_FOUND';
    if (errorString.contains('UNAUTHORIZED')) return 'UNAUTHORIZED';
    if (errorString.contains('FORBIDDEN')) return 'FORBIDDEN';
    if (errorString.contains('NOT_FOUND')) return 'NOT_FOUND';
    if (errorString.contains('500')) return 'INTERNAL_SERVER_ERROR';
    if (errorString.contains('503')) return 'SERVICE_UNAVAILABLE';

    return null;
  }
}

/// Helper function to show error SnackBar with user-friendly message
void showErrorSnackBar(
  BuildContext context,
  Object error, {
  VoidCallback? onRetry,
  Duration duration = const Duration(seconds: 4),
}) {
  final errorCode = _extractErrorCode(error);
  final message = ErrorMessages.getFriendlyMessage(
    errorCode,
    fallback: error.toString(),
  );
  final isRecoverable = ErrorMessages.isRecoverable(errorCode);
  final suggestedAction = ErrorMessages.getSuggestedAction(errorCode);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppTheme.lossRed,
      duration: duration,
      action: onRetry != null && isRecoverable
          ? SnackBarAction(
              label: suggestedAction ?? 'Retry',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    ),
  );
}

/// Helper function to show success SnackBar
void showSuccessSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppTheme.profitGreen,
      duration: duration,
    ),
  );
}

/// Helper function to show warning SnackBar
void showWarningSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppTheme.warningYellow,
      duration: duration,
    ),
  );
}

String? _extractErrorCode(Object error) {
  final errorString = error.toString();

  // Try to extract error code from common patterns
  if (errorString.contains('TIMEOUT')) return 'TIMEOUT';
  if (errorString.contains('CONNECTION')) return 'CONNECTION_ERROR';
  if (errorString.contains('NETWORK')) return 'NETWORK_ERROR';
  if (errorString.contains('INSUFFICIENT_BALANCE'))
    return 'INSUFFICIENT_BALANCE';
  if (errorString.contains('BOT_RUNNING') ||
      errorString.contains('bot is already running')) return 'BOT_RUNNING';
  if (errorString.contains('POSITION_NOT_FOUND')) return 'POSITION_NOT_FOUND';
  if (errorString.contains('UNAUTHORIZED')) return 'UNAUTHORIZED';
  if (errorString.contains('FORBIDDEN')) return 'FORBIDDEN';
  if (errorString.contains('NOT_FOUND')) return 'NOT_FOUND';
  if (errorString.contains('500')) return 'INTERNAL_SERVER_ERROR';
  if (errorString.contains('503')) return 'SERVICE_UNAVAILABLE';

  return null;
}
