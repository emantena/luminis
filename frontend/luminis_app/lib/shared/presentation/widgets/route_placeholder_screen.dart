import 'package:flutter/material.dart';

/// Tela placeholder mínima usada enquanto o conteúdo real de uma rota não
/// foi implementado.
///
/// **Provisório**: existe apenas para o `go_router` funcionar de ponta a
/// ponta antes de o `luminis-flutter-agent` entregar o conteúdo real de
/// cada tela. Cada arquivo de tela que usa este widget deve ter seu
/// `build` substituído — o arquivo e o nome da classe permanecem os
/// mesmos, para que o router não precise ser alterado.
class RoutePlaceholderScreen extends StatelessWidget {
  const RoutePlaceholderScreen({required this.routeLabel, super.key});

  /// Rótulo legível da rota (ex.: "Estante", "Detalhe do livro").
  final String routeLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(routeLabel)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '$routeLabel\n(placeholder — conteúdo real pendente)',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
