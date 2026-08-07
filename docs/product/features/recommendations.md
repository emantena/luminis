# Feature: Recomendacoes

## Objetivo

Ajudar usuarios a descobrir proximas leituras com base em sinais sociais reais.

## Decisao aprovada

As recomendacoes iniciais sao sociais, nao IA-first.

## Sinais sociais candidatos

- Pessoas que o usuario segue.
- Leitores com livros, avaliacoes ou generos parecidos.
- Membros dos mesmos grupos.
- Livros populares entre conexoes.
- Livros bem avaliados por pessoas proximas.
- Livros adicionados a `quero ler` por usuarios relacionados.
- Livros concluidos recentemente por pessoas seguidas.

## Tipos de recomendacao

- Pessoas que voce segue leram.
- Popular nos seus grupos.
- Leitores parecidos gostaram.
- Em alta entre quem leu um livro parecido.
- Muito marcado como quero ler.
- Bem avaliado nos seus generos favoritos.

## Regras relacionadas

- `BR-RECOMMENDATION-001`
- `BR-RECOMMENDATION-002`

## Criterios iniciais

- Recomendacao deve ter motivo explicavel quando possivel.
- A primeira versao pode usar heuristicas simples.
- IA generativa nao deve ser dependencia central da recomendacao inicial.
- O usuario deve poder ignorar ou remover recomendacoes no futuro.

## Perguntas abertas

- Recomendacao aparece em tela propria, feed ou detalhe do livro?
- Usuarios poderao seguir autores e generos?
- O app deve permitir ocultar um livro recomendado?
- Como medir gosto parecido na primeira versao?
