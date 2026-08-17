/// Falhas de domínio para a fronteira HTTP compartilhada (ADR-009, ADR-010).
///
/// `ApiClient` converte respostas HTTP e falhas de rede nestes tipos antes
/// de propagar para repositories/`application`/`presentation`. Nenhum tipo
/// aqui carrega stack trace, corpo bruto da resposta ou dado sensível do
/// usuário (senha, token, email, texto de resenha etc.) — apenas o que o
/// envelope de erro do backend já expõe com segurança: `code`, `message` e
/// `traceId`.
///
/// `sealed` permite que controllers tratem cada falha de forma exaustiva
/// (`switch`) sem depender de checagem de tipo solta.
sealed class ApiFailure implements Exception {
  const ApiFailure();

  /// Mensagem já segura para apoiar a mensagem exibida ao usuário. A
  /// decisão final de copy/tradução de UI pertence à presentation.
  String get message;

  @override
  String toString() => 'ApiFailure($message)';
}

/// Falha de rede/conectividade antes de qualquer resposta do servidor
/// (timeout, host inalcançável, socket). Não existe envelope de erro do
/// backend para preservar aqui.
final class ApiNetworkFailure extends ApiFailure {
  const ApiNetworkFailure(this.message);

  @override
  final String message;
}

/// Falha construída a partir de uma resposta HTTP com o envelope de erro
/// padrão do Luminis: `code`, `message`, `traceId` e `errors` (ver
/// `docs/architecture/backend-contracts.md`).
sealed class ApiResponseFailure extends ApiFailure {
  const ApiResponseFailure({
    required this.code,
    required this.message,
    required this.statusCode,
    this.traceId,
  });

  /// Código estável do backend (ex.: `auth.invalid_credentials`).
  final String code;

  @override
  final String message;

  /// Status HTTP da resposta.
  final int statusCode;

  /// Identificador de correlação para suporte, quando o backend enviar.
  final String? traceId;
}

/// Erro de validação (`400`) com detalhamento por campo.
final class ApiValidationFailure extends ApiResponseFailure {
  const ApiValidationFailure({
    required super.code,
    required super.message,
    required super.statusCode,
    required this.fieldErrors,
    super.traceId,
  });

  /// Mapa de campo para lista de mensagens de erro (`errors` do envelope).
  final Map<String, List<String>> fieldErrors;
}

/// Autenticação ausente ou inválida (`401`).
final class ApiUnauthorizedFailure extends ApiResponseFailure {
  const ApiUnauthorizedFailure({
    required super.code,
    required super.message,
    required super.statusCode,
    super.traceId,
  });
}

/// Recurso não encontrado (`404`).
final class ApiNotFoundFailure extends ApiResponseFailure {
  const ApiNotFoundFailure({
    required super.code,
    required super.message,
    required super.statusCode,
    super.traceId,
  });
}

/// Conflito de estado (`409`), ex.: item duplicado ou email já usado.
final class ApiConflictFailure extends ApiResponseFailure {
  const ApiConflictFailure({
    required super.code,
    required super.message,
    required super.statusCode,
    super.traceId,
  });
}

/// Serviço ou provedor indisponível (`503`).
final class ApiServiceUnavailableFailure extends ApiResponseFailure {
  const ApiServiceUnavailableFailure({
    required super.code,
    required super.message,
    required super.statusCode,
    super.traceId,
  });
}

/// Erro HTTP recebido, mas sem um tipo mais específico mapeado acima.
final class ApiUnknownFailure extends ApiResponseFailure {
  const ApiUnknownFailure({
    required super.code,
    required super.message,
    required super.statusCode,
    super.traceId,
  });
}
