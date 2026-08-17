# ADR-010 - Usar O Pacote `http` Como Cliente HTTP Do Flutter

Status: Aceita

## Contexto

O ADR-009 define `mock-api/` (`json-server`) como fronteira HTTP de mock consumida pelo Flutter via repositories, DTOs, mappers e uma base URL configuravel. Nenhum pacote HTTP estava aprovado em `docs/architecture/flutter-dependencies.md`, o que bloqueava a implementacao de qualquer repository que fale com `mock-api/`. `docs/engineering/dependency-policy.md` exige que dependencias de cliente HTTP sejam registradas em ADR antes de uso.

O prototipo precisa apenas de requisicoes REST simples (GET/POST/PATCH/PUT/DELETE), envio e leitura de JSON, tratamento do envelope de erro `code/message/traceId/errors` e configuracao de base URL. Nao ha necessidade hoje de interceptors complexos, cancelamento avancado de requisicoes, upload multipart pesado ou cache HTTP nativo.

## Decisao

Adotar o pacote `http` (`^1.6.0`, mantido pelo time Dart) como cliente HTTP do Flutter.

- Toda comunicacao com `mock-api/` passa por repositories em `data/` que usam `http.Client` internamente; nenhuma feature ou widget referencia `http` diretamente.
- A base URL fica em configuracao compartilhada (`shared/infrastructure`), nunca hardcoded em repository ou widget.
- Erros de rede e HTTP sao convertidos para excecoes/tipos de dominio explicitos antes de chegar na presentation, preservando `traceId` quando util para suporte, sem expor detalhes internos ao usuario.
- Timeout, headers padrao e decodificacao JSON ficam centralizados em um cliente/base repository compartilhado para evitar duplicacao entre features.

## Consequencias

### Positivas

- Pacote mantido pelo time Dart, API estavel e amplamente documentada, sem dependencias transitivas pesadas.
- Suficiente para o escopo atual (REST simples contra `mock-api/`), sem trazer complexidade nao usada.
- Compativel com o SDK do projeto (`environment.sdk: ^3.12.2`; `http` exige Dart `^3.4.0`).

### Custos E Limites

- Sem suporte nativo a interceptors, retry automatico ou cache; se essas necessidades surgirem, a decisao devera ser revisada.
- Requer codigo manual para decodificacao/erro padronizados, centralizado no cliente compartilhado para nao se repetir por feature.

## Alternativas Consideradas

### `dio`

Rejeitada por ora. Traz interceptors, cancelamento e cache nativos que o prototipo nao usa; adicionaria superficie e dependencias transitivas sem reduzir complexidade real, contrariando `docs/engineering/dependency-policy.md`.

### Nenhum cliente HTTP; manter mocks em memoria no cliente indefinidamente

Rejeitada. Contraria o ADR-009, que exige validar a fronteira HTTP, serializacao JSON e contrato de erro desde o protototipo integrado.

## Referencias

- `docs/adr/ADR-009-json-server-contract-mock-boundary.md`
- `docs/engineering/dependency-policy.md`
- `docs/architecture/flutter-dependencies.md`
- `docs/architecture/backend-contracts.md`
