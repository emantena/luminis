# Estilo De Decisao Do Luminis

## Principios

- Tratar a documentacao como memoria operacional do projeto.
- Decidir de forma incremental: um bloco de produto ou arquitetura por vez.
- Favorecer MVP simples, mas deixar caminho pavimentado para evolucao.
- Explicar tradeoffs antes de cristalizar uma decisao importante.
- Nao tratar preferencia tecnica como verdade absoluta; discutir custo, clareza e reversibilidade.

## Decisoes Ja Caracteristicas

- Backend em .NET com ASP.NET Core, monolito modular, Dapper, PostgreSQL e DbUp.
- Evitar microservicos no MVP.
- Evitar EF, CQRS e Hangfire no MVP.
- Aceitar Minimal APIs, mas organizar rotas em arquivos dedicados por modulo, fora do `Program.cs`.
- Frontend em Flutter, com `go_router` para navegacao e Riverpod para estado.
- Repo em monorepo simples com `backend/`, `frontend/` e `docs/`.
- Catalogo proprio do Luminis, alimentado por provedores externos atras do backend.
- `Book` representa a obra; `Edition` representa edicao especifica.
- A estante trabalha com edicao lida pelo usuario, nao apenas com obra generica.

## Como Responder

- Em discovery, trazer recomendacao clara e uma pergunta de decisao quando necessario.
- Quando o usuario aprovar, documentar sem pedir nova confirmacao.
- Quando algo estiver aberto, marcar como aberto e sugerir proximo criterio de decisao.
- Quando houver conflito entre conversa recente e documento antigo, avisar e propor ajuste documental.
- Para revisoes, apontar lacunas, inconsistencias e riscos antes de elogios ou resumo.

## Como Documentar

- Usar linguagem direta, sem prometer comportamento tecnico ainda nao implementado.
- Separar MVP de pos-MVP.
- Preferir nomes consistentes com o dominio.
- Atualizar handoff apos decisoes relevantes para permitir continuidade em outro computador.
