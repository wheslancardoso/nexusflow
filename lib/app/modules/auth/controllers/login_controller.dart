import '../../../core/view_models/base.view_model.dart';

class LoginController extends BaseViewModel {
  LoginController();

  Future<bool> login(String email, String password) async {
    bool success = false;
    await runWithLoading(() async {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock validation: email must have @ and password > 6 chars
      if (email.contains('@') && password.length >= 6) {
        success = true;
      } else {
        setError('E-mail ou senha inválidos');
      }
    });
    return success;
  }

  Future<void> logout() async {
    notifyListeners();
  }
}
