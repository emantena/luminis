# Mapa Flutter Do Luminis

Use este mapa para tarefas de implementacao Flutter.

## Arquitetura Flutter

- Arquitetura principal: `docs/architecture/flutter-architecture.md`
- Navegacao: `docs/architecture/navigation.md`
- Estado: `docs/architecture/state-management.md`
- Dependencias Flutter: `docs/architecture/flutter-dependencies.md`
- Layout do repositorio: `docs/architecture/repository-layout.md`
- Estilo de codigo: `docs/engineering/coding-style.md`
- Politica de dependencias: `docs/engineering/dependency-policy.md`
- Estrategia de testes: `docs/engineering/testing-strategy.md`

## UX Para Implementar

- Prototipos de telas: `docs/ux/prototype-screens.md`
- Design system: `docs/ux/design-system.md`
- Arquitetura de informacao: `docs/ux/information-architecture.md`
- Navegacao UX: `docs/ux/navigation.md`
- Estados vazios: `docs/ux/empty-states.md`
- Estados de erro: `docs/ux/error-states.md`
- Acessibilidade: `docs/ux/accessibility.md`

## Produto Que Pode Impactar Codigo

- Regras de negocio: `docs/product/business-rules.md`
- MVP: `docs/product/mvp.md`
- Estante: `docs/product/features/bookshelf.md`
- Progresso de leitura: `docs/product/features/reading-progress.md`
- Metas: `docs/product/features/goals.md`
- Busca: `docs/product/features/search-and-discovery.md`
- Perfil: `docs/product/features/profile.md`

## Contratos Futuros

- Contratos backend: `docs/architecture/backend-contracts.md`
- Modelo de dominio: `docs/architecture/domain-model.md`
- Entidades/schema: `docs/data/entities.md`, `docs/data/database-schema-mvp.md`

## Checklist Antes De Codar

- Confirmar se o pedido e prototipo mockado ou codigo definitivo.
- Verificar se `frontend/luminis_app` ja existe e qual estrutura foi criada.
- Usar dependencias aprovadas antes de adicionar novas.
- Manter mocks substituiveis por repositorios/API depois.
- Para navegacao, usar `luminis-go-router-agent`.
- Para estado/DI, usar `luminis-riverpod-agent`.
