# Riverpod 3.x No Luminis

Status: referencia versionada.

Ultima revisao com documentacao oficial: 2026-08-07.

Fontes oficiais consultadas:

- `riverpod.dev/docs/introduction/getting_started`
- `riverpod.dev/docs/concepts2/providers`
- `riverpod.dev/docs/concepts2/consumers`
- `riverpod.dev/docs/concepts2/containers`
- `riverpod.dev/docs/concepts2/refs`
- `riverpod.dev/docs/concepts2/auto_dispose`
- `riverpod.dev/docs/concepts2/family`
- `riverpod.dev/docs/concepts2/overrides`
- `riverpod.dev/docs/concepts2/observers`
- `riverpod.dev/docs/concepts/about_code_generation`
- `riverpod.dev/docs/how_to/testing`
- `riverpod.dev/docs/how_to/select`
- `pub.dev/packages/flutter_riverpod`
- `pub.dev/packages/riverpod_annotation`
- `pub.dev/packages/riverpod_generator`

## Versao E Compatibilidade

Dependencias planejadas sem codegen:

```yaml
dependencies:
  flutter_riverpod: ^3.4.1
```

Dependencias planejadas com codegen:

```yaml
dependencies:
  flutter_riverpod: ^3.4.1
  riverpod_annotation: ^4.0.5

dev_dependencies:
  build_runner: any
  riverpod_generator: ^4.0.7
```

Atencao:

- `^3.4.1` pode resolver versoes 3.x mais novas.
- Em 2026-08-07, `pub.dev` mostra `flutter_riverpod 3.4.2` como versao mais recente.
- Em 2026-08-07, `pub.dev` mostra `riverpod_annotation 4.0.6` e `riverpod_generator 4.0.8` como versoes mais recentes.
- Antes de implementar, verificar `pubspec.lock`.
- Se for necessario comportamento exatamente de uma versao, pinusar a dependencia em vez de usar caret.

## Decisao De Codegen

Para o MVP do Luminis, comecar sem codegen.

Motivo:

- o mapa de telas e providers ainda esta nascendo;
- evita custo inicial de `build_runner`;
- mantem iteracao rapida no prototipo Flutter;
- a propria documentacao oficial diz que codegen e opcional e recomenda ponderar seu uso quando o projeto ainda nao usa geracao.

Reavaliar codegen quando:

- a quantidade de families ficar verbosa;
- controllers/notifiers crescerem;
- o projeto ja estiver usando `freezed` ou `json_serializable`;
- houver ganho claro de ergonomia com parametros nomeados em providers gerados.

## Modelo Mental

Riverpod deve ser usado como:

- cache declarativo de dados;
- mecanismo de injecao de dependencia;
- coordenador de estado de tela;
- ponte testavel entre UI, application services e repositories.

Providers nao devem virar uma segunda camada de dominio. Regra pura fica em domain/application; provider orquestra dependencias, lifecycle e estado apresentavel.

## ProviderScope E ProviderContainer

No app Flutter:

```dart
void main() {
  runApp(
    const ProviderScope(
      child: LuminisApp(),
    ),
  );
}
```

Em testes:

```dart
final container = ProviderContainer.test(
  overrides: [
    bookshelfRepositoryProvider.overrideWithValue(fakeRepository),
  ],
);
```

Regras:

- usar `ProviderScope` na raiz do app;
- usar `ProviderContainer.test()` em testes unitarios de providers/controllers;
- nao compartilhar `ProviderContainer` entre testes;
- usar overrides para mocks, fake APIs e cenarios de erro.

## Estrutura Por Feature

```text
features/<feature>/
  domain/
    entities/
    repositories/
    value_objects/
  application/
    services/
    use_cases/
  data/
    models/
    mappers/
    repositories/
  presentation/
    controllers/
    screens/
    state/
    widgets/
```

Providers devem ficar perto da responsabilidade que possuem:

- provider de repository: `data` ou `application`, conforme fronteira adotada pela feature;
- provider de use case/service: `application`;
- provider de controller: `presentation/controllers`;
- provider derivado de UI: `presentation/state`.

Evitar arquivo gigante `providers.dart` global. Usar barrels somente quando ajudarem importacao sem esconder ownership.

## Tipos De Provider

Usar `Provider<T>` para:

- repositories;
- clients;
- services;
- valores derivados sincronos;
- configuracoes.

Usar `FutureProvider<T>` para:

- consultas assicronas simples sem comandos de tela;
- dados read-only que podem ser recarregados com invalidacao.

Usar `StreamProvider<T>` para:

- dados reativos de backend ou armazenamento local;
- eventos continuos.

Usar `NotifierProvider<Notifier, State>` para:

- estado mutavel sincrono;
- filtros, selecoes, formulario simples;
- comandos que alteram estado local.

Usar `AsyncNotifierProvider<Notifier, State>` para:

- estado de tela assincrono;
- comandos que fazem chamada de repository/API;
- fluxos com loading/data/error.

Nao usar provider complexo quando uma funcao pura ou value object resolve.

## Padrao De Repository

Contrato no dominio:

```dart
abstract interface class BookshelfRepository {
  Future<List<BookshelfItem>> listItems();
}
```

Provider da implementacao:

```dart
final bookshelfRepositoryProvider = Provider<BookshelfRepository>((ref) {
  return MockBookshelfRepository();
});
```

Regras:

- mock e API real implementam o mesmo contrato;
- widget nunca instancia repository;
- controller/use case recebe repository via `ref.watch` ou provider de service;
- troca de ambiente deve acontecer com override ou provider dedicado.

## Padrao De Controller Com AsyncNotifier

```dart
final bookshelfControllerProvider =
    AsyncNotifierProvider<BookshelfController, List<BookshelfItem>>(
  BookshelfController.new,
);

class BookshelfController extends AsyncNotifier<List<BookshelfItem>> {
  @override
  Future<List<BookshelfItem>> build() async {
    final repository = ref.watch(bookshelfRepositoryProvider);
    return repository.listItems();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(bookshelfRepositoryProvider);
      return repository.listItems();
    });
  }
}
```

Regras:

- `build` monta o estado inicial;
- comandos publicos expressam intencao da UI;
- usar `AsyncValue.guard` para traduzir excecoes em estado de erro;
- nao expor repository para widget;
- nao colocar regra de negocio de leitura/metas dentro do widget.

## Consumo Em Widgets

Preferir `ConsumerWidget` para telas sem lifecycle local.

```dart
class BookshelfScreen extends ConsumerWidget {
  const BookshelfScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(bookshelfControllerProvider);

    return switch (items) {
      AsyncData(:final value) when value.isEmpty => const EmptyBookshelfView(),
      AsyncData(:final value) => BookshelfList(items: value),
      AsyncError() => const BookshelfErrorView(),
      _ => const BookshelfLoadingView(),
    };
  }
}
```

Usar:

- `ref.watch` em build para dados que atualizam UI;
- `ref.read(provider.notifier)` em callbacks;
- `ref.listen` para efeitos pontuais de UI.

Exemplo de callback:

```dart
onPressed: () {
  ref.read(bookshelfControllerProvider.notifier).refresh();
}
```

Evitar:

- `ref.read` em build para dados que devem reconstruir a tela;
- chamada de API direta no `onPressed`;
- regra de negocio em widget;
- provider lido em widget sem estado visual de loading/error.

## AsyncValue E Estado De Tela

Para dados assincronos, UI deve tratar:

- loading;
- data;
- empty, quando lista vazia tiver significado;
- error;
- refreshing/reloading quando a experiencia exigir diferenciar.

Para formularios ou comandos com multiplos campos, criar state proprio:

```dart
class ReadingProgressState {
  const ReadingProgressState({
    required this.currentPage,
    required this.isSubmitting,
    this.errorMessage,
  });

  final int? currentPage;
  final bool isSubmitting;
  final String? errorMessage;
}
```

Nao forcar tudo em `AsyncValue` se o estado de UI tiver varios campos independentes.

## Families

Usar `family` para providers parametrizados por:

- `bookId`;
- `bookshelfItemId`;
- `readingGoalId`;
- termo de busca;
- filtro de estante.

Exemplo:

```dart
final bookDetailProvider = FutureProvider.autoDispose.family<BookDetail, String>((ref, bookId) async {
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.getBookDetail(bookId);
});
```

Regras:

- parametros de family precisam ter `==`/`hashCode` estaveis;
- evitar passar `List`, `Map` mutavel ou objeto sem igualdade correta;
- preferir value object imutavel para filtros compostos;
- habilitar `autoDispose` para families de tela/busca para evitar cache infinito por parametro.

## Auto Dispose E Lifecycle

Usar `autoDispose` para:

- busca conforme digita;
- detalhes abertos temporariamente;
- telas de formulario;
- providers com parametro de rota;
- recursos que precisam liberar stream/controller.

Manter vivo (`keepAlive`) para:

- sessao autenticada;
- tema/configuracao;
- repositories;
- cache que deve sobreviver a navegacao entre abas.

Usar `ref.onDispose` para liberar recursos:

```dart
final searchProvider = FutureProvider.autoDispose.family<SearchResult, String>((ref, query) async {
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  final repository = ref.watch(catalogRepositoryProvider);
  return repository.search(query, cancelToken: cancelToken);
});
```

## Overrides

Usar overrides para:

- testes unitarios;
- widget tests;
- mocks de desenvolvimento;
- trocar API real por fake;
- simular usuario autenticado/desautenticado.

Exemplo:

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(fakeAuthRepository),
    ],
    child: const LuminisApp(),
  ),
);
```

Nao criar `if (mock)` dentro de widget ou controller. Trocar implementacao pelo container/scope.

## ProviderObserver

Usar `ProviderObserver` para debugging local ou analytics tecnico.

Regras:

- nunca logar senha, token, email sensivel ou conteudo privado de leitura/resenha;
- em producao, logs devem ser sanitizados;
- nomear providers manuais quando isso ajudar debugging.

## select E Performance

Usar `select` apenas quando houver indicio real de rebuild desnecessario.

Exemplo:

```dart
final displayName = ref.watch(profileProvider.select((profile) => profile.displayName));
```

Regras:

- nao otimizar antes de medir ou perceber problema claro;
- preferir dividir widgets pequenos antes de espalhar `select`;
- usar `select` em componentes muito reutilizados ou telas densas.

## Integracao Com go_router

Quando a navegacao depender de auth:

- estado de auth pertence ao Riverpod;
- router le estado ja carregado;
- redirect nao chama repository/API;
- criar ponte `Listenable` se `go_router` precisar reavaliar redirect quando auth mudar;
- usar a skill `luminis-go-router-agent` para detalhes de rota.

## Testes

Unit test de provider/controller:

```dart
void main() {
  test('loads bookshelf items', () async {
    final repository = FakeBookshelfRepository(items: [sampleItem]);
    final container = ProviderContainer.test(
      overrides: [
        bookshelfRepositoryProvider.overrideWithValue(repository),
      ],
    );

    final result = await container.read(bookshelfControllerProvider.future);

    expect(result, [sampleItem]);
  });
}
```

Widget test:

```dart
testWidgets('shows empty bookshelf', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        bookshelfRepositoryProvider.overrideWithValue(FakeBookshelfRepository.empty()),
      ],
      child: const LuminisApp(),
    ),
  );

  expect(find.text('Sua estante esta vazia'), findsOneWidget);
});
```

Regras:

- cada teste cria seu proprio `ProviderContainer.test()` ou `ProviderScope`;
- testar erro de repository;
- testar loading/data/empty/error quando a tela tiver esses estados;
- preferir teste de dominio sem Flutter para regra pura.

## Nao Fazer

- Nao instanciar repository diretamente dentro de widget.
- Nao chamar API diretamente dentro de widget.
- Nao guardar regra de negocio em `onPressed`.
- Nao usar provider global sem ownership claro.
- Nao acoplar mock a UI de forma que impeca API real depois.
- Nao criar abstracao generica antes de repeticao real.
- Nao usar `StateNotifier` como padrao novo sem motivo; preferir `Notifier`/`AsyncNotifier` em Riverpod 3.x.
- Nao ativar Mutations, Offline persistence ou APIs experimentais sem decisao registrada.
- Nao usar scoping avancado para resolver problema simples de arquitetura.

## Checklist De Implementacao

- Confirmar versao resolvida no `pubspec.lock`.
- Confirmar se a feature precisa de provider simples, async, notifier ou family.
- Criar contrato de repository antes da implementacao concreta.
- Injetar repository por provider.
- Manter regra pura fora de widget/controller quando pertencer ao dominio.
- Tratar loading, data, empty e error.
- Usar `autoDispose` em families temporarias.
- Usar overrides nos testes.
- Rodar `flutter analyze`.
- Rodar testes de providers/controllers com `ProviderContainer.test()`.
