# Teste De Desejabilidade Visual

Status: proposta para validar a sensacao de que o app esta limpo, mas apagado.

Data: 2026-08-21.

## Spike Visual B

Status: iniciado em Flutter para comparacao no device.

Primeira fatia implementada:

- Bottom navigation trocada para `NavigationBar`, com indicador ativo mais expressivo.
- Estados vazios receberam uma marca visual curta com `Accent`, `Primary` e `Coral`, alem de icone em superficie com borda.
- Buscar ganhou estado inicial de descoberta com sugestoes tocaveis, em vez de apenas um vazio informativo.
- Campo de busca permanece limpo, sem sombra pesada.
- Botoes primarios passaram a usar `Action` escuro com `OnAction` claro; `Accent` fica reservado para progresso, marcadores e realces.

Esta direcao ainda precisa ser avaliada com o roteiro abaixo antes de virar padrao final do design system.

## Benchmark Skoob

O benchmark competitivo do Skoob esta registrado em `docs/ux/competitive-benchmark-skoob.md`.

Principais implicacoes para a proxima variante:

- Criar uma Variante C mais quente, sem abandonar o contraste da Variante B.
- Melhorar fallback covers, chips/status e estados selecionados para evitar excesso de azul/cinza.
- Fazer `adicionar a estante` gerar um proximo passo contextual: meta, progresso ou avaliacao futura.
- Aproximar Estante, Leitura e Metas por sinais visuais recorrentes.

## Objetivo

Avaliar se a experiencia autenticada do Luminis transmite energia, acolhimento e desejo de continuar usando, sem perder clareza operacional.

Este teste existe para capturar sinais como:

- O app parece vivo ou triste?
- A navegacao tem personalidade ou parece generica?
- O usuario entende rapidamente que esta em um app de leitura?
- A interface convida a continuar explorando?
- Os momentos principais geram satisfacao visual sem atrapalhar a tarefa?

## Hipotese

A base atual esta correta em clareza e estrutura, mas falta uma camada de encantamento visual. O candidato visual deve manter o app clean, porem adicionar mais presenca em pontos-chave:

- Navegacao inferior com estado ativo mais marcante.
- Telas vazias com composicao mais literaria e menos fria.
- Uso mais intencional de capas, progresso e cor.
- Pequenos momentos de feedback em acoes principais.
- Hierarquia visual mais calorosa nas telas raiz.

## O Que Testar

Comparar duas variantes:

- Variante A: build atual.
- Variante B: spike visual com camada de encantamento.

A variante B deve mexer primeiro em poucas areas de alto impacto:

- Bottom navigation: item ativo mais expressivo, com indicador visual claro e microfeedback discreto.
- Estante vazia: estado vazio menos cinza, com sinal visual de livro/leitura e chamada mais convidativa.
- Buscar: campo limpo sem sombra pesada, area inicial de descoberta mais rica.
- Leitura: card principal com mais presenca quando houver leitura ativa.
- Perfil: cabecalho com mais identidade pessoal, sem virar rede social completa.

## Roteiro

### Preparacao

- Usar o mesmo conteudo mockado nas duas variantes.
- Testar em device real, preferencialmente no mesmo aparelho.
- Evitar explicar que uma versao e "melhorada"; apresentar como duas direcoes visuais.
- Registrar tela inicial, navegacao entre abas, busca e uma acao primaria.

### Tarefas

1. Abrir o app autenticado e observar a primeira tela por ate 10 segundos.
2. Navegar pelas abas Estante, Buscar, Leitura, Metas e Perfil.
3. Abrir Buscar e procurar um livro.
4. Abrir uma tela com acao primaria, como editar perfil, registrar progresso ou criar meta.
5. Voltar para a tela raiz que mais chamou atencao.

### Perguntas Depois De Cada Variante

Usar escala de 1 a 7:

- Frio / Acolhedor.
- Apagado / Vivo.
- Generico / Memoravel.
- Pesado / Leve.
- Confuso / Claro.
- Sem vontade / Quero explorar.

Perguntas abertas:

- O que voce acha que este app quer que voce faca agora?
- Que parte mais chamou sua atencao?
- Alguma parte parece triste, sem energia ou generica?
- O app parece de leitura ou parece um app generico com textos sobre livros?
- O que faria voce ter mais vontade de voltar amanha?

### Comparacao Final

Depois das duas variantes:

- Qual versao voce manteria instalada?
- Qual versao parece mais confiavel?
- Qual versao parece mais prazerosa?
- Qual versao parece mais "Luminis"?
- O que a versao escolhida tem que a outra nao tem?

## Sinais De Sucesso

A variante B passa no teste se:

- Pelo menos 70% dos participantes preferirem a variante B na comparacao final.
- Mediana de "Apagado / Vivo" for 5 ou maior.
- Mediana de "Generico / Memoravel" for 5 ou maior.
- Mediana de "Sem vontade / Quero explorar" for 5 ou maior.
- Clareza nao cair abaixo da variante A.
- Participantes citarem espontaneamente algo visual ou emocional que os fez querer continuar.

## Sinais De Alerta

Rever a direcao se:

- O app ficar mais bonito, mas menos claro.
- A navegacao chamar mais atencao que o conteudo.
- As cores parecerem infantis, gamificadas demais ou pouco literarias.
- O visual depender de decoracao sem relacao com livros, leitura, progresso ou identidade pessoal.
- O app parecer marketing em vez de ferramenta diaria.

## Principios Para O Spike Visual

- Encantamento deve vir de conteudo, ritmo e estado: capas, progresso, leitura atual, metas e identidade do leitor.
- Evitar sombras pesadas, cards dentro de cards e decoracao sem funcao.
- Usar cor para guiar atencao, nao para pintar tudo.
- Fazer a navegacao parecer responsiva e cuidada, mas sempre previsivel.
- Preservar acessibilidade: contraste, area de toque, texto escalavel e sem depender apenas de cor.

## Resultado Esperado

Ao final do teste, decidir uma destas opcoes:

- Aprovar a direcao visual B e aplicar no app inteiro.
- Ajustar apenas navegacao e telas vazias.
- Manter a base atual e melhorar somente conteudo/capas.
- Criar uma variante C com mais personalidade antes de implementar.
