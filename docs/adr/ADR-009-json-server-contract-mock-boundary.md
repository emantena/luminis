# ADR-009 - Usar JSON Server Como Fronteira HTTP de Mock

Status: Aceita

## Contexto

O prototipo Flutter precisa percorrer os fluxos completos do MVP — autenticacao, catalogo, estante, leitura e metas — antes de o backend .NET estar disponivel. Esses fluxos ja possuem contratos HTTP previstos em `docs/architecture/backend-contracts.md`.

Mocks diretamente em widgets ou repositories Dart encurtariam a primeira entrega, mas nao validariam serializacao JSON, codigos de erro, rotas HTTP, estados de loading ou o encaixe entre o cliente e os contratos futuros. O projeto precisa de uma fronteira substituivel que permita exercitar esses comportamentos sem chamar provedores externos nem antecipar o backend de producao.

## Decisao

Criar um servico Node de desenvolvimento em `backend/mock-api/`, usando `json-server` como base de persistencia JSON e rotas REST simples.

O servico fica dentro de `backend/` porque representa a fronteira HTTP que sera substituida pelo backend .NET real (ADR-003) no mesmo local do repositorio, mantendo a raiz do projeto sem uma pasta de infraestrutura temporaria separada.

- O servico expoe apenas rotas `/api/...` previstas nos contratos do Luminis.
- `db.json` e fixtures JSON definem o estado inicial e cenarios controlados; dados permanecem em memoria durante a execucao local.
- Middlewares e rotas customizadas simulam comandos e regras observaveis pelo cliente, como autenticacao mockada, duplicidade de item ativo, validacao de progresso, transicoes de status, planos e calculos de metas.
- Respostas de erro seguem o envelope `code`, `message`, `traceId` e `errors` definido para o backend.
- O Flutter depende de repositories, DTOs, mappers e uma base URL configuravel. Ele nao referencia `json-server`, `db.json` ou detalhes do mock.
- O servico e exclusivo para desenvolvimento, demonstracao e testes de integracao locais; nao e backend de producao, fonte de verdade de regra de negocio nem integracao com provedores externos.
- A primeira instalacao deve fixar uma versao nao beta do `json-server` no `package-lock.json`. A linha 1.x so pode ser adotada apos validar suas mudancas de compatibilidade.

## Consequencias

### Positivas

- O Flutter valida a fronteira HTTP e os contratos JSON desde o inicio.
- Fluxos completos podem alterar estado entre telas sem dados acoplados a widgets.
- Cenarios de sucesso, vazio, validacao e erro tornam-se reproduziveis por fixture.
- A futura substituicao pelo backend .NET preserva a API consumida pelo Flutter e reduz retrabalho nos controllers e na UI.

### Custos E Limites

- Parte das regras de negocio visiveis precisara ser simulada em JavaScript; a implementacao definitiva continuara pertencendo ao backend .NET e ao dominio correspondente.
- Rotas fora do CRUD exigem middleware ou handlers customizados; `json-server` sozinho nao cobre o comportamento do MVP.
- O estado em memoria e local; nao representa concorrencia, autorizacao real, persistencia, seguranca ou disponibilidade de producao.
- O contrato mockado deve acompanhar mudancas aprovadas em `backend-contracts.md`.

## Alternativas Consideradas

### Mocks em memoria apenas no Flutter

Rejeitada para o prototipo integrado. Continua adequada em testes unitarios isolados, mas nao valida HTTP, JSON e erros de contrato.

### Aguardar o backend .NET

Rejeitada para o primeiro ciclo. Atrasaria a validacao de UX e navegacao, que devem acontecer antes da implementacao completa do backend.

### Consumir provedores de catalogo externos diretamente no Flutter

Rejeitada conforme ADR-002. Acoplaria o cliente a provedores, formatos, limites e credenciais que pertencem ao backend.

## Validacao E Evolucao

- Cada rota simulada deve ter fixture de sucesso e, quando aplicavel, fixture de erro ou validacao.
- Testes de integracao do Flutter devem percorrer ao menos login, busca, adicao a estante, registro de progresso e meta usando o servico local.
- A API .NET substitui o mock por rota, preservando paths, payloads, codigos de erro e contratos aprovados.
- Reavaliar a fronteira quando a API .NET cobrir os fluxos principais ou quando handlers customizados tornarem o `json-server` inadequado; nesse caso, migrar o mock para um servidor Node explicito sem alterar o contrato consumido pelo Flutter.

## Referencias

- `docs/architecture/backend-contracts.md`
- `docs/architecture/flutter-architecture.md`
- `docs/architecture/navigation.md`
- `docs/architecture/state-management.md`
- `docs/adr/ADR-002-book-catalog-provider-strategy.md`
- `docs/adr/ADR-004-auth-authorization-error-pipeline.md`
- `docs/data/seed-data.md`
- `docs/ux/flutter-prototype-handoff.md`
