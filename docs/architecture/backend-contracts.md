# Contratos De Backend

Status: proposta inicial.

Este arquivo deve documentar contratos antes ou durante a criacao do backend.

## Arquitetura backend aprovada

Conforme `docs/adr/ADR-003-backend-modular-monolith-dotnet.md`, o backend sera um monolito modular em .NET/ASP.NET Core, com projetos separados por modulo de negocio, PostgreSQL e Dapper.

O Flutter deve consumir a API propria do Luminis. Regras de negocio e permissao devem ser validadas no backend.

Rotas HTTP devem seguir `docs/adr/ADR-005-minimal-apis-module-routes.md`: Minimal APIs por modulo, agregadas por `ModuleRoutes`, sem endpoints individuais em `Program.cs`.

## Recursos candidatos

- `users`
- `auth`
- `books`
- `book_search`
- `book_sources`
- `bookshelf_items`
- `reading_plans`
- `reading_sessions`
- `reading_progress_entries`
- `reviews`
- `activities`
- `comments`
- `follows`
- `blocks`
- `goals`

## Padrao de contrato

```md
## GET /books/{id}

Objetivo:

Autenticacao:

Resposta:

Erros:

Regras relacionadas:
```

## Principios

- Contratos devem citar regras de negocio relacionadas.
- Campos de data devem usar formato ISO 8601.
- Identificadores devem ser opacos para o cliente.
- Erros esperados devem ter codigo estavel.
- Erros devem incluir `traceId`.
- Endpoints autenticados devem usar bearer token.

## Erros

Formato conceitual:

```json
{
  "code": "validation.failed",
  "message": "Existem campos invalidos.",
  "traceId": "00-...",
  "errors": {}
}
```

Regras:
- Nao expor stack trace em producao.
- Erros esperados devem usar codigos estaveis.
- Validacoes devem retornar detalhes por campo quando aplicavel.

## Identity

Status: aprovado para MVP.

### POST /api/auth/register

Objetivo:
Criar usuario com email e senha.

Autenticacao:
Publico.

Request:

```json
{
  "displayName": "Everton",
  "email": "everton@email.com",
  "password": "senha-forte"
}
```

Response:

```json
{
  "accessToken": "jwt...",
  "refreshToken": "...",
  "expiresAt": "2026-08-06T18:00:00Z",
  "user": {
    "id": "uuid",
    "displayName": "Everton",
    "photoUrl": null,
    "status": "active"
  }
}
```

### POST /api/auth/login

Objetivo:
Autenticar usuario por email e senha.

Autenticacao:
Publico.

Request:

```json
{
  "email": "everton@email.com",
  "password": "senha-forte"
}
```

Response:
Mesmo formato de `/api/auth/register`.

Regras:
- Respeitar `locked_until`.
- Incrementar `failed_attempts` em falha.
- Atualizar `last_login_at` em sucesso.

### POST /api/auth/google

Objetivo:
Autenticar ou criar usuario a partir de login Google.

Autenticacao:
Publico.

Request:

```json
{
  "idToken": "google-id-token"
}
```

Response:
Mesmo formato de `/api/auth/register`.

Regras:
- Backend valida token com Google.
- `provider` deve ser `google`.
- `provider_user_id` e a identidade externa confiavel.
- Quando o Google retornar email verificado que ja exista em `user_password_credentials.email`, o backend deve vincular o login Google ao usuario local existente, evitando duplicidade de conta.
- Quando o email do Google nao estiver verificado, ele nao deve ser usado para vinculo automatico com credencial local existente.

### POST /api/auth/logout

Objetivo:
Revogar refresh token.

Autenticacao:
Bearer token.

Request:

```json
{
  "refreshToken": "..."
}
```

Response:

```json
{
  "success": true
}
```

### POST /api/auth/refresh

Objetivo:
Rotacionar refresh token e emitir novo access token.

Autenticacao:
Publico com refresh token valido.

Request:

```json
{
  "refreshToken": "..."
}
```

Response:

```json
{
  "accessToken": "jwt...",
  "refreshToken": "...",
  "expiresAt": "2026-08-06T18:00:00Z"
}
```

Regras:
- Refresh token real nao deve ser armazenado puro.
- Refresh deve rotacionar token.

### POST /api/auth/forgot-password

Objetivo:
Iniciar recuperacao de senha.

Autenticacao:
Publico.

Request:

```json
{
  "email": "user@email.com"
}
```

Response:

```json
{
  "success": true
}
```

Regras:
- Nao revelar se email existe.
- Gerar token de reset quando email existir.
- Envio de email deve passar por abstracao de email transacional.

### POST /api/auth/reset-password

Objetivo:
Redefinir senha usando token de recuperacao.

Autenticacao:
Publico com token valido.

Request:

```json
{
  "token": "...",
  "newPassword": "nova-senha"
}
```

Response:

```json
{
  "success": true
}
```

Regras:
- Token real nao deve ser armazenado puro.
- Token usado deve ser marcado com `used_at`.
- Senha deve ser armazenada apenas como hash.

### GET /api/me

Objetivo:
Retornar usuario autenticado.

Autenticacao:
Bearer token.

Response:

```json
{
  "id": "uuid",
  "displayName": "Everton",
  "photoUrl": "https://...",
  "bio": null,
  "status": "active"
}
```

Erros esperados:
- `auth.invalid_credentials`
- `auth.email_already_used`
- `auth.account_locked`
- `auth.google_token_invalid`
- `auth.refresh_token_invalid`
- `auth.password_reset_token_invalid`
- `auth.unauthorized`
- `validation.failed`

## Catalogo de livros

Status: aprovado para MVP.

Conforme `docs/adr/ADR-002-book-catalog-provider-strategy.md`, o cliente Flutter deve consumir contratos proprios do Luminis para busca e consulta de livros. Provedores como Google Books, BrasilAPI ISBN e Open Library devem ficar atras de uma camada de backend/catalogo quando a arquitetura final for implementada.

### Decisao anterior de representacao dos resultados

Status: Depreciada

A decisao de retornar `Book` como recurso principal com uma `defaultEdition` resumida foi substituida. Ela ocultava as edicoes distintas retornadas por fontes de catalogo e exigia uma regra implicita para escolher uma edicao padrao.

### Decisao de representacao dos resultados

Status: Aprovada

Cada item de `GET /api/books/search` deve representar uma `Edition` e incluir a `Book` associada. A mesma obra pode aparecer em mais de um item quando houver edicoes distintas relevantes para a busca.

O item nao deve expor `defaultEdition` nem `displayEdition`. A edicao retornada e a propria opcao que o usuario pode selecionar ao adicionar o livro a estante.

Racional:
- Preserva capa, editora, ano, idioma, formato, paginacao e ISBN da publicacao encontrada.
- Mantem explicita a separacao entre `Book` como obra e `Edition` como publicacao.
- Evita que o backend escolha silenciosamente uma edicao representativa.

### Decisao de roteamento

Status: Aprovada

As rotas publicas do Catalog devem usar o prefixo `/api`, alinhadas ao padrao ja adotado por Identity.

Rotas iniciais:
- `GET /api/books/search`
- `GET /api/books/{bookId}`
- `GET /api/books/isbn/{isbn}`

### Decisao de autenticacao das leituras do Catalog

Status: Aprovada

As rotas de leitura do Catalog no MVP exigem bearer token: `GET /api/books/search`, `GET /api/books/{bookId}` e `GET /api/books/isbn/{isbn}`. O Luminis nao oferece exploracao anonima do catalogo, pois o acesso ao aplicativo requer autenticacao.

### Decisao sobre tipo de busca

Status: Aprovada

`GET /api/books/search` deve expor o parametro `type` de forma declarativa. O valor informa o campo ou a intencao de busca, como `author` ou `title`, em vez de delegar essa interpretacao exclusivamente a heuristicas do backend.

O contrato e proprio do Luminis. Provedores externos, incluindo Google Books, permanecem detalhes internos do Catalog e nao definem diretamente os parametros ou o formato da resposta publica.

Valores iniciais aceitos por `type`:
- `all`: busca ampla.
- `title`: titulo e subtitulo da obra ou edicao.
- `author`: nome do autor.
- `publisher`: nome da editora.
- `subject`: assunto ou categoria, quando disponivel.
- `isbn`: ISBN de uma edicao.

Quando `type` nao for informado, o valor assumido deve ser `all`.

`type=publisher` deve buscar edicoes de livros vinculadas a editoras cujo nome corresponda ao termo pesquisado. O retorno permanece no formato de itens `Book` + `Edition`; o MVP nao cria uma busca ou listagem independente de editoras.

### Decisao sobre assuntos do Catalog

Status: Aprovada

O Catalog deve persistir assuntos ou categorias recebidos de provedores aprovados em um modelo plano. `type=subject` deve consultar os vinculos de assuntos ja persistidos e pode complementar resultados por meio de provedores aprovados que suportem esse tipo de consulta.

Assuntos nao possuem hierarquia, sinonimos ou equivalencias manuais no MVP. A origem de cada vinculo fica interna ao Catalog e nao integra o DTO publico.

### Decisao sobre termo de busca

Status: Aprovada

O parametro `q` e obrigatorio em `GET /api/books/search` para todos os valores de `type`. O valor deve conter ao menos um caractere nao vazio apos normalizacao de espacos.

Quando `q` estiver ausente ou vazio, a API deve retornar `400 Bad Request` com `validation.failed` e detalhe para o campo `q`.

### Decisao sobre erros de validacao do Catalog

Status: Aprovada

No Catalog, entradas que violarem regras de formato ou campos obrigatorios devem retornar `400 Bad Request` com o codigo `validation.failed` e os detalhes por campo no envelope de erro padrao. O MVP nao diferencia `400` de `422` para validacao de entrada.

### Decisao sobre paginacao de entrada

Status: Aprovada

`GET /api/books/search` usa paginacao baseada em pagina:
- `page` deve ser um inteiro positivo e assume `1` quando omitido.
- `limit` deve ser um inteiro positivo, assume `20` quando omitido e aceita no maximo `50`.

Valores fora dessas regras devem retornar `400 Bad Request` com `validation.failed` e detalhe para o campo correspondente.

### Decisao sobre paginacao na resposta

Status: Aprovada

A resposta de `GET /api/books/search` deve incluir `items`, `page`, `limit` e `hasNextPage`. O MVP nao deve expor `total`, pois a combinacao, normalizacao e deduplicacao de resultados internos e externos pode tornar esse valor caro ou pouco confiavel.

Uma busca concluida sem resultados deve retornar `200 OK`, preservando esse envelope com `items: []` e `hasNextPage: false`. `204 No Content` nao deve ser usado, pois impediria o retorno consistente dos metadados de paginacao.

### Decisao sobre indisponibilidade de provedores

Status: Aprovada

Falhas de provedores externos nao devem transformar uma consulta concluida em ausencia de resultado:
- Quando houver resultados no Catalog interno, `GET /api/books/search` deve retornar `200 OK`, mesmo que uma consulta complementar a provedor externo falhe.
- Quando nao houver resultado interno e todos os provedores externos aplicaveis falharem, `GET /api/books/search` e `GET /api/books/isbn/{isbn}` devem retornar `503 Service Unavailable` com o codigo `catalog.provider_unavailable`.
- `200 OK` com `items: []` na busca e `404 Not Found` na consulta exata por ISBN so podem ser retornados quando a consulta foi concluida sem correspondencias.

### Decisao sobre consulta exata por ISBN

Status: Aprovada

`GET /api/books/search?q={isbn}&type=isbn` mantem o contrato paginado de busca. `GET /api/books/isbn/{isbn}` representa uma consulta exata e deve retornar um unico objeto com `book` e `edition`, no mesmo formato de item retornado pela busca, sem envelope de paginacao.

O ISBN deve ser normalizado e validado antes da consulta. ISBN invalido deve retornar `400 Bad Request` com `validation.failed`. Quando a consulta for concluida e nenhuma fonte encontrar uma edicao correspondente, a API deve retornar `catalog.isbn_not_found`.

### Decisao sobre detalhe da obra

Status: Aprovada

`GET /api/books/{bookId}` deve retornar a `Book` completa, com titulo, subtitulo, descricao, titulo original e autores, junto de suas edicoes conhecidas. Cada item de `editions` usa o mesmo formato de `edition` retornado por `GET /api/books/search`.

O contrato de detalhe nao inclui estado de estante, progresso ou outros dados pessoais. Essas informacoes pertencem aos modulos Bookshelf e Reading.

Quando `bookId` nao corresponder a uma obra existente, a API deve retornar `404 Not Found` com o codigo `catalog.book_not_found`. Um identificador malformado deve retornar `400 Bad Request` com `validation.failed`.

### Decisao sobre metadados ausentes

Status: Aprovada

Os contratos do Catalog devem manter forma estavel quando metadados estiverem ausentes:
- Campos escalares opcionais devem ser retornados como `null`.
- Colecoes sem itens devem ser retornadas como `[]`.
- A API nao deve omitir campos definidos no contrato nem inventar valores de fallback.

### Decisao sobre proveniencia de metadados

Status: Aprovada

A proveniencia de metadados, incluindo `source`, identificadores externos e URLs de provedores, deve permanecer interna ao Catalog e ser registrada em `book_external_references`. Esses dados nao devem integrar os objetos publicos de busca, consulta por ISBN ou detalhe da obra.

O Flutter consome apenas o contrato normalizado do Luminis, sem acoplamento a Google Books, Open Library ou outros provedores.

### Decisao sobre importacao de provedores aprovados

Status: Aprovada

Metadados de provedores externos previamente aprovados podem integrar o catalogo global sob demanda, depois de normalizacao, validacao e deduplicacao pelo Catalog. A aprovacao da fonte e esses controles automaticos compoem a governanca exigida para a importacao.

Essa permissao nao se estende a cadastros, sugestoes ou correcoes enviados por usuarios, que permanecem privados ate curadoria futura.

### Decisao sobre cadastro local e curadoria

Status: Aprovada

Cadastros locais pertencem ao usuario que os criou e nao podem se tornar publicos ou integrar o catalogo global sem validacao, curadoria ou processo equivalente. Um cadastro local pode ser usado imediatamente na estante pessoal por meio de `user_book_draft_id`, sem promover uma `Book` ou `Edition` global.

Contratos de cadastro local devem exigir autenticacao e validar que o draft referenciado pertence ao usuario autenticado.

### Decisao de rota para criacao de cadastro local

Status: Aprovada

`POST /api/book-drafts` deve criar um cadastro local privado. A rota fica separada de `/api/books` para deixar explicito que ela nao cria uma `Book` ou `Edition` global.

### Decisao sobre payload de cadastro local

Status: Aprovada

`POST /api/book-drafts` recebe um payload estruturado com `title`, `authors` e `edition`. `title` e obrigatorio e nao vazio; `authors` e `edition` sao opcionais. O campo `edition` usa nomes de propriedades publicos e tipados, e nao expõe o `edition_data` interno do banco.

O backend converte o objeto `edition` para a persistencia interna de `user_book_drafts.edition_data`.

`title` ausente, vazio ou composto apenas por espacos deve retornar `400 Bad Request` com `validation.failed` e detalhe para o campo `title`.

### Decisao sobre uso imediato de cadastro local

Status: Aprovada

`POST /api/book-drafts` cria somente o draft local e retorna sua identidade. A inclusao do draft na estante e responsabilidade do modulo Bookshelf, por meio de `POST /api/bookshelf-items` com `userBookDraftId`.

O fluxo usa duas operacoes explicitas para preservar as responsabilidades dos modulos Catalog e Bookshelf. A criacao de um draft nao deve impor automaticamente um status de leitura.

### Decisao sobre resposta de criacao de cadastro local

Status: Aprovada

`POST /api/book-drafts` deve retornar `201 Created` com o draft completo, incluindo `id`, `title`, `authors`, `edition`, `status` e `createdAt`. O contrato nao expõe `userId`, pois o draft pertence ao usuario autenticado. O `id` retornado e usado posteriormente por `POST /api/bookshelf-items` como `userBookDraftId`.

### DTOs compartilhados do Catalog

Status: Aprovada

O Catalog deve reutilizar os mesmos formatos publicos para `Book`, `Edition`, `Author`, `Subject` e `Publisher` nas rotas de busca, consulta por ISBN e detalhe da obra.

`Publisher` deve expor `logoUrl` como campo opcional. Quando a editora nao tiver logo cadastrado, `logoUrl` deve ser retornado como `null`; fallback visual pertence ao Flutter.

`Edition` deve representar uma publicacao especifica e expor, no minimo, `id`, `title`, `subtitle`, `coverUrl`, `publisher`, `publishedYear`, `language`, `format`, `pageCount`, `isbn10` e `isbn13`.

Contratos aprovados para MVP:

````md
## GET /api/books/search

Objetivo:
Buscar livros por texto, titulo, autor, editora, assunto ou ISBN.

Autenticacao:
Bearer token.

Parametros:
- `q` (obrigatorio e nao vazio)
- `type` (`all` quando omitido; `all`, `title`, `author`, `publisher`, `subject` ou `isbn`)
- `page` (inteiro positivo; `1` quando omitido)
- `limit` (inteiro positivo; `20` quando omitido; maximo `50`)

Response: `200 OK`

```json
{
  "items": [
    {
      "book": {
        "id": "uuid",
        "title": "Memorias Postumas de Bras Cubas",
        "subtitle": null,
        "authors": [
          {
            "id": "uuid",
            "name": "Machado de Assis"
          }
        ]
      },
      "edition": {
        "id": "uuid",
        "title": "Memorias Postumas de Bras Cubas",
        "subtitle": null,
        "coverUrl": "https://...",
        "publisher": {
          "id": "uuid",
          "name": "Companhia das Letras",
          "logoUrl": "https://..."
        },
        "publishedYear": 2014,
        "language": "pt-BR",
        "format": "paperback",
        "pageCount": 368,
        "isbn10": "8582850128",
        "isbn13": "9788582850121"
      }
    }
  ],
  "page": 1,
  "limit": 20,
  "hasNextPage": true
}
```

Fontes candidatas:
- Catalogo interno.
- Google Books.
- Open Library.

Regras:
- Normalizar resposta antes de enviar ao Flutter.
- Registrar fonte do resultado.

Erros:
- `auth.unauthorized` com `401 Unauthorized` quando o bearer token estiver ausente ou invalido.
- `validation.failed` com `400 Bad Request` quando `q`, `type`, `page` ou `limit` forem invalidos.
- `catalog.provider_unavailable` com `503 Service Unavailable` quando nao houver resultado interno e todos os provedores aplicaveis falharem.
````

````md
## POST /api/book-drafts

Objetivo:
Criar um cadastro local privado para uso imediato do usuario autenticado.

Autenticacao:
Bearer token.

Request:

```json
{
  "title": "Livro nao encontrado",
  "authors": ["Nome do Autor"],
  "edition": {
    "publisher": "Editora Exemplo",
    "publishedYear": 2024,
    "language": "pt-BR",
    "format": "paperback",
    "pageCount": 240,
    "isbn10": null,
    "isbn13": null,
    "coverUrl": null
  }
}
```

Response: `201 Created`

```json
{
  "id": "uuid",
  "title": "Livro nao encontrado",
  "authors": ["Nome do Autor"],
  "edition": {
    "publisher": "Editora Exemplo",
    "publishedYear": 2024,
    "language": "pt-BR",
    "format": "paperback",
    "pageCount": 240,
    "isbn10": null,
    "isbn13": null,
    "coverUrl": null
  },
  "status": "local",
  "createdAt": "2026-08-06T18:00:00Z"
}
```

Erros:
- `auth.unauthorized` com `401 Unauthorized` quando o bearer token estiver ausente ou invalido.
- `validation.failed` com `400 Bad Request` quando `title` estiver ausente, vazio ou contiver somente espacos.

````

````md
## GET /api/books/{bookId}

Objetivo:
Retornar o detalhe de uma obra e suas edicoes conhecidas.

Autenticacao:
Bearer token.

Response:

```json
{
  "book": {
    "id": "uuid",
    "title": "Memorias Postumas de Bras Cubas",
    "subtitle": null,
    "description": "...",
    "originalTitle": null,
    "authors": [
      {
        "id": "uuid",
        "name": "Machado de Assis"
      }
    ],
    "subjects": [
      {
        "id": "uuid",
        "name": "Ficcao cientifica"
      }
    ]
  },
  "editions": [
    {
      "id": "uuid",
      "title": "Memorias Postumas de Bras Cubas",
      "subtitle": null,
      "coverUrl": "https://...",
      "publisher": {
        "id": "uuid",
        "name": "Companhia das Letras",
        "logoUrl": "https://..."
      },
      "publishedYear": 2014,
      "language": "pt-BR",
      "format": "paperback",
      "pageCount": 368,
      "isbn10": "8582850128",
      "isbn13": "9788582850121"
    }
  ]
}
```

Erros:
- `auth.unauthorized` com `401 Unauthorized` quando o bearer token estiver ausente ou invalido.
- `validation.failed` com `400 Bad Request` quando `bookId` for malformado.
- `catalog.book_not_found` quando a obra nao existir.
````

````md
## GET /api/books/isbn/{isbn}

Objetivo:
Buscar ou enriquecer uma edicao especifica por ISBN.

Autenticacao:
Bearer token.

Response:
Um unico objeto com `book` e `edition`, usando o mesmo formato de cada item em `GET /api/books/search`, sem `items`, `page`, `limit` ou `hasNextPage`.

```json
{
  "book": {
    "id": "uuid",
    "title": "Memorias Postumas de Bras Cubas",
    "subtitle": null,
    "authors": [
      {
        "id": "uuid",
        "name": "Machado de Assis"
      }
    ]
  },
  "edition": {
    "id": "uuid",
    "title": "Memorias Postumas de Bras Cubas",
    "subtitle": null,
    "coverUrl": "https://...",
    "publisher": {
      "id": "uuid",
      "name": "Companhia das Letras",
      "logoUrl": "https://..."
    },
    "publishedYear": 2014,
    "language": "pt-BR",
    "format": "paperback",
    "pageCount": 368,
    "isbn10": "8582850128",
    "isbn13": "9788582850121"
  }
}
```

Erros:
- `auth.unauthorized` com `401 Unauthorized` quando o bearer token estiver ausente ou invalido.
- `validation.failed` com `400 Bad Request` quando o ISBN for invalido.
- `catalog.isbn_not_found` quando a consulta for concluida sem edicao correspondente.
- `catalog.provider_unavailable` com `503 Service Unavailable` quando nao houver resultado interno e todos os provedores aplicaveis falharem.

Fontes candidatas:
- Catalogo interno.
- BrasilAPI ISBN.
- Google Books.
- Open Library.

Regras:
- Validar ISBN antes de consultar provedores externos.
- Preferir resultado do catalogo interno quando existir.
- Registrar fonte do metadado.
````

## Bookshelf

Status: aprovado para MVP.

### Decisao sobre payload inicial de item de estante

Status: Aprovada

`POST /api/bookshelf-items` recebe somente o alvo do item e o status de leitura. Para um livro global, o request deve usar `bookId`, `editionId` e `readingStatus`. Para um cadastro local, usa `userBookDraftId` e `readingStatus`.

Para livro global, `editionId` e obrigatorio. A estante representa a leitura de uma edicao concreta, e nao apenas do livro conceitual. O backend deve validar que a `Edition` informada pertence ao `Book` informado.

O campo de alvo nao usado deve ser omitido, e nao enviado como `null`. Etiquetas auxiliares nao fazem parte da criacao inicial e devem ser tratadas por atualizacao posterior.

### Decisao sobre resposta de criacao de item de estante

Status: Aprovada

`POST /api/bookshelf-items` deve retornar o item criado com `id`, `target`, `readingStatus` e `addedAt`. O campo `target` e discriminado por `type`: `book` inclui `bookId` e `editionId`; `draft` inclui `userBookDraftId`.

### Decisao sobre duplicidade de item de estante

Status: Aprovada

Quando o usuario tentar adicionar uma edicao global ou draft local que ja possua item ativo na estante, `POST /api/bookshelf-items` deve retornar `409 Conflict` com o codigo `bookshelf.item_already_exists`.

Para itens globais, a duplicidade e avaliada por `userId + editionId` ativo. O mesmo `Book` pode existir mais de uma vez na estante do usuario quando as edicoes forem diferentes, por exemplo uma edicao `pt-BR` e outra `en-US` do mesmo livro.

Para itens locais, a duplicidade e avaliada por `userId + userBookDraftId` ativo.

Racional:
- O request traz uma escolha explicita de `readingStatus`.
- Retornar silenciosamente o item existente poderia ignorar o status solicitado.
- Alterar o item existente transformaria uma criacao em atualizacao sem acao explicita do usuario.

Uma futura chave de idempotencia pode tratar repeticoes causadas por falha de rede sem alterar esta regra de conflito semantico.

### Decisao sobre alteracao de status de leitura

Status: Aprovada

Alterar `readingStatus` de um item da estante representa uma intencao explicita do usuario e pode orquestrar recursos de Reading quando fizer sentido.

`targetFinishDate` nao faz parte da alteracao de status. A data alvo de conclusao pode ser definida, alterada ou removida a qualquer momento por meio dos contratos de plano de leitura.

Regras por status:
- `reading`: atualiza `bookshelf_items.reading_status`; quando houver `reading_session` pausada para o item, reativa essa mesma sessao; quando nao houver sessao pausada ou ativa, cria uma `reading_session` ativa.
- `rereading`: atualiza `bookshelf_items.reading_status` e cria uma nova `reading_session` ativa quando o item ainda nao possuir uma.
- `paused`: atualiza `bookshelf_items.reading_status`, pausa a `reading_session` ativa, preserva seus `reading_progress_entries` e cancela o plano ativo.
- `read`: atualiza `bookshelf_items.reading_status`, preenche `bookshelf_items.finished_at` quando informado, cria um progresso final na ultima pagina quando a edicao tiver total de paginas conhecido e esse progresso ainda nao existir, finaliza a `reading_session` ativa como `finished`, preenche `reading_sessions.finished_at`, marca o plano ativo como `completed` e recalcula conclusao de metas ativas afetadas.
- `abandoned`: atualiza `bookshelf_items.reading_status`, finaliza a `reading_session` ativa como `abandoned` e cancela o plano ativo.
- `want_to_read`: atualiza `bookshelf_items.reading_status`, cancela automaticamente o plano ativo e trata a sessao atual conforme a escolha explicita do usuario.

Cancelar automaticamente o plano ao voltar para `want_to_read` evita manter uma data alvo para uma leitura que deixou de estar em andamento.

Quando existir sessao ativa ou pausada e o usuario voltar para `want_to_read`, o Flutter deve perguntar se ele quer manter a sessao para retomar depois ou encerrar aquela tentativa de leitura:
- Manter para retomar depois: a `reading_session` fica ou volta para `paused`, preservando progresso e permitindo reativar a mesma sessao quando o usuario voltar para `reading`.
- Encerrar tentativa: a `reading_session` deve ser marcada como `interrupted`, preservando historico. Quando o usuario voltar para `reading`, o backend cria uma nova sessao ativa.

Pausar uma leitura nao apaga progresso. Ao retomar de `paused` para `reading`, o ponto de retomada deve ser derivado do progresso mais recente da mesma `reading_session`, por `pageNumber` ou `percentage`.

### Decisao sobre listagem da estante

Status: Aprovada

`GET /api/bookshelf-items` deve listar somente itens ativos da estante do usuario autenticado, ou seja, itens com `removed_at is null`.

A listagem deve aceitar filtros pelos campos principais de organizacao da estante: `readingStatus` e etiquetas auxiliares booleanas. A paginacao deve seguir o mesmo modelo do Catalog: `page`, `limit` e `hasNextPage`, sem `total` no MVP.

Cada item retornado deve trazer o alvo (`book` ou `draft`) e metadados suficientes para exibir a lista sem chamadas adicionais obrigatorias. Para item global, a resposta deve incluir dados resumidos de `Book` e `Edition`. Para item local, deve incluir os dados do `user_book_draft`.

### GET /api/bookshelf-items

Objetivo:
Listar itens ativos da estante do usuario autenticado.

Autenticacao:
Bearer token.

Parametros:
- `readingStatus` opcional (`want_to_read`, `reading`, `paused`, `read`, `rereading` ou `abandoned`)
- `isFavorite` opcional (`true` ou `false`)
- `isOwned` opcional (`true` ou `false`)
- `isWished` opcional (`true` ou `false`)
- `isBorrowed` opcional (`true` ou `false`)
- `isLent` opcional (`true` ou `false`)
- `isEbook` opcional (`true` ou `false`)
- `isAudiobook` opcional (`true` ou `false`)
- `page` (inteiro positivo; `1` quando omitido)
- `limit` (inteiro positivo; `20` quando omitido; maximo `50`)

Response: `200 OK`

```json
{
  "items": [
    {
      "id": "uuid",
      "target": {
        "type": "book",
        "bookId": "uuid",
        "editionId": "uuid"
      },
      "book": {
        "id": "uuid",
        "title": "Memorias Postumas de Bras Cubas",
        "subtitle": null,
        "authors": [
          {
            "id": "uuid",
            "name": "Machado de Assis"
          }
        ]
      },
      "edition": {
        "id": "uuid",
        "title": "Memorias Postumas de Bras Cubas",
        "coverUrl": "https://...",
        "pageCount": 368,
        "language": "pt-BR",
        "format": "paperback"
      },
      "draft": null,
      "readingStatus": "reading",
      "tags": {
        "isFavorite": false,
        "isOwned": true,
        "isWished": false,
        "isBorrowed": false,
        "isLent": false,
        "isEbook": false,
        "isAudiobook": false
      },
      "startedAt": "2026-08-07T00:00:00Z",
      "finishedAt": null,
      "addedAt": "2026-08-06T18:00:00Z",
      "updatedAt": "2026-08-07T10:00:00Z"
    }
  ],
  "page": 1,
  "limit": 20,
  "hasNextPage": false
}
```

Regras:
- A listagem deve retornar somente itens do usuario autenticado.
- Itens removidos logicamente (`removed_at is not null`) nao devem aparecer.
- Filtros booleanos, quando omitidos, nao restringem a consulta.
- Multiplos filtros devem ser combinados com `AND`.
- Busca textual na estante fica fora deste contrato inicial.
- A ordenacao padrao deve ser por `updatedAt desc`, com `addedAt desc` como desempate.
- Resposta sem itens deve retornar `200 OK` com `items: []` e `hasNextPage: false`.

Erros:
- `auth.unauthorized` com `401 Unauthorized` quando o bearer token estiver ausente ou invalido.
- `validation.failed` com `400 Bad Request` quando filtros, `page` ou `limit` forem invalidos.

### Contrato candidato para detalhe do item

Status: Proposta, dependente de validacao de UX.

`GET /api/bookshelf-items/{bookshelfItemId}` pode ser considerado se a navegacao entre lista da estante e detalhe do item ficar truncada durante prototipo ou teste de usabilidade.

Uso esperado:
- abrir uma tela intermediaria de detalhe do item da estante;
- evitar carregar o estado completo de leitura quando a tela precisar apenas de status, tags, alvo, datas e metadados resumidos;
- melhorar fluidez de navegacao a partir da lista.

Restricoes:
- Nao entra como contrato obrigatorio do MVP neste momento.
- Nao deve substituir `GET /api/bookshelf-items/{bookshelfItemId}/reading-state` quando a tela precisar de sessao, progresso, plano e ritmo.
- Deve ser removido ou permanecer fora do escopo se a listagem e `reading-state` cobrirem bem a experiencia.

### Decisao sobre etiquetas auxiliares

Status: Aprovada

Etiquetas auxiliares da estante sao campos booleanos de organizacao pessoal. Elas nao substituem `readingStatus` e nao devem orquestrar recursos de Reading, como sessoes, progresso ou planos.

`PATCH /api/bookshelf-items/{bookshelfItemId}/tags` deve aceitar atualizacao parcial. Campos omitidos permanecem inalterados; campos enviados devem substituir o valor atual.

### PATCH /api/bookshelf-items/{bookshelfItemId}/tags

Objetivo:
Atualizar etiquetas auxiliares de um item ativo da estante do usuario autenticado.

Autenticacao:
Bearer token.

Request:

```json
{
  "isFavorite": true,
  "isOwned": true,
  "isWished": false,
  "isBorrowed": false,
  "isLent": false,
  "isEbook": false,
  "isAudiobook": false
}
```

Response: `200 OK`

```json
{
  "id": "uuid",
  "tags": {
    "isFavorite": true,
    "isOwned": true,
    "isWished": false,
    "isBorrowed": false,
    "isLent": false,
    "isEbook": false,
    "isAudiobook": false
  },
  "updatedAt": "2026-08-07T11:00:00Z"
}
```

Regras:
- `bookshelfItemId` deve pertencer ao usuario autenticado.
- O item deve estar ativo na estante (`removed_at is null`).
- A atualizacao deve ser parcial; campos omitidos nao devem ser alterados.
- Campos enviados devem ser booleanos.
- A operacao nao altera `readingStatus`.
- A operacao nao cria, pausa, conclui nem cancela `reading_sessions` ou `reading_plans`.
- Pelo menos uma etiqueta deve ser enviada.

Erros:
- `auth.unauthorized` com `401 Unauthorized` quando o bearer token estiver ausente ou invalido.
- `validation.failed` com `400 Bad Request` quando `bookshelfItemId` ou alguma etiqueta forem invalidos.
- `bookshelf.item_not_found` com `404 Not Found` quando o item nao existir, nao pertencer ao usuario autenticado ou estiver removido.

### Decisao sobre remocao da estante

Status: Aprovada

Remover um item da estante deve ser uma remocao logica por `removed_at`, nao exclusao fisica imediata. A remocao desfaz o vinculo ativo do usuario com aquela edicao global ou cadastro local, mas nao apaga `Book`, `Edition`, `user_book_draft`, sessoes ou registros de progresso.

Ao remover um item, o backend deve cancelar o plano ativo e marcar sessao ativa ou pausada relacionada ao item como `interrupted`. Registros de progresso permanecem preservados para historico, auditoria e estatisticas futuras.

### DELETE /api/bookshelf-items/{bookshelfItemId}

Objetivo:
Remover logicamente um item ativo da estante do usuario autenticado.

Autenticacao:
Bearer token.

Response: `204 No Content`

Regras:
- `bookshelfItemId` deve pertencer ao usuario autenticado.
- O item deve estar ativo na estante (`removed_at is null`).
- A operacao deve preencher `removed_at`.
- A operacao deve cancelar plano ativo relacionado ao item, quando houver.
- A operacao deve marcar sessao ativa ou pausada relacionada ao item como `interrupted`, quando houver.
- Registros de progresso nao devem ser apagados.
- A remocao nao deve apagar `Book`, `Edition`, `user_book_draft` nem metadados de catalogo.
- Apos remocao, o item nao deve aparecer em `GET /api/bookshelf-items`.
- Se o usuario adicionar novamente a mesma edicao ou draft depois da remocao, um novo item ativo pode ser criado.

Erros:
- `auth.unauthorized` com `401 Unauthorized` quando o bearer token estiver ausente ou invalido.
- `validation.failed` com `400 Bad Request` quando `bookshelfItemId` for malformado.
- `bookshelf.item_not_found` com `404 Not Found` quando o item nao existir, nao pertencer ao usuario autenticado ou ja estiver removido.

### POST /api/bookshelf-items

Objetivo:
Adicionar uma edicao global ou um cadastro local do usuario autenticado a estante.

Autenticacao:
Bearer token.

Request para obra global:

```json
{
  "bookId": "uuid",
  "editionId": "uuid",
  "readingStatus": "reading"
}
```

Request para cadastro local:

```json
{
  "userBookDraftId": "uuid",
  "readingStatus": "want_to_read"
}
```

Response para obra global:

```json
{
  "id": "uuid",
  "target": {
    "type": "book",
    "bookId": "uuid",
    "editionId": "uuid"
  },
  "readingStatus": "reading",
  "addedAt": "2026-08-06T18:00:00Z"
}
```

Response para cadastro local:

```json
{
  "id": "uuid",
  "target": {
    "type": "draft",
    "userBookDraftId": "uuid"
  },
  "readingStatus": "want_to_read",
  "addedAt": "2026-08-06T18:00:00Z"
}
```

Regra aprovada:
- O request deve referenciar `bookId` ou `userBookDraftId`, nunca ambos.
- Quando `bookId` for informado, `editionId` tambem deve ser informado.
- `editionId` deve pertencer ao `bookId` informado.
- Quando `userBookDraftId` for informado, o modulo deve validar que o draft pertence ao usuario autenticado.
- `readingStatus` e obrigatorio e deve ser escolhido explicitamente pelo usuario; a API nao deve assumir um valor padrao.
- `readingStatus` aceita apenas `want_to_read`, `reading`, `paused`, `read`, `rereading` ou `abandoned`.
- Valor de `readingStatus` fora dessa enumeracao deve retornar `validation.failed` com detalhe para o campo.
- Quando o item nascer com `readingStatus = reading` ou `rereading`, o backend deve criar uma `reading_session` ativa.
- Quando o item nascer com `readingStatus = read`, o backend deve preencher `bookshelf_items.finished_at`, criar uma `reading_session` ja finalizada como `finished` e, se houver `page_count` conhecido, criar progresso final na ultima pagina.
- Quando o item nascer com `readingStatus = want_to_read`, nenhuma sessao de leitura deve ser criada.
- Item ativo duplicado deve retornar `409 Conflict` com `bookshelf.item_already_exists`.

### PATCH /api/bookshelf-items/{bookshelfItemId}/reading-status

Objetivo:
Alterar o status principal de leitura de um item da estante do usuario autenticado.

Autenticacao:
Bearer token.

Request:

```json
{
  "readingStatus": "reading",
  "startedAt": "2026-08-07",
  "finishedAt": null,
  "sessionAction": null
}
```

Response: `200 OK`

```json
{
  "id": "uuid",
  "readingStatus": "reading",
  "startedAt": "2026-08-07T00:00:00Z",
  "finishedAt": null,
  "updatedAt": "2026-08-07T10:00:00Z"
}
```

Regras:
- `bookshelfItemId` deve pertencer ao usuario autenticado.
- `readingStatus` e obrigatorio e aceita apenas `want_to_read`, `reading`, `paused`, `read`, `rereading` ou `abandoned`.
- `targetFinishDate` nao deve ser enviado neste contrato; plano de leitura tem contrato proprio.
- `startedAt` e opcional e so se aplica quando `readingStatus` for `reading` ou `rereading`.
- `finishedAt` e opcional e so se aplica quando `readingStatus` for `read` ou `abandoned`.
- `sessionAction` so se aplica quando `readingStatus` for `want_to_read` e existir sessao ativa ou pausada. Valores: `keep_paused` ou `interrupt`.
- Ao mudar de `paused` para `reading`, o backend deve reativar a mesma `reading_session` pausada.
- Ao mudar para `reading` sem sessao pausada ou ativa, o backend deve criar uma `reading_session` ativa.
- Ao mudar para `rereading`, o backend deve criar uma nova `reading_session` ativa quando nao houver uma.
- Ao mudar para `read`, o backend deve finalizar a `reading_session` ativa como `finished`, preencher `reading_sessions.finished_at`, marcar plano ativo como `completed` e recalcular conclusao de metas ativas afetadas.
- Ao mudar para `paused`, o backend deve pausar a `reading_session` ativa como `paused`, preservar os registros de progresso e cancelar plano ativo.
- Ao mudar para `abandoned`, o backend deve finalizar a `reading_session` ativa como `abandoned` e cancelar plano ativo.
- Ao mudar para `want_to_read`, o backend deve cancelar plano ativo automaticamente.
- Ao mudar para `want_to_read` com `sessionAction = keep_paused`, o backend deve manter ou marcar a sessao atual como `paused`.
- Ao mudar para `want_to_read` com `sessionAction = interrupt`, o backend deve marcar a sessao atual como `interrupted`.
- Ao mudar para `want_to_read` com sessao ativa ou pausada, `sessionAction` e obrigatorio para evitar inferencia de intencao do usuario.

Erros:
- `auth.unauthorized` com `401 Unauthorized` quando o bearer token estiver ausente ou invalido.
- `validation.failed` com `400 Bad Request` quando `bookshelfItemId`, `readingStatus`, `startedAt`, `finishedAt` ou `sessionAction` forem invalidos.
- `bookshelf.item_not_found` com `404 Not Found` quando o item nao existir ou nao pertencer ao usuario autenticado.

## Reading

Status: aprovado para MVP.

### Decisao sobre plano de leitura

Status: Aprovada

Plano de leitura e o recurso responsavel por armazenar a data alvo de conclusao de um item da estante. Ele nao pertence a `bookshelf_items`, pois a estante descreve o vinculo do usuario com uma edicao ou cadastro local; tambem nao pertence a `reading_sessions`, pois sessao representa uma instancia/tentativa de leitura.

Um item da estante pode ter no maximo um plano ativo. Atualizar a data alvo deve alterar o plano ativo existente quando houver um, ou criar um novo plano quando nao houver.

`dailyPagesTarget` nao deve ser persistido no MVP. O backend ou o Flutter podem calcular a sugestao de paginas por dia a partir de `targetFinishDate`, progresso mais recente e total de paginas da edicao.

Quando o item mudar para `paused`, o plano ativo deve ser cancelado no MVP. Ao retomar a leitura (`reading` ou `rereading`), o usuario pode criar um novo plano informando uma nova `targetFinishDate`.

### PUT /api/bookshelf-items/{bookshelfItemId}/reading-plan

Objetivo:
Criar ou atualizar o plano ativo de leitura para um item da estante do usuario autenticado.

Autenticacao:
Bearer token.

Request:

```json
{
  "targetFinishDate": "2026-09-30",
  "startDate": "2026-08-07"
}
```

Response: `200 OK`

```json
{
  "id": "uuid",
  "bookshelfItemId": "uuid",
  "status": "active",
  "startDate": "2026-08-07",
  "targetFinishDate": "2026-09-30",
  "createdAt": "2026-08-07T10:00:00Z",
  "updatedAt": "2026-08-07T10:00:00Z"
}
```

Regras:
- `bookshelfItemId` deve pertencer ao usuario autenticado.
- `targetFinishDate` e obrigatorio.
- `targetFinishDate` nao deve ser anterior a data atual.
- `startDate` e opcional; quando omitido, o backend pode assumir a data atual no plano.
- Se ja existir plano ativo para o item, a operacao atualiza esse plano.
- Se nao existir plano ativo para o item, a operacao cria um novo plano ativo.
- A operacao nao altera automaticamente `readingStatus`.
- `dailyPagesTarget` nao e retornado como valor persistido; quando exposto futuramente, deve ser tratado como campo calculado.

Erros:
- `auth.unauthorized` com `401 Unauthorized` quando o bearer token estiver ausente ou invalido.
- `validation.failed` com `400 Bad Request` quando `bookshelfItemId`, `targetFinishDate` ou `startDate` forem invalidos.
- `bookshelf.item_not_found` com `404 Not Found` quando o item nao existir ou nao pertencer ao usuario autenticado.

### DELETE /api/bookshelf-items/{bookshelfItemId}/reading-plan

Objetivo:
Cancelar o plano ativo de leitura de um item da estante do usuario autenticado.

Autenticacao:
Bearer token.

Response: `204 No Content`

Regras:
- `bookshelfItemId` deve pertencer ao usuario autenticado.
- Quando houver plano ativo, ele deve ser marcado como `cancelled`.
- Quando nao houver plano ativo, a operacao deve ser idempotente e retornar `204 No Content`.
- A operacao nao altera automaticamente `readingStatus`.

Erros:
- `auth.unauthorized` com `401 Unauthorized` quando o bearer token estiver ausente ou invalido.
- `validation.failed` com `400 Bad Request` quando `bookshelfItemId` for malformado.
- `bookshelf.item_not_found` com `404 Not Found` quando o item nao existir ou nao pertencer ao usuario autenticado.

## Goals

Status: aprovado para MVP.

Metas de leitura representam compromissos do usuario em um periodo, com uma metrica clara e um valor alvo. No MVP, a UI deve priorizar metas mensais e anuais, mas o backend pode aceitar qualquer `periodType` ativo previsto no schema para nao fechar caminho para bimestre, trimestre, semestre ou periodo customizado.

O progresso da meta nao deve ser persistido no MVP. Ele deve ser calculado a partir dos dados de leitura do usuario.

Quando o usuario atinge `targetValue`, a meta deve ser marcada como `completed` por comandos que alteram dados de leitura, como registro de progresso ou conclusao de sessao. Consultas `GET` nao devem persistir mudancas de status. Leituras ou paginas acima do alvo, dentro do mesmo periodo, continuam sendo calculadas como bonus/excedente para preparar gamificacao futura sem exigir mecanicas de recompensa no MVP.

Para metas `pages_read`, o backend deve calcular paginas lidas por avanco de leitura. `pageNumber` representa a posicao atual no livro; `pageAdvance` e um conceito calculado que representa quantas paginas novas foram lidas desde o ultimo progresso da mesma sessao. O MVP nao precisa persistir `pageAdvance`.

Quando o progresso for registrado apenas por percentual, ele so deve contribuir para metas `pages_read` se a edicao tiver `pageCount` conhecido. Em leituras como Kindle, onde nem sempre ha quantidade de paginas, o percentual pode registrar progresso e concluir leitura em `100%`, mas nao deve gerar paginas lidas para metas por paginas.

Metas nao podem ser concluidas manualmente pelo usuario. A conclusao e uma transicao controlada pelo backend quando o progresso calculado atinge `targetValue`.

Quando uma meta ativa ultrapassar `endsOn` sem atingir o alvo, ela permanece `active`. O backend deve expor campos calculados para que o Flutter alerte o usuario e ofereca alteracao da meta, sem encerrar automaticamente a meta como falhada.

Regras relacionadas:
- BR-GOAL-001
- BR-GOAL-002
- BR-GOAL-003
- BR-GOAL-004
- BR-GOAL-005
- BR-GOAL-006
- BR-GOAL-007
- BR-GOAL-008

### GET /api/reading-goals

Objetivo:
Listar metas do usuario autenticado.

Autenticacao:
Bearer token.

Query params:
- `status`: opcional. Valores: `active`, `completed`, `cancelled`.
- `periodType`: opcional. Valores iniciais: `monthly`, `bimonthly`, `quarterly`, `semiannual`, `annual`, `custom`.
- `metricType`: opcional. Valores iniciais: `books_read`, `pages_read`.
- `year`: opcional. Filtra metas cujo periodo intersecta o ano informado.

Response: `200 OK`

```json
{
  "items": [
    {
      "id": "uuid",
      "periodType": "annual",
      "metricType": "books_read",
      "status": "active",
      "targetValue": 24,
      "startsOn": "2026-01-01",
      "endsOn": "2026-12-31",
      "isPublic": false,
      "completedAt": null,
      "progress": {
        "currentValue": 8,
        "percentage": 33.33,
        "remainingValue": 16,
        "bonusValue": 0,
        "isReached": false,
        "isExceeded": false,
        "isExpired": false,
        "needsAttention": false
      }
    }
  ]
}
```

Regras:
- Retornar apenas metas do usuario autenticado.
- Nao retornar metas com `deleted_at` preenchido.
- `progress` deve ser calculado no momento da consulta.

Erros:
- `auth.unauthorized` com `401 Unauthorized` quando o bearer token estiver ausente ou invalido.
- `validation.failed` com `400 Bad Request` quando algum filtro tiver valor invalido.

### POST /api/reading-goals

Objetivo:
Criar uma meta de leitura.

Autenticacao:
Bearer token.

Request:

```json
{
  "periodType": "monthly",
  "metricType": "pages_read",
  "targetValue": 1200,
  "startsOn": "2026-08-01",
  "endsOn": "2026-08-31",
  "isPublic": false
}
```

Response: `201 Created`

```json
{
  "id": "uuid",
  "periodType": "monthly",
  "metricType": "pages_read",
  "status": "active",
  "targetValue": 1200,
  "startsOn": "2026-08-01",
  "endsOn": "2026-08-31",
  "isPublic": false,
  "completedAt": null,
  "progress": {
    "currentValue": 0,
    "percentage": 0,
    "remainingValue": 1200,
    "bonusValue": 0,
    "isReached": false,
    "isExceeded": false,
    "isExpired": false,
    "needsAttention": false
  }
}
```

Regras:
- `targetValue` deve ser maior que zero.
- `endsOn` deve ser maior ou igual a `startsOn`.
- Meta nasce com status `active`.
- Meta nasce privada quando `isPublic` nao for informado.
- O usuario pode ter apenas uma meta nao cancelada para a mesma combinacao de periodo, metrica e intervalo.
- No MVP, o Flutter pode expor apenas `monthly` e `annual`, mesmo que o backend aceite outros tipos ativos.

Erros:
- `auth.unauthorized` com `401 Unauthorized` quando o bearer token estiver ausente ou invalido.
- `validation.failed` com `400 Bad Request` quando o payload for invalido.
- `reading_goal.duplicate_goal` com `409 Conflict` quando ja existir meta ativa ou concluida para a mesma combinacao.

### GET /api/reading-goals/{readingGoalId}

Objetivo:
Retornar uma meta especifica do usuario autenticado, incluindo progresso calculado.

Autenticacao:
Bearer token.

Response: `200 OK`

```json
{
  "id": "uuid",
  "periodType": "annual",
  "metricType": "books_read",
  "status": "active",
  "targetValue": 24,
  "startsOn": "2026-01-01",
  "endsOn": "2026-12-31",
  "isPublic": false,
  "completedAt": null,
  "progress": {
    "currentValue": 8,
    "percentage": 33.33,
    "remainingValue": 16,
    "bonusValue": 0,
    "isReached": false,
    "isExceeded": false,
    "isExpired": false,
    "needsAttention": false
  }
}
```

Regras:
- `readingGoalId` deve pertencer ao usuario autenticado.
- `progress` deve ser calculado no momento da consulta.

Erros:
- `auth.unauthorized` com `401 Unauthorized` quando o bearer token estiver ausente ou invalido.
- `validation.failed` com `400 Bad Request` quando `readingGoalId` for malformado.
- `reading_goal.not_found` com `404 Not Found` quando a meta nao existir ou nao pertencer ao usuario autenticado.

### PATCH /api/reading-goals/{readingGoalId}

Objetivo:
Atualizar os dados editaveis de uma meta de leitura.

Autenticacao:
Bearer token.

Request:

```json
{
  "targetValue": 1800,
  "startsOn": "2026-08-01",
  "endsOn": "2026-08-31",
  "isPublic": true
}
```

Response: `200 OK`

Mesmo formato de `GET /api/reading-goals/{readingGoalId}`.

Regras:
- Atualizacao deve ser parcial.
- Ao menos um campo deve ser informado.
- Apenas metas `active` podem ser editadas.
- `periodType` e `metricType` nao devem ser alterados neste endpoint; se o usuario quiser mudar a natureza da meta, deve cancelar a meta atual e criar outra.
- `status`, `completedAt` e qualquer campo de conclusao nao devem ser aceitos neste endpoint.
- Alterar `startsOn` ou `endsOn` deve respeitar a regra de duplicidade de meta nao cancelada.

Erros:
- `auth.unauthorized` com `401 Unauthorized` quando o bearer token estiver ausente ou invalido.
- `validation.failed` com `400 Bad Request` quando o payload for invalido.
- `reading_goal.not_found` com `404 Not Found` quando a meta nao existir ou nao pertencer ao usuario autenticado.
- `reading_goal.not_editable` com `409 Conflict` quando a meta nao estiver ativa.
- `reading_goal.duplicate_goal` com `409 Conflict` quando a alteracao conflitar com outra meta ativa ou concluida.

### POST /api/reading-goals/{readingGoalId}/cancel

Objetivo:
Cancelar uma meta ativa.

Autenticacao:
Bearer token.

Request:

```json
{
  "reason": "Ajustei minha meta para outro periodo."
}
```

Response: `200 OK`

Mesmo formato de `GET /api/reading-goals/{readingGoalId}`.

Regras:
- Apenas metas `active` podem ser canceladas.
- Cancelamento muda o status para `cancelled`.
- O motivo e opcional no contrato, mas so deve ser persistido se existir coluna propria futura; no MVP pode ser ignorado pelo backend.
- Cancelar meta nao altera estante, sessoes, planos de leitura nem progresso de leitura.

Erros:
- `auth.unauthorized` com `401 Unauthorized` quando o bearer token estiver ausente ou invalido.
- `validation.failed` com `400 Bad Request` quando `readingGoalId` for malformado.
- `reading_goal.not_found` com `404 Not Found` quando a meta nao existir ou nao pertencer ao usuario autenticado.
- `reading_goal.not_cancellable` com `409 Conflict` quando a meta nao estiver ativa.

### GET /api/reading-goals/{readingGoalId}/progress

Objetivo:
Retornar somente o progresso calculado de uma meta.

Autenticacao:
Bearer token.

Response: `200 OK`

```json
{
  "readingGoalId": "uuid",
  "metricType": "pages_read",
  "targetValue": 1200,
  "currentValue": 1350,
  "percentage": 100,
  "remainingValue": 0,
  "bonusValue": 150,
  "isReached": true,
  "isExceeded": true,
  "isExpired": false,
  "needsAttention": false,
  "calculatedAt": "2026-08-07T12:00:00Z"
}
```

Regras:
- Para `books_read`, contar `reading_sessions` finalizadas como `finished` no intervalo da meta, incluindo releituras.
- O calculo de `books_read` deve juntar `reading_sessions` ao `bookshelf_items` do usuario autenticado.
- Para `pages_read`, somar `pageAdvance` calculado a partir dos registros de progresso no intervalo da meta.
- `pageAdvance` deve ser calculado como `pageNumberAtual - pageNumberAnterior` dentro da mesma sessao.
- Quando nao houver `pageNumberAnterior` na sessao, `pageAdvance` deve ser igual a `pageNumberAtual`.
- `pageNumber` e posicao atual no livro, nao quantidade lida no registro.
- Quando houver apenas `percentage`, o backend so deve converter percentual para paginas se a edicao tiver `pageCount` conhecido.
- Quando a edicao nao tiver `pageCount`, progresso por percentual nao contribui para `pages_read`.
- O calculo deve considerar apenas dados do usuario autenticado.
- `percentage` deve ser limitado a `100` quando `currentValue` exceder `targetValue`.
- `isReached` deve ser `true` quando `currentValue >= targetValue`.
- `bonusValue` deve ser `0` enquanto `currentValue <= targetValue`; acima disso, deve ser `currentValue - targetValue`.
- `isExceeded` deve ser `true` quando `bonusValue > 0`.
- Atingir o valor alvo deve marcar a meta como `completed` e preencher `completedAt` durante comandos que alteram dados de leitura ou criam/editam a propria meta.
- `GET /api/reading-goals/{readingGoalId}/progress` nao deve ter efeito colateral de persistencia; ele apenas retorna o progresso calculado.
- Mesmo concluida, a meta continua retornando progresso calculado e bonus ate o fim do periodo.
- Concluir uma meta nao altera estante, sessoes, planos de leitura nem progresso de leitura.
- Nao existe conclusao manual de meta no MVP.
- `isExpired` deve ser `true` quando a data atual for posterior a `endsOn` e a meta ainda estiver ativa.
- `needsAttention` deve ser `true` quando a meta estiver ativa, expirada e ainda nao atingida.
- Meta ativa expirada e nao atingida permanece `active`; o alerta visual e a opcao de alterar a meta pertencem ao Flutter, apoiados por `isExpired` e `needsAttention`.

Erros:
- `auth.unauthorized` com `401 Unauthorized` quando o bearer token estiver ausente ou invalido.
- `validation.failed` com `400 Bad Request` quando `readingGoalId` for malformado.
- `reading_goal.not_found` com `404 Not Found` quando a meta nao existir ou nao pertencer ao usuario autenticado.

### Decisao sobre registro de progresso

Status: Aprovada

Registro de progresso pertence a uma `reading_session`, nao diretamente ao item da estante. Isso preserva o historico da tentativa de leitura e permite pausar/retomar sem perder o ponto atual.

O MVP aceita progresso por pagina (`pageNumber`) ou percentual (`percentage`). Pelo menos um dos dois deve ser informado. Quando ambos forem informados, eles devem representar o mesmo ponto de leitura de forma coerente; o backend pode rejeitar combinacoes incompatíveis quando houver total de paginas conhecido.

Progresso so pode ser registrado em sessao `active`. Quando a sessao estiver `paused`, o usuario deve retomar a leitura antes de registrar novo progresso.

Chegar ao final do livro deve concluir automaticamente a leitura quando o backend conseguir validar o fim da edicao. Se `pageNumber` atingir `editions.page_count` conhecido ou `percentage` chegar a `100`, o backend deve registrar o progresso e mudar o item da estante para `read`.

### POST /api/reading-sessions/{readingSessionId}/progress

Objetivo:
Registrar um novo progresso de leitura em uma sessao ativa do usuario autenticado.

Autenticacao:
Bearer token.

Request:

```json
{
  "pageNumber": 120,
  "percentage": null,
  "note": "Leitura boa ate aqui",
  "isPublic": false
}
```

Response: `201 Created`

```json
{
  "id": "uuid",
  "readingSessionId": "uuid",
  "pageNumber": 120,
  "percentage": null,
  "note": "Leitura boa ate aqui",
  "isPublic": false,
  "createdAt": "2026-08-07T10:30:00Z",
  "readingStatusAfterProgress": "reading",
  "completedReading": false
}
```

Regras:
- `readingSessionId` deve pertencer ao usuario autenticado.
- A sessao deve estar com `status = active`.
- `pageNumber` e `percentage` sao opcionais individualmente, mas ao menos um deve ser informado.
- `pageNumber`, quando informado, deve ser maior que zero.
- `pageNumber` nao deve ser maior que `editions.page_count` quando o total de paginas for conhecido.
- `pageNumber` nao deve ser menor que a ultima pagina registrada na mesma sessao; nesse caso, o registro deve ser rejeitado.
- `percentage`, quando informado, deve estar entre `0` e `100`.
- `note` e opcional e deve respeitar o limite definido no schema.
- `isPublic` e opcional; quando omitido, deve assumir `false`.
- Registrar progresso so altera automaticamente `readingStatus` quando o progresso indicar conclusao da leitura.
- Se `pageNumber` for igual ao total de paginas conhecido da edicao, ou `percentage` for `100`, o backend deve mudar o item da estante para `read`, preencher `bookshelf_items.finished_at`, finalizar a sessao ativa como `finished`, preencher `reading_sessions.finished_at`, marcar o plano ativo como `completed` e recalcular conclusao de metas ativas afetadas.
- A resposta deve informar `readingStatusAfterProgress` e `completedReading` para o Flutter atualizar a tela sem consulta adicional obrigatoria.

Erros:
- `auth.unauthorized` com `401 Unauthorized` quando o bearer token estiver ausente ou invalido.
- `validation.failed` com `400 Bad Request` quando `readingSessionId`, `pageNumber`, `percentage`, `note` ou `isPublic` forem invalidos.
- `reading.progress_regression` com `409 Conflict` quando `pageNumber` for menor que a ultima pagina registrada na mesma sessao.
- `reading.session_not_found` com `404 Not Found` quando a sessao nao existir ou nao pertencer ao usuario autenticado.
- `reading.session_not_active` com `409 Conflict` quando a sessao existir, mas nao estiver ativa.

### Decisao sobre estado de leitura

Status: Aprovada

`reading-state` e uma consulta agregada para montar a tela de leitura atual no Flutter. Ele nao representa uma nova tabela nem uma nova fonte de verdade; apenas consolida `bookshelf_items`, `reading_sessions`, `reading_progress_entries`, `reading_plans` e metadados basicos de `Book`/`Edition`.

O estado de leitura deve retornar a sessao ativa ou pausada mais relevante do item, o progresso mais recente, o plano ativo quando existir e o calculo de ritmo quando for possivel calcular.

Quando nao houver sessao ativa ou pausada, o contrato deve retornar `session: null`, `lastProgress: null`, `activePlan: null`, `readingPace.canCalculate: false` e preservar os dados do item da estante. Isso permite usar a mesma tela para itens ainda nao iniciados.

### GET /api/bookshelf-items/{bookshelfItemId}/reading-state

Objetivo:
Retornar o estado consolidado de leitura de um item da estante do usuario autenticado.

Autenticacao:
Bearer token.

Response: `200 OK`

```json
{
  "bookshelfItem": {
    "id": "uuid",
    "readingStatus": "reading",
    "target": {
      "type": "book",
      "bookId": "uuid",
      "editionId": "uuid"
    }
  },
  "book": {
    "id": "uuid",
    "title": "Memorias Postumas de Bras Cubas",
    "subtitle": null
  },
  "edition": {
    "id": "uuid",
    "title": "Memorias Postumas de Bras Cubas",
    "pageCount": 368,
    "coverUrl": "https://..."
  },
  "session": {
    "id": "uuid",
    "status": "active",
    "startedAt": "2026-08-07T00:00:00Z",
    "finishedAt": null
  },
  "lastProgress": {
    "id": "uuid",
    "pageNumber": 120,
    "percentage": null,
    "createdAt": "2026-08-07T10:30:00Z"
  },
  "activePlan": {
    "id": "uuid",
    "targetFinishDate": "2026-09-30",
    "startDate": "2026-08-07"
  },
  "readingPace": {
    "canCalculate": true,
    "remainingPages": 248,
    "remainingDays": 54,
    "dailyPagesTarget": 5
  }
}
```

Regras:
- `bookshelfItemId` deve pertencer ao usuario autenticado.
- O contrato deve retornar sessao `active` quando existir.
- Se nao houver sessao `active`, o contrato pode retornar a sessao `paused` mais recente.
- `lastProgress` deve ser o registro mais recente da sessao retornada.
- `activePlan` deve ser retornado somente quando houver plano ativo.
- `readingPace.canCalculate` deve ser `false` quando faltar plano ativo, total de paginas, progresso atual ou dias restantes validos.
- `dailyPagesTarget` e calculado, nao persistido.
- O calculo de ritmo deve usar paginas restantes e dias restantes ate `targetFinishDate`.

Erros:
- `auth.unauthorized` com `401 Unauthorized` quando o bearer token estiver ausente ou invalido.
- `validation.failed` com `400 Bad Request` quando `bookshelfItemId` for malformado.
- `bookshelf.item_not_found` com `404 Not Found` quando o item nao existir ou nao pertencer ao usuario autenticado.
