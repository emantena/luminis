# Database Schema MVP

Status: Em definicao

Este documento registra o schema inicial do banco PostgreSQL para o MVP. Ele deve orientar as migrations DbUp.

Diagrama ER:
- `docs/data/database-schema-mvp-er.md`

## Convencoes

- IDs principais usam `uuid`.
- Datas usam `timestamptz`.
- Migrations seguem `ddMMyyyyHHMMSS_<nome_descritivo>.sql`.
- Nomes de tabelas e colunas usam `snake_case`.
- Constraints e indices devem ter nomes explicitos quando possivel.

## Identity

Status: Aprovado

### users

Representa a identidade/perfil interno do usuario no Luminis.

```sql
create table users (
  id uuid primary key,
  display_name varchar(120) not null,
  photo_url text null,
  bio varchar(500) null,
  status varchar(30) not null default 'active',
  created_at timestamptz not null,
  updated_at timestamptz null,
  deleted_at timestamptz null,
  constraint ck_users_status check (status in ('active', 'suspended', 'deleted'))
);
```

Regras:
- `display_name` e obrigatorio.
- `users` nao armazena email no MVP.
- `status` inicia como `active`.
- `deleted_at` permite soft delete futuro.

### user_external_logins

Representa provedores externos associados ao usuario interno.

```sql
create table user_external_logins (
  id uuid primary key,
  user_id uuid not null references users(id),
  provider varchar(40) not null,
  provider_user_id varchar(200) not null,
  provider_email varchar(320) null,
  created_at timestamptz not null,
  last_login_at timestamptz null,
  constraint uq_user_external_logins_provider_user unique (provider, provider_user_id)
);

create index ix_user_external_logins_user_id
  on user_external_logins(user_id);
```

Regras:
- A identidade externa confiavel e `provider + provider_user_id`.
- `provider_email` e apenas dado informado pelo provedor.
- `provider_email` verificado pode ser usado pelo backend para vincular login Google a usuario local existente com o mesmo email.
- `provider_email` nao verificado nao deve vincular automaticamente uma credencial local.

### user_password_credentials

Representa credencial local de login por email e senha.

```sql
create table user_password_credentials (
  user_id uuid primary key references users(id),
  email varchar(320) not null,
  password_hash text not null,
  password_hash_algorithm varchar(50) not null,
  email_verified_at timestamptz null,
  password_updated_at timestamptz not null,
  failed_attempts int not null default 0,
  locked_until timestamptz null,
  created_at timestamptz not null,
  last_login_at timestamptz null,
  constraint uq_user_password_credentials_email unique (email),
  constraint ck_user_password_credentials_failed_attempts check (failed_attempts >= 0)
);
```

Regras:
- Senha nunca deve ser armazenada em texto puro.
- `email` e o identificador de login local e deve ser unico.
- `failed_attempts` e `locked_until` entram no schema MVP para suportar lockout.
- Um usuario pode existir sem credencial local quando usa apenas provedor externo.

### refresh_tokens

Representa refresh tokens emitidos pelo backend.

```sql
create table refresh_tokens (
  id uuid primary key,
  user_id uuid not null references users(id),
  token_hash text not null,
  expires_at timestamptz not null,
  revoked_at timestamptz null,
  created_at timestamptz not null,
  created_by_ip varchar(45) null,
  replaced_by_token_id uuid null references refresh_tokens(id)
);

create index ix_refresh_tokens_user_id
  on refresh_tokens(user_id);

create index ix_refresh_tokens_token_hash
  on refresh_tokens(token_hash);
```

Regras:
- Refresh token real nunca deve ser armazenado em texto puro.
- Logout revoga refresh token.
- Refresh deve rotacionar token, criando novo e marcando o anterior como revogado/substituido.

### password_reset_tokens

Representa tokens de recuperacao de senha.

```sql
create table password_reset_tokens (
  id uuid primary key,
  user_id uuid not null references users(id),
  token_hash text not null,
  expires_at timestamptz not null,
  used_at timestamptz null,
  created_at timestamptz not null
);

create index ix_password_reset_tokens_user_id
  on password_reset_tokens(user_id);

create index ix_password_reset_tokens_token_hash
  on password_reset_tokens(token_hash);
```

Regras:
- Token real nunca deve ser armazenado em texto puro.
- Expiracao deve ser curta.
- Reset de senha marca token como usado.
- Forgot password nao deve revelar se o email existe.

## Catalog

Status: Aprovado

O catalogo proprio do Luminis no MVP deve ser criado sob demanda. Isso significa que o sistema nao importa uma base gigante inicialmente; ele persiste obras, edicoes, autores e editoras quando forem escolhidos/adicionados por usuarios, retornados por provedores externos ou cadastrados localmente.

Metadados retornados por provedores externos previamente aprovados podem alimentar o catalogo global sob demanda depois de normalizacao, validacao e deduplicacao no backend. Cadastros, sugestoes e correcoes enviados por usuarios permanecem privados ate curadoria futura.

### authors

Representa autores normalizados para busca e relacionamento com obras.

```sql
create table authors (
  id uuid primary key,
  name varchar(200) not null,
  normalized_name varchar(200) not null,
  created_at timestamptz not null,
  updated_at timestamptz null,
  constraint uq_authors_normalized_name unique (normalized_name)
);
```

Regras:
- `normalized_name` deve ser usado para deduplicacao simples no MVP.
- Nao tentaremos curadoria avancada de autores no MVP.

### publishers

Representa editoras normalizadas para busca, filtros e exibicao visual.

```sql
create table publishers (
  id uuid primary key,
  name varchar(200) not null,
  normalized_name varchar(200) not null,
  logo_url text null,
  created_at timestamptz not null,
  updated_at timestamptz null,
  constraint uq_publishers_normalized_name unique (normalized_name)
);
```

Regras:
- `logo_url` e opcional.
- Logo nao deve bloquear cadastro ou exibicao de edicao.
- Quando nao houver logo, a UI deve usar fallback visual.
- `normalized_name` deve ser usado para deduplicacao simples no MVP.

### books

Representa a obra/livro conceitual, agrupando edicoes.

```sql
create table books (
  id uuid primary key,
  title varchar(300) not null,
  subtitle varchar(300) null,
  description text null,
  original_title varchar(300) null,
  created_at timestamptz not null,
  updated_at timestamptz null
);

create index ix_books_title
  on books(title);
```

### book_authors

Relaciona livros e autores, preservando ordem de exibicao.

```sql
create table book_authors (
  book_id uuid not null references books(id),
  author_id uuid not null references authors(id),
  author_order int not null default 0,
  primary key (book_id, author_id),
  constraint ck_book_authors_author_order check (author_order >= 0)
);

create index ix_book_authors_author_id
  on book_authors(author_id);
```

### subjects

Representa assuntos ou categorias planos preservados de fontes externas aprovadas.

```sql
create table subjects (
  id uuid primary key,
  name varchar(200) not null,
  normalized_name varchar(200) not null,
  created_at timestamptz not null,
  updated_at timestamptz null,
  constraint uq_subjects_normalized_name unique (normalized_name)
);
```

### book_subjects

Relaciona uma obra a assuntos informados por uma fonte externa.

```sql
create table book_subjects (
  book_id uuid not null references books(id),
  subject_id uuid not null references subjects(id),
  source varchar(40) not null,
  created_at timestamptz not null,
  primary key (book_id, subject_id, source)
);

create index ix_book_subjects_subject_id
  on book_subjects(subject_id);
```

Regras:
- Assuntos sao planos no MVP; nao ha hierarquia, sinonimos ou equivalencias manuais.
- `source` preserva internamente a origem do vinculo entre obra e assunto.
- Assuntos sao importados de provedores aprovados; usuarios nao os criam nem publicam no MVP.

### editions

Representa uma publicacao especifica de uma obra.

```sql
create table editions (
  id uuid primary key,
  book_id uuid not null references books(id),
  publisher_id uuid null references publishers(id),
  title varchar(300) not null,
  subtitle varchar(300) null,
  published_year int null,
  language varchar(20) null,
  format varchar(40) null,
  page_count int null,
  isbn10 varchar(10) null,
  isbn13 varchar(13) null,
  cover_url text null,
  created_at timestamptz not null,
  updated_at timestamptz null,
  constraint ck_editions_page_count check (page_count is null or page_count > 0),
  constraint ck_editions_published_year check (published_year is null or published_year between 1400 and 2200)
);

create index ix_editions_book_id
  on editions(book_id);

create index ix_editions_publisher_id
  on editions(publisher_id);

create unique index uq_editions_isbn10
  on editions(isbn10)
  where isbn10 is not null;

create unique index uq_editions_isbn13
  on editions(isbn13)
  where isbn13 is not null;
```

Regras:
- `page_count` pertence a edicao e alimenta progresso/ritmo de leitura.
- ISBN pertence a edicao.
- Capa pertence a edicao.
- Editora e opcional para permitir dados incompletos.

### book_external_references

Registra identificadores externos de obras ou edicoes.

```sql
create table book_external_references (
  id uuid primary key,
  book_id uuid null references books(id),
  edition_id uuid null references editions(id),
  source varchar(40) not null,
  external_id varchar(200) not null,
  url text null,
  created_at timestamptz not null,
  constraint uq_book_external_references_source_external unique (source, external_id),
  constraint ck_book_external_references_target check (book_id is not null or edition_id is not null)
);

create index ix_book_external_references_book_id
  on book_external_references(book_id);

create index ix_book_external_references_edition_id
  on book_external_references(edition_id);
```

Fontes candidatas:
- `google_books`
- `brasilapi_isbn`
- `open_library`
- `manual`
- `user_suggested`

### user_book_drafts

Representa livro cadastrado localmente por usuario antes de curadoria global.

```sql
create table user_book_drafts (
  id uuid primary key,
  user_id uuid not null references users(id),
  title varchar(300) not null,
  authors text null,
  edition_data jsonb null,
  status varchar(30) not null default 'local',
  created_at timestamptz not null,
  suggested_to_catalog_at timestamptz null,
  constraint ck_user_book_drafts_status check (status in ('local', 'suggested', 'accepted', 'rejected'))
);

create index ix_user_book_drafts_user_id
  on user_book_drafts(user_id);
```

Regras:
- Draft local permite uso imediato quando livro nao existe no catalogo.
- Draft local permanece privado ao usuario que o criou ate validacao, curadoria ou processo equivalente.
- Sugestao para catalogo global deve passar por validacao/curadoria futura.
- O fluxo de sugestao e curadoria nao possui contrato nem operacao no MVP.
- `edition_data` permite guardar dados ainda nao normalizados.

## Bookshelf

Status: Aprovado

### bookshelf_items

Representa a relacao do usuario com uma edicao global especifica ou com um cadastro local privado.

```sql
create table bookshelf_items (
  id uuid primary key,
  user_id uuid not null references users(id),
  book_id uuid null references books(id),
  user_book_draft_id uuid null references user_book_drafts(id),
  edition_id uuid null references editions(id),
  reading_status varchar(30) not null,
  is_favorite boolean not null default false,
  is_owned boolean not null default false,
  is_wished boolean not null default false,
  is_borrowed boolean not null default false,
  is_lent boolean not null default false,
  is_ebook boolean not null default false,
  is_audiobook boolean not null default false,
  started_at timestamptz null,
  finished_at timestamptz null,
  added_at timestamptz not null,
  updated_at timestamptz null,
  removed_at timestamptz null,
  constraint ck_bookshelf_items_reading_status check (
    reading_status in ('want_to_read', 'reading', 'paused', 'read', 'rereading', 'abandoned')
  ),
  constraint ck_bookshelf_items_catalog_target check (
    (book_id is not null and edition_id is not null and user_book_draft_id is null)
    or (book_id is null and edition_id is null and user_book_draft_id is not null)
  )
);

create unique index uq_bookshelf_items_user_edition_active
  on bookshelf_items(user_id, edition_id)
  where removed_at is null and edition_id is not null;

create unique index uq_bookshelf_items_user_draft_active
  on bookshelf_items(user_id, user_book_draft_id)
  where removed_at is null and user_book_draft_id is not null;

create index ix_bookshelf_items_user_status
  on bookshelf_items(user_id, reading_status)
  where removed_at is null;

create index ix_bookshelf_items_book_id
  on bookshelf_items(book_id);

create index ix_bookshelf_items_user_book_draft_id
  on bookshelf_items(user_book_draft_id);

create index ix_bookshelf_items_edition_id
  on bookshelf_items(edition_id);
```

Regras:
- Para item global, `book_id` e `edition_id` sao obrigatorios.
- `edition_id` deve pertencer ao `book_id`; essa consistencia deve ser validada pelo backend.
- Usuario pode ter apenas um item ativo por `edition_id` na estante.
- Usuario pode ter mais de um item ativo do mesmo `book_id` quando forem edicoes diferentes.
- Usuario pode ter apenas um item ativo por `user_book_draft_id` na estante.
- Item de estante deve apontar para uma edicao global ou para um draft local, nunca para ambos.
- `user_book_draft_id` deve pertencer ao mesmo usuario de `bookshelf_items`; essa autoria deve ser validada pelo backend.
- `publisher_id` nao pertence a `bookshelf_items`; editora pertence a `editions`.
- Status principal deve ser unico por item.
- Status de leitura deve ser escolhido explicitamente ao criar o item; nao ha status padrao implicito.
- Flags booleanas representam etiquetas auxiliares conhecidas no MVP.
- `removed_at` permite remover da estante sem apagar historico imediatamente.
- Remocao logica deve cancelar plano ativo e marcar sessao ativa ou pausada como `interrupted`, preservando registros de progresso.
- Depois de removido, o mesmo alvo pode ser adicionado novamente criando novo item ativo.

## Reading

Status: Aprovado

### reading_plans

Representa o plano de conclusao de leitura para um item da estante.

```sql
create table reading_plans (
  id uuid primary key,
  bookshelf_item_id uuid not null references bookshelf_items(id),
  status varchar(30) not null default 'active',
  start_date date null,
  target_finish_date date not null,
  completed_at timestamptz null,
  cancelled_at timestamptz null,
  created_at timestamptz not null,
  updated_at timestamptz null,
  constraint ck_reading_plans_status check (
    status in ('active', 'completed', 'cancelled')
  )
);

create unique index uq_reading_plans_bookshelf_item_active
  on reading_plans(bookshelf_item_id)
  where status = 'active';

create index ix_reading_plans_bookshelf_item_id
  on reading_plans(bookshelf_item_id);
```

Regras:
- Plano de leitura e diferente de sessao de leitura.
- Um item da estante pode ter no maximo um plano ativo.
- `target_finish_date` pertence ao plano, nao a `reading_sessions`.
- `daily_pages_target` nao e persistido no MVP; deve ser calculado a partir do ultimo progresso, `target_finish_date` e total de paginas da edicao.
- Plano pode ser criado quando o item entra em `reading` ou quando o usuario informa/atualiza uma data alvo.
- Plano ativo deve ser marcado como `completed` quando a leitura for concluida e como `cancelled` quando o usuario remover a data alvo ou abandonar o planejamento.

### reading_sessions

Representa uma instancia concreta de leitura de um item da estante.

```sql
create table reading_sessions (
  id uuid primary key,
  bookshelf_item_id uuid not null references bookshelf_items(id),
  status varchar(30) not null default 'active',
  started_at timestamptz null,
  finished_at timestamptz null,
  created_at timestamptz not null,
  updated_at timestamptz null,
  constraint ck_reading_sessions_status check (
    status in ('active', 'finished', 'abandoned', 'paused', 'interrupted')
  )
);

create unique index uq_reading_sessions_bookshelf_item_active
  on reading_sessions(bookshelf_item_id)
  where status = 'active';

create index ix_reading_sessions_bookshelf_item_id
  on reading_sessions(bookshelf_item_id);
```

Regras:
- Uma sessao representa uma tentativa/instancia de leitura.
- Um item da estante pode ter no maximo uma sessao ativa.
- Sessao de leitura e diferente de plano de leitura.
- Sessao de leitura e diferente de meta de leitura.
- Sessao pausada preserva seus registros de progresso.
- Ao retomar uma leitura pausada, a mesma sessao deve voltar para `active`.
- Sessao `interrupted` representa uma tentativa encerrada sem abandono da obra; progresso fica preservado, mas uma retomada futura deve criar nova sessao.
- O ponto atual da leitura deve ser derivado do progresso mais recente da sessao.

### reading_progress_entries

Representa um registro de progresso dentro de uma sessao de leitura.

```sql
create table reading_progress_entries (
  id uuid primary key,
  reading_session_id uuid not null references reading_sessions(id),
  page_number int null,
  percentage numeric(5,2) null,
  note varchar(1000) null,
  is_public boolean not null default false,
  created_at timestamptz not null,
  constraint ck_reading_progress_page_number check (page_number is null or page_number > 0),
  constraint ck_reading_progress_percentage check (percentage is null or (percentage >= 0 and percentage <= 100)),
  constraint ck_reading_progress_value check (page_number is not null or percentage is not null)
);

create index ix_reading_progress_entries_session_created
  on reading_progress_entries(reading_session_id, created_at desc);
```

Regras:
- Progresso aponta para `reading_session_id`.
- Progresso detalhado e privado por padrao.
- `page_number` e `percentage` sao opcionais, mas ao menos um deve ser informado.
- Progresso so pode ser registrado quando `reading_sessions.status = 'active'`; essa regra deve ser validada pelo backend.
- `page_number` nao deve exceder `editions.page_count` quando o total de paginas for conhecido.
- `page_number` nao deve ser menor que a ultima pagina registrada na mesma sessao; se for menor, o backend deve rejeitar o registro.
- `note` entra no MVP como anotacao simples de progresso.
- Ritmo de leitura deve ser calculado a partir do ultimo progresso, do plano ativo e de `editions.page_count`.
- Registros de progresso nao devem ser removidos quando uma sessao for pausada.
- Progresso em `100%` ou na ultima pagina conhecida deve concluir automaticamente a leitura.
- Quando o usuario alterar manualmente o status para `read`, o backend deve criar um progresso final na ultima pagina quando a edicao tiver `page_count` conhecido e esse progresso ainda nao existir.

## Goals

Status: Aprovado

Metas de leitura devem nascer flexiveis o suficiente para suportar metas mensais, bimestrais, trimestrais, semestrais, anuais e customizadas, alem de metricas por livros lidos ou paginas lidas.

No MVP, a UI pode oferecer apenas metas anuais e mensais, mas o schema deve deixar o caminho pavimentado para outros periodos.

### reading_goal_period_types

Representa os tipos de periodo disponiveis para metas.

```sql
create table reading_goal_period_types (
  id smallint primary key,
  code varchar(30) not null,
  name varchar(80) not null,
  sort_order int not null,
  is_active boolean not null default true,
  constraint uq_reading_goal_period_types_code unique (code)
);
```

Seeds estaveis:

```text
1 monthly
2 bimonthly
3 quarterly
4 semiannual
5 annual
6 custom
```

### reading_goal_metric_types

Representa as metricas disponiveis para metas.

```sql
create table reading_goal_metric_types (
  id smallint primary key,
  code varchar(30) not null,
  name varchar(80) not null,
  sort_order int not null,
  is_active boolean not null default true,
  constraint uq_reading_goal_metric_types_code unique (code)
);
```

Seeds estaveis:

```text
1 books_read
2 pages_read
```

### reading_goal_statuses

Representa os estados possiveis de uma meta.

```sql
create table reading_goal_statuses (
  id smallint primary key,
  code varchar(30) not null,
  name varchar(80) not null,
  sort_order int not null,
  is_terminal boolean not null default false,
  constraint uq_reading_goal_statuses_code unique (code)
);
```

Seeds estaveis:

```text
1 active
2 completed
3 cancelled
```

### reading_goals

Representa uma meta de leitura do usuario.

```sql
create table reading_goals (
  id uuid primary key,
  user_id uuid not null references users(id),
  period_type_id smallint not null references reading_goal_period_types(id),
  metric_type_id smallint not null references reading_goal_metric_types(id),
  status_id smallint not null references reading_goal_statuses(id),
  target_value int not null,
  starts_on date not null,
  ends_on date not null,
  is_public boolean not null default false,
  completed_at timestamptz null,
  created_at timestamptz not null,
  updated_at timestamptz null,
  deleted_at timestamptz null,
  constraint ck_reading_goals_target_value check (target_value > 0),
  constraint ck_reading_goals_dates check (ends_on >= starts_on)
);

create unique index uq_reading_goals_open_period_metric
  on reading_goals(user_id, period_type_id, metric_type_id, starts_on, ends_on)
  where deleted_at is null and status_id in (1, 2);

create index ix_reading_goals_user_period
  on reading_goals(user_id, starts_on, ends_on)
  where deleted_at is null;
```

Regras:
- `is_public` substitui visibilidade textual.
- Meta e privada por padrao.
- `status_id = 1` representa meta ativa.
- `status_id = 2` representa meta concluida por alcance do valor alvo.
- O usuario pode ter uma meta nao cancelada por combinacao de periodo, metrica e intervalo.
- O progresso da meta nao deve ser persistido no MVP; deve ser calculado.
- Para `books_read`, o calculo deve contar `reading_sessions` com `status = 'finished'` e `finished_at` dentro do intervalo da meta, juntando com `bookshelf_items` do usuario.
- Releituras contam como novas leituras concluidas quando gerarem uma nova `reading_session` finalizada.
- Para `pages_read`, o calculo deve somar avancos de leitura, nao a soma bruta de `page_number`.
- `page_number` representa a posicao atual no livro; o avanco de leitura e a diferenca entre o registro atual e o registro anterior da mesma sessao.
- Quando nao houver registro anterior na sessao, o avanco de leitura por pagina e o proprio `page_number`.
- Progresso informado apenas por percentual so deve contribuir para `pages_read` quando a edicao tiver `page_count` conhecido e o backend conseguir converter percentual em paginas.
- Quando `page_count` for desconhecido, percentual continua registrando progresso de leitura, mas nao gera paginas lidas para meta `pages_read`.
- Ao atingir `target_value`, a meta deve ser marcada como `completed` e `completed_at` deve registrar o momento em que o alvo foi alcancado por comandos que alteram dados de leitura ou criam/editam a propria meta.
- Consultas de progresso de meta nao devem alterar `status_id` nem `completed_at`.
- `completed_at` e gerenciado pelo backend; usuario nao pode concluir meta manualmente.
- Leituras ou paginas acima do alvo continuam entrando no progresso calculado como bonus/excedente.
- `completed` representa estado persistido da meta, mas o progresso e o bonus continuam calculados.
- Meta ativa expirada sem atingir o alvo permanece `active`; o alerta para o usuario deve ser derivado por calculo no backend/API e apresentado pelo Flutter.
- Seeds de tipos/status devem ter IDs estaveis.

## Proximos blocos

- Revisao dos schemas MVP.
- Contratos de API MVP.
