import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modal estilo TikTok que ocupa todo el ancho
/// con botones en la parte inferior para uso con una mano
class TikTokModal extends StatelessWidget {
  final String? title;
  final Widget? content;
  final String? message;
  final List<TikTokModalButton> actions;
  final bool isDismissible;
  final Color? backgroundColor;
  final double? height;

  const TikTokModal({
    super.key,
    this.title,
    this.content,
    this.message,
    required this.actions,
    this.isDismissible = true,
    this.backgroundColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      width: size.width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar para cerrar
          if (isDismissible)
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          // Título
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Contenido
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: content ??
                  (message != null
                      ? Text(
                          message!,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        )
                      : const SizedBox.shrink()),
            ),
          ),

          const SizedBox(height: 16),

          // Botones en la parte inferior (estilo TikTok)
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              bottomPadding > 0 ? bottomPadding : 16,
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < actions.length; i++) ...[
                  _buildActionButton(context, actions[i]),
                  if (i < actions.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, TikTokModalButton button) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          if (button.hapticFeedback) {
            HapticFeedback.mediumImpact();
          }
          button.onPressed?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: button.backgroundColor ??
              (button.isPrimary
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface),
          foregroundColor: button.foregroundColor ??
              (button.isPrimary
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: button.isPrimary
                ? BorderSide.none
                : BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    width: 1,
                  ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (button.icon != null) ...[
              Icon(button.icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              button.text,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: button.isPrimary ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón para el modal TikTok
class TikTokModalButton {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool hapticFeedback;

  const TikTokModalButton({
    required this.text,
    this.onPressed,
    this.isPrimary = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.hapticFeedback = true,
  });
}

/// Helper para mostrar modal estilo TikTok
Future<T?> showTikTokModal<T>({
  required BuildContext context,
  String? title,
  Widget? content,
  String? message,
  required List<TikTokModalButton> actions,
  bool isDismissible = true,
  Color? backgroundColor,
  double? height,
  bool useRootNavigator = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    useRootNavigator: useRootNavigator,
    backgroundColor: Colors.transparent,
    builder: (context) => TikTokModal(
      title: title,
      content: content,
      message: message,
      actions: actions,
      isDismissible: isDismissible,
      backgroundColor: backgroundColor,
      height: height,
    ),
  );
}

/// Helper para modal de confirmación simple (estilo TikTok)
Future<bool?> showTikTokConfirmation({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDestructive = false,
  IconData? icon,
}) {
  return showTikTokModal<bool>(
    context: context,
    title: title,
    message: message,
    actions: [
      TikTokModalButton(
        text: confirmText,
        isPrimary: true,
        icon: icon,
        backgroundColor: isDestructive ? Colors.red : null,
        onPressed: () => Navigator.of(context).pop(true),
      ),
      TikTokModalButton(
        text: cancelText,
        onPressed: () => Navigator.of(context).pop(false),
      ),
    ],
  );
}

/// Helper para modal de alerta simple (estilo TikTok)
Future<void> showTikTokAlert({
  required BuildContext context,
  required String title,
  required String message,
  String buttonText = 'OK',
  IconData? icon,
}) {
  return showTikTokModal<void>(
    context: context,
    title: title,
    message: message,
    actions: [
      TikTokModalButton(
        text: buttonText,
        isPrimary: true,
        icon: icon,
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  );
}
