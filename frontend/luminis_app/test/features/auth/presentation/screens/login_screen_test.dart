import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/app/router/app_route_names.dart';
import 'package:luminis_app/app/router/app_router.dart';
import 'package:luminis_app/features/auth/data/providers/auth_providers.dart';
import 'package:luminis_app/features/auth/presentation/screens/login_screen.dart';
import 'package:luminis_app/main.dart';

import '../../fakes/fake_auth_repository.dart';

/// Localiza texto especificamente dentro da `AppBar` da tela ativa (mesmo
/// padrão de `test/app/router/app_router_test.dart`, necessário porque os
/// rótulos das abas do shell autenticado coincidem com o título de tela).
Finder _appBarText(String text) =>
    find.descendant(of: find.byType(AppBar), matching: find.text(text));

Future<ProviderContainer> _pumpAppAtLogin(
  WidgetTester tester, {
  required FakeAuthRepository repository,
}) async {
  final container = ProviderContainer.test(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const LuminisApp()),
  );
  await tester.pumpAndSettle();

  container.read(appRouterProvider).goNamed(AppRouteNames.authLogin);
  await tester.pumpAndSettle();

  return container;
}

void main() {
  group('LoginScreen', () {
    testWidgets('exibe formulário com email, senha e ação Entrar', (
      tester,
    ) async {
      await _pumpAppAtLogin(tester, repository: FakeAuthRepository());

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
      expect(find.text('Esqueci minha senha'), findsOneWidget);
    });

    testWidgets(
      'bloqueia envio e mostra erro local quando campos estão vazios, sem '
      'chamar o repository',
      (tester) async {
        final repository = FakeAuthRepository();
        await _pumpAppAtLogin(tester, repository: repository);

        await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
        await tester.pumpAndSettle();

        expect(find.text('Informe seu email.'), findsOneWidget);
        expect(find.text('Informe sua senha.'), findsOneWidget);
        expect(repository.loginCallCount, 0);
        expect(find.byType(LoginScreen), findsOneWidget);
      },
    );

    testWidgets('credenciais inválidas mostram alerta geral sem navegar', (
      tester,
    ) async {
      final repository = FakeAuthRepository(
        onLogin: ({required email, required password}) async {
          throw invalidCredentialsFailure;
        },
      );
      await _pumpAppAtLogin(tester, repository: repository);

      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'ana@email.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Senha'),
        'senha-errada',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text(invalidCredentialsFailure.message), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets(
      'login com sucesso não navega manualmente; redirect do router leva à '
      'Estante',
      (tester) async {
        final session = buildSampleSession();
        final repository = FakeAuthRepository(
          onLogin: ({required email, required password}) async => session,
        );
        await _pumpAppAtLogin(tester, repository: repository);

        await tester.enterText(
          find.widgetWithText(TextField, 'Email'),
          'ana@email.com',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Senha'),
          'senha-forte',
        );
        await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
        await tester.pumpAndSettle();

        expect(_appBarText('Estante'), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      },
    );
  });
}
