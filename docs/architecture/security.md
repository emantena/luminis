# Seguranca

Status: proposta inicial.

## Areas de atencao

- Autenticacao.
- Autorizacao.
- Privacidade de perfil e estante.
- Bloqueios.
- Denuncias.
- Conteudo com spoiler.
- Dados pessoais.

## Principios

- Cliente Flutter nao deve ser fonte de verdade para permissoes.
- Backend deve validar todas as acoes sensiveis.
- Conteudos privados nao devem ser enviados ao cliente sem autorizacao.
- Logs nao devem conter tokens ou dados sensiveis.

## Autenticacao

Status: aprovado para direcao inicial.

O app deve priorizar login com Google, especialmente para reduzir friccao em usuarios Android.

Login por email e senha tambem entra no MVP.

O backend deve trabalhar com bearer token/JWT ou OIDC compativel e manter usuario interno do Luminis associado a provedores externos e/ou credencial local.

Firebase Auth nao entra no MVP. A autenticacao sera propria no backend.

Senha nunca deve ser armazenada em texto puro. Credenciais locais devem armazenar apenas hash, algoritmo usado e datas relevantes.

Email deve ter fonte clara:
- `users` nao armazena email no MVP.
- Email de provedor externo fica no login externo.
- Email de login local fica na credencial de senha e deve ser unico.

Credenciais locais devem manter `failed_attempts` e `locked_until` para suportar bloqueio temporario por tentativas falhas.

Refresh tokens e tokens de reset de senha devem ser armazenados apenas como hash.

Email transacional deve ser acessado por abstracao, como `IEmailSender`, com provider concreto definido posteriormente.

## Autorizacao

Autorizacao tecnica:
- Usuario autenticado.
- Claims/policies simples.

Autorizacao de negocio:
- Deve ficar nos modulos de aplicacao/dominio.
- Deve validar dono de recurso, privacidade, bloqueios, grupos fechados e permissoes contextuais.

## Erros

Erros de API devem retornar codigo estavel, mensagem segura e `traceId`.

Stack trace nao deve ser exposto em producao.

## Perguntas abertas

- Qual provedor de autenticacao sera usado?
- Qual politica de exclusao de conta e dados?
- O backend emitira JWT proprio ou aceitara token do provedor diretamente?
- Havera Apple Sign-In para iOS?
- Qual algoritmo/biblioteca de hash de senha sera adotado?
- Qual provider de email transacional sera usado?
