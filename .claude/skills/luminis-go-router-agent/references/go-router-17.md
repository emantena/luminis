# go_router 17.x No Luminis

Status: referencia versionada.

Ultima revisao com documentacao oficial: 2026-08-07.

Fontes oficiais consultadas:

- `pub.dev/packages/go_router`
- `pub.dev/packages/go_router/changelog`
- `pub.dev/documentation/go_router/latest/topics/Configuration-topic.html`
- `pub.dev/documentation/go_router/latest/topics/Navigation-topic.html`
- `pub.dev/documentation/go_router/latest/topics/Redirection-topic.html`
- `pub.dev/documentation/go_router/latest/topics/Named routes-topic.html`
- `pub.dev/documentation/go_router/latest/topics/Error handling-topic.html`
- API docs de `GoRouter`, `GoRoute`, `ShellRoute`, `StatefulShellRoute`, `StatefulNavigationShell` e `StatefulShellBranch`

## Versao E Compatibilidade

Dependencia planejada:

```yaml
dependencies:
  go_router: ^17.3.0
```

Atencao:

- `^17.3.0` pode resolver versoes 17.x mais novas.
- Em 2026-08-07, `pub.dev` mostra `17.4.0` como versao mais recente.
- O changelog oficial de `17.3.0` exige Flutter `3.38` e Dart `3.10`.
- Antes de implementar, verificar `pubspec.lock` e `flutter --version`.
- Se for necessario comportamento exatamente de `17.3.0`, pinusar `go_router: 17.3.0` em vez de caret.

## Modelo Mental

`go_router` e declarativo e baseado em URL:

- `GoRouter` centraliza configuracao, redirects, observers, erros e rota inicial.
- `GoRoute` representa uma tela ou segmento navegavel.
- `ShellRoute` adiciona um shell visual com um Navigator interno.
- `StatefulShellRoute` cria navegacao paralela por branches; e a escolha padrao para abas com estado preservado.
- `StatefulNavigationShell` e o widget usado pelo shell para mostrar a branch ativa e trocar de branch com `goBranch`.

## Estrutura Recomendada

```text
lib/app/router/
  app_router.dart
  app_route_names.dart
  app_route_paths.dart
  app_route_refresh_listenable.dart
  app_shell.dart
```

Responsabilidades:

- `app_router.dart`: cria o `GoRouter`, declara rotas, redirects, erro e observers.
- `app_route_names.dart`: nomes estaveis para rotas.
- `app_route_paths.dart`: paths e helpers para parametros.
- `app_route_refresh_listenable.dart`: ponte entre estado Riverpod e `refreshListenable`, se necessario.
- `app_shell.dart`: scaffold autenticado com bottom navigation.

Nao colocar widgets de tela dentro de `app_router.dart`; importar telas das features.

## Mapa De Navegacao MVP

Publicas:

| Nome | Path | Uso |
| --- | --- | --- |
| `authWelcome` | `/auth/welcome` | entrada publica |
| `authLogin` | `/auth/login` | login email/senha |
| `authRegister` | `/auth/register` | cadastro |
| `authForgotPassword` | `/auth/forgot-password` | solicitar recuperacao |
| `authResetPassword` | `/auth/reset-password` | redefinir senha |

Shell autenticado com `StatefulShellRoute.indexedStack`:

| Branch | Nome raiz | Path raiz | Observacao |
| --- | --- | --- | --- |
| Estante | `bookshelf` | `/bookshelf` | colecao do usuario |
| Buscar | `search` | `/search` | busca de livros/autores/editoras/leitores |
| Leitura | `reading` | `/reading` | lendo agora e sessoes |
| Metas | `goals` | `/goals` | metas mensais/anuais |
| Perfil | `profile` | `/profile` | perfil do usuario |

Rotas protegidas empilhadas:

| Nome | Path | Onde empilhar |
| --- | --- | --- |
| `bookDetail` | `/books/:bookId` | branch de origem quando fizer sentido |
| `bookDraftNew` | `/book-drafts/new` | root navigator se for fluxo global |
| `readingState` | `/reading/:bookshelfItemId` | branch Leitura |
| `readingProgressNew` | `/reading/:bookshelfItemId/progress/new` | branch Leitura |
| `readingPlan` | `/reading/:bookshelfItemId/plan` | branch Leitura |
| `goalNew` | `/goals/new` | branch Metas |
| `goalDetail` | `/goals/:readingGoalId` | branch Metas |
| `goalEdit` | `/goals/:readingGoalId/edit` | branch Metas |
| `profileEdit` | `/profile/edit` | branch Perfil |

## StatefulShellRoute Para Abas

Usar `StatefulShellRoute.indexedStack` para as cinco abas autenticadas. Isso preserva historico e estado por aba e combina com a UX mobile do Luminis.

Padrao:

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return AppShell(navigationShell: navigationShell);
  },
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutePaths.bookshelf,
          name: AppRouteNames.bookshelf,
          builder: (context, state) => const BookshelfScreen(),
        ),
      ],
    ),
  ],
)
```

No `AppShell`, trocar abas com:

```dart
navigationShell.goBranch(index);
```

Usar `initialLocation: true` apenas quando o comportamento desejado for voltar para a raiz da aba ao tocar novamente ou ao reabrir uma branch. Caso contrario, manter a ultima tela da branch.

## go, push E pop

Usar:

- `context.goNamed(...)`: troca de area principal, redirecionamentos, entrada em aba raiz.
- `context.pushNamed(...)`: detalhes, formularios, bottom sheets full-screen ou telas que precisam voltar para onde estavam.
- `context.pop(...)`: retorno da tela atual.
- `context.namedLocation(...)`: montar URL em redirects ou links internos.

Evitar:

- `Navigator.push` em telas que devem ser deep-linkable.
- Path literal dentro de widget.
- `extra` para dados essenciais, porque pode ser perdido em cenarios web/deep link se nao houver codec.

## Parametros

Usar path parameters para IDs obrigatorios:

```dart
final bookId = state.pathParameters['bookId'];
```

Usar query parameters para filtros opcionais:

```dart
final source = state.uri.queryParameters['source'];
```

Validar parametros na tela/controller. O router so extrai e direciona.

## Redirect De Autenticacao

Usar redirect top-level para separar rotas publicas e protegidas.

Regras:

- redirect deve ser rapido e deterministico;
- nao chamar API/repository no redirect;
- nao misturar regra de negocio de dominio com regra de acesso;
- retornar `null` quando a navegacao atual e permitida;
- evitar loops entre `/auth/*` e `/bookshelf`;
- usar `redirectLimit` apenas se houver cadeia real de redirects.

Pseudocodigo:

```dart
redirect: (context, state) {
  final isAuthenticated = authState.isAuthenticated;
  final isAuthRoute = state.uri.path.startsWith('/auth');

  if (!isAuthenticated && !isAuthRoute) {
    return context.namedLocation(AppRouteNames.authWelcome);
  }

  if (isAuthenticated && isAuthRoute) {
    return context.namedLocation(AppRouteNames.bookshelf);
  }

  return null;
}
```

## Integracao Com Riverpod

O router pode ler estado via provider, mas nao deve recriar navegacao de forma instavel.

Padrao recomendado para o MVP:

- criar provider do `GoRouter`;
- ler estado de auth mockado;
- usar uma ponte `Listenable` em `refreshListenable` quando mudancas de auth precisarem reavaliar redirect;
- manter o redirect puro, usando apenas estado ja carregado.

Exemplo conceitual:

```dart
final appRouterProvider = Provider<GoRouter>((ref) {
  final authListenable = ref.watch(authRouteRefreshListenableProvider);

  return GoRouter(
    initialLocation: AppRoutePaths.bookshelf,
    refreshListenable: authListenable,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      return resolveAuthRedirect(context, state, authState);
    },
    routes: appRoutes,
    errorBuilder: (context, state) => AppRouteErrorScreen(error: state.error),
  );
});
```

Se a implementacao com Riverpod 3.x tiver um padrao melhor no momento do codigo, usar a skill `luminis-riverpod-agent` em conjunto e atualizar esta referencia.

## ShellRoute Simples

Usar `ShellRoute` somente quando:

- a tela precisa de um shell visual;
- nao precisa preservar pilhas independentes por aba;
- existe apenas um Navigator interno.

Para a navegacao principal com abas do Luminis, preferir `StatefulShellRoute`.

## parentNavigatorKey

Usar `parentNavigatorKey` quando uma rota filha precisa aparecer fora do Navigator atual.

Exemplos possiveis:

- fluxo global de criacao de livro manual;
- modal full-screen que cobre a bottom navigation;
- rota de erro global.

Nao usar para detalhes comuns que devem voltar naturalmente para a aba de origem.

## Erros

Configurar uma tela propria de erro:

```dart
errorBuilder: (context, state) => AppRouteErrorScreen(error: state.error),
```

Usar `onException` somente quando a navegacao precisar escolher entre ignorar, redirecionar ou mostrar uma pagina especifica para excecoes conhecidas.

## Type-safe Routes

Nao usar `go_router_builder` no MVP sem decisao explicita.

Motivo:

- adiciona codegen e dependencias;
- o MVP ainda esta validando mapa de telas;
- constantes de nomes/paths sao suficientes por enquanto.

Reavaliar quando o mapa de rotas estabilizar ou quando muitos parametros comecarem a se repetir.

## Checklist De Implementacao

- Confirmar versao resolvida no `pubspec.lock`.
- Confirmar Flutter SDK compativel.
- Declarar nomes e paths em arquivos dedicados.
- Usar `StatefulShellRoute.indexedStack` para abas.
- Usar `goBranch` no bottom navigation.
- Proteger rotas com redirect top-level.
- Garantir fallback de erro com visual Luminis.
- Evitar string literal de rota em widgets.
- Evitar repository/API dentro do router.
- Testar usuario desautenticado acessando rota protegida.
- Testar usuario autenticado acessando `/auth/login`.
- Testar troca de abas preservando estado.
- Testar detalhes/formularios com voltar.
