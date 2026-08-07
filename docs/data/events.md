# Eventos

Status: proposta inicial.

Eventos podem alimentar feed, estatisticas, notificacoes e analytics.

## Eventos de dominio

- `book_added_to_bookshelf`
- `reading_started`
- `reading_progress_recorded`
- `reading_finished`
- `book_rated`
- `review_published`
- `user_followed`
- `comment_created`
- `goal_created`
- `goal_completed`
- `reading_group_created`
- `reading_group_joined`
- `recommendation_shown`
- `recommendation_dismissed`
- `book_imported_from_external_source`
- `book_metadata_corrected`
- `book_duplicate_merged`
- `local_book_draft_created`
- `book_catalog_suggestion_submitted`
- `reading_group_checkpoint_created`

## Campos comuns

- `id`
- `type`
- `actorUserId`
- `occurredAt`
- `visibility`
- `metadata`

## Pergunta aberta

Eventos serao persistidos como fonte do feed ou derivados das tabelas principais?
