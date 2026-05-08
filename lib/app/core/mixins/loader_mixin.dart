import 'package:flutter/material.dart';

mixin LoaderMixin<T extends StatefulWidget> on State<T> {
  OverlayEntry? _overlayEntry;

  void showLoader() {
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

  @override
  void dispose() {
    hideLoader();
    super.dispose();
  }
}
