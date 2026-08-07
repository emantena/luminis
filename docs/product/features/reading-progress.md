# Feature: Progresso De Leitura

## Objetivo

Permitir que o usuario registre e acompanhe sua evolucao em uma leitura.

## Modelo conceitual

- `BookshelfItem`: vinculo do usuario com o livro na estante.
- `ReadingSession`: instancia concreta de leitura daquele item.
- `ReadingProgressEntry`: registro de progresso dentro de uma sessao.

## Fluxos principais

- Iniciar leitura.
- Atualizar pagina atual ou percentual.
- Adicionar comentario de progresso.
- Definir data alvo de conclusao.
- Ver sugestao de paginas por dia.
- Concluir leitura.
- Consultar historico.

## Regras relacionadas

- `BR-READING-001`
- `BR-READING-002`
- `BR-READING-003`
- `BR-READING-004`

## Criterios iniciais

- Progresso nao deve exceder o total de paginas quando esse dado existir.
- Conclusao deve registrar data.
- Historico deve preservar registros anteriores.
- Progresso pode gerar atividade social se o usuario optar por publicar.
- Quando houver pagina atual, total de paginas e data alvo, o app deve calcular paginas por dia necessarias.
- Progresso deve pertencer a uma sessao de leitura.
- Um item da estante pode ter no maximo uma sessao ativa.
- `daily_pages_target` nao deve ser persistido no MVP; deve ser calculado.

## Formula inicial

```text
paginas_restantes = total_paginas - pagina_atual
dias_restantes = data_alvo - hoje
paginas_por_dia = teto(paginas_restantes / dias_restantes)
```

## Perguntas abertas

- O calculo deve ignorar dias em que o usuario nao pretende ler?
- O app deve recalcular automaticamente apos cada progresso?
- O app deve sugerir uma nova data quando o ritmo necessario estiver alto?
