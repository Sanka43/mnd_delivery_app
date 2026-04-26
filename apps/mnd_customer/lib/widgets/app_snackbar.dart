import 'package:flutter/material.dart';

/// Shared snackbar style for customer app feedback.
abstract final class AppSnackBar {
  static void showInfo(
    BuildContext context, {
    required String message,
    IconData icon = Icons.info_outline_rounded,
    double? iconSize,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      message: message,
      icon: icon,
      iconSize: iconSize,
      duration: duration,
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    IconData icon = Icons.check_circle_outline_rounded,
    double? iconSize,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      message: message,
      icon: icon,
      iconSize: iconSize,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    IconData icon = Icons.error_outline_rounded,
    double? iconSize,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      icon: icon,
      iconSize: iconSize,
      duration: duration,
      isError: true,
    );
  }

  static void show(
    BuildContext context, {
    required String message,
    IconData icon = Icons.info_outline_rounded,
    double? iconSize,
    Duration duration = const Duration(seconds: 2),
    bool isError = false,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final cs = Theme.of(context).colorScheme;

    final background = isError ? cs.errorContainer : cs.inverseSurface;
    final foreground = isError ? cs.onErrorContainer : cs.onInverseSurface;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        backgroundColor: background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            Icon(icon, size: iconSize ?? 18, color: foreground),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
