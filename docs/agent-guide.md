# Guia Para Agentes

Este guia define como agentes devem trabalhar no Luminis.

## Ordem de consulta

1. Se disponivel, use a skill local adequada em `.agents/skills` (Codex) ou `.claude/skills` (Claude Code).
2. Leia `docs/README.md`.
3. Leia a documentacao especifica do dominio afetado.
4. Leia o codigo existente antes de propor ou aplicar mudancas.
5. Se houver conflito entre documentacao e codigo, trate como divergencia e registre no resultado.

## Skills locais do projeto

Existem em dois formatos equivalentes, mantidos em paralelo:

- `.agents/skills/<nome>/` para Codex (com `agents/openai.yaml`).
- `.claude/skills/<nome>/` para Claude Code, mais `.claude/agents/<nome>.md` com subagents finos que apontam para a skill correspondente e podem ser invocados em contexto isolado.

O conteudo normativo (papel, fronteira, fluxo, referencias) e o mesmo nos dois formatos. Ao registrar uma decisao nova de uma skill, atualize as duas versoes para nao divergirem.

- `luminis-product-agent`: produto, MVP, regras de negocio, escopo, decisoes e documentacao.
- `luminis-ux-agent`: jornadas, telas, estados, interacoes, usabilidade e prototipacao.
- `luminis-flutter-agent`: implementacao Flutter, `go_router`, Riverpod, mocks, widgets e validacao do app.
- `luminis-go-router-agent`: navegacao Flutter com `go_router` 17.x, redirects, shell autenticado e rotas.
- `luminis-riverpod-agent`: estado, injecao de dependencia, providers, repositories, controllers e testes com Riverpod 3.x.

O agente de produto deve delegar para UX quando a pergunta for sobre experiencia/telas e para Flutter quando a pergunta for sobre implementacao.
O agente Flutter deve delegar para `luminis-go-router-agent` quando mexer em navegacao e para `luminis-riverpod-agent` quando mexer em estado ou DI.

## Respostas sobre produto

Ao responder perguntas de produto:

- Use `docs/rag/product-agent.md` como especificacao de comportamento do agente de produto.
- Use `.agents/skills/luminis-product-agent` como ponto de entrada quando a sessao suportar skills locais.
- Use `docs/product/business-rules.md` como fonte normativa.
- Use `docs/product/skoob-research.md` apenas como referencia de inspiracao e benchmarking.
- Nao assuma que o Luminis deve copiar o Skoob. O objetivo e criar uma rede social de livros propria.

## Implementacao

Ao implementar:

- Prefira escopos pequenos e verificaveis.
- Atualize a documentacao quando criar ou alterar uma regra de negocio.
- Evite regras implicitas escondidas em widgets.
- Separe estado, dominio e apresentacao quando o fluxo crescer.

## Como registrar conhecimento novo

Use este formato para novas regras:

```md
### BR-DOMINIO-000 - Titulo curto

Status: Proposta | Aprovada | Depreciada

Regra:
Explicacao objetiva.

Criterios:
- Cenario verificavel.
```

Use este formato para decisoes:

```md
### ADR-000 - Titulo curto

Status: Proposta | Aceita | Substituida
Contexto:
Decisao:
Consequencias:
```
