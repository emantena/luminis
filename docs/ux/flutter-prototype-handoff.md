# Handoff Para Prototipo Flutter

Status: pronto para iniciar prototipo com dados mockados.

Este documento orienta o `luminis-flutter-agent` na implementacao inicial do app Flutter. A fonte detalhada das telas continua em `docs/ux/prototype-screens.md`; este handoff concentra o que precisa entrar no primeiro ciclo de codigo.

## Objetivo Do Prototipo

Validar navegacao, hierarquia visual e fluxos principais do MVP usando dados mockados em memoria.

O prototipo deve provar:

- entrada no app;
- shell autenticado com abas;
- estante pessoal;
- busca e detalhe de livro;
- adicionar livro a estante;
- cadastro local privado;
- continuidade de leitura;
- registro de progresso;
- plano de leitura com ritmo sugerido;
- metas mensais/anuais;
- perfil simples.

## Referencias Obrigatorias

- Navegacao: `docs/architecture/navigation.md`
- Telas e regras de UX: `docs/ux/prototype-screens.md`
- Indice visual: `docs/ux/prototypes/README.md`
- Design system: `docs/ux/design-system.md`
- Revisao UX: `docs/ux/prototype-review.md`
- Regras de negocio: `docs/product/business-rules.md`

## Stack Esperada

- Flutter em `frontend/luminis_app`.
- `go_router` para navegacao.
- Riverpod para estado mockado.
- Dados mockados em memoria.
- Sem consumo de backend no primeiro ciclo.

## Estrutura De Navegacao

### Fluxo Publico

- `/auth/welcome`
- `/auth/login`
- `/auth/register`
- `/auth/forgot-password`
- `/auth/reset-password`

Regras:
- Usuario nao autenticado deve cair em `/auth/welcome`.
- Usuario autenticado deve ir para `/bookshelf`.
- No prototipo, login Google ou email/senha pode autenticar de forma mockada.

Observacao:
O preview visual existe apenas para `Welcome`. As demais telas podem seguir formulario simples, respeitando a especificacao textual.

### Shell Autenticado

Abas:

- Estante: `/bookshelf`
- Buscar: `/search`
- Leitura: `/reading`
- Metas: `/goals`
- Perfil: `/profile`

Regras:
- Bottom navigation fixa nas rotas raiz das abas.
- Telas empilhadas podem esconder ou preservar bottom navigation conforme melhor ergonomia, mas devem manter navegacao previsivel com voltar.

## Ordem Recomendada De Implementacao

1. Tema, tokens visuais e componentes basicos.
2. `go_router`, guarda de autenticacao mockada e shell autenticado.
3. Auth minimo.
4. Estante.
5. Busca, detalhe do livro e bottom sheet de adicionar a estante.
6. Cadastro local.
7. Leitura, estado de leitura, progresso e plano.
8. Metas.
9. Perfil.
10. Estados vazios e erros principais.

## Componentes Base

Implementar ou preparar componentes reutilizaveis:

- `BookCover`
- `BookCard`
- `BookshelfStatusChip`
- `ReadingProgressBar`
- `PrimaryButton`
- `SecondaryButton`
- `DestructiveButton`
- `BottomNavigation`
- `EmptyState`
- `UserAvatar`

## Paleta E Status

Usar a paleta de `docs/ux/design-system.md`.

Status principais de estante:

- `want_to_read`
- `reading`
- `paused`
- `read`
- `rereading`
- `abandoned`

Cores dos chips devem seguir `BookshelfStatusChip` no design system.

## Telas Do Primeiro Ciclo

| Fluxo | Rota | Preview |
| --- | --- | --- |
| Auth | `/auth/welcome` | `docs/ux/prototypes/auth-welcome-screen-preview.png` |
| Estante | `/bookshelf` | `docs/ux/prototypes/bookshelf-screen-preview.png` |
| Buscar | `/search` | `docs/ux/prototypes/search-screen-preview.png` |
| Detalhe do livro | `/books/:bookId` | `docs/ux/prototypes/book-detail-screen-preview.png` |
| Cadastro local | `/book-drafts/new` | `docs/ux/prototypes/local-book-draft-screen-preview.png` |
| Leitura | `/reading` | `docs/ux/prototypes/reading-screen-preview.png` |
| Estado de leitura | `/reading/:bookshelfItemId` | `docs/ux/prototypes/reading-state-screen-preview.png` |
| Registrar progresso | `/reading/:bookshelfItemId/progress/new` | `docs/ux/prototypes/reading-progress-screen-preview.png` |
| Plano de leitura | `/reading/:bookshelfItemId/plan` | `docs/ux/prototypes/reading-plan-screen-preview.png` |
| Metas | `/goals` | `docs/ux/prototypes/goals-screen-preview.png` |
| Criar meta | `/goals/new` | `docs/ux/prototypes/create-goal-screen-preview.png` |
| Detalhe da meta | `/goals/:readingGoalId` | `docs/ux/prototypes/goal-detail-screen-preview.png` |
| Editar meta | `/goals/:readingGoalId/edit` | `docs/ux/prototypes/edit-goal-screen-preview.png` |
| Perfil | `/profile` | `docs/ux/prototypes/profile-screen-preview.png` |

Bottom sheets:

- Adicionar a estante: `docs/ux/prototypes/add-to-bookshelf-bottom-sheet-preview.png`
- Voltar para `Quero ler`: `docs/ux/prototypes/want-to-read-decision-bottom-sheet-preview.png`

## Dados Mockados Necessarios

### Usuario

- Usuario autenticado com nome, handle, foto opcional e bio.
- Usuario sem foto e sem bio para estado alternativo.

### Catalogo

- Livros com uma edicao.
- Livros com multiplas edicoes.
- Edicao com `pageCount`.
- Edicao sem `pageCount`.
- Editoras com `logoUrl`.
- Editoras sem `logoUrl`.
- Resultado de busca ja presente na estante.
- Busca sem resultado.
- Erro de provedor simulado.

### Estante

- Item `want_to_read`.
- Item `reading`.
- Item `paused`.
- Item `read`.
- Item `rereading`.
- Item `abandoned`.
- Item global por `bookId` e `editionId`.
- Item local por `userBookDraftId`.

### Leitura

- Sessao ativa.
- Sessao pausada.
- Sessao `interrupted`.
- Ultimo progresso por pagina.
- Ultimo progresso por percentual.
- Plano ativo com ritmo calculavel.
- Plano sem ritmo calculavel.
- Progresso final que conclui leitura automaticamente.
- Progresso invalido por regressao.

### Metas

- Meta ativa no prazo.
- Meta concluida com bonus.
- Meta vencida nao atingida.
- Meta por livros.
- Meta por paginas.
- Meta privada por padrao.

## Regras Sensíveis Para Simular

- Ao adicionar livro a estante, status inicial permitido: `Quero ler`, `Lendo` ou `Lido`.
- `Relendo`, `Pausado` e `Abandonei` nao sao status iniciais de adicao.
- Ao registrar progresso menor que o ultimo, bloquear e mostrar erro no campo.
- Ao registrar ultima pagina conhecida ou `100%`, concluir leitura automaticamente.
- Sessao pausada deve ser retomada antes de receber progresso.
- Ao pausar leitura, cancelar plano ativo no MVP.
- Ao mudar para `Quero ler`, abrir bottom sheet para manter progresso pausado ou encerrar tentativa.
- Metas nao podem ser concluidas manualmente.
- Meta vencida nao atingida continua ativa e deve alertar o usuario.
- Cadastro local e privado no MVP e nao entra no catalogo global automaticamente.

## Pendencias Assumidas

- O `Welcome` deve usar o logo oficial quando o asset estiver disponivel; o preview atual e apenas placeholder visual.
- Auth detalhado pode ser formulario simples no primeiro ciclo.
- `/profile/edit` pode ser formulario simples sem preview proprio.
- Estados vazios e erros devem existir no prototipo mesmo que nem todos tenham preview visual dedicado.

## Criterios De Aceite Do Prototipo

- App inicia em `/auth/welcome` quando desautenticado.
- Login mockado leva para `/bookshelf`.
- Abas autenticadas navegam sem perder estado basico.
- Busca abre detalhe do livro.
- Detalhe permite abrir bottom sheet de adicionar a estante.
- Adicionar como `Lendo` permite ir para estado de leitura.
- Registro de progresso atualiza estado mockado.
- Plano calcula ritmo quando houver paginas e data alvo.
- Mudar para `Quero ler` exibe bottom sheet de decisao.
- Metas exibem ativo, concluido com bonus e vencido nao atingido.
- Perfil exibe dados basicos e permite logout mockado.
