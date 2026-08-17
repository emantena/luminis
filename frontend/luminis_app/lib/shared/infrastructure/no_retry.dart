/// Desliga o retry automático de providers assíncronos do Riverpod 3.x.
///
/// Riverpod 3.x tenta novamente, com backoff exponencial (até 10 tentativas,
/// ver `ProviderContainer.defaultRetry` no pacote `riverpod`), qualquer erro
/// que não seja `Error` nem `ProviderException`. Como `ApiFailure`
/// (`api_exception.dart`) implementa `Exception`, ela seria retentada
/// silenciosamente por padrão — atrasando (e em testes síncronos,
/// mascarando) o estado de erro que a UI precisa mostrar imediatamente via
/// `AsyncValue`, conforme `references/riverpod-3.md`.
///
/// Usar em todo `FutureProvider`/`AsyncNotifierProvider` (e suas variantes
/// `family`/`autoDispose`) cujo `build`/computação dependa de um repository
/// desta app: `retry: noRetry`. Não é necessário em `Notifier`/
/// `NotifierProvider` síncronos que já capturam `ApiFailure` internamente
/// (ex.: `LoginController`, `BookSearchController`) — o retry automático só
/// atua quando a própria computação do provider lança sem ser capturada.
Duration? noRetry(int retryCount, Object error) => null;
