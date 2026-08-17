/// Configuração compartilhada da fronteira HTTP consumida pelo app.
///
/// Nenhuma feature deve montar ou apontar uma base URL própria; toda
/// comunicação HTTP deve passar pelo [ApiConfig.baseUrl] (ADR-009, ADR-010).
/// Nenhum código aqui referencia `json-server`, `db.json` ou detalhes do
/// mock local — apenas a URL configurável do serviço.
abstract final class ApiConfig {
  /// Base URL do backend consumido pelo app (hoje, `backend/mock-api/`
  /// executando localmente; futuramente, a API .NET real).
  ///
  /// Configurável em tempo de build/execução via
  /// `--dart-define=API_BASE_URL=http://<host>:<porta>/api`, sem alterar
  /// código. O padrão assume o mock local rodando em `localhost:3000`.
  ///
  /// Observação: emuladores Android não enxergam `localhost` do host; nesse
  /// caso, informe `--dart-define=API_BASE_URL=http://10.0.2.2:3000/api`.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  /// Timeout padrão de requisições HTTP.
  static const Duration requestTimeout = Duration(seconds: 10);
}
