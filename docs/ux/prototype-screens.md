# Prototipo De Telas MVP

Status: aprovado como guia de prototipacao.

Este documento define as telas iniciais do prototipo Flutter com dados mockados. O objetivo e validar fluxo, navegacao e usabilidade antes da implementacao definitiva com backend.

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

### Decisao Ao Voltar Para Quero Ler

Tipo:
- Dialog ou bottom sheet.

Objetivo:
Perguntar o que fazer com a sessao atual quando usuario muda para `want_to_read`.

Acoes:
- Manter progresso para retomar depois: envia `sessionAction = keep_paused`.
- Encerrar esta tentativa: envia `sessionAction = interrupt`.
- Cancelar acao.

Navega para:
- `/bookshelf` ou permanece em `/reading/:bookshelfItemId`, conforme prototipo.

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

### Editar Meta

Rota:
- `/goals/:readingGoalId/edit`

Objetivo:
Alterar valor, intervalo ou privacidade de uma meta ativa.

Navega para:
- `/goals/:readingGoalId`

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
