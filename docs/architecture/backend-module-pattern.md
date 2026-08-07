# Padrao De Modulo Backend

Status: Aprovado para direcao inicial.

## Objetivo

Definir a organizacao interna de cada modulo do backend .NET.

## Estrutura

```text
Luminis.Modules.{Module}/
  Api/
    {Module}Routes.cs
    Requests/
    Responses/
  Application/
    Services/
    UseCases/
    Abstractions/
  Domain/
    Entities/
    ValueObjects/
    Errors/
  Infrastructure/
    Repositories/
    Sql/
    External/
```

## Responsabilidades

### Api

- Registrar rotas do modulo.
- Definir requests/responses HTTP.
- Aplicar autorizacao tecnica.
- Converter request HTTP em entrada de Application.
- Converter resultado de Application em resposta HTTP.

Nao deve:
- Executar SQL.
- Aplicar regra de negocio complexa.
- Acessar infraestrutura diretamente quando houver service/use case.

### Application

- Executar casos de uso.
- Orquestrar repositorios e servicos.
- Validar entrada de aplicacao.
- Aplicar autorizacao de negocio.
- Retornar `Result` para erros esperados.

### Domain

- Concentrar entidades, value objects e regras puras.
- Nao depender de Dapper, HTTP, banco ou provedores externos.

### Infrastructure

- Implementar repositorios.
- Conter SQL usado pelo Dapper.
- Integrar com provedores externos.
- Tratar detalhes tecnicos.

## Padrao de arquivos por caso de uso

Para fluxos relevantes, preferir estrutura por caso de uso:

```text
Application/
  UseCases/
    AddWorkToShelf/
      AddWorkToShelfCommand.cs
      AddWorkToShelfHandler.cs
      AddWorkToShelfResult.cs
```

O nome `Handler` aqui nao implica CQRS formal. E apenas uma classe de aplicacao para executar um caso de uso.

## Repositorios

Repositorios devem ficar em `Infrastructure`.

SQL pode ficar:
- inline em constantes privadas quando curto;
- em arquivos `.sql` quando crescer;
- em classe dedicada por consulta quando houver reutilizacao real.

## Migrations

Migrations de schema nao devem ficar espalhadas dentro de repositorios. Elas devem ser versionadas no projeto `Luminis.Database`, conforme `docs/adr/ADR-006-database-migrations-dbup.md`.

Quando um modulo precisar alterar schema, a migration deve deixar claro o modulo afetado no nome ou pasta do script.

Padrao de nome:

```text
ddMMyyyyHHMMSS_<nome_descritivo>.sql
```

## Rotas

Cada modulo deve expor um metodo:

```csharp
public static IEndpointRouteBuilder Map{Module}Routes(this IEndpointRouteBuilder app)
```

O agregador de rotas do projeto `Luminis.Api` chama esses metodos.

## Testes

- Domain: testes unitarios puros.
- Application: testes de caso de uso com repositorios fake ou test doubles.
- Infrastructure: testes de integracao com PostgreSQL quando necessario.
- Api: testes de contrato/endpoints quando fluxo for critico.
