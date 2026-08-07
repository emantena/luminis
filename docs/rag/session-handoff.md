# Handoff De Sessao

Use este arquivo para retomar o projeto Luminis em outro computador, outro chat ou outro agente mantendo o contexto e o modo de colaboracao.

## Prompt de retomada

Copie e cole isto no novo chat/agente:

```text
Estamos trabalhando no projeto Luminis, um app Flutter com backend .NET para organizador social de leitura.

Se as skills locais estiverem disponiveis:
- use $luminis-product-agent para produto, regras e decisoes;
- use $luminis-ux-agent para telas, jornadas e prototipos;
- use $luminis-flutter-agent para implementacao Flutter.

Antes de responder ou implementar qualquer coisa, leia:
- docs/README.md
- .agents/skills/luminis-product-agent/SKILL.md
- .agents/skills/luminis-ux-agent/SKILL.md
- .agents/skills/luminis-flutter-agent/SKILL.md
- docs/rag/product-agent.md
- docs/product/mvp.md
- docs/product/business-rules.md
- docs/architecture/overview.md
- docs/architecture/repository-layout.md
- docs/architecture/backend-architecture.md
- docs/data/database-schema-mvp.md
- docs/data/database-schema-mvp-er.md
- docs/architecture/backend-contracts.md
- docs/architecture/navigation.md
- docs/ux/prototype-screens.md

Modo de trabalho esperado:
- trabalhar de forma conversacional e iterativa;
- discutir uma decisao por vez;
- quando uma decisao for aprovada, documentar nos arquivos corretos;
- nao criar codigo ainda sem alinhamento;
- diferenciar claramente Aprovado, Proposta e Aberto;
- nao inventar regra que nao esteja nos docs;
- manter o ritmo de produto/arquitetura que ja vinha sendo usado.

Estado atual:
- Produto e MVP ja estao bem definidos.
- Backend sera monolito modular .NET com Dapper/PostgreSQL/DbUp.
- Minimal APIs serao usadas como experimento controlado, com rotas por modulo.
- Auth proprio entra no MVP com Google Sign-In, email/senha, refresh, logout, forgot/reset password.
- Login Google com email verificado deve vincular automaticamente usuario local existente com o mesmo email.
- Schema MVP ja tem Identity, Catalog, Bookshelf, Reading e Goals.
- Diagrama ER esta em docs/data/database-schema-mvp-er.md.
- Contratos do Catalog estao aprovados para MVP: busca, detalhe, ISBN e cadastro local privado.
- Contratos de Bookshelf/Reading estao aprovados para MVP, exceto `GET /api/bookshelf-items/{bookshelfItemId}`, que permanece candidato dependente de validacao de UX.
- Bookshelf permite multiplas edicoes do mesmo Book; item global exige `bookId` + `editionId`.
- Plano de leitura foi separado em `reading_plans`; `target_finish_date` pertence ao plano, nao a `reading_sessions`.
- Contratos de Goals estao aprovados para MVP.
- Navegacao Flutter do MVP esta aprovada com `go_router`, fluxo publico de auth e abas Estante, Buscar, Leitura, Metas e Perfil.
- Guia de prototipacao das telas esta em docs/ux/prototype-screens.md.
- Estrutura inicial do repositorio foi preparada com `backend/` e `frontend/`; codigo novo ainda nao foi criado nessas pastas.
- Flutter antigo criado na raiz foi removido.
- Skills locais do projeto foram criadas em `.agents/skills/` para preservar o modo de trabalho entre sessoes.
- `luminis-product-agent` ficou responsavel por produto/regras/decisoes e deve delegar UX para `luminis-ux-agent` e implementacao Flutter para `luminis-flutter-agent`.

Proximo alvo recomendado:
Prototipar as telas principais do MVP com dados mockados seguindo `docs/ux/prototype-screens.md`.
```

## Resumo do produto

Luminis e um organizador social de leitura. O MVP nasce como organizador pessoal, mas prepara base para social, grupos e recomendacoes.

Pilares:
- Estante pessoal.
- Progresso e ritmo de leitura.
- Metas.
- Catalogo proprio sob demanda.
- Futuro social/grupos/recomendacoes.

## Decisoes aprovadas principais

- MVP prioriza organizador pessoal.
- Relacao social inicial sera seguir, sem reciprocidade obrigatoria.
- `Book` representa livro/obra conceitual.
- `Edition` representa publicacao especifica.
- Avaliacao futura usa escala 0.5 a 5.0 estrelas.
- Privacidade e hibrida.
- Grupos futuros podem ser publicos ou fechados.
- Recomendacao inicial sera social, nao IA-first.
- Catalogo proprio sera criado sob demanda.

## Decisoes tecnicas aprovadas

- Flutter como cliente inicial.
- Backend em monolito modular .NET/ASP.NET Core.
- Projetos separados por modulo de negocio.
- PostgreSQL.
- Dapper.
- DbUp para migrations SQL.
- Migrations no padrao `ddMMyyyyHHMMSS_<nome_descritivo>.sql`.
- Sem Entity Framework no MVP.
- Sem CQRS formal no MVP.
- Sem Hangfire/jobs dedicados no MVP.
- Minimal APIs por modulo, sem endpoints individuais em `Program.cs`.
- API usa ProblemDetails customizado ou formato equivalente com `code`, `message` e `traceId`.
- Flutter deve usar `go_router` no MVP, com fluxo publico de auth e shell autenticado com abas.
- Abas autenticadas do MVP: Estante, Buscar, Leitura, Metas e Perfil.
- Flutter deve usar Riverpod como estrategia principal de estado no MVP/prototipo.

## Schema MVP

O schema aprovado esta em:
- `docs/data/database-schema-mvp.md`

O diagrama ER aprovado esta em:
- `docs/data/database-schema-mvp-er.md`

Blocos ja modelados:
- Identity.
- Catalog.
- Bookshelf.
- Reading.
- Goals.

## Contratos de API

Identity ja foi iniciado em:
- `docs/architecture/backend-contracts.md`

Endpoints de Identity no MVP:
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/google`
- `POST /api/auth/logout`
- `POST /api/auth/refresh`
- `POST /api/auth/forgot-password`
- `POST /api/auth/reset-password`
- `GET /api/me`

Catalog ja esta aprovado para MVP em:
- `docs/architecture/backend-contracts.md`

Endpoints de Catalog no MVP:
- `GET /api/books/search`
- `GET /api/books/{bookId}`
- `GET /api/books/isbn/{isbn}`
- `POST /api/book-drafts`

Decisoes importantes do Catalog:
- Busca retorna itens por `Edition`, com `Book` associado.
- `type` aceita `all`, `title`, `author`, `publisher`, `subject` e `isbn`.
- `Publisher` expoe `logoUrl` opcional.
- Cadastro local privado usa `POST /api/book-drafts` e nao cria `Book`/`Edition` global.

Bookshelf/Reading aprovados para MVP em:
- `docs/architecture/backend-contracts.md`

Decisoes importantes de Bookshelf/Reading:
- Item global de estante exige `bookId` e `editionId`.
- `editionId` deve pertencer ao `bookId`.
- O usuario pode ter o mesmo `Book` em edicoes diferentes na estante.
- Duplicidade global e por `userId + editionId` ativo.
- Listagem da estante usa `GET /api/bookshelf-items`, com filtros por `readingStatus` e etiquetas auxiliares.
- `GET /api/bookshelf-items/{bookshelfItemId}` e apenas candidato dependente de validacao de UX, nao obrigatorio no MVP.
- Etiquetas auxiliares usam `PATCH /api/bookshelf-items/{bookshelfItemId}/tags` e nao alteram status/sessao/plano.
- Remocao da estante usa `DELETE /api/bookshelf-items/{bookshelfItemId}` com soft delete por `removed_at`, preservando progresso.
- Plano de leitura fica em `reading_plans`.
- `dailyPagesTarget` nao e persistido no MVP; deve ser calculado.
- `targetFinishDate` pode ser definido/alterado/removido a qualquer momento pelo plano de leitura, nao pelo PATCH de status.
- `paused` e status principal da estante para leitura iniciada e pausada sem abandono.
- Mudar status para `paused` cancela o plano ativo; ao retomar, o usuario define nova data alvo se quiser.
- Pausar nao remove progresso; ao retomar de `paused` para `reading`, a mesma `reading_session` deve ser reativada e o ponto vem do progresso mais recente.
- Mudar status para `want_to_read` cancela automaticamente o plano ativo.
- Ao mudar para `want_to_read` com sessao ativa ou pausada, o usuario escolhe entre manter sessao como `paused` para retomar depois ou encerrar a tentativa como `interrupted`.
- Sessao `interrupted` preserva historico, mas uma retomada futura cria nova sessao.
- Progresso e registrado em `POST /api/reading-sessions/{readingSessionId}/progress`.
- Progresso so pode ser registrado em sessao `active`; progresso na ultima pagina conhecida ou em 100% conclui automaticamente a leitura e muda o item para `read`.
- Quando o usuario muda manualmente o item para `read`, o backend deve criar progresso final na ultima pagina se a edicao tiver total de paginas conhecido e esse progresso ainda nao existir.
- Progresso por pagina nao pode regredir dentro da mesma sessao; `pageNumber` menor que a ultima pagina registrada deve ser rejeitado com erro claro.
- Em metas `pages_read`, `pageNumber` e posicao atual no livro; o calculo deve somar `pageAdvance`, ou seja, o avanco entre o progresso atual e o progresso anterior da mesma sessao.
- Em metas `books_read`, o calculo deve contar `reading_sessions` finalizadas como `finished` dentro do periodo da meta, incluindo releituras.
- Consultas de progresso de meta nao devem ter efeito colateral; conclusao de meta acontece em comandos que alteram leitura/progresso/status ou criam/editam metas.
- Tela de leitura deve usar `GET /api/bookshelf-items/{bookshelfItemId}/reading-state` para estado consolidado.

Goals aprovado para MVP em:
- `docs/architecture/backend-contracts.md`

Endpoints de Goals no MVP:
- `GET /api/reading-goals`
- `POST /api/reading-goals`
- `GET /api/reading-goals/{readingGoalId}`
- `PATCH /api/reading-goals/{readingGoalId}`
- `POST /api/reading-goals/{readingGoalId}/cancel`
- `GET /api/reading-goals/{readingGoalId}/progress`

Decisoes importantes de Goals:
- UI do MVP prioriza metas mensais e anuais.
- Backend pode aceitar todos os `periodType` ativos previstos no schema para deixar caminho aberto.
- Progresso da meta e calculado no momento da consulta, nao persistido.
- Meta nasce `active` e privada por padrao.
- `periodType` e `metricType` nao sao editaveis via PATCH; para mudar a natureza da meta, cancelar e criar outra.
- Atingir o alvo marca a meta como `completed` e preenche `completedAt`.
- Leituras ou paginas acima do alvo, dentro do periodo da meta, continuam sendo calculadas como bonus/excedente.
- Usuario pode ter apenas uma meta nao cancelada por combinacao de periodo, metrica e intervalo.
- Usuario nao pode concluir meta manualmente; conclusao e calculada pelo backend.
- Meta ativa vencida e nao atingida permanece `active`; API deve expor flags calculadas para o Flutter alertar o usuario e oferecer alteracao.
- Progresso por percentual so contribui para meta `pages_read` quando houver `pageCount/page_count` conhecido para converter percentual em paginas.

## Proximo trabalho recomendado

Escolha um:

1. Prototipar telas principais do MVP com dados mockados.
2. Criar esqueleto Flutter do prototipo com `go_router`, Riverpod e dados mockados.
3. Revisar contratos de Identity.
4. Detalhar regras de estatisticas.
5. Transformar schema MVP em migrations DbUp.
6. Criar esqueleto da solucao .NET.

Recomendacao atual:
Prototipar as telas principais com dados mockados seguindo a navegacao aprovada, antes de criar codigo definitivo.

## Skills do projeto

As skills locais do Luminis estao em:
- `.agents/skills/luminis-product-agent`
- `.agents/skills/luminis-ux-agent`
- `.agents/skills/luminis-flutter-agent`

Uso recomendado em novas sessoes:
- `Use $luminis-product-agent para discutir, especificar ou revisar decisoes de produto, arquitetura e regras do Luminis.`
- `Use $luminis-ux-agent para desenhar fluxos, telas, interacoes e prototipos do Luminis.`
- `Use $luminis-flutter-agent para implementar o app Flutter do Luminis com go_router, Riverpod e arquitetura aprovada.`

As skills nao substituem a documentacao em `docs/`; elas orientam o agente sobre quais documentos consultar, quando delegar e como registrar novas decisoes.
