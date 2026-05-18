import 'package:flutter/material.dart';

abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> runWithLoading(Future<void> Function() action) async {
    try {
      setLoading(true);
      setError(null);
      await action();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}
