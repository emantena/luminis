# ADR-007 - Manter Cadastros Locais Privados Na Estante

Status: Aceita

## Contexto

O MVP aprovado permite que o usuario cadastre um livro localmente e o use de imediato quando ele nao existir no catalogo. O mesmo produto exige validacao, curadoria ou processo equivalente antes que um cadastro ou correcao afete o catalogo global.

O schema original exigia `bookshelf_items.book_id`, impedindo que um `user_book_draft` fosse usado na estante sem promover dados nao curados para `books` e `editions`.

## Decisao

Manter `user_book_drafts` privados ao usuario que os criou e permitir que `bookshelf_items` referencie exatamente um dos alvos:

- `book_id`, para uma obra global; ou
- `user_book_draft_id`, para um cadastro local do proprio usuario.

`edition_id` somente pode ser informado quando o item referenciar uma obra global. O backend deve validar que o draft pertence ao mesmo usuario do item de estante.

Catalog e Bookshelf permanecem responsaveis por operacoes distintas: `POST /api/book-drafts` cria somente o draft local, enquanto `POST /api/bookshelf-items` cria o vinculo com a estante. O fluxo de uso imediato usa essas duas operacoes e nao atribui status de leitura automaticamente na criacao do draft.

Nenhum cadastro local, sugestao ou metadado nao curado pode integrar resultados publicos do Catalog ou o catalogo global antes da curadoria.

## Consequencias

### Positivas

- O usuario usa um cadastro manual imediatamente na estante pessoal.
- O catalogo global nao recebe dados nao curados.
- A separacao entre dados privados e publicos permanece explicita no schema e nos contratos.

### Custos e limites

- Consultas da estante devem resolver o alvo global ou local conforme o item.
- Um item baseado em draft nao possui `edition_id`; recursos dependentes de `editions.page_count`, como o ritmo por paginas, podem ficar indisponiveis enquanto esses dados nao existirem.
- A promocao futura de um draft curado para o catalogo global exigira uma decisao de migracao do vinculo da estante.

## Alternativas consideradas

### Promover o draft diretamente para `books` e `editions`

Rejeitada porque exporia ou incorporaria no catalogo global dados ainda nao curados.

### Impedir o uso do draft na estante

Rejeitada porque contraria o uso imediato aprovado para cadastro manual local.

### Criar `Book` e `Edition` privados por usuario

Rejeitada no MVP porque adiciona ownership, visibilidade e regras de consulta a entidades hoje definidas como catalogo global.

## Referencias

- `docs/product/business-rules.md` (`BR-BOOK-004`, `BR-BOOK-005` e `BR-BOOK-006`)
- `docs/data/database-schema-mvp.md`
- `docs/data/database-schema-mvp-er.md`
- `docs/architecture/backend-contracts.md`
