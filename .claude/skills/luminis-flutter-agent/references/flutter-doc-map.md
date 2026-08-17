# Mapa Flutter Do Luminis

Use este mapa para selecionar a documentacao antes de implementar. Leia apenas as fontes relacionadas a tarefa.

## Autoridade Das Fontes

1. Pedido explicito atual e ADR aplicavel.
2. Produto e rotas aprovadas: `docs/product/business-rules.md`, `docs/product/features/` e `docs/architecture/navigation.md`.
3. Decisoes tecnicas: `docs/architecture/` e `docs/engineering/`.
4. Especificacao de prototipo: `docs/ux/flutter-prototype-handoff.md`, `docs/ux/prototype-screens.md` e `docs/ux/design-system.md`.
5. Documentos marcados como proposta, candidato ou direcao inicial servem apenas como contexto; nao substituem decisao aprovada.

Encaminhe conflitos entre fontes aprovadas para produto ou UX antes de codificar.

## Arquitetura Flutter

- Arquitetura principal: `docs/architecture/flutter-architecture.md`
- Navegacao: `docs/architecture/navigation.md`
- Estado: `docs/architecture/state-management.md`
- Dependencias Flutter: `docs/architecture/flutter-dependencies.md`
- Layout do repositorio: `docs/architecture/repository-layout.md`
- Estilo de codigo: `docs/engineering/coding-style.md`
- Politica de dependencias: `docs/engineering/dependency-policy.md`
- Estrategia de testes: `docs/engineering/testing-strategy.md`
- Observabilidade: `docs/engineering/observability.md`
- Seguranca: `docs/architecture/security.md`
- Cenarios de QA: `docs/qa/test-scenarios.md`

## UX Para Implementar

- Handoff do prototipo: `docs/ux/flutter-prototype-handoff.md`
- Prototipos de telas: `docs/ux/prototype-screens.md`
- Design system: `docs/ux/design-system.md`
- Estados vazios: `docs/ux/empty-states.md`
- Estados de erro: `docs/ux/error-states.md`
- Acessibilidade: `docs/ux/accessibility.md`

Consultar `docs/ux/information-architecture.md` e `docs/ux/navigation.md` somente como contexto: ambos contem direcoes candidatas e nao definem as abas aprovadas do MVP.

## Produto Que Pode Impactar Codigo

- Regras de negocio: `docs/product/business-rules.md`
- MVP: `docs/product/mvp.md`
- Estante: `docs/product/features/bookshelf.md`
- Progresso de leitura: `docs/product/features/reading-progress.md`
- Metas: `docs/product/features/goals.md`
- Busca: `docs/product/features/search-and-discovery.md`
- Perfil: `docs/product/features/profile.md`
- Privacidade e permissoes: `docs/product/business/permissions-and-privacy.md`

## Contratos Futuros

- Contratos backend: `docs/architecture/backend-contracts.md`
- Modelo de dominio: `docs/architecture/domain-model.md`
- Entidades/schema: `docs/data/entities.md`, `docs/data/database-schema-mvp.md`

## Fronteira De Mock HTTP

- Decisao de usar `json-server` como fronteira HTTP de mock: `docs/adr/ADR-009-json-server-contract-mock-boundary.md`

## Checklist Antes De Codar

- Confirmar se o pedido e prototipo mockado ou codigo definitivo.
- Verificar se `frontend/luminis_app` ja existe e qual estrutura foi criada.
- Usar dependencias aprovadas antes de adicionar novas.
- Manter mocks substituiveis por repositorios/API depois.
- Para navegacao, usar `luminis-go-router-agent`.
- Para estado/DI, usar `luminis-riverpod-agent`.
- Para regra, escopo ou conflito de produto, usar `luminis-product-agent`.
- Para interacao, hierarquia, copy ou decisao visual incompleta, usar `luminis-ux-agent`.
