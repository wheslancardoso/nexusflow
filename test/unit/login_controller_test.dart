import 'package:flutter_test/flutter_test.dart';
import 'package:nexusflow/app/modules/auth/controllers/login_controller.dart';
import 'package:nexusflow/app/core/di/dependency_injection.dart';

void main() {
  late LoginController controller;

  setUp(() async {
    await getIt.reset();
    controller = LoginController();
  });

  group('LoginController Unit Tests', () {
    test('deve falhar se o e-mail não contiver @', () async {
      final success = await controller.login('tecniconexusflow.com.br', '123456');

      expect(success, isFalse);
      expect(controller.errorMessage, equals('E-mail ou senha inválidos'));
      expect(controller.isLoading, isFalse);
    });

    test('deve falhar se a senha tiver menos de 6 caracteres', () async {
      final success = await controller.login('tecnico@nexusflow.com.br', '12345');

      expect(success, isFalse);
      expect(controller.errorMessage, equals('E-mail ou senha inválidos'));
      expect(controller.isLoading, isFalse);
    });

    test('deve autenticar com sucesso quando e-mail é válido e senha tem 6 ou mais caracteres', () async {
      final success = await controller.login('tecnico@nexusflow.com.br', '123456');

      expect(success, isTrue);
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, isFalse);
    });
  });
}
