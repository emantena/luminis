# Arquitetura Flutter

Status: proposta inicial.

## Objetivo

Construir um app Flutter mobile-first, com dominio legivel, testavel e preparado para evoluir para backend real sem reescrever a interface.

## Estrutura sugerida

```text
lib/
  main.dart
  app/
    luminis_app.dart
    router/
    theme/
  features/
    auth/
    bookshelf/
    books/
    goals/
    profile/
    reading/
    search/
  shared/
    domain/
    infrastructure/
    presentation/
```

## Camadas

- `domain`: entidades, value objects, regras puras e contratos.
- `infrastructure`: implementacoes concretas de repositorios, APIs, cache e storage.
- `presentation`: widgets, controllers/view models e estados de tela.

## Features iniciais recomendadas

1. Estante.
2. Busca/catalogo.
3. Detalhe do livro.
4. Leitura atual.
5. Progresso de leitura.
6. Plano de leitura e ritmo.
7. Metas.
8. Perfil simples.

## Estado

Status: aprovado para MVP.

O MVP deve usar Riverpod como estrategia principal de estado.

Racional:
- O app tera dados compartilhados entre auth, estante, leitura atual, progresso e metas.
- O prototipo deve poder evoluir para implementacao real sem trocar toda a organizacao de estado.
- Riverpod oferece boa composicao para dados mockados, repositorios e chamadas futuras de API.

Diretrizes:
- Providers devem ficar proximos da feature quando forem especificos.
- Providers compartilhados, como sessao autenticada, devem ficar em `shared` ou `app`.
- Repositorios mockados devem implementar contratos que possam ser substituidos por APIs reais depois.
- Estado de tela deve representar carregamento, sucesso vazio, sucesso com dados e erro.
- Evitar logica de negocio relevante dentro de widgets.

## Navegacao

Status: aprovado para MVP.

O MVP deve usar `go_router`, conforme `docs/architecture/navigation.md`.

A navegacao deve separar fluxo publico de autenticacao e shell autenticado com abas principais:
- Estante.
- Buscar.
- Leitura.
- Metas.
- Perfil.

## Persistencia

Decisao em aberto. Para prototipo, dados mockados em memoria. Para uso local offline, considerar SQLite/Drift ou Isar. Para produto com sincronizacao, definir backend antes de acoplar o app.

## Tema visual

O Luminis deve ter identidade propria. Como direcao inicial:

- Interface clara, acolhedora e legivel.
- Foco em capas de livros, progresso e atividade social.
- Evitar copiar paleta, layout ou linguagem visual do Skoob.
- Componentes compactos o suficiente para uso diario, sem parecer landing page.

## Testes

- Testes unitarios para regras de dominio.
- Testes de widget para componentes e fluxos principais.
- Testes de integracao quando houver persistencia, autenticacao ou navegacao critica.
