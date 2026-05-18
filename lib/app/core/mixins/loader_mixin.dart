import 'package:flutter/material.dart';

mixin LoaderMixin {
  OverlayEntry? _overlayEntry;

  // Dialog-based loading (ServiceFlow standard)
  void showLoading(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(
              child: Text(message ?? 'Carregando...'),
            ),
          ],
        ),
      ),
    );
  }

  void hideLoading(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // State-based overlay loading (compatibility)
  void showLoader(BuildContext context) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Container(
          color: Colors.black54,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void hideLoader() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }
}
