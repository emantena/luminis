# Politica De Dependencias

Status: proposta inicial.

## Principios

- Adicionar dependencia apenas quando reduzir complexidade real.
- Preferir bibliotecas maduras e ativas.
- Registrar decisoes estruturais em ADR.
- Evitar dependencia para utilidade trivial.

## Antes de adicionar

- Qual problema resolve?
- Existe recurso nativo suficiente?
- Qual impacto em build, tamanho e manutencao?
- A biblioteca e mantida?

## Dependencias estruturais

Dependencias de estado, navegacao, banco local, cliente HTTP, autenticacao e analytics devem ser registradas em `docs/adr/`.

## Backend

Decisoes aprovadas:
- PostgreSQL como banco principal.
- Dapper para acesso a dados.
- DbUp para migrations SQL.
- Entity Framework fora do MVP.
- CQRS formal fora do MVP.
- Hangfire/jobs dedicados fora do MVP.

Novas dependencias de backend devem respeitar `docs/adr/ADR-003-backend-modular-monolith-dotnet.md`.
Migrations devem respeitar `docs/adr/ADR-006-database-migrations-dbup.md`.
