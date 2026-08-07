# Feature: Estante

## Objetivo

Permitir que usuarios organizem os livros vinculados a sua jornada de leitura.

## Fluxos principais

- Adicionar livro a estante.
- Remover livro da estante.
- Alterar status de leitura.
- Aplicar etiquetas auxiliares.
- Filtrar por status, etiqueta, autor, genero ou ano.

## Regras relacionadas

- `BR-BOOKSHELF-001`
- `BR-BOOKSHELF-002`
- `BR-BOOKSHELF-003`
- `BR-BOOKSHELF-004`

## Estados

- Vazia.
- Com livros.
- Carregando.
- Erro.
- Sem resultados apos filtro.

## Criterios iniciais

- Um livro pode estar apenas uma vez de forma ativa na estante do mesmo usuario.
- Um item deve ter no maximo um status principal.
- Etiquetas podem ser combinadas.
- Remover da estante nao remove o livro do catalogo global.
- `publisher_id` nao pertence ao item de estante; editora pertence a edicao.
