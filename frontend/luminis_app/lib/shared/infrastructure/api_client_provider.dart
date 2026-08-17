import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Instância única de [ApiClient] compartilhada por todos os repositories do
/// app (ADR-009, ADR-010).
///
/// `keepAlive` porque repositories vivem durante toda a sessão do app,
/// conforme `references/riverpod-3.md`. Nenhuma feature deve instanciar
/// `ApiClient` diretamente — apenas repositories em `data/`, via este
/// provider.
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(client.dispose);
  return client;
});
