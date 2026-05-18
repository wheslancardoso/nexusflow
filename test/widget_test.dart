import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nexusflow/app/modules/auth/presentation/pages/login_page.dart';
import 'package:nexusflow/app/modules/auth/controllers/login_controller.dart';
import 'package:nexusflow/app/core/di/dependency_injection.dart';

void main() {
  setUpAll(() async {
    await getIt.reset();
    getIt.registerFactory<LoginController>(() => LoginController());
  });

  testWidgets('Deve renderizar os componentes da LoginPage com sucesso', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => getIt<LoginController>()),
        ],
        child: const MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verifica se os elementos da nova página de Login Glassmorphic estão na tela
    expect(find.text('NexusFlow'), findsOneWidget);
    expect(find.text('Acessar Sistema'), findsOneWidget);
    expect(find.byKey(const Key('login-email-field')), findsOneWidget);
    expect(find.byKey(const Key('login-password-field')), findsOneWidget);
    expect(find.byKey(const Key('login-btn')), findsOneWidget);
  });
}
