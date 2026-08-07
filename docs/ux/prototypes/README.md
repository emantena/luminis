# Prototipos MVP

Status: organizado para revisao e implementacao Flutter.

Este indice agrupa as telas e bottom sheets do prototipo MVP. A especificacao detalhada continua em `docs/ux/prototype-screens.md`; este arquivo serve como mapa rapido de navegacao visual.

Para implementacao Flutter, usar tambem `docs/ux/flutter-prototype-handoff.md`.

## Ordem Recomendada De Revisao

1. Entrada e shell autenticado.
2. Estante.
3. Busca e detalhe do livro.
4. Adicionar a estante.
5. Leitura e progresso.
6. Metas.
7. Perfil.

## Telas Por Fluxo

### Auth

| Tela | Rota | Tipo | Preview |
| --- | --- | --- | --- |
| Welcome | `/auth/welcome` | Publica | `auth-welcome-screen-preview.png` |

### Estante

| Tela | Rota | Tipo | Preview |
| --- | --- | --- | --- |
| Estante | `/bookshelf` | Aba | `bookshelf-screen-preview.png` |

### Busca E Catalogo

| Tela | Rota | Tipo | Preview |
| --- | --- | --- | --- |
| Buscar | `/search` | Aba | `search-screen-preview.png` |
| Detalhe do livro | `/books/:bookId` | Tela empilhada | `book-detail-screen-preview.png` |
| Adicionar a estante | Acionada por `/books/:bookId` | Bottom sheet | `add-to-bookshelf-bottom-sheet-preview.png` |
| Cadastro local | `/book-drafts/new` | Tela empilhada | `local-book-draft-screen-preview.png` |

### Leitura

| Tela | Rota | Tipo | Preview |
| --- | --- | --- | --- |
| Leitura | `/reading` | Aba | `reading-screen-preview.png` |
| Estado de leitura | `/reading/:bookshelfItemId` | Tela empilhada | `reading-state-screen-preview.png` |
| Registrar progresso | `/reading/:bookshelfItemId/progress/new` | Tela empilhada | `reading-progress-screen-preview.png` |
| Plano de leitura | `/reading/:bookshelfItemId/plan` | Tela empilhada | `reading-plan-screen-preview.png` |
| Voltar para Quero ler | Acionada por mudanca de status | Bottom sheet | `want-to-read-decision-bottom-sheet-preview.png` |

### Metas

| Tela | Rota | Tipo | Preview |
| --- | --- | --- | --- |
| Metas | `/goals` | Aba | `goals-screen-preview.png` |
| Criar meta | `/goals/new` | Tela empilhada | `create-goal-screen-preview.png` |
| Detalhe da meta | `/goals/:readingGoalId` | Tela empilhada | `goal-detail-screen-preview.png` |
| Editar meta | `/goals/:readingGoalId/edit` | Tela empilhada | `edit-goal-screen-preview.png` |

### Perfil

| Tela | Rota | Tipo | Preview |
| --- | --- | --- | --- |
| Perfil | `/profile` | Aba | `profile-screen-preview.png` |

## Telas Ainda Sem Preview Visual

Essas telas estao especificadas em `docs/ux/prototype-screens.md`, mas ainda nao possuem imagem de referencia:

- Auth detalhado: `/auth/login`, `/auth/register`, `/auth/forgot-password`, `/auth/reset-password`.
- Editar perfil: `/profile/edit`.

## Criterios Para Considerar Uma Tela Pronta Para Flutter

- Rota definida.
- Objetivo claro.
- Dados mockados identificados.
- Estados principais definidos.
- Acoes e navegacao apos acao definidas.
- Preview visual quando a tela tiver peso de UX relevante.
- Regras de negocio sensiveis referenciadas ou descritas.
