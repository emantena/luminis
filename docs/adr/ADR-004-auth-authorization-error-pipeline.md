# ADR-004 - Autenticacao, Autorizacao E Tratamento De Erros

Status: Aceita

## Contexto

Luminis tera app Flutter mobile-first, backend .NET e recursos sociais com privacidade relevante: estante, progresso, resenhas, grupos publicos/fechados, bloqueios e feed. Precisamos de autenticacao simples para usuario final, especialmente Android, e autorizacao confiavel no backend.

Para usuarios Android, entrar ou criar conta com Google tende a reduzir friccao. Ao mesmo tempo, o backend nao deve depender de detalhes de UI ou claims HTTP espalhadas pelo dominio.

## Decisao

O backend deve usar autenticacao baseada em bearer token/JWT ou OIDC compativel. O app Flutter deve priorizar login com Google como caminho inicial de autenticacao para usuarios Android, mas login por email e senha tambem entra no MVP.

O backend deve manter uma identidade interna do Luminis associada a provedores externos de login.

O MVP usara autenticacao propria no backend. Firebase Auth nao entra no MVP.

Recuperacao de senha e emails transacionais devem usar uma abstracao de envio de email, como `IEmailSender`, com provider concreto a decidir.

O pipeline HTTP deve incluir:

1. Correlation/Request Id.
2. Tratamento global de excecoes.
3. Logging/observabilidade.
4. Autenticacao.
5. Autorizacao.
6. Rotas dos modulos.

## Direcao de login

Fluxo conceitual:

```text
Flutter
  -> Google Sign-In
  -> envia token/credencial ao backend
Backend
  -> valida token com provedor
  -> encontra ou cria usuario interno
  -> emite sessao/token aceito pela API
Flutter
  -> envia Authorization: Bearer <token>
```

## Identidade interna

O usuario do dominio deve ser representado por uma identidade interna do Luminis. Provedores externos devem ser detalhes de autenticacao.

Entidades candidatas:
- `User`
- `UserExternalLogin`
- `UserPasswordCredential`
- `RefreshToken`
- `PasswordResetToken`

Campos candidatos de `UserExternalLogin`:
- `userId`
- `provider`
- `providerUserId`
- `providerEmail`
- `createdAt`
- `lastLoginAt`

Campos candidatos de `UserPasswordCredential`:
- `userId`
- `email`
- `passwordHash`
- `passwordHashAlgorithm`
- `emailVerifiedAt`
- `passwordUpdatedAt`
- `createdAt`
- `lastLoginAt`

Regras:
- Senha nunca deve ser armazenada em texto puro.
- `users` nao deve armazenar email no MVP.
- `user_external_logins.providerEmail` representa email informado pelo provedor externo.
- `user_password_credentials.email` representa email de login local e deve ser unico.
- Usuario pode ter login externo, login por senha ou ambos vinculados a mesma conta interna.
- Refresh token real nunca deve ser armazenado em texto puro.
- Password reset token real nunca deve ser armazenado em texto puro.
- Logout deve revogar refresh token.
- Refresh deve rotacionar refresh token.
- Forgot password nao deve revelar se o email existe.

## Autorizacao

Autorizacao deve existir em dois niveis:

### Autorizacao tecnica

- Usuario autenticado.
- Claims basicas.
- Roles/policies simples quando existirem.

### Autorizacao de negocio

Deve ficar em Application/Domain services dos modulos.

Exemplos:
- Usuario pode editar esta resenha?
- Usuario pode ver este grupo fechado?
- Usuario pode entrar neste grupo?
- Bloqueio impede comentario/interacao?
- Progresso deve permanecer privado?

## Tratamento de erros

Erros esperados devem usar resultado explicito, como `Result`, em vez de exceptions como fluxo normal.

Exceptions devem representar falhas inesperadas.

Resposta de erro deve seguir `ProblemDetails` customizado ou formato equivalente, contendo:

- `code`
- `message`
- `traceId`
- detalhes de validacao quando existirem

Exemplo:

```json
{
  "code": "validation.failed",
  "message": "Existem campos invalidos.",
  "traceId": "00-...",
  "errors": {
    "title": ["Titulo e obrigatorio."]
  }
}
```

## Regras

- Nao vazar stack trace em producao.
- Todo erro esperado deve ter codigo estavel.
- Toda resposta de erro deve incluir `traceId`.
- Endpoints nao devem conter regra de negocio.
- Claims HTTP nao devem ser usadas diretamente no dominio.
- Application deve receber `CurrentUser`/`UserContext` abstraido.

## Consequencias

- Login com Google reduz friccao no Android.
- Login por email e senha permite cadastro fora do fluxo Google e facilita acesso multiplataforma.
- Auth proprio preserva controle do dominio de identidade.
- Backend continua sendo fonte de verdade de usuario interno e autorizacao.
- Erros ficam padronizados para Flutter e backend.
- Autorizacao de negocio nao fica limitada a atributos/policies.
- Ainda precisamos escolher detalhes do provedor e biblioteca de login no Flutter.

## Perguntas futuras

- O backend emitira JWT proprio ou usara tokens do provedor diretamente?
- Haverá Apple Sign-In para iOS?
- Qual biblioteca Flutter sera usada para Google Sign-In?
- Usaremos `ProblemDetails` nativo customizado ou envelope proprio?
- Qual algoritmo/biblioteca de hash de senha sera adotado?
- Qual provider de email transacional sera usado?
