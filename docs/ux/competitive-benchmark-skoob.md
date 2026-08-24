# Benchmark Competitivo: Skoob

Status: insumo para Variante C de UX visual e navegacao.

Data: 2026-08-21.

## Objetivo

Entender quais padroes de navegacao e motivacao do Skoob, concorrente direto do Luminis, podem inspirar melhorias no MVP sem copiar identidade visual, textos proprietarios ou trade dress.

## Fontes Consultadas

- Google Play: `https://play.google.com/store/apps/details?id=com.gaudium.skoob`
- Central de Ajuda: adicionar livro a estante.
- Central de Ajuda: adicionar livro a meta de leitura.
- Central de Ajuda: encontrar livros de meta na estante.
- Central de Ajuda: Jornada de Leitura.
- Central de Ajuda: Historico de Leitura.
- Central de Ajuda: resenhas.

## O Que O Skoob Parece Fazer Bem

### 0. Navegacao Observada No App

Observacao feita com o app do Skoob aberto em device real, sem alterar dados da conta.

Abas principais observadas no rodape:

- Inicio.
- Busca.
- Perfil.
- Estante.
- Menu.

Padrao percebido:
- `Inicio` mistura chamadas de proxima acao com feed social.
- `Busca` funciona como descoberta editorial antes mesmo de uma consulta.
- `Perfil` mostra identidade do leitor, contadores e meta de leitura.
- `Estante` e o centro operacional, com filtros/status, paginometro e capas em grade.
- `Menu` parece reservar funcoes secundarias, evitando lotar a navegacao principal.

### 1. Encadeamento De Acao

O fluxo central e facil de entender:

1. Buscar livro pelo rodape.
2. Abrir a tela do livro.
3. Tocar em adicionar a estante.
4. Escolher status: lido, lendo, quero ler, relendo ou abandonei.
5. A partir dai, vincular meta, registrar historico, avaliar ou resenhar.

Aprendizado para o Luminis:
- A acao primaria nao deve terminar no status. Depois de adicionar um livro, o app deve sugerir o proximo passo natural.
- Para `Quero ler`: sugerir adicionar a uma meta ou definir prioridade.
- Para `Lendo`: sugerir registrar pagina atual ou plano de leitura.
- Para `Lido`: sugerir avaliacao/resenha, com cuidado para nao virar rede social cedo demais.

### 2. Estante Como Sistema De Filtros Visuais

O Skoob usa a estante como centro de organizacao e expande filtros/status no topo, incluindo marcadores como meta de leitura.

Aprendizado para o Luminis:
- A Estante nao deve ser apenas uma lista; ela deve comunicar "meu mapa de leitura".
- Filtros por status podem ganhar mais personalidade visual, desde que continuem legiveis.
- A meta pode aparecer como um filtro/sinal dentro da estante, nao apenas como uma aba isolada.
- Capas em grade deixam a biblioteca mais viva do que uma lista puramente textual.
- Marcadores visuais sobre a capa ajudam a identificar status sem roubar a leitura do titulo.
- Um contador agregado, como paginas/livros, torna o progresso pessoal mais tangivel.

### 3. Meta De Leitura Como Motivador

O Skoob posiciona meta como acompanhamento anual, com quantidade de livros, paginas e ritmo de leitura.

Aprendizado para o Luminis:
- A aba Metas deve se conectar melhor com Estante e Leitura.
- O app pode mostrar um resumo pequeno de meta em telas raiz, por exemplo: livros planejados, lidos, paginas e ritmo.
- Evitar gamificacao pesada no MVP; usar motivacao calma, mais literaria e pessoal.
- Perfil pode exibir uma previa da meta com capas e progresso, sem transformar a tela em rede social.

### 4. Jornada Do Livro

O Skoob tem uma Jornada de Leitura na tela do livro, mostrando etapas como adicionar a estante, concluir leitura, preencher data, avaliar e resenhar.

Aprendizado para o Luminis:
- A tela de detalhe do livro pode virar um pequeno "painel de continuidade", nao so metadados.
- Um modulo "Jornada deste livro" seria um bom candidato para a Variante C:
  - Adicionado a estante.
  - Status atual.
  - Progresso registrado.
  - Meta vinculada.
  - Avaliacao/resenha quando estiver no escopo.

### 5. Historico De Leitura

O Skoob permite registrar progresso, impressoes e notas ao longo da leitura.

Aprendizado para o Luminis:
- A aba Leitura precisa deixar claro que o usuario pode voltar ao livro e registrar uma pequena atualizacao.
- O historico pode ser privado por padrao no Luminis, deixando social para uma etapa posterior.
- O valor emocional vem de lembrar "o que senti/pensei enquanto lia", nao apenas de porcentagem.

## O Que Nao Devemos Copiar

- Identidade visual, cor, icones e composicao especifica do Skoob.
- Excesso de funcionalidades sociais antes do MVP estar claro.
- Desafios/rankings como pilar inicial; podem deixar o Luminis menos calmo e mais competitivo.
- Fluxos muito densos com muitas opcoes simultaneas em modais.

## Implicacoes Para A Variante C

### Ajustes Visuais Prioritarios

- Variar capas fallback por livro/status para evitar listas frias e repetitivas em azul.
- Aquecer estados selecionados de chips/segmentados com `Warm`/`Accent` suave, mantendo contraste.
- Manter `Action` escuro apenas para CTA principal, nao como cor dominante de tela.
- Usar progresso, status e meta como pontos de cor, nao decoracao solta.
- Testar Estante em grade ou modo hibrido para itens com capa, mantendo lista quando a decisao exigir mais texto.
- Usar marcadores de status sobre a capa, em vez de depender apenas de chips abaixo do texto.
- Dar mais presenca para capas reais na Busca inicial e nos resultados.

### Ajustes De Navegacao Prioritarios

- Apos adicionar livro a estante, oferecer proximo passo contextual:
  - `Quero ler`: adicionar a meta.
  - `Lendo`: registrar progresso inicial.
  - `Lido`: avaliar ou escrever anotacao curta, quando aprovado.
- Na tela do livro, incluir um bloco de continuidade quando o livro ja estiver na estante.
- Na Estante, destacar relacao com meta e leitura atual.
- Na Leitura, quando nao houver leitura ativa mas houver livros em `Quero ler`, sugerir iniciar um deles em vez de apenas abrir a estante.

## Hipotese Para Teste

Uma Variante C mais quente deve preservar a clareza da Variante B, mas aumentar sensacao de vida ao fazer tres coisas:

1. Transformar status/meta/progresso em sinais visuais recorrentes.
2. Fazer cada acao gerar um proximo passo claro.
3. Usar capas e fallback covers com mais variedade editorial.

## Criterios De Sucesso

- Usuario entende o proximo passo depois de adicionar um livro.
- Estante parece uma biblioteca pessoal viva, nao uma lista fria.
- Buscar continua limpa, mas resultados parecem mais editoriais.
- Leitura deixa de parecer vazia quando ha livros planejados.
- O app continua claramente diferente do Skoob em identidade visual e tom.
