import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/controllers/session_controller.dart';
import '../../features/auth/presentation/controllers/session_state.dart';

/// Ponte entre `sessionControllerProvider` (Riverpod) e o parâmetro
/// `refreshListenable` do `GoRouter`.
///
/// `GoRouter` não observa providers Riverpod nativamente. Esta classe usa
/// `ref.listen` — válido dentro do corpo de criação de qualquer provider,
/// não apenas em `build` de widget — para escutar `sessionControllerProvider`
/// e notificar os listeners do `go_router` (que reavalia `redirect`) apenas
/// quando o status autenticado/não autenticado muda de fato. Isso evita
/// reavaliar o redirect em transições irrelevantes para o guard de rota,
/// como `SessionAuthenticating` -> `SessionAuthenticating`.
class GoRouterRefreshListenable extends ChangeNotifier {
  GoRouterRefreshListenable(Ref ref) {
    _subscription = ref.listen<SessionState>(sessionControllerProvider, (
      previous,
      next,
    ) {
      final wasAuthenticated = previous is SessionAuthenticated;
      final isAuthenticated = next is SessionAuthenticated;
      if (wasAuthenticated != isAuthenticated) {
        notifyListeners();
      }
    });
  }

  late final ProviderSubscription<SessionState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

/// Provider `keepAlive` (padrão de `Provider`) que expõe a ponte acima.
///
/// Fica vivo durante toda a vida do app: `appRouterProvider` depende desta
/// instância estável para que o `GoRouter` seja criado uma única vez.
final goRouterRefreshListenableProvider = Provider<GoRouterRefreshListenable>((
  ref,
) {
  final listenable = GoRouterRefreshListenable(ref);
  ref.onDispose(listenable.dispose);
  return listenable;
});
