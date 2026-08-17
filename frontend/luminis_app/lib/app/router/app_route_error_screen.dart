import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/luminis_colors.dart';
import 'app_route_paths.dart';

/// Tela de erro de rota do Luminis, usada em `errorBuilder` do `GoRouter`.
///
/// Evita o fallback visual genérico do Flutter/`go_router` para rotas não
/// encontradas ou falhas de navegação (diretriz da skill
/// `luminis-go-router-agent`).
class AppRouteErrorScreen extends StatelessWidget {
  const AppRouteErrorScreen({required this.error, super.key});

  final GoException? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.explore_off_outlined,
                  size: 48,
                  color: LuminisColors.ink,
                ),
                const SizedBox(height: 16),
                Text(
                  'Não encontramos essa página.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutePaths.bookshelf),
                  child: const Text('Voltar para a estante'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
