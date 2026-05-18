import 'package:flutter/material.dart';

mixin MessagesMixin {
  void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context, 
      message, 
      Colors.green, 
      Icons.check_circle_outline, 
      duration: const Duration(seconds: 3),
    );
  }

  void showError(BuildContext context, String message) {
    _showSnackBar(
      context, 
      message, 
      Colors.red, 
      Icons.error_outline, 
      duration: const Duration(days: 365),
      hasCloseButton: true,
    );
  }

  void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context, 
      message, 
      Colors.orange, 
      Icons.warning_amber_rounded, 
      duration: const Duration(seconds: 4),
    );
  }

  void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context, 
      message, 
      Colors.blue, 
      Icons.info_outline, 
      duration: const Duration(seconds: 4),
    );
  }

  Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(
    BuildContext context, 
    String message, 
    Color color, 
    IconData icon, {
    required Duration duration,
    bool hasCloseButton = false,
  }) {
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
        duration: duration,
        action: hasCloseButton
            ? SnackBarAction(
                label: 'Fechar',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              )
            : null,
      ),
    );
  }
}
