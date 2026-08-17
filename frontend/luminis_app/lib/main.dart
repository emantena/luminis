import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router/app_router.dart';
import 'app/theme/luminis_theme.dart';

void main() {
  runApp(const ProviderScope(child: LuminisApp()));
}

/// Composição raiz do app.
///
/// Navegação via `go_router` (`appRouterProvider`, em
/// `lib/app/router/app_router.dart`): fluxo público de autenticação
/// separado do shell autenticado com abas, com guard de autenticação
/// lendo `sessionControllerProvider`.
class LuminisApp extends ConsumerWidget {
  const LuminisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Luminis',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: LuminisTheme.light(),
      routerConfig: router,
    );
  }
}
