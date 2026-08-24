import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/app/router/app_route_names.dart';
import 'package:luminis_app/app/router/app_router.dart';
import 'package:luminis_app/features/auth/data/providers/auth_providers.dart';
import 'package:luminis_app/features/auth/presentation/controllers/session_controller.dart';
import 'package:luminis_app/features/auth/presentation/screens/login_screen.dart';
import 'package:luminis_app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:luminis_app/features/books/data/providers/book_providers.dart';
import 'package:luminis_app/features/books/data/repositories/mock_book_catalog_repository.dart';
import 'package:luminis_app/main.dart';

import '../../features/auth/fakes/fake_auth_repository.dart';

/// Localiza texto especificamente dentro da `AppBar` da tela ativa.
///
/// Necessário porque os rótulos das abas do shell autenticado (`Estante`,
/// `Buscar`, ...) coincidem de propósito com o título das telas raiz de
/// cada aba — `find.text(...)` sozinho encontraria os dois (título da
/// `AppBar` da tela + rótulo do item na `NavigationBar`).
Finder _appBarText(String text) =>
    find.descendant(of: find.byType(AppBar), matching: find.text(text));

/// Localiza texto especificamente dentro da `NavigationBar`, para
/// tocar em uma aba pelo rótulo sem ambiguidade com o título da tela ativa.
Finder _bottomNavTab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

Future<ProviderContainer> _pumpAuthenticatedApp(WidgetTester tester) async {
  final session = buildSampleSession();
  final container = ProviderContainer.test(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        FakeAuthRepository(
          onLogin: ({required email, required password}) async => session,
        ),
      ),
      bookCatalogRepositoryProvider.overrideWithValue(
        MockBookCatalogRepository(),
      ),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const LuminisApp()),
  );
  await tester.pumpAndSettle();

  await container
      .read(sessionControllerProvider.notifier)
      .loginWithPassword(email: 'ana@email.com', password: 'senha-forte');
  await tester.pumpAndSettle();

  return container;
}

void main() {
  group('AppRouter · guard de autenticação', () {
    testWidgets('usuário desautenticado inicia em Auth · Welcome', (
      tester,
    ) async {
      final container = ProviderContainer.test(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const LuminisApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('usuário desautenticado tentando acessar rota protegida é '
        'redirecionado para Auth · Welcome', (tester) async {
      final container = ProviderContainer.test(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const LuminisApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(appRouterProvider).goNamed(AppRouteNames.bookshelf);
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('login mockado autentica e redireciona para a Estante', (
      tester,
    ) async {
      await _pumpAuthenticatedApp(tester);

      expect(_appBarText('Estante'), findsOneWidget);
      expect(find.byType(WelcomeScreen), findsNothing);
    });

    testWidgets('usuário autenticado tentando acessar rota pública de auth é '
        'redirecionado para a Estante', (tester) async {
      final container = await _pumpAuthenticatedApp(tester);
      expect(_appBarText('Estante'), findsOneWidget);

      container.read(appRouterProvider).goNamed(AppRouteNames.authLogin);
      await tester.pumpAndSettle();

      expect(_appBarText('Estante'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('logout volta para Auth · Welcome', (tester) async {
      final container = await _pumpAuthenticatedApp(tester);
      expect(_appBarText('Estante'), findsOneWidget);

      await container.read(sessionControllerProvider.notifier).logout();
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });
  });

  group('AppRouter · shell autenticado', () {
    testWidgets(
      'trocar de aba com a bottom navigation preserva a pilha de cada branch',
      (tester) async {
        final container = await _pumpAuthenticatedApp(tester);
        final router = container.read(appRouterProvider);

        // Vai para a aba Buscar pela bottom navigation (goBranch real).
        await tester.tap(_bottomNavTab('Buscar'));
        await tester.pumpAndSettle();
        expect(_appBarText('Buscar'), findsOneWidget);

        // Empilha o detalhe de um livro dentro da branch Buscar.
        router.pushNamed(
          AppRouteNames.bookDetail,
          pathParameters: {'bookId': 'book_bras_cubas'},
        );
        await tester.pumpAndSettle();
        expect(find.text('Dados da edição'), findsOneWidget);

        // Troca para a aba Estante...
        await tester.tap(_bottomNavTab('Estante'));
        await tester.pumpAndSettle();
        expect(_appBarText('Estante'), findsOneWidget);

        // ...e volta para Buscar: a pilha empilhada deve ter sido
        // preservada (StatefulShellRoute.indexedStack + goBranch), então
        // o detalhe do livro continua no topo — não a raiz da aba Buscar.
        await tester.tap(_bottomNavTab('Buscar'));
        await tester.pumpAndSettle();
        expect(find.text('Dados da edição'), findsOneWidget);
      },
    );
  });
}
