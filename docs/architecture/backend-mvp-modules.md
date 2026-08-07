# Modulos Do Backend MVP

Status: Aprovado

## Objetivo

Definir quais projetos/modulos entram no primeiro backend real do Luminis e quais ficam para depois.

## Modulos do MVP

```text
Luminis.Api
Luminis.SharedKernel
Luminis.Database
Luminis.Modules.Identity
Luminis.Modules.Catalog
Luminis.Modules.Bookshelf
Luminis.Modules.Reading
Luminis.Modules.Goals
```

## Responsabilidade de cada modulo

### Luminis.Api

Composicao da aplicacao, pipeline HTTP, autenticacao/autorizacao tecnica, exception handling e agregacao de rotas.

### Luminis.SharedKernel

Tipos compartilhados pequenos e estaveis, como `Result`, `Error`, codigos de erro, abstrações de usuario atual e utilitarios de dominio realmente comuns.

### Luminis.Database

Runner DbUp e scripts SQL versionados.

### Luminis.Modules.Identity

Usuario interno do Luminis, associacao com login externo, login com Google, login por email e senha, refresh tokens, recuperacao de senha e contexto de autenticacao.

### Luminis.Modules.Catalog

`Book`, `Edition`, busca/catalogo inicial, livro local e sugestao para catalogo global.

### Luminis.Modules.Bookshelf

Estante pessoal, status de leitura, etiquetas auxiliares e vinculo entre usuario e edicao global ou cadastro local privado.

### Luminis.Modules.Reading

Planos de leitura, registro de progresso, historico de leitura, data alvo e calculo de paginas por dia.

### Luminis.Modules.Goals

Metas mensais e anuais no MVP, com schema preparado para periodos flexiveis e metricas por livros ou paginas.

## Fora do MVP

```text
Luminis.Modules.Reviews
Luminis.Modules.Social
Luminis.Modules.Groups
Luminis.Modules.Recommendations
Luminis.Modules.Notifications
Luminis.Modules.Moderation
```

## Ordem recomendada de criacao

1. `Luminis.SharedKernel`
2. `Luminis.Database`
3. `Luminis.Modules.Identity`
4. `Luminis.Modules.Catalog`
5. `Luminis.Modules.Bookshelf`
6. `Luminis.Modules.Reading`
7. `Luminis.Modules.Goals`
8. `Luminis.Api`

## Racional

- O MVP nasce como organizador pessoal de leitura.
- Social completo, grupos e recomendacoes ficam pos-MVP.
- Catalogo, estante, leitura e metas sao suficientes para entregar valor individual.
- Identity entra cedo porque dados do usuario, estante e metas dependem de usuario interno.
- Database entra cedo para estabelecer migrations DbUp antes de criar tabelas reais.

## Proxima discussao recomendada

Modelagem inicial do banco MVP:

- `users`
- `user_external_logins`
- `user_password_credentials`
- `refresh_tokens`
- `password_reset_tokens`
- `books`
- `editions`
- `bookshelf_items`
- `reading_plans`
- `reading_sessions`
- `reading_progress_entries`
- `reading_goal_period_types`
- `reading_goal_metric_types`
- `reading_goal_statuses`
- `reading_goals`
