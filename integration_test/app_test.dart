import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nexusflow/main.dart' as app;
import 'package:nexusflow/app/core/di/dependency_injection.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('NexusFlow E2E Integration Suite', () {
    setUp(() async {
      // Clean up dependency injection to ensure pristine state
      await getIt.reset();
    });

    testWidgets('Deve realizar o login, acessar Nova OS, faturar uma OS e atualizar o Painel', (WidgetTester tester) async {
      // 1. Inicializa o aplicativo principal
      app.main();
      await tester.pumpAndSettle();

      // 2. Verifica se estamos na tela de Login e preenche as credenciais
      final emailFieldFinder = find.byKey(const Key('login-email-field'));
      final passwordFieldFinder = find.byKey(const Key('login-password-field'));
      final loginBtnFinder = find.byKey(const Key('login-btn'));

      expect(emailFieldFinder, findsOneWidget);
      expect(passwordFieldFinder, findsOneWidget);
      expect(loginBtnFinder, findsOneWidget);

      // Preenche dados válidos (E-mail com '@' e senha com 6+ caracteres)
      await tester.enterText(emailFieldFinder, 'tecnico@nexusflow.com.br');
      await tester.enterText(passwordFieldFinder, '123456');
      await tester.pumpAndSettle();

      // Clica em "Entrar" e aguarda o redirecionamento (simulação de delay de 1s inclusa no controlador)
      await tester.tap(loginBtnFinder);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // 3. Verifica se fomos redirecionados com sucesso para a Dashboard (Procura pelo texto "Desempenho e Indicadores")
      expect(find.text('Desempenho e Indicadores'), findsOneWidget);

      // 4. Navega para a aba "Nova OS"
      final tabNovaOsFinder = find.byKey(const Key('tab-nova-os'));
      expect(tabNovaOsFinder, findsOneWidget);
      
      await tester.tap(tabNovaOsFinder);
      await tester.pumpAndSettle();

      // Verifica se estamos no formulário express de faturamento de O.S.
      expect(find.text('Faturar Nova O.S.'), findsOneWidget);

      // 5. Preenche a Identificação do Cliente (Busca reativa simulada)
      final cpfFieldFinder = find.byKey(const Key('os-cpf-field'));
      final nomeFieldFinder = find.byKey(const Key('os-nome-field'));
      final foneFieldFinder = find.byKey(const Key('os-fone-field'));
      final emailFieldClienteFinder = find.byKey(const Key('os-email-field'));
      final enderecoFieldFinder = find.byKey(const Key('os-endereco-field'));

      expect(cpfFieldFinder, findsOneWidget);
      expect(nomeFieldFinder, findsOneWidget);

      await tester.enterText(cpfFieldFinder, '12345678901');
      await tester.pumpAndSettle(); // Dispara o onChange

      await tester.enterText(nomeFieldFinder, 'Cliente E2E Test');
      await tester.enterText(foneFieldFinder, '11999999999');
      await tester.enterText(emailFieldClienteFinder, 'e2e@nexusflow.com');
      await tester.enterText(enderecoFieldFinder, 'Avenida Paulista, 1000');
      await tester.pumpAndSettle();

      // 6. Preenche os Detalhes do Serviço da O.S.
      final descFieldFinder = find.byKey(const Key('os-desc-field'));
      final valFieldFinder = find.byKey(const Key('os-val-field'));

      expect(descFieldFinder, findsOneWidget);
      expect(valFieldFinder, findsOneWidget);

      await tester.enterText(descFieldFinder, 'Troca de tela LCD e bateria interna de Macbook Pro.');
      await tester.enterText(valFieldFinder, '1200.00');
      await tester.pumpAndSettle();

      // 7. Clica em "Faturar O.S." para registrar o cliente e a O.S. simultaneamente em 1 passo
      final faturarBtnFinder = find.byKey(const Key('os-faturar-btn'));
      expect(faturarBtnFinder, findsOneWidget);

      await tester.tap(faturarBtnFinder);
      // Aguarda animação de faturamento e redirecionamento de sucesso para a aba Painel
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // 8. Valida o sucesso do fluxo de "cabo a rabo" (Volta ao Painel e verifica a nova O.S.)
      final tabPainelFinder = find.byKey(const Key('tab-painel'));
      await tester.tap(tabPainelFinder);
      await tester.pumpAndSettle();

      // Verifica se a nova ordem está presente na lista de Ordens Recentes da Dashboard
      expect(find.text('Cliente E2E Test'), findsOneWidget);
      expect(find.text('Troca de tela LCD e bateria interna de Macbook Pro.'), findsOneWidget);
    });
  });
}
