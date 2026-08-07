# Arquitetura Backend

Status: Aprovada para direcao inicial.

## Decisao principal

O backend do Luminis sera um monolito modular em .NET/ASP.NET Core, com deploy unico e projetos separados por modulo de negocio.

Referencia normativa:
- `docs/adr/ADR-003-backend-modular-monolith-dotnet.md`

## Stack

- ASP.NET Core.
- PostgreSQL.
- Dapper.
- DbUp para migrations SQL.
- SQL explicito.
- Sem Entity Framework no MVP.
- Sem CQRS formal no MVP.
- Sem Hangfire/jobs dedicados no MVP.

## Estrutura conceitual

```text
backend/
  Luminis.sln
  src/
    Luminis.Api/
    Luminis.SharedKernel/
    Luminis.Modules.Catalog/
      Domain/
      Application/
      Infrastructure/
      Api/
    Luminis.Modules.Bookshelf/
      Domain/
      Application/
      Infrastructure/
      Api/
    Luminis.Modules.Reading/
      Domain/
      Application/
      Infrastructure/
      Api/
    Luminis.Modules.Goals/
    Luminis.Modules.Reviews/
    Luminis.Modules.Social/
    Luminis.Modules.Groups/
    Luminis.Modules.Recommendations/
    Luminis.Database/
```

## Modulos do MVP

Referencia:
- `docs/architecture/backend-mvp-modules.md`

Entram no primeiro backend:
- `Luminis.Api`
- `Luminis.SharedKernel`
- `Luminis.Database`
- `Luminis.Modules.Identity`
- `Luminis.Modules.Catalog`
- `Luminis.Modules.Bookshelf`
- `Luminis.Modules.Reading`
- `Luminis.Modules.Goals`

Ficam pos-MVP:
- `Luminis.Modules.Reviews`
- `Luminis.Modules.Social`
- `Luminis.Modules.Groups`
- `Luminis.Modules.Recommendations`
- `Luminis.Modules.Notifications`
- `Luminis.Modules.Moderation`

## Minimal APIs

Referencia normativa:
- `docs/adr/ADR-005-minimal-apis-module-routes.md`

Minimal APIs serao usadas inicialmente como experimento controlado.

Regras:
- `Program.cs` nao registra endpoints individuais.
- Rotas ficam em arquivos dedicados por modulo.
- `Luminis.Api/Routing/ModuleRoutes.cs` agrega as rotas.
- Endpoints chamam Application services/use cases.
- A decisao pode ser revista se Controllers se mostrarem mais claros.

## Responsabilidades por pasta

### Domain

Entidades, value objects, regras de negocio puras e comportamentos do dominio.

### Application

Casos de uso, servicos de aplicacao, validacao de comandos e orquestracao.

### Infrastructure

Repositorios, Dapper, SQL, integracoes externas, providers e detalhes tecnicos.

### Api

Endpoints, requests/responses HTTP e composicao de rotas do modulo.

Para detalhes do padrao interno de modulos, consulte `docs/architecture/backend-module-pattern.md`.

## Principios

- Endpoints finos.
- SQL fora de endpoints.
- Regras de negocio fora de controllers/endpoints.
- Modulos nao devem atravessar fronteiras internas sem contrato.
- SharedKernel deve ser pequeno e estavel.
- Otimizacoes estruturais devem nascer de medicao.

## Pipeline HTTP

Referencia normativa:
- `docs/adr/ADR-004-auth-authorization-error-pipeline.md`

Ordem conceitual:

```text
Correlation/Request Id
Exception handling
Logging/observability
Authentication
Authorization
Module routes
```

Diretrizes:
- Login com Google e o caminho inicial priorizado para usuarios Android.
- Backend deve manter identidade interna propria do Luminis.
- Autorizacao tecnica fica no pipeline/policies.
- Autorizacao de negocio fica nos modulos.
- Erros devem ter codigo estavel e `traceId`.

## Fora do MVP

- Microservicos.
- CQRS formal.
- Event sourcing.
- Job processor dedicado.
- Mensageria distribuida.
