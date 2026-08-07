# Feature: Resenhas E Avaliacoes

## Objetivo

Permitir que usuarios expressem opiniao sobre livros e ajudem outras pessoas a decidir leituras.

## Fluxos principais

- Avaliar livro.
- Escrever resenha.
- Marcar resenha como spoiler.
- Editar resenha.
- Excluir resenha.
- Ler resenhas na pagina do livro.

## Regras relacionadas

- `BR-REVIEW-001`
- `BR-REVIEW-002`
- `BR-REVIEW-003`

## Criterios iniciais

- Resenha deve ter tamanho minimo de 100 caracteres.
- Resenha com spoiler deve ser ocultada por padrao.
- Avaliacao e resenha devem pertencer a um usuario e a um livro.
- Avaliacao usa escala de 0.5 a 5.0 estrelas.
- Avaliacao principal fica vinculada a obra.
- Cada usuario deve ter no maximo uma avaliacao ativa por obra.
