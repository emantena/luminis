# ADR-006 - Migrations Com DbUp E SQL Versionado

Status: Aceita

## Contexto

O backend do Luminis usara PostgreSQL, Dapper e SQL explicito. Como nao usaremos Entity Framework no MVP, precisamos de uma estrategia de migrations que preserve visibilidade do SQL, seja simples de executar localmente e funcione bem em CI/deploy.

## Decisao

Usar DbUp para executar migrations SQL versionadas.

Criar um projeto dedicado para migrations:

```text
backend/
  src/
    Luminis.Database/
      Program.cs
      Scripts/
        06082026143000_create_identity.sql
        06082026143500_create_catalog.sql
        06082026144000_create_bookshelf.sql
```

Ou, se a quantidade crescer, organizar por modulo:

```text
Scripts/
  Identity/
    06082026143000_create_users.sql
  Catalog/
    06082026143500_create_works.sql
    06082026144000_create_editions.sql
  Bookshelf/
    06082026144500_create_bookshelf_items.sql
```

## Regras

- Migrations devem ser arquivos `.sql` versionados.
- Migrations devem seguir o padrao `ddMMyyyyHHMMSS_<nome_descritivo>.sql`.
- Scripts devem ser pequenos, revisaveis e ordenados.
- A ordenacao de execucao deve seguir o timestamp do nome do arquivo.
- DbUp deve registrar quais scripts ja foram executados.
- A API nao deve aplicar migrations automaticamente em producao.
- Migrations devem ser executadas por comando local, pipeline de CI ou etapa controlada de deploy.
- Alteracoes destrutivas devem ser explicitas e revisadas com cuidado.

## Comando conceitual

```text
dotnet run --project backend/src/Luminis.Database -- "<connection-string>"
```

## Racional

- Mantem SQL visivel e alinhado ao uso de Dapper.
- Facilita revisao de indices, constraints e planos de execucao.
- Evita dependencias de Entity Framework.
- Mantem migration fora do startup da API em producao.
- E simples para desenvolvimento local e CI.

## Alternativas consideradas

### FluentMigrator

Bom e maduro, mas incentiva migrations em C# fluent. Para o Luminis, SQL explicito e preferivel.

### Evolve

Boa alternativa baseada em scripts SQL, mas DbUp foi escolhido por encaixar bem com projeto console dedicado e fluxo .NET simples.

### Runner proprio

Evitaria dependencia externa, mas recriaria journaling, ordenacao e execucao segura de scripts sem necessidade.

## Perguntas futuras

- Scripts serao embutidos como recursos ou lidos do filesystem no deploy?
- Usaremos uma pasta unica ordenada ou pastas por modulo?
- Qual sera a politica para rollback?
- Como lidar com seeds iniciais?
