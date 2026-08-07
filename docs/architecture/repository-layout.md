# Layout Do Repositorio

Status: aprovado para preparacao inicial.

O repositorio deve manter documentacao, backend e frontend separados desde o inicio, sem implicar microservicos.

## Estrutura aprovada

```text
luminis/
  docs/
  backend/
  frontend/
```

## Responsabilidades

### docs/

Fonte de verdade para produto, arquitetura, regras de negocio, contratos, schema, RAG e UX.

### backend/

Raiz futura da solucao .NET, projetos por modulo, testes e migrations DbUp.

Estrutura futura candidata:

```text
backend/
  Luminis.sln
  src/
  tests/
  database/
    migrations/
```

### frontend/

Raiz futura do app Flutter.

Estrutura futura candidata:

```text
frontend/
  luminis_app/
    pubspec.yaml
    lib/
    test/
```

## Decisoes

- O Flutter antigo criado na raiz foi removido.
- O novo Flutter deve ser criado futuramente dentro de `frontend/luminis_app`.
- O backend deve ser criado futuramente dentro de `backend`.
- Nenhum projeto de codigo deve ser criado antes da proxima decisao explicita.
