import 'package:flutter/material.dart';

mixin MessagesMixin {
  void showSuccess(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.green, Icons.check_circle_outline);
  }

  void showError(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.red, Icons.error_outline);
  }

  void showWarning(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.orange, Icons.warning_amber_rounded);
  }

  void showInfo(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.blue, Icons.info_outline);
  }

  void _showSnackBar(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Fechar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
