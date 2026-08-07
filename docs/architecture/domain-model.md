# Modelo De Dominio

Status: proposta inicial.

## Entidades principais

### User

Representa uma pessoa cadastrada.

Campos candidatos:
- `id`
- `displayName`
- `photoUrl`
- `bio`
- `status`
- `createdAt`
- `updatedAt`
- `deletedAt`

### UserExternalLogin

Representa um provedor externo associado a um usuario interno do Luminis.

Campos candidatos:
- `userId`
- `provider`
- `providerUserId`
- `providerEmail`
- `createdAt`
- `lastLoginAt`

### UserPasswordCredential

Representa a credencial local de login por email e senha de um usuario interno.

Campos candidatos:
- `userId`
- `email`
- `passwordHash`
- `passwordHashAlgorithm`
- `emailVerifiedAt`
- `passwordUpdatedAt`
- `createdAt`
- `lastLoginAt`

Regras:
- Senha em texto puro nunca deve ser persistida.
- Email de login local deve ser unico.
- `User` nao armazena email no MVP.
- Email retornado por provedor externo fica em `UserExternalLogin.providerEmail`.
- Um usuario pode existir sem credencial local se tiver apenas login externo.
- `displayName` e obrigatorio.
- `User.status` aceita `active`, `suspended` e `deleted`.
- Credencial local possui `failedAttempts` e `lockedUntil` para suporte a lockout.

### RefreshToken

Representa refresh token emitido pelo backend.

Campos candidatos:
- `id`
- `userId`
- `tokenHash`
- `expiresAt`
- `revokedAt`
- `createdAt`
- `createdByIp`
- `replacedByTokenId`

### PasswordResetToken

Representa token de recuperacao de senha.

Campos candidatos:
- `id`
- `userId`
- `tokenHash`
- `expiresAt`
- `usedAt`
- `createdAt`

### Book

Representa a obra/livro conceitual, agrupando edicoes.

Campos candidatos:
- `id`
- `title`
- `description`
- `genres`
- `createdAt`

### Author

Representa autor normalizado para busca e relacionamento com obras.

Campos candidatos:
- `id`
- `name`
- `normalizedName`
- `createdAt`
- `updatedAt`

### Publisher

Representa editora normalizada para busca, filtros e exibicao visual.

Campos candidatos:
- `id`
- `name`
- `normalizedName`
- `logoUrl`
- `createdAt`
- `updatedAt`

### Edition

Representa uma publicacao especifica de uma obra.

Campos candidatos:
- `id`
- `bookId`
- `publisherId`
- `coverUrl`
- `pageCount`
- `language`
- `publisher`
- `format`
- `externalIds`
- `sourceMetadata`

### BookshelfItem

Representa uma edicao global especifica ou um cadastro local privado na estante de um usuario.

Campos candidatos:
- `id`
- `userId`
- `bookId`
- `editionId`
- `userBookDraftId`
- `readingStatus`
- `tags`
- `startedAt`
- `finishedAt`
- `addedAt`

Regras:
- Item global exige `bookId` e `editionId`.
- Item local exige `userBookDraftId`.
- `readingStatus` aceita `want_to_read`, `reading`, `paused`, `read`, `rereading` e `abandoned`.

### ReadingPlan

Representa o planejamento de conclusao de leitura de um item da estante.

Campos candidatos:
- `id`
- `bookshelfItemId`
- `status`
- `startDate`
- `targetFinishDate`
- `completedAt`
- `cancelledAt`
- `createdAt`
- `updatedAt`

### ReadingSession

Representa uma instancia concreta de leitura de um item da estante.

Campos candidatos:
- `id`
- `bookshelfItemId`
- `status`
- `startedAt`
- `finishedAt`
- `createdAt`
- `updatedAt`

### ReadingProgressEntry

Representa um registro de progresso.

Campos candidatos:
- `id`
- `readingSessionId`
- `page`
- `percentage`
- `note`
- `createdAt`
- `isPublic`

### Review

Representa uma resenha.

Campos candidatos:
- `id`
- `userId`
- `bookId`
- `editionId`
- `rating`
- `text`
- `hasSpoiler`
- `createdAt`
- `updatedAt`

### Activity

Representa evento social exibivel no feed.

Campos candidatos:
- `id`
- `actorUserId`
- `type`
- `bookId`
- `editionId`
- `targetId`
- `createdAt`
- `visibility`

### ReadingGroup

Representa um grupo de leitura criado por usuarios.

Campos candidatos:
- `id`
- `name`
- `description`
- `bookId`
- `editionId`
- `ownerUserId`
- `visibility`
- `joinPolicy`
- `startsAt`
- `targetEndsAt`
- `createdAt`

### ReadingGroupCheckpoint

Representa um marco de leitura coletivo dentro de um grupo.

Campos candidatos:
- `id`
- `groupId`
- `title`
- `targetDate`
- `targetPage`
- `targetChapter`
- `discussionId`

### ReadingGroupMember

Representa a participacao de um usuario em um grupo.

Campos candidatos:
- `id`
- `groupId`
- `userId`
- `role`
- `status`
- `joinedAt`

### Recommendation

Representa uma recomendacao exibida ao usuario.

Campos candidatos:
- `id`
- `userId`
- `bookId`
- `editionId`
- `reason`
- `source`
- `createdAt`
- `dismissedAt`

### ReadingGoalPeriodType

Representa tipo de periodo disponivel para metas.

Campos candidatos:
- `id`
- `code`
- `name`
- `sortOrder`
- `isActive`

### ReadingGoalMetricType

Representa metrica disponivel para metas.

Campos candidatos:
- `id`
- `code`
- `name`
- `sortOrder`
- `isActive`

### ReadingGoalStatus

Representa estado de uma meta.

Campos candidatos:
- `id`
- `code`
- `name`
- `sortOrder`
- `isTerminal`

### ReadingGoal

Representa uma meta de leitura do usuario.

Campos candidatos:
- `id`
- `userId`
- `periodTypeId`
- `metricTypeId`
- `statusId`
- `targetValue`
- `startsOn`
- `endsOn`
- `isPublic`
- `createdAt`
- `updatedAt`
- `deletedAt`

### BookSource

Representa a origem externa ou interna de metadados de livro.

Valores candidatos:
- `luminis_catalog`
- `google_books`
- `brasilapi_isbn`
- `open_library`
- `manual`
- `user_suggested`

### BookExternalReference

Representa um identificador de livro em fonte externa.

Campos candidatos:
- `source`
- `externalId`
- `isbn10`
- `isbn13`
- `url`

### UserBookDraft

Representa um livro cadastrado localmente por usuario antes de curadoria global.

Campos candidatos:
- `id`
- `userId`
- `title`
- `authors`
- `editionData`
- `createdAt`
- `suggestedToCatalogAt`

## Value objects candidatos

- `ReadingStatus`
- `BookshelfTag`
- `Rating`
- `Visibility`
- `ExternalBookId`
- `ReadingGroupRole`
- `ReadingGroupVisibility`
- `ReadingGroupJoinPolicy`
- `RecommendationReason`
- `BookSource`

## Perguntas abertas

- `Activity` deve sempre carregar `bookId`/`editionId` ou apenas `targetId` tipado?
- `Activity` sera materializada ou derivada de eventos?
- Grupos tematicos sem `bookId`/`editionId` serao permitidos no MVP?
- Como deduplicar resultados vindos de Google Books, BrasilAPI ISBN e Open Library?
