# Revisao Do Prototipo MVP

Status: revisao inicial apos organizacao das telas e handoff Flutter.

Data: 2026-08-07.

## Resultado Geral

O prototipo cobre o nucleo do MVP como organizador pessoal de leitura:

- Estante.
- Auth minimo.
- Busca e descoberta.
- Detalhe do livro.
- Adicionar a estante.
- Cadastro local.
- Leitura hub.
- Estado de leitura.
- Registro de progresso.
- Plano de leitura.
- Decisao ao voltar para `Quero ler`.
- Metas.
- Perfil.

As telas principais possuem especificacao em `docs/ux/prototype-screens.md` e previews organizados em `docs/ux/prototypes/`.

## Ajustes Feitos Durante A Revisao

- Previews de tela e bottom sheets foram movidos para `docs/ux/prototypes/`.
- Criado indice visual em `docs/ux/prototypes/README.md`.
- Atualizadas referencias de previews em `docs/ux/prototype-screens.md`.
- Corrigida a especificacao do detalhe do livro para remover menu de tres pontos do hero.
- Alinhada a navegacao para usar `/reading/:bookshelfItemId` como rota de estado de leitura.
- Criado handoff para Flutter em `docs/ux/flutter-prototype-handoff.md`.

## Pontos Bons

- O fluxo de leitura esta forte e consistente: estado, progresso, plano e decisao de pausa/interrupcao se conectam bem.
- A decisao de editora com `logoUrl` aparece de forma util na busca e no detalhe.
- Metas respeitam as regras aprovadas: conclusao automatica, bonus e meta vencida ainda ativa.
- A UI evita parecer rede social completa antes da hora.
- As acoes sensiveis estao previstas com confirmacao ou separacao visual.

## Lacunas Antes Do Flutter

### Previews Ainda Ausentes Ou Opcionais

- Auth detalhado: `/auth/login`, `/auth/register`, `/auth/forgot-password`, `/auth/reset-password`.
- Editar perfil: `/profile/edit`.

### Estados Que Merecem Preview Ou Mock Dedicado

- Estante vazia.
- Busca sem resultado.
- Erro de provedor na busca.
- Edicao sem `pageCount`.
- Sessao pausada no estado de leitura.
- Ritmo indisponivel no plano de leitura.
- Meta vazia.
- Perfil sem foto e sem bio.

### Decisoes De Baixo Risco Pendentes

- Se Auth detalhado precisa de preview visual antes do Flutter ou pode seguir com formulario padrao simples.
- Se editar perfil precisa entrar no primeiro ciclo de prototipo Flutter ou pode vir depois da navegacao principal.

## Recomendacao

Antes de implementar em Flutter, fechar pelo menos:

1. Preview de editar perfil, se o primeiro ciclo Flutter incluir edicao de perfil.
2. Revisao dos estados vazios e erros antes da implementacao visual final.
3. Encaminhar implementacao para `luminis-flutter-agent`.

Depois disso, o `luminis-flutter-agent` pode iniciar o prototipo com dados mockados e rotas protegidas.
