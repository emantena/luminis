# Prototipo De Telas MVP

Status: aprovado como guia de prototipacao.

Este documento define as telas iniciais do prototipo Flutter com dados mockados. O objetivo e validar fluxo, navegacao e usabilidade antes da implementacao definitiva com backend.

## Organizacao Dos Artefatos

- Especificacao detalhada das telas: este documento.
- Indice visual e ordem de revisao: `docs/ux/prototypes/README.md`.
- Previews de telas e bottom sheets: `docs/ux/prototypes/`.
- Fundamentos visuais e componentes: `docs/ux/design-system.md`.
- Navegacao aprovada: `docs/architecture/navigation.md`.

## Principios

- Usar a navegacao aprovada em `docs/architecture/navigation.md`.
- Usar dados mockados em memoria.
- Prototipar o app real do MVP, nao uma landing page.
- Priorizar uso mobile.
- Provar valor como organizador pessoal antes de social completo.

## Mapa De Telas

### Auth

Telas:
- Welcome: `/auth/welcome`
- Login: `/auth/login`
- Cadastro: `/auth/register`
- Recuperar senha: `/auth/forgot-password`
- Redefinir senha: `/auth/reset-password`

Objetivo:
Validar entrada por Google, email/senha, cadastro e recuperacao de senha.

Acoes principais:
- Entrar com Google.
- Entrar com email e senha.
- Criar conta.
- Solicitar recuperacao de senha.

Navega para:
- `/bookshelf` apos autenticacao mockada.

Estados:
- Usuario nao autenticado.
- Login com Google disponivel.
- Login por email e senha.
- Cadastro por email e senha.
- Recuperacao de senha solicitada.
- Redefinicao de senha por token.
- Erro de credenciais invalidas.
- Conta temporariamente bloqueada.

Composicao visual aprovada para prototipacao:
- O fluxo publico deve ser simples e direto, sem landing page.
- `Welcome` deve priorizar `Entrar com Google`, especialmente para usuarios Android.
- `Welcome` tambem deve oferecer `Entrar com email` e `Criar conta`.
- `Login` deve conter email, senha, acao `Entrar`, link `Esqueci minha senha` e alternativa para criar conta.
- `Cadastro` deve conter nome exibido, email, senha e confirmacao de senha.
- `Forgot password` deve pedir email e informar que, se o email existir, as instrucoes serao enviadas sem revelar existencia de conta.
- `Reset password` deve pedir nova senha e confirmacao de senha.
- Usuario autenticado nao deve permanecer em telas publicas; deve ir para `/bookshelf`.
- Erros devem aparecer proximos ao campo ou como alerta compacto, sem expor detalhes sensiveis.
- No prototipo mockado, qualquer autenticacao bem sucedida navega para `/bookshelf`.

Referencia visual:
- `docs/ux/prototypes/auth-welcome-screen-preview.png`

### Estante

Rota:
- `/bookshelf`

Objetivo:
Mostrar biblioteca pessoal ativa do usuario.

Dados:
- Itens ativos da estante.
- Status de leitura.
- Etiquetas auxiliares.
- Dados resumidos de livro/edicao ou cadastro local.

Acoes:
- Filtrar por status.
- Filtrar por etiquetas.
- Abrir leitura de um item.
- Alterar etiquetas.
- Remover item.
- Ir para busca.

Navega para:
- `/reading/:bookshelfItemId`
- `/search`

Estados:
- Estante vazia.
- Item lendo.
- Item pausado.
- Item quero ler.
- Item lido.

Composicao visual aprovada para prototipacao:
- Topo simples com saudacao curta, titulo `Estante` e acao de busca/adicao.
- Usar dois cards separados no inicio quando houver leitura/meta: `Lendo agora` e `Meta ativa`.
- O card `Lendo agora` deve destacar o livro atual, progresso e ponto de leitura.
- O card `Meta ativa` deve destacar progresso da meta e sugestao de ritmo, por exemplo `Leia 18 paginas por dia para cumprir`.
- Meta deve aparecer como contexto rapido, nao como dashboard completa; detalhes continuam na aba `Metas`.
- Se houver meta vencida e nao atingida, exibir alerta compacto com acao para revisar na aba `Metas`.
- Filtros por status em chips horizontais, usando o mapeamento de cores de `docs/ux/design-system.md`.
- Lista vertical de `BookCard`, com capa a esquerda, titulo, autor, edicao/idioma e status.
- Itens em leitura devem exibir progresso e atalho claro para continuar.
- Itens pausados devem exibir status sem parecer erro.
- Bottom navigation fixa com abas aprovadas do MVP.

Referencia visual:
- `docs/ux/prototypes/bookshelf-screen-preview.png`

### Buscar

Rota:
- `/search`

Objetivo:
Buscar livros no catalogo mockado.

Dados:
- Termo.
- Tipo de busca: todos, titulo, autor, editora, assunto, ISBN.
- Resultados por edicao.

Acoes:
- Buscar.
- Abrir detalhe.
- Criar cadastro local quando nao encontrar.

Navega para:
- `/books/:bookId`
- `/book-drafts/new`

Estados:
- Sem termo.
- Com resultados.
- Sem resultados.
- Erro de provedor simulado.

Composicao visual aprovada para prototipacao:
- Topo com titulo `Buscar` e texto curto orientado a acao.
- Campo de busca grande e persistente, com acao de limpar quando houver termo.
- Abas/chips principais de descoberta: livros, autores e leitores.
- Filtros por tipo dentro de livros: todos, titulo, autor, editora, assunto e ISBN.
- Quando nao houver termo, a tela deve funcionar como descoberta: editoras em carrossel horizontal e grade de novidades/lancamentos.
- Editoras devem usar `logoUrl` quando existir, reforcando a decisao de manter editora no catalogo.
- Resultados pesquisados devem ser apresentados por edicao, com capa, titulo da obra, autor, editora, idioma, formato, paginas e ISBN quando disponivel.
- Cada resultado deve deixar claro se ja esta na estante.
- Acao primaria por resultado: abrir detalhe da obra/edicao.
- Quando nao houver resultados, oferecer `Criar cadastro local`.
- Erro de provedor deve permitir tentar novamente e criar cadastro local sem bloquear o usuario.
- Bottom navigation fixa com aba `Buscar` ativa.

Referencia visual:
- `docs/ux/prototypes/search-screen-preview.png`

### Detalhe Do Livro

Rota:
- `/books/:bookId`

Objetivo:
Mostrar obra e edicoes disponiveis para adicionar a estante.

Dados:
- Book.
- Autores.
- Descricao.
- Assuntos.
- Edicoes.
- Capa, editora, idioma, formato, paginas e ISBN.

Acoes:
- Selecionar edicao.
- Adicionar a estante escolhendo status.
- Iniciar leitura apos adicionar.

Navega para:
- `/bookshelf`
- `/reading/:bookshelfItemId`

Estados:
- Uma edicao.
- Multiplas edicoes do mesmo livro.
- Edicao sem `pageCount`.

Composicao visual aprovada para prototipacao:
- Tela sequencial com composicao editorial, priorizando capa, identidade da edicao e decisao de adicionar.
- Hero visual com capa grande centralizada, fundo derivado da capa e acao de voltar.
- Bloco de identidade com titulo da obra/edicao, autor, avaliacao media mockada e total de avaliacoes.
- Acao principal proxima ao topo: `Adicionar a estante`.
- Nao exibir card promocional externo no MVP. Link externo/afiliado, como Amazon, pode ser avaliado futuramente fora do MVP.
- Secao `Sinopse` com texto truncado e acao `Ver mais`.
- Secao de metadados da edicao com editora, ano, paginas, ISBN, idioma e formato.
- Editora deve ter presenca visual com logo/nome quando existir.
- Secao `Generos`/assuntos em chips.
- Secao `Outras edicoes` com cards selecionaveis quando houver multiplas edicoes.
- Cada edicao deve mostrar editora, idioma, formato, ano, paginas e ISBN quando disponivel.
- Se a edicao ja estiver na estante, mostrar status e bloquear duplicidade ativa.
- Ao adicionar, o usuario deve escolher status inicial: `Quero ler`, `Lendo` ou `Lido`.
- Se escolher `Lendo`, oferecer caminho para iniciar leitura apos adicionar.
- Quando a edicao nao tiver paginas, avisar discretamente que progresso e ritmo podem usar percentual.
- Avaliacoes agregadas simples podem aparecer no prototipo. Resenhas completas ficam fora do foco do MVP inicial.

Referencia visual:
- `docs/ux/prototypes/book-detail-screen-preview.png`

### Adicionar A Estante

Tipo:
- Bottom sheet acionado por `Adicionar a estante` no detalhe do livro.

Objetivo:
Escolher o status inicial do item antes de adicionar a edicao selecionada a estante.

Dados:
- Livro/obra.
- Edicao selecionada.
- Capa.
- Editora.
- Idioma.
- Formato.
- Paginas quando conhecidas.

Acoes:
- Escolher `Quero ler`.
- Escolher `Lendo`.
- Escolher `Lido`.
- Confirmar adicao.
- Cancelar.

Regras:
- O bottom sheet deve mostrar somente status disponiveis no momento da adicao: `Quero ler`, `Lendo` e `Lido`.
- `Relendo`, `Pausado` e `Abandonei` nao entram como status inicial na adicao.
- Se a edicao ja estiver ativa na estante, nao exibir confirmacao de adicao; orientar usuario a abrir o item existente.
- Se o usuario escolher `Lendo`, apos confirmar deve haver caminho claro para ir para a tela de leitura.
- Data alvo nao deve ser exigida no bottom sheet; ela pode ser definida depois no plano de leitura.

Navega para:
- `/bookshelf` quando adicionar como `Quero ler` ou `Lido`.
- `/reading/:bookshelfItemId` quando adicionar como `Lendo` e usuario escolher continuar leitura.

Referencia visual:
- `docs/ux/prototypes/add-to-bookshelf-bottom-sheet-preview.png`

### Cadastro Local

Rota:
- `/book-drafts/new`

Objetivo:
Criar livro local privado quando catalogo nao encontrar a edicao.

Dados:
- Titulo.
- Autores.
- Editora.
- Ano.
- Idioma.
- Formato.
- Paginas opcionais.
- Capa opcional.

Acoes:
- Salvar draft.
- Adicionar draft a estante.

Navega para:
- `/bookshelf`
- `/reading/:bookshelfItemId`

Estados:
- Cadastro iniciado a partir de busca sem resultado.
- Titulo ausente.
- Autor ausente.
- Paginas desconhecidas.
- Capa ausente.

Composicao visual aprovada para prototipacao:
- Tela de formulario aberta quando a busca nao encontra a edicao desejada.
- Topo com voltar e titulo `Cadastro local`.
- Exibir aviso compacto de que o livro sera privado e usado apenas na estante do usuario no MVP.
- Campos obrigatorios no MVP: titulo e autor.
- Campos opcionais: editora, ano, idioma, formato, paginas e capa.
- Paginas devem ser opcionais para cobrir leituras sem total conhecido, como Kindle.
- Quando paginas ficarem vazias, progresso futuro deve poder usar percentual e ritmo por paginas ficara indisponivel.
- Capa opcional deve ter area de upload/fallback visual, sem bloquear salvamento.
- Acao primaria: `Salvar e adicionar`.
- Apos salvar, abrir escolha de status inicial ou adicionar diretamente com status escolhido no proprio formulario; no prototipo, usar escolha de status no formulario para reduzir um passo.
- Status inicial deve permitir apenas `Quero ler`, `Lendo` ou `Lido`.
- Se escolher `Lendo`, apos salvar navegar para `/reading/:bookshelfItemId`.
- Se escolher `Quero ler` ou `Lido`, apos salvar navegar para `/bookshelf`.
- Nao oferecer sugestao para catalogo global no MVP.

Referencia visual:
- `docs/ux/prototypes/local-book-draft-screen-preview.png`

### Leitura

Rota:
- `/reading`

Objetivo:
Mostrar leituras atuais e atalhos para continuar.

Dados:
- Sessoes ativas.
- Sessoes pausadas relevantes.
- Ultimo progresso.
- Plano ativo.
- Ritmo calculado quando possivel.

Acoes:
- Abrir leitura atual.
- Retomar leitura pausada.
- Ir para estante.

Navega para:
- `/reading/:bookshelfItemId`
- `/bookshelf`

Estados:
- Sem leitura atual.
- Uma leitura ativa.
- Varias pausadas.

Composicao visual aprovada para prototipacao:
- Tela principal da aba `Leitura`, com bottom navigation fixa e aba `Leitura` ativa.
- Deve funcionar como hub de continuidade, nao como duplicacao completa da estante.
- Topo com titulo `Leitura` e resumo curto do momento atual.
- Quando houver uma leitura ativa, destacar um card principal `Continuar lendo` com capa, titulo, progresso, ultimo ponto e ritmo quando calculavel.
- Acao primaria do card ativo: `Continuar`, navegando para `/reading/:bookshelfItemId`.
- Quando houver plano ativo, mostrar a sugestao de paginas por dia de forma compacta.
- Abaixo do card principal, exibir `Pausados` com leituras pausadas relevantes.
- Leitura pausada deve mostrar ponto de parada e acao `Retomar`, navegando para `/reading/:bookshelfItemId`.
- Ao retomar, a mesma sessao pausada deve ser reativada; novo plano pode ser definido depois.
- Estado vazio deve orientar o usuario a escolher um livro na estante ou buscar livro.
- A tela deve evitar filtros completos; organizacao por status continua sendo papel da Estante.

Referencia visual:
- `docs/ux/prototypes/reading-screen-preview.png`

### Estado De Leitura

Rota:
- `/reading/:bookshelfItemId`

Objetivo:
Concentrar progresso, status, plano e ritmo de um item.

Dados:
- Item da estante.
- Book/Edition ou draft.
- Sessao ativa ou pausada.
- Ultimo progresso.
- Plano ativo.
- Ritmo calculado.

Acoes:
- Registrar progresso.
- Definir ou alterar data alvo.
- Pausar.
- Retomar.
- Marcar como lido.
- Mudar para quero ler.
- Abandonar.

Navega para:
- `/reading/:bookshelfItemId/progress/new`
- `/reading/:bookshelfItemId/plan`
- `/bookshelf`

Estados:
- Sem sessao iniciada.
- Sessao ativa.
- Sessao pausada.
- Sem `pageCount`, permitindo progresso por percentual.
- Ritmo indisponivel.

Composicao visual aprovada para prototipacao:
- Tela de continuidade da leitura, com foco em responder rapidamente: onde parei, quanto falta e o que faco agora.
- Topo simples com voltar, titulo `Leitura` e status principal em chip.
- Bloco compacto do livro com capa, titulo, autor, editora/idioma e edicao.
- Card principal de progresso com pagina ou percentual atual, barra de progresso, paginas restantes quando calculavel e ultimo registro.
- Card de plano com data alvo, sugestao de ritmo e acao `Alterar plano`.
- Quando houver plano ativo e paginas conhecidas, exibir frase acionavel, por exemplo `Leia 18 paginas por dia para terminar ate 30/09`.
- Quando nao houver plano ativo, exibir acao secundaria `Definir data alvo`.
- Quando a edicao nao tiver total de paginas, priorizar percentual e informar ritmo indisponivel de forma neutra.
- Acao primaria fixa ou muito proxima do conteudo principal: `Registrar progresso`.
- Acoes secundarias devem ficar abaixo da acao primaria: pausar/retomar, marcar como lido, voltar para quero ler e abandonar.
- Em sessao pausada, a acao primaria muda para `Retomar leitura`; registrar progresso fica indisponivel ate retomar.
- Ao marcar como lido com paginas conhecidas, o sistema cria progresso final se necessario.
- Ao registrar ultima pagina conhecida ou `100%`, a leitura e concluida automaticamente.
- Ao mudar para `Quero ler` com sessao ativa ou pausada, abrir decisao para manter progresso pausado ou encerrar tentativa.
- A tela nao deve parecer dashboard; deve parecer uma area de acao diaria.

Referencia visual:
- `docs/ux/prototypes/reading-state-screen-preview.png`

### Registrar Progresso

Rota:
- `/reading/:bookshelfItemId/progress/new`

Objetivo:
Registrar pagina atual ou percentual lido.

Dados:
- Sessao ativa.
- Ultimo progresso.
- `pageCount` quando conhecido.

Acoes:
- Informar pagina.
- Informar percentual.
- Adicionar anotacao opcional.
- Definir se progresso e publico.
- Salvar progresso.

Navega para:
- `/reading/:bookshelfItemId`

Estados:
- Pagina menor que progresso anterior.
- Pagina igual ao total conhecido, concluindo leitura.
- Percentual 100, concluindo leitura.
- Edicao sem paginas conhecidas.

Composicao visual aprovada para prototipacao:
- Tela curta e objetiva, aberta a partir de `Estado De Leitura`.
- Topo com voltar e titulo `Registrar progresso`.
- Resumo compacto do livro e do ultimo ponto registrado para dar contexto antes do formulario.
- Quando a edicao tiver `pageCount`, priorizar entrada por pagina atual.
- Campo principal: `Pagina atual`, com total visivel ao lado, por exemplo `de 500`.
- Exibir barra de progresso prevista conforme o valor digitado.
- Exibir diferenca calculada em relacao ao ultimo registro, por exemplo `+40 paginas desde ontem`.
- Permitir alternar para percentual quando fizer sentido, sem esconder que pagina e o modo preferencial quando total for conhecido.
- Quando a edicao nao tiver `pageCount`, priorizar entrada por percentual.
- Campo de anotacao opcional deve ser discreto e nao competir com o progresso.
- Publicacao social do progresso fica privada por padrao no MVP; se houver controle visual, ele deve aparecer como opcional e desligado.
- Acao primaria: `Salvar progresso`.
- Se a pagina informada for menor que a ultima registrada, bloquear salvamento e mostrar erro direto no campo.
- Se a pagina informada for maior que o total conhecido, bloquear salvamento e mostrar erro direto no campo.
- Se o valor atingir a ultima pagina conhecida ou `100%`, avisar antes de salvar que a leitura sera concluida.
- Apos salvar, voltar para `Estado De Leitura` com dados atualizados.

Referencia visual:
- `docs/ux/prototypes/reading-progress-screen-preview.png`

### Plano De Leitura

Rota:
- `/reading/:bookshelfItemId/plan`

Objetivo:
Criar, alterar ou remover data alvo de conclusao.

Dados:
- Data alvo.
- Progresso atual.
- Total de paginas quando conhecido.
- Ritmo calculado.

Acoes:
- Salvar data alvo.
- Remover plano.
- Ajustar data alvo.

Navega para:
- `/reading/:bookshelfItemId`

Estados:
- Ritmo calculavel.
- Ritmo indisponivel por falta de paginas.
- Data alvo exigente demais.

Composicao visual aprovada para prototipacao:
- Tela curta, aberta a partir de `Estado De Leitura`, focada em definir quando o usuario quer terminar.
- Topo com voltar e titulo `Plano de leitura`.
- Resumo compacto do livro e progresso atual.
- Campo principal: `Data alvo`, com seletor de data nativo no Flutter.
- O ritmo deve ser exibido como resultado calculado, nao como campo editavel.
- Quando houver `pageCount` e ultimo progresso, exibir paginas restantes, dias restantes e sugestao de paginas por dia.
- Quando o ritmo calculado for alto, exibir alerta suave sugerindo ajustar a data alvo.
- Quando nao houver `pageCount`, permitir salvar a data alvo, mas mostrar que o app nao consegue calcular paginas por dia.
- Acao primaria: `Salvar plano`.
- Se ja houver plano ativo, manter acao secundaria `Remover plano`.
- Remover plano deve exigir confirmacao simples.
- Apos salvar ou remover, voltar para `Estado De Leitura` com plano atualizado.
- O plano nao deve ser criado automaticamente ao mudar status para `Lendo`; o usuario define quando quiser.

Referencia visual:
- `docs/ux/prototypes/reading-plan-screen-preview.png`

### Decisao Ao Voltar Para Quero Ler

Tipo:
- Bottom sheet.

Objetivo:
Perguntar o que fazer com a sessao atual quando usuario muda para `want_to_read`.

Acoes:
- Manter progresso para retomar depois: envia `sessionAction = keep_paused`.
- Encerrar esta tentativa: envia `sessionAction = interrupt`.
- Cancelar acao.

Navega para:
- `/bookshelf` ou permanece em `/reading/:bookshelfItemId`, conforme prototipo.

Composicao visual aprovada para prototipacao:
- Bottom sheet acionado quando o usuario tenta mudar uma leitura ativa ou pausada para `Quero ler`.
- Titulo direto: `Voltar para Quero ler?`.
- Texto deve explicar que o plano ativo sera removido ao voltar para `Quero ler`.
- Exibir contexto do ultimo ponto de leitura, por exemplo `Voce parou na pagina 300`.
- Opcao recomendada: `Manter progresso pausado`, enviando `sessionAction = keep_paused`.
- Essa opcao muda o item para `Quero ler`, cancela o plano ativo e preserva a sessao pausada para retomada futura.
- Opcao alternativa: `Encerrar esta tentativa`, enviando `sessionAction = interrupt`.
- Essa opcao muda o item para `Quero ler`, cancela o plano ativo e marca a sessao como `interrupted`, mantendo historico.
- `Cancelar` fecha o bottom sheet sem alterar status, plano ou sessao.
- A copia deve evitar o termo tecnico `interrupted` na interface.
- A acao de encerrar tentativa deve ter peso visual menor e usar `Coral` apenas no texto, nao como botao destrutivo cheio.
- Apos confirmar uma das opcoes, navegar para `/bookshelf` no prototipo, com o item em `Quero ler`.

Referencia visual:
- `docs/ux/prototypes/want-to-read-decision-bottom-sheet-preview.png`

### Metas

Rota:
- `/goals`

Objetivo:
Listar metas do usuario e destacar progresso.

Dados:
- Metas ativas.
- Metas concluidas.
- Progresso calculado.
- `isExpired`.
- `needsAttention`.

Acoes:
- Criar meta.
- Abrir detalhe.
- Editar meta ativa.
- Cancelar meta.

Navega para:
- `/goals/new`
- `/goals/:readingGoalId`
- `/goals/:readingGoalId/edit`

Estados:
- Sem metas.
- Meta ativa no prazo.
- Meta concluida com bonus.
- Meta vencida nao atingida.

Composicao visual aprovada para prototipacao:
- Tela principal da aba `Metas`, com bottom navigation fixa e aba `Metas` ativa.
- Topo com titulo `Metas` e acao `Criar`.
- Exibir primeiro as metas que precisam de acao do usuario, especialmente meta vencida nao atingida.
- Meta ativa no prazo deve mostrar periodo, metrica, progresso atual, alvo, percentual e tempo restante.
- Meta concluida deve mostrar alvo atingido e bonus/excedente quando houver progresso alem do alvo no mesmo periodo.
- Meta vencida nao atingida deve continuar ativa visualmente, mas com alerta compacto e acao `Revisar meta`.
- Nao oferecer acao de concluir manualmente uma meta.
- Cartoes devem deixar clara a diferenca entre meta por livros e meta por paginas.
- Quando meta por paginas recebe progresso por percentual sem total de paginas conhecido, esse progresso nao deve aparecer como paginas lidas calculadas.
- Acao primaria da tela quando houver metas: `Criar meta`.
- Estado vazio deve orientar criacao de meta mensal ou anual.
- A tela deve ser mais operacional do que gamificada no MVP; bonus aparece como dado positivo, sem sistema de recompensa ainda.

Referencia visual:
- `docs/ux/prototypes/goals-screen-preview.png`

### Criar Meta

Rota:
- `/goals/new`

Objetivo:
Criar meta mensal ou anual no MVP.

Dados:
- Periodo.
- Metrica: livros lidos ou paginas lidas.
- Valor alvo.
- Publica ou privada.

Navega para:
- `/goals`
- `/goals/:readingGoalId`

Acoes:
- Escolher periodo.
- Escolher metrica.
- Informar valor alvo.
- Definir se a meta e publica.
- Salvar meta.
- Cancelar.

Estados:
- Valor alvo ausente.
- Valor alvo invalido.
- Meta privada por padrao.

Composicao visual aprovada para prototipacao:
- Tela de formulario curto, aberta pela aba `Metas`.
- Topo com voltar e titulo `Criar meta`.
- Periodo deve usar controle segmentado com opcoes `Mensal` e `Anual` no MVP.
- O schema pode suportar periodos flexiveis, mas a UI inicial nao deve expor bimestral, trimestral, semestral ou customizado.
- Metrica deve usar controle segmentado com opcoes `Livros` e `Paginas`.
- Valor alvo deve usar campo numerico com unidade contextual, por exemplo `livros` ou `paginas`.
- Privacidade deve usar toggle `Meta publica`, desligado por padrao.
- Exibir resumo textual curto antes de salvar, por exemplo `Ler 12 livros em 2026`.
- Nao permitir criar meta sem valor alvo positivo.
- Acao primaria: `Criar meta`.
- Apos salvar, navegar para `Detalhe Da Meta` ou voltar para `Metas`; no prototipo, preferir `Detalhe Da Meta`.

Referencia visual:
- `docs/ux/prototypes/create-goal-screen-preview.png`

### Detalhe Da Meta

Rota:
- `/goals/:readingGoalId`

Objetivo:
Mostrar progresso calculado de uma meta.

Dados:
- Meta.
- Progresso.
- Bonus.
- Status.
- Alertas.

Acoes:
- Editar meta ativa.
- Cancelar meta ativa.

Navega para:
- `/goals/:readingGoalId/edit`
- `/goals`

Estados:
- Meta ativa no prazo.
- Meta concluida.
- Meta concluida com bonus.
- Meta vencida nao atingida.

Composicao visual aprovada para prototipacao:
- Tela de detalhe aberta pela lista de metas.
- Topo com voltar, titulo `Detalhe da meta` e acao de editar quando a meta estiver ativa.
- Card principal deve exibir periodo, metrica, progresso atual, alvo e percentual.
- Quando a meta estiver concluida, mostrar conclusao como resultado calculado pelo sistema.
- Quando houver bonus/excedente, destacar o excedente sem transformar em recompensa complexa no MVP.
- Quando a meta estiver vencida e nao atingida, mostrar alerta e acao `Revisar meta`.
- Nao exibir acao para concluir manualmente.
- Acoes permitidas em meta ativa: editar e cancelar.
- Cancelar meta deve exigir confirmacao.
- Exibir composicao do progresso com itens que alimentaram o calculo, por exemplo livros concluidos ou paginas lidas por leitura.
- Para meta por paginas, deixar claro que o valor soma paginas novas lidas, nao a posicao acumulada de cada registro.
- Para meta por livros, releituras concluidas contam como novas leituras quando houver sessao finalizada no periodo.

Referencia visual:
- `docs/ux/prototypes/goal-detail-screen-preview.png`

### Editar Meta

Rota:
- `/goals/:readingGoalId/edit`

Objetivo:
Alterar valor, intervalo ou privacidade de uma meta ativa.

Acoes:
- Alterar periodo.
- Alterar metrica.
- Alterar valor alvo.
- Alterar privacidade.
- Salvar alteracoes.
- Cancelar meta ativa.
- Cancelar edicao.

Navega para:
- `/goals/:readingGoalId`

Estados:
- Meta ativa no prazo.
- Meta vencida nao atingida.
- Valor alvo invalido.

Composicao visual aprovada para prototipacao:
- Tela de formulario baseada em `Criar Meta`, reaproveitando periodo, metrica, valor alvo e privacidade.
- Topo com voltar e titulo `Editar meta`.
- Exibir resumo do progresso atual antes do formulario para o usuario entender o impacto da edicao.
- Quando a meta estiver vencida e nao atingida, exibir alerta compacto explicando que ela continua ativa e pode ser revista.
- Nao exibir nenhum controle para marcar meta como concluida.
- Se a edicao fizer o progresso atual atingir ou ultrapassar o novo alvo, a conclusao continua sendo calculada pelo sistema apos salvar.
- Acao primaria: `Salvar alteracoes`.
- Acao secundaria sensivel: `Cancelar meta`, separada visualmente do formulario.
- Cancelar meta deve abrir confirmacao antes de executar.
- Apos salvar ou cancelar meta, retornar para `Detalhe Da Meta` ou `Metas`, conforme estado; no prototipo, salvar retorna para `Detalhe Da Meta`.

Referencia visual:
- `docs/ux/prototypes/edit-goal-screen-preview.png`

### Perfil

Rotas:
- `/profile`
- `/profile/edit`

Objetivo:
Mostrar e editar perfil simples.

Dados:
- Nome.
- Foto.
- Bio.
- Estatisticas basicas disponiveis.

Acoes:
- Editar perfil.
- Sair.

Navega para:
- `/auth/welcome` apos logout.

Estados:
- Usuario com foto.
- Usuario sem foto.
- Bio vazia.
- Estatisticas basicas disponiveis.

Composicao visual aprovada para prototipacao:
- Tela principal da aba `Perfil`, com bottom navigation fixa e aba `Perfil` ativa.
- Topo com titulo `Perfil` e acao `Editar`.
- Exibir avatar/foto, nome exibido e bio opcional.
- Quando nao houver foto, usar avatar com iniciais em `Primary`.
- Perfil basico pode ser publico por padrao, conforme regra de privacidade hibrida.
- Exibir estatisticas resumidas do usuario, como livros lidos, lendo agora, paginas lidas e metas concluidas.
- Exibir atalho para configuracoes futuras de privacidade apenas como bloco informativo no MVP, sem detalhar preferencias ainda.
- Exibir acao `Sair` no final da tela, separada das informacoes principais.
- Sair deve abrir confirmacao antes de encerrar sessao.

Referencia visual:
- `docs/ux/prototypes/profile-screen-preview.png`

### Editar Perfil

Rota:
- `/profile/edit`

Objetivo:
Editar dados basicos do perfil do usuario.

Dados:
- Nome exibido.
- Foto opcional.
- Bio opcional.

Acoes:
- Alterar foto.
- Alterar nome exibido.
- Alterar bio.
- Salvar perfil.
- Cancelar.

Navega para:
- `/profile`

Estados:
- Nome exibido ausente.
- Foto ausente.
- Bio vazia.

Composicao visual aprovada para prototipacao:
- Tela de formulario curto aberta pelo perfil.
- Topo com voltar e titulo `Editar perfil`.
- Foto deve aparecer no topo com acao `Alterar foto`.
- Nome exibido deve ser obrigatorio.
- Bio deve ser opcional e limitada visualmente para texto curto.
- Acao primaria: `Salvar perfil`.
- Apos salvar, retornar para `/profile`.

## Fluxos A Validar

### Entrar No App

1. Abrir `/auth/welcome`.
2. Simular login Google ou email/senha.
3. Entrar em `/bookshelf`.

### Buscar Livro E Adicionar A Estante

1. Abrir `/search`.
2. Buscar termo.
3. Abrir `/books/:bookId`.
4. Escolher edicao.
5. Escolher status inicial.
6. Adicionar a estante.
7. Ir para `/bookshelf` ou `/reading/:bookshelfItemId`.

### Iniciar Leitura E Registrar Progresso

1. Abrir item em `/reading/:bookshelfItemId`.
2. Garantir sessao ativa.
3. Abrir `/reading/:bookshelfItemId/progress/new`.
4. Registrar pagina ou percentual.
5. Voltar para estado de leitura.

### Definir Data Alvo

1. Abrir `/reading/:bookshelfItemId/plan`.
2. Escolher data alvo.
3. Ver ritmo calculado.
4. Salvar.
5. Voltar para estado de leitura.

### Voltar Para Quero Ler

1. Em leitura ativa ou pausada, selecionar `want_to_read`.
2. Exibir decisao:
   - manter progresso para retomar depois;
   - encerrar tentativa.
3. Aplicar comportamento mockado.
4. Confirmar que o plano ativo foi removido/cancelado.

### Criar Meta E Acompanhar

1. Abrir `/goals`.
2. Criar meta mensal/anual.
3. Registrar progresso de leitura.
4. Ver progresso da meta.
5. Simular meta concluida com bonus.
6. Simular meta vencida nao atingida com alerta.

## Dados Mockados Necessarios

- Usuario autenticado.
- Usuario sem foto.
- Livros com uma e multiplas edicoes.
- Edicao com `pageCount`.
- Edicao sem `pageCount`.
- Editoras com e sem `logoUrl`.
- Estante com status `want_to_read`, `reading`, `paused`, `read`, `rereading` e `abandoned`.
- Sessao ativa.
- Sessao pausada.
- Sessao `interrupted`.
- Progresso por pagina.
- Progresso por percentual.
- Plano ativo com ritmo calculavel.
- Plano sem ritmo calculavel.
- Meta ativa.
- Meta concluida com bonus.
- Meta vencida nao atingida.

