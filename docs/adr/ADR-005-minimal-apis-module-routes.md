# ADR-005 - Minimal APIs Com Rotas Por Modulo

Status: Aceita como experimento controlado

## Contexto

O backend sera um monolito modular em .NET/ASP.NET Core. Existe preferencia por organizacao clara e fronteiras explicitas entre modulos. Minimal APIs podem reduzir cerimonia, mas tambem podem prejudicar clareza se as rotas ficarem concentradas em `Program.cs` ou se lambdas acumularem regra de negocio.

## Decisao

Usar Minimal APIs inicialmente, como experimento controlado, com rotas organizadas por modulo e agregadas por um arquivo de roteamento central.

`Program.cs` nao deve registrar endpoints individuais. Ele deve apenas configurar a aplicacao e chamar o agregador de rotas.

Estrutura conceitual:

```text
src/
  Luminis.Api/
    Program.cs
    Routing/
      ModuleRoutes.cs

  Luminis.Modules.Bookshelf/
    Api/
      BookshelfRoutes.cs
      Requests/
      Responses/

  Luminis.Modules.Catalog/
    Api/
      CatalogRoutes.cs
      Requests/
      Responses/
```

## Exemplo conceitual

`Program.cs`:

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddLuminisModules(builder.Configuration);

var app = builder.Build();

app.MapLuminisRoutes();

app.Run();
```

Agregador:

```csharp
public static class ModuleRoutes
{
    public static IEndpointRouteBuilder MapLuminisRoutes(this IEndpointRouteBuilder app)
    {
        app.MapCatalogRoutes();
        app.MapBookshelfRoutes();
        app.MapReadingRoutes();

        return app;
    }
}
```

Modulo:

```csharp
public static class BookshelfRoutes
{
    public static IEndpointRouteBuilder MapBookshelfRoutes(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/bookshelf")
            .WithTags("Bookshelf");

        group.MapGet("/", GetBookshelfAsync);
        group.MapPost("/", AddToBookshelfAsync);

        return app;
    }
}
```

## Regras

- `Program.cs` nao registra endpoints individuais.
- Cada modulo expoe `Map{Module}Routes`.
- `ModuleRoutes` conhece os modulos; modulos nao devem conhecer rotas de outros modulos.
- Endpoints devem ser finos.
- Endpoints nao devem conter regra de negocio.
- Endpoints chamam Application services/use cases.
- Requests e responses HTTP ficam em `Api/Requests` e `Api/Responses`.
- Validacao deve sair do lambda quando crescer.
- Autorizacao tecnica pode ser aplicada em rotas/grupos.
- Autorizacao de negocio fica em Application/Domain.

## Criterios de revisao

Esta decisao deve ser revista se:

- Arquivos de rotas ficarem grandes demais.
- Testabilidade piorar.
- OpenAPI/Swagger ficar inconsistente.
- Validações e filtros ficarem repetitivos.
- Controllers oferecerem clareza melhor para o time.

## Alternativas consideradas

### Controllers

Mais familiares e estruturados, mas adicionam mais cerimonia. Permanecem como alternativa se Minimal APIs nao trouxerem ganho real.

### Endpoints no Program.cs

Rejeitado por prejudicar modularidade e legibilidade.

## Consequencias

- Ganhamos experiencia real com Minimal APIs.
- Mantemos `Program.cs` limpo.
- Preservamos rotas por modulo.
- A decisao continua reversivel.
