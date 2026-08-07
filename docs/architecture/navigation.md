# Navegacao

Status: aprovado para MVP.

## Decisao principal

O Flutter deve usar `go_router` no MVP.

Racional:
- O app tera fluxo publico de autenticacao e shell autenticado com abas.
- Rotas protegidas sao necessarias desde o inicio.
- Detalhes de livro, leitura e perfil podem ganhar deep links no futuro sem reescrever navegacao.

## Estrutura de navegacao

O app deve ter dois blocos principais:

1. Fluxo publico de entrada.
2. Shell autenticado com abas principais.

### Fluxo publico

Rotas:
- `/auth/welcome`
- `/auth/login`
- `/auth/register`
- `/auth/forgot-password`
- `/auth/reset-password`

Regras:
- Usuario nao autenticado deve ser redirecionado para `/auth/welcome` ao tentar acessar rotas protegidas.
- Usuario autenticado nao deve permanecer em telas de login/cadastro; deve ser redirecionado para `/bookshelf`.
- Login Google e login por email/senha pertencem ao fluxo publico.

### Shell autenticado

Abas do MVP:
- `Estante`
- `Buscar`
- `Leitura`
- `Metas`
- `Perfil`

Rotas raiz das abas:
- `/bookshelf`
- `/search`
- `/reading`
- `/goals`
- `/profile`

Racional:
- O MVP nasce como organizador pessoal, por isso `Estante` e a rota inicial autenticada.
- `Buscar` fica como aba propria porque adicionar livros e uma acao recorrente.
- `Leitura` concentra leitura atual, progresso e ritmo.
- `Metas` concentra metas mensais/anuais e resumo de progresso.
- `Perfil` fica simples no MVP, mas prepara expansao social futura.

Feed completo nao deve ser aba no MVP. Quando social entrar, a aba `Inicio` ou `Feed` pode ser avaliada sem deslocar o nucleo de organizacao pessoal.

## Rotas protegidas do MVP

### Estante

- `/bookshelf`

Uso:
- `/bookshelf` lista itens ativos da estante com filtros.
- Ao abrir um item em leitura, a navegacao deve usar `/reading/:bookshelfItemId`.

Observacao:
`GET /api/bookshelf-items/{bookshelfItemId}` permanece candidato de UX. A navegacao deve tentar cobrir o fluxo com listagem e `reading-state` antes de aprovar uma tela intermediaria obrigatoria.

### Busca e catalogo

- `/search`
- `/books/:bookId`
- `/book-drafts/new`

Uso:
- `/search` busca livros por titulo, autor, editora, assunto ou ISBN digitado.
- `/books/:bookId` mostra detalhe de obra e edicoes.
- `/book-drafts/new` permite cadastro local privado quando a edicao nao for encontrada.

### Leitura

- `/reading`
- `/reading/:bookshelfItemId`
- `/reading/:bookshelfItemId/progress/new`
- `/reading/:bookshelfItemId/plan`

Uso:
- `/reading` mostra leitura atual, pausadas relevantes e atalhos para retomar.
- `/reading/:bookshelfItemId` usa o estado consolidado de leitura.
- `/reading/:bookshelfItemId/progress/new` registra progresso.
- `/reading/:bookshelfItemId/plan` cria, altera ou remove data alvo.

### Metas

- `/goals`
- `/goals/new`
- `/goals/:readingGoalId`
- `/goals/:readingGoalId/edit`

Uso:
- `/goals` lista metas do usuario e destaca metas que precisam de atencao.
- `/goals/new` cria meta mensal/anual no MVP.
- `/goals/:readingGoalId` mostra detalhe e progresso calculado.
- `/goals/:readingGoalId/edit` altera dados editaveis da meta ativa.

### Perfil

- `/profile`
- `/profile/edit`

Uso:
- `/profile` mostra perfil simples e estatisticas basicas disponiveis.
- `/profile/edit` edita dados basicos do usuario.

## Padroes de interacao

- Acoes de criacao simples podem abrir como tela empilhada, nao modal obrigatorio.
- Confirmacoes destrutivas ou sensiveis devem usar dialog ou bottom sheet.
- Ao mudar um item para `want_to_read` com sessao ativa ou pausada, o Flutter deve perguntar se o usuario quer manter a sessao pausada ou encerrar a tentativa como `interrupted`.
- Registro de progresso deve voltar para a tela de leitura atual apos sucesso.
- Adicionar livro a estante deve oferecer caminho claro para abrir a estante ou iniciar leitura.

## Deep links

Deep links publicos nao entram no MVP.

Ainda assim, as rotas devem ser estaveis o suficiente para futura abertura direta de:
- detalhe de livro;
- perfil publico;
- item de leitura;
- meta publica.

## Criterios

- Navegacao deve ser previsivel em mobile.
- Abas devem representar areas de trabalho, nao campanhas ou landing pages.
- Fluxos autenticados devem ser protegidos por estado de autenticacao.
- A tela inicial autenticada deve ser util mesmo sem rede social.
- Rotas devem ser nomeadas de forma consistente com contratos de backend.
