# Entidades De Dados

Status: proposta inicial.

## Entidades

- User.
- UserExternalLogin.
- UserPasswordCredential.
- RefreshToken.
- PasswordResetToken.
- Book.
- Edition.
- Author.
- Publisher.
- BookshelfItem.
- ReadingSession.
- ReadingProgressEntry.
- Review.
- Activity.
- Comment.
- Follow.
- Block.
- Goal.
- ReadingGroup.
- ReadingGroupMember.
- ReadingGroupCheckpoint.
- Recommendation.
- ReadingGoal.
- ReadingGoalPeriodType.
- ReadingGoalMetricType.
- ReadingGoalStatus.
- BookSource.
- BookExternalReference.
- UserBookDraft.

## Relacoes

- Book possui muitas Editions.
- Book possui muitos Authors via BookAuthor.
- Edition pode pertencer a Publisher.
- User pode ter varios UserExternalLogins.
- User pode ter zero ou uma UserPasswordCredential.
- User pode ter muitos RefreshTokens.
- User pode ter muitos PasswordResetTokens.
- User nao armazena email no MVP.
- User possui status `active`, `suspended` ou `deleted`.
- UserPasswordCredential possui email unico para login local.
- User possui muitos BookshelfItems.
- BookshelfItem pertence a User, Book e opcionalmente Edition.
- Review pertence a User, Book e opcionalmente Edition.
- ReadingSession pertence a BookshelfItem.
- ReadingProgressEntry pertence a ReadingSession.
- Activity pertence a User ator e pode referenciar Book, Edition, Review ou ReadingProgressEntry.
- Follow liga dois usuarios.
- Block liga dois usuarios.
- ReadingGroup pertence a um dono e pode estar associado a Book/Edition.
- ReadingGroupMember liga User e ReadingGroup.
- ReadingGroupCheckpoint pertence a ReadingGroup.
- Recommendation pertence a User e referencia Book/Edition.
- ReadingGoal pertence a User.
- ReadingGoal referencia ReadingGoalPeriodType, ReadingGoalMetricType e ReadingGoalStatus.
- Book/Edition podem ter varias referencias externas.
- BookSource identifica origem de metadados internos ou externos.
- UserBookDraft pertence ao usuario que criou o cadastro local.

## Observacao

Este arquivo deve evoluir junto com `docs/architecture/domain-model.md` e futuros contratos de backend.
