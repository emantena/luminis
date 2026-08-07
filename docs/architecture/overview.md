# Visao Geral De Arquitetura

## Direcao

O Luminis deve crescer como aplicativo Flutter conectado a um backend em monolito modular .NET, com dominio explicito, documentacao viva e fronteiras claras por modulo de negocio.

## Prioridades tecnicas

- Clareza de dominio.
- Mudancas pequenas e testaveis.
- UI mobile-first.
- Baixo acoplamento com fonte de dados inicial.
- Preparacao para backend e sincronizacao futura.
- Catalogo proprio com provedores externos atras de uma camada de backend quando a feature amadurecer.
- Backend com deploy unico e projetos separados por modulo.

## Decisoes em aberto

- Gerenciamento de estado.
- Persistencia local.
- Autenticacao.
- Fonte de catalogo de livros.

## ADRs relacionadas

- `docs/adr/ADR-001-flutter-first.md`
- `docs/adr/ADR-002-book-catalog-provider-strategy.md`
- `docs/adr/ADR-003-backend-modular-monolith-dotnet.md`

## Documentos relacionados

- `docs/architecture/flutter-architecture.md`
- `docs/architecture/domain-model.md`
- `docs/architecture/state-management.md`
- `docs/architecture/navigation.md`
- `docs/architecture/persistence.md`
- `docs/architecture/backend-contracts.md`
- `docs/architecture/backend-architecture.md`
- `docs/architecture/backend-module-pattern.md`
- `docs/architecture/backend-mvp-modules.md`
