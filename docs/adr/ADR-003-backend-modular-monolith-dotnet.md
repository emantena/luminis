# ADR-003 - Backend Em Monolito Modular .NET

Status: Aceita

## Contexto

Luminis tera dominio com varios nucleos claros: catalogo, estante, leitura, metas, resenhas, social, grupos e recomendacoes. O produto ainda esta em descoberta, entao microservicos adicionariam custo operacional, distribuicao, observabilidade e complexidade antes de haver gargalo real.

Ao mesmo tempo, queremos fronteiras explicitas para evitar que regras de negocio se misturem e para manter uma visao clara de onde cada responsabilidade vive.

## Decisao

O backend do Luminis deve iniciar como monolito modular em .NET/ASP.NET Core, com deploy unico e projetos separados por modulo de negocio.

Estrutura conceitual:

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
```

## Stack inicial

- ASP.NET Core.
- PostgreSQL como banco principal.
- Dapper para acesso a dados.
- SQL explicito como padrao.
- Sem Entity Framework no MVP.
- Sem CQRS formal no MVP.
- Sem Hangfire ou processamento dedicado de jobs no MVP.

## Racional

- Monolito modular reduz custo operacional e acelera desenvolvimento inicial.
- Projetos por modulo deixam fronteiras de negocio mais visiveis.
- Camadas internas por pasta mantem dominio, aplicacao, infraestrutura e endpoints organizados.
- Dapper oferece controle claro sobre SQL, planos de execucao e indices.
- CQRS e jobs dedicados devem surgir de necessidade real, nao de antecipacao.
- A arquitetura favorece baixo acoplamento conceitual, sem fingir que ja existem microservicos.

## Dependencias desejadas

```text
Luminis.Api
  -> Luminis.Modules.*
  -> Luminis.SharedKernel

Luminis.Modules.*
  -> Luminis.SharedKernel

Dentro de cada modulo:
  Api -> Application
  Application -> Domain
  Infrastructure -> Application/Domain
  Domain -> SharedKernel
```

## Regras

- Um modulo nao deve acessar diretamente tabelas ou classes internas de outro modulo sem contrato explicito.
- Regras de negocio devem viver em `Domain` ou `Application`, nao em endpoints.
- SQL deve ficar em `Infrastructure` ou repositorios equivalentes.
- Endpoints devem ser finos e delegar comportamento para aplicacao.
- SharedKernel deve permanecer pequeno.

## Consequencias

- Mais projetos do que uma API simples por pastas.
- Fronteiras ficam mais claras desde o inicio.
- Ainda ha apenas um deploy e um banco principal.
- Extracao futura para servico separado continua possivel, mas nao e o objetivo inicial.
- Pode ser necessario adicionar testes de arquitetura para proteger dependencias entre modulos.

## Alternativas consideradas

### Microservicos desde o inicio

Rejeitado por custo operacional e ausencia de gargalos conhecidos.

### Um unico projeto ASP.NET Core por pastas

Mais simples, mas com fronteiras menos explicitas do que o desejado.

### Camadas globais

Projetos como `Domain`, `Application` e `Infrastructure` globais sao familiares, mas podem misturar dominios fortes como catalogo, leitura e grupos.

## Perguntas futuras

- Quais modulos entram no primeiro backend real?
- Como proteger dependencias entre modulos?
- Como versionar migrations SQL?
- Quando uma rotina assincrona justificara job processor?
