# Feature: Busca E Descoberta

## Objetivo

Ajudar usuarios a encontrar livros, autores, usuarios e proximas leituras.

## Fluxos principais

- Buscar livro.
- Buscar autor.
- Buscar usuario.
- Ver similares.
- Ver lancamentos ou tendencias.
- Escanear ISBN, se aprovado.
- Importar ou enriquecer livro a partir de fonte externa.
- Criar livro local quando nao houver resultado.
- Sugerir livro ou correcao para catalogo global.

## Regras relacionadas

- `BR-DISCOVERY-001`
- `BR-DISCOVERY-002`

## Criterios iniciais

- Busca deve tolerar pequenas diferencas de acentuacao e caixa.
- Resultados devem distinguir livros, autores e usuarios.
- Resultados de livros devem mostrar capa, titulo e autor quando disponiveis.
- Livro local deve permitir uso imediato na estante do usuario.
- Sugestao global deve passar por validacao antes de alterar catalogo compartilhado.

## Fontes candidatas

Conforme `docs/adr/ADR-002-book-catalog-provider-strategy.md`, a direcao proposta e ter catalogo proprio com enriquecimento externo.

- Google Books para busca textual.
- BrasilAPI ISBN para ISBN.
- Open Library como fallback/complemento.
- Cadastro manual e curadoria para ausencias, erros e duplicidades.

## Catalogo proprio no MVP

O catalogo proprio deve ser criado sob demanda, nao importado em massa.

Entidades iniciais:
- `books`
- `editions`
- `authors`
- `publishers`
- `book_authors`
- `book_external_references`
- `user_book_drafts`

Busca deve considerar titulo, autor e editora quando os dados existirem.

Editoras podem ter `logo_url` opcional para enriquecer visualmente telas e filtros.
