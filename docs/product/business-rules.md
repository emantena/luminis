# Regras De Negocio

Status geral: proposta inicial.

## Identidade do produto

### BR-PRODUCT-001 - Produto

Status: Aprovada

Regra:
Luminis e uma rede social mobile-first para leitores organizarem biblioteca pessoal, acompanharem leituras, descobrirem livros e interagirem com outros leitores.

Complemento:
O produto combina organizador de leitura e rede social literaria. O nucleo e organizar leitura, ler junto, descobrir pelo social e cumprir metas com ritmo realista.

### BR-PRODUCT-002 - Nao leitor de ebooks

Status: Proposta

Regra:
Luminis nao nasce como leitor de ebooks. O foco inicial e organizacao, acompanhamento e socializacao da jornada de leitura.

## Usuarios

### BR-USER-001 - Perfil publico

Status: Aprovada

Regra:
Cada usuario deve possuir perfil com nome exibido, foto opcional, bio opcional, estatisticas resumidas e conteudos publicos.

### BR-USER-002 - Relacoes sociais

Status: Aprovada

Regra:
O produto deve suportar seguidores como relacao social inicial. A relacao nao exige reciprocidade.

Complemento:
Amizade reciproca, mensagens privadas e rankings apenas entre amigos ficam fora do escopo inicial e podem ser avaliados depois.

## Livros e catalogo

### BR-BOOK-001 - Livro como obra catalogavel

Status: Aprovada

Regra:
Na interface, o usuario pode ver o conceito simplificado de livro. No dominio, `Book` representa o livro/obra conceitual e `Edition` representa uma publicacao especifica.

### BR-BOOK-002 - Obra

Status: Aprovada

Regra:
Obra representa o conceito intelectual do livro e agrupa edicoes diferentes.

### BR-BOOK-003 - Edicao

Status: Aprovada

Regra:
Edicao representa uma publicacao especifica de uma obra, com ISBN, capa, editora, idioma, formato e numero de paginas quando disponiveis.

### BR-BOOK-004 - Cadastro manual local

Status: Aprovada

Regra:
Quando um livro nao for encontrado no catalogo, o usuario pode criar um cadastro local para uso imediato.

### BR-BOOK-005 - Sugestao para catalogo global

Status: Aprovada

Regra:
Usuario pode sugerir que um livro local ou correcao de metadados entre no catalogo global do Luminis. Sugestoes devem passar por validacao, curadoria ou processo equivalente antes de afetar o catalogo global.

Escopo:
Essa capacidade fica fora do MVP. No MVP, o cadastro local existe somente para uso privado do usuario.

### BR-BOOK-006 - Curadoria antes de exposicao publica

Status: Aprovada

Regra:
Nenhum livro, edicao ou metadado originado de cadastro local ou sugestao de usuario pode se tornar publico ou integrar o catalogo global antes de validacao, curadoria ou processo equivalente.

Criterios:
- Cadastro local pertence ao usuario que o criou e permanece privado ate sua curadoria.
- Um cadastro local pode ser usado imediatamente na estante pessoal sem ser promovido ao catalogo global.
- Sugestoes e correcoes nao devem alterar resultados publicos do catalogo enquanto estiverem pendentes de curadoria.

### BR-BOOK-007 - Importacao por fonte aprovada

Status: Aprovada

Regra:
Metadados originados de provedores externos previamente aprovados podem integrar o catalogo global sob demanda, desde que o backend os normalize, valide e deduplique antes da persistencia.

Complemento:
A aprovacao da fonte e os controles automaticos compoem a governanca necessaria para essa importacao. Essa regra nao se aplica a cadastros, sugestoes ou correcoes enviados por usuarios.

### BR-BOOK-008 - Assuntos importados do catalogo

Status: Aprovada

Regra:
O Catalog deve preservar assuntos ou categorias retornados por provedores externos aprovados e vinculados a obras importadas.

Escopo do MVP:
- Assuntos formam uma lista plana, sem hierarquia, sinonimos ou equivalencias manuais.
- A origem do vinculo com o assunto deve ser preservada internamente.
- Usuarios nao criam nem publicam assuntos no MVP.

## Estante

### BR-BOOKSHELF-001 - Item na estante

Status: Aprovada

Regra:
Um usuario adiciona uma edicao global ou um cadastro local privado a sua estante criando um item de estante pertencente ao usuario.

Criterios:
- Item global deve referenciar `bookId` e `editionId`.
- `editionId` e obrigatorio para item global.
- `editionId` deve pertencer ao `bookId` informado.
- Item local deve referenciar `userBookDraftId` e nao deve informar `bookId` nem `editionId`.
- O mesmo usuario nao pode ter dois itens ativos para a mesma `editionId`.
- O mesmo usuario pode ter mais de um item ativo do mesmo `bookId` quando forem edicoes diferentes.
- O mesmo usuario nao pode ter dois itens ativos para o mesmo `userBookDraftId`.

### BR-BOOKSHELF-002 - Status de leitura unico

Status: Aprovada

Regra:
Cada item de estante deve possuir no maximo um status principal de leitura por vez.

Status iniciais:
- `want_to_read`
- `reading`
- `paused`
- `read`
- `rereading`
- `abandoned`

Semantica:
- `want_to_read`: o usuario pretende ler futuramente e nao ha leitura em andamento.
- `reading`: o usuario esta lendo atualmente.
- `paused`: o usuario iniciou a leitura, mas pausou sem abandonar.
- `read`: o usuario concluiu a leitura.
- `rereading`: o usuario esta relendo atualmente.
- `abandoned`: o usuario abandonou a leitura.

### BR-BOOKSHELF-003 - Etiquetas auxiliares

Status: Aprovada

Regra:
Etiquetas auxiliares nao substituem o status principal de leitura. Elas representam qualificadores pessoais de organizacao da estante.

Criterios:
- Etiquetas auxiliares iniciais sao `isFavorite`, `isOwned`, `isWished`, `isBorrowed`, `isLent`, `isEbook` e `isAudiobook`.
- Etiquetas auxiliares devem ser atualizadas separadamente do status principal de leitura.
- Atualizar etiquetas nao deve criar, pausar, concluir nem cancelar sessoes ou planos de leitura.
- Atualizacao de etiquetas deve aceitar alteracao parcial.

### BR-BOOKSHELF-004 - Remocao da estante

Status: Aprovada

Regra:
Remover um item da estante deve desfazer o vinculo ativo do usuario com aquela edicao global ou cadastro local, sem apagar catalogo, cadastro local ou historico de progresso.

Criterios:
- Remocao da estante deve ser logica.
- Item removido nao deve aparecer na listagem padrao da estante.
- Remover item deve cancelar plano ativo relacionado.
- Remover item deve marcar sessao ativa ou pausada relacionada como `interrupted`.
- Registros de progresso devem permanecer preservados.
- Remover item nao deve apagar `Book`, `Edition` nem cadastro local.
- O usuario pode adicionar novamente a mesma edicao ou cadastro local depois da remocao.

### BR-BOOKSHELF-005 - Escolha explicita de status

Status: Aprovada

Regra:
Ao adicionar uma obra global ou cadastro local a estante, o usuario deve escolher explicitamente o status de leitura. O sistema nao deve presumir nem atribuir automaticamente um status em nome do usuario.

### BR-BOOKSHELF-006 - Alteracao de status

Status: Aprovada

Regra:
Alterar o status principal de leitura representa uma intencao explicita do usuario e deve atualizar os recursos de leitura relacionados quando fizer sentido.

Criterios:
- Ao mudar de `paused` para `reading`, o sistema deve reativar a mesma sessao de leitura pausada.
- Ao mudar para `reading` sem sessao pausada ou ativa, o sistema deve criar uma sessao de leitura ativa.
- Ao mudar para `rereading`, o sistema deve garantir uma nova sessao de leitura ativa quando nao houver uma.
- Ao mudar para `paused`, o sistema deve pausar a sessao ativa, preservar o historico de progresso e cancelar o plano ativo.
- Ao mudar para `read`, o sistema deve finalizar a sessao ativa e marcar o plano ativo como concluido.
- Ao mudar para `abandoned`, o sistema deve finalizar a sessao ativa como abandonada e cancelar o plano ativo.
- Ao mudar para `want_to_read`, o sistema deve cancelar automaticamente o plano ativo.
- Ao mudar para `want_to_read` com sessao ativa ou pausada, o usuario deve escolher se quer manter a sessao para retomar depois ou encerrar aquela tentativa de leitura.
- Se o usuario escolher manter para retomar depois, a sessao deve permanecer ou voltar para `paused`.
- Se o usuario escolher encerrar aquela tentativa, a sessao deve ser marcada como `interrupted`.
- Data alvo de conclusao nao faz parte da alteracao de status; ela pode ser definida, alterada ou removida a qualquer momento pelo plano de leitura.

### BR-BOOKSHELF-007 - Listagem da estante

Status: Aprovada

Regra:
O usuario deve conseguir listar os itens ativos da propria estante com filtros por status principal e etiquetas auxiliares.

Criterios:
- A listagem retorna apenas itens do usuario autenticado.
- Itens removidos da estante nao aparecem na listagem padrao.
- Filtros por status e etiquetas auxiliares podem ser combinados.
- A resposta deve trazer dados suficientes para exibir livro/edicao ou cadastro local sem chamadas adicionais obrigatorias.
- Busca textual dentro da estante fica fora do contrato inicial.

## Progresso de leitura

### BR-READING-001 - Registro de progresso

Status: Aprovada

Regra:
Usuarios podem registrar progresso de leitura por pagina ou percentual, dependendo dos dados disponiveis da edicao.

Criterios:
- Progresso pertence a uma sessao de leitura.
- A sessao precisa estar ativa para receber novo progresso.
- Sessao pausada deve ser retomada antes de receber novo progresso.
- Pagina informada nao pode exceder o total de paginas da edicao quando esse total for conhecido.
- Pagina informada nao pode ser menor que a ultima pagina registrada na mesma sessao; nesse caso, o sistema deve rejeitar o registro e informar o usuario.
- Percentual informado deve estar entre 0 e 100.
- Quando o usuario registrar progresso na ultima pagina conhecida da edicao, ou em `100%`, o sistema deve concluir automaticamente a leitura, mudando o status para `read`.
- Quando o usuario alterar manualmente o status para `read` e a edicao tiver total de paginas conhecido, o sistema deve criar um registro de progresso final na ultima pagina quando esse progresso ainda nao existir.

### BR-READING-002 - Historico de leitura

Status: Aprovada

Regra:
Cada registro de progresso deve preservar data/hora, progresso informado e comentario opcional.

### BR-READING-003 - Conclusao

Status: Aprovada

Regra:
Ao concluir uma leitura, o item deve poder mudar para `read` e receber uma data de conclusao.

Criterios:
- A conclusao pode acontecer por acao explicita do usuario ao mudar o status para `read`.
- A conclusao tambem pode acontecer automaticamente quando o progresso registrado atingir a ultima pagina conhecida ou `100%`.
- Ao concluir, a sessao ativa deve ser finalizada e o plano ativo deve ser marcado como concluido.

### BR-READING-005 - Plano de leitura

Status: Aprovada

Regra:
Um usuario pode informar uma data alvo de conclusao por meio de um plano de leitura.

Criterios:
- Plano de leitura pertence a um item da estante.
- Um item da estante pode ter no maximo um plano ativo.
- A data alvo de conclusao pertence ao plano de leitura, nao ao item da estante nem a sessao de leitura.
- A data alvo pode ser definida, alterada ou removida a qualquer momento.
- Ao pausar uma leitura, o plano ativo deve ser cancelado no MVP.
- Ao retomar uma leitura pausada, a mesma sessao de leitura deve ser reativada.
- O ponto de retomada deve vir do progresso mais recente da sessao, por pagina ou percentual.
- Ao retomar uma leitura pausada, o usuario pode criar um novo plano informando nova data alvo.
- O app deve calcular a sugestao de paginas por dia a partir do plano ativo, progresso mais recente e total de paginas da edicao.
- `dailyPagesTarget` nao deve ser persistido no MVP.

### BR-READING-004 - Ritmo acionavel

Status: Aprovada

Regra:
O app deve sugerir uma quantidade de paginas por dia para que o usuario alcance uma data alvo de conclusao.

Criterios:
- A sugestao deve considerar paginas restantes e dias restantes.
- Quando total de paginas ou data alvo estiverem ausentes, o app deve informar que nao consegue calcular a sugestao.
- Quando o ritmo necessario for alto, o app deve poder sugerir ajustar a data alvo em vez de pressionar o usuario.

### BR-READING-006 - Estado de leitura

Status: Aprovada

Regra:
O app deve conseguir consultar o estado consolidado de leitura de um item da estante para montar a tela de leitura atual.

Criterios:
- Estado de leitura consolida item da estante, sessao ativa ou pausada, ultimo progresso, plano ativo e ritmo calculado quando possivel.
- Estado de leitura nao e uma nova entidade de dominio persistida.
- Quando nao houver sessao ativa ou pausada, o estado deve retornar sessao e ultimo progresso ausentes.
- O ritmo calculado deve informar claramente quando nao puder ser calculado.
- `dailyPagesTarget` no estado de leitura e calculado, nao persistido.

## Avaliacoes e resenhas

### BR-REVIEW-001 - Avaliacao

Status: Aprovada

Regra:
Usuario pode avaliar uma obra com nota de 0.5 a 5.0 estrelas.

Criterios:
- Cada usuario deve ter no maximo uma avaliacao ativa por obra.
- A edicao lida pode ser registrada junto da experiencia de leitura, sem fragmentar a avaliacao principal por edicao.

### BR-REVIEW-002 - Resenha

Status: Proposta

Regra:
Usuario pode publicar resenha textual para livro lido. A primeira versao deve validar tamanho minimo de 100 caracteres, inspirada no comportamento observado no Skoob.

### BR-REVIEW-003 - Spoiler

Status: Proposta

Regra:
Resenhas devem permitir marcacao de spoiler. Conteudos marcados devem exigir uma acao explicita do leitor antes de exibir o texto integral.

## Social

### BR-SOCIAL-001 - Feed

Status: Proposta

Regra:
O feed deve exibir atividades relevantes de leitura, como livro adicionado, progresso publicado, livro concluido, avaliacao e resenha.

### BR-SOCIAL-002 - Comentarios

Status: Proposta

Regra:
Usuarios podem comentar atividades e resenhas publicas.

### BR-SOCIAL-003 - Bloqueio

Status: Proposta

Regra:
Usuario deve poder bloquear outro usuario. Bloqueio deve restringir interacoes diretas e reduzir visibilidade social entre as partes.

## Grupos de leitura

### BR-GROUP-001 - Grupo de leitura

Status: Aprovada

Regra:
Usuarios podem criar grupos de leitura para ler e discutir livros junto com outras pessoas.

### BR-GROUP-002 - Visibilidade do grupo

Status: Aprovada

Regra:
Ao criar um grupo de leitura, o criador deve definir se o grupo e publico ou fechado.

Criterios:
- Grupo publico pode ser encontrado por outros usuarios.
- Grupo fechado deve exigir convite, aprovacao ou outro mecanismo controlado de entrada.
- A visibilidade do grupo deve afetar descoberta, entrada e exposicao de atividades.

### BR-GROUP-005 - Entrada em grupo publico

Status: Aprovada

Regra:
Grupo publico pode ter entrada livre ou entrada por aprovacao, conforme configuracao definida na criacao do grupo.

### BR-GROUP-006 - Cronograma com checkpoints

Status: Aprovada

Regra:
Grupos de leitura devem suportar cronograma coletivo com data de inicio, data prevista de fim e checkpoints opcionais.

Criterios:
- Checkpoint pode ter titulo, data alvo e pagina ou capitulo alvo.
- Discussao pode ser vinculada a checkpoint.
- Checkpoints devem ajudar a reduzir spoilers fora do ponto de leitura combinado.

### BR-GROUP-003 - Moderacao do grupo

Status: Proposta

Regra:
Todo grupo deve ter ao menos um dono ou moderador responsavel por configuracoes, entrada de membros e moderacao basica.

### BR-GROUP-004 - Grupo associado a livro

Status: Proposta

Regra:
A primeira versao de grupos deve priorizar grupos associados a um livro especifico, pois isso simplifica cronograma, ritmo de leitura e discussoes.

## Recomendacoes

### BR-RECOMMENDATION-001 - Recomendacao social

Status: Aprovada

Regra:
As recomendacoes iniciais do Luminis devem ser baseadas principalmente em sinais sociais, nao em IA generativa.

Criterios:
- Sinais sociais incluem pessoas seguidas, leitores com gosto parecido, membros de grupos, livros populares entre conexoes, avaliacoes e livros adicionados a estante por pessoas relacionadas.
- IA pode ser adicionada no futuro como camada auxiliar, mas nao e o principio inicial da recomendacao.

### BR-RECOMMENDATION-002 - Contexto da recomendacao

Status: Proposta

Regra:
Recomendacoes devem explicar o motivo de aparecerem quando possivel.

Exemplos:
- Pessoas que voce segue leram.
- Popular entre membros dos seus grupos.
- Bem avaliado por leitores com gosto parecido.
- Muitos leitores colocaram em quero ler.

## Feed e publicacao

### BR-FEED-001 - Feed hibrido

Status: Aprovada

Regra:
O feed deve usar modelo hibrido de publicacao: algumas atividades aparecem automaticamente, enquanto outras exigem confirmacao ou configuracao do usuario.

Complemento:
O MVP nao tera feed completo. Quando o social entrar, o feed inicial deve usar padroes fixos e respeitosos antes de oferecer configuracoes finas por tipo de atividade.

## MVP

### BR-MVP-001 - Organizador pessoal primeiro

Status: Aprovada

Regra:
O MVP deve priorizar a experiencia de organizador pessoal de leitura antes do feed social completo, grupos e recomendacoes sociais.

Escopo:
- Estante pessoal.
- Busca/catalogo inicial.
- Detalhe do livro.
- Status de leitura.
- Registro de progresso por pagina.
- Ritmo de leitura com paginas por dia ate data alvo.
- Metas mensais e anuais, com base preparada para periodos flexiveis e metricas por livros ou paginas.
- Cadastro local privado de livro quando nao houver edicao no catalogo.
- Perfil simples.

Fora do MVP:
- Feed social completo.
- Grupos de leitura.
- Recomendacoes sociais.
- Comentarios.
- Seguidores em experiencia completa.
- Resenhas avancadas.
- Moderacao.

## Privacidade

### BR-PRIVACY-001 - Privacidade hibrida

Status: Aprovada

Regra:
Luminis deve adotar privacidade hibrida: conteudos basicos de perfil e leitura podem ser publicos por padrao, enquanto sinais sensiveis ficam privados por padrao.

Publico por padrao:
- Perfil basico.
- Estante.
- Livros lidos.
- Resenhas publicadas.
- Avaliacoes.

Privado por padrao:
- Progresso detalhado.
- Notas pessoais.
- Ritmo individual.
- Livro abandonado.
- Grupos fechados.
- Anotacoes.
- Trechos.
- Data alvo pessoal.

### BR-PRIVACY-002 - Confirmacao para atividades sensiveis

Status: Aprovada

Regra:
Atividades sensiveis devem exigir confirmacao antes de aparecer no feed.

### BR-FEED-002 - Privado por padrao para sinais sensiveis

Status: Proposta

Regra:
Progresso detalhado, abandono de livro, notas pessoais, ritmo individual e grupos fechados devem ser privados por padrao.

### BR-FEED-003 - Publicacao automatica inicial

Status: Proposta

Regra:
Resenha publicada e livro concluido podem gerar atividade automaticamente, respeitando configuracoes futuras de privacidade.

## Metas e estatisticas

### BR-GOAL-001 - Meta anual

Status: Aprovada

Regra:
Usuario pode definir uma meta anual de livros lidos.

### BR-GOAL-002 - Meta mensal

Status: Aprovada

Regra:
Usuario pode definir meta mensal de leitura.

### BR-GOAL-003 - Metricas de meta

Status: Aprovada

Regra:
Metas de leitura devem suportar livros lidos e paginas lidas como metricas iniciais.

Complemento:
Para metas por paginas lidas, o sistema deve calcular o avanco de leitura entre registros de progresso. `pageNumber` representa a posicao atual no livro; o avanco de leitura representa quantas paginas novas foram lidas desde o ultimo progresso da mesma sessao.

Quando o progresso for registrado apenas por percentual, ele so deve contar para metas de paginas lidas se a edicao tiver total de paginas conhecido. Em leituras como Kindle, onde nem sempre ha paginas disponiveis, o percentual continua valido para acompanhamento e conclusao em `100%`, mas nao gera paginas lidas para a meta.

Para metas por livros lidos, o sistema deve contar leituras concluidas dentro do periodo da meta, usando a data de conclusao da leitura.

Releituras contam como novas leituras concluidas. Por isso, a metrica de livros lidos deve considerar sessoes de leitura finalizadas como `finished`, e nao somente a ultima data de conclusao do item da estante.

Exemplo:
- Primeiro registro na pagina 100 conta 100 paginas.
- Registro seguinte na pagina 120 conta 20 paginas.
- Registro seguinte na pagina 150 conta 30 paginas.

Nesse exemplo, a meta recebe 150 paginas lidas, nao 370.

### BR-GOAL-004 - Periodos flexiveis

Status: Aprovada

Regra:
O schema de metas deve suportar periodos mensal, bimestral, trimestral, semestral, anual e customizado, mesmo que o MVP exponha apenas parte desses periodos na UI.

### BR-GOAL-005 - Meta privada por padrao

Status: Aprovada

Regra:
Metas devem ser privadas por padrao e usar um campo booleano `is_public` para exposicao publica.

### BR-GOAL-006 - Conclusao e bonus de meta

Status: Aprovada

Regra:
Quando o usuario atingir o valor alvo de uma meta, a meta deve ser marcada como concluida. Leituras ou paginas registradas depois da conclusao, mas ainda dentro do periodo da meta, devem continuar sendo calculadas como bonus/excedente.

Complemento:
Essa regra prepara o produto para gamificacao futura sem exigir mecanicas de recompensa no MVP.

### BR-GOAL-007 - Sem conclusao manual de meta

Status: Aprovada

Regra:
Usuario nao pode marcar uma meta como concluida manualmente. A conclusao de meta deve acontecer somente por calculo do sistema quando o valor atual atingir ou ultrapassar o valor alvo.

Criterios:
- Usuario pode editar uma meta ativa.
- Usuario pode cancelar uma meta ativa.
- Usuario pode corrigir leituras, paginas ou livros que alimentam o calculo da meta.
- Usuario nao pode forcar `completed`, `completedAt` ou equivalente por acao direta.

### BR-GOAL-008 - Meta vencida nao atingida

Status: Aprovada

Regra:
Quando uma meta ativa passar da data final sem atingir o alvo, ela deve continuar ativa e o app deve alertar o usuario que a meta nao foi alcancada.

Criterios:
- O backend deve expor estado calculado suficiente para o Flutter identificar meta vencida e nao atingida.
- O Flutter deve apresentar o alerta e oferecer opcao para o usuario alterar a meta.
- A meta nao deve ser encerrada automaticamente como falhada.
- A meta nao deve ser concluida manualmente para esconder o nao atingimento.

### BR-STATS-001 - Estatisticas basicas

Status: Proposta

Regra:
Estatisticas iniciais devem incluir livros lidos no ano, paginas lidas, media de paginas por dia, generos mais lidos, autores mais lidos e historico mensal.

## Descoberta

### BR-DISCOVERY-001 - Busca

Status: Proposta

Regra:
Busca deve permitir encontrar livros, autores e usuarios.

### BR-DISCOVERY-002 - ISBN

Status: Aberto

Regra:
Scanner de codigo de barras/ISBN e desejavel, mas deve ser planejado conforme dependencia de camera e fonte confiavel de catalogo.
