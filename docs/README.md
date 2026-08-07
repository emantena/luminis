# Luminis Docs

Esta pasta e a base de conhecimento do projeto Luminis. Ela deve ser tratada como a fonte primaria para agentes, assistentes e pessoas que precisem entender produto, regras de negocio, arquitetura e padroes de codigo.

## Como usar em modo RAG

Ao responder perguntas ou implementar funcionalidades, consulte primeiro:

0. `docs/rag/session-handoff.md` quando estiver retomando o projeto em outro chat/computador.
1. `docs/agent-guide.md` para entender como usar a documentacao.
2. `docs/product/skoob-research.md` para contexto de produto inspirado no Skoob.
3. `docs/product/business-rules.md` para regras de negocio do Luminis.
4. `docs/architecture/flutter-architecture.md` para decisoes de arquitetura.
5. `docs/engineering/coding-style.md` para convencoes de codigo.

## Arvore de documentacao

```text
docs/
  README.md
  agent-guide.md
  product/
    vision.md
    mvp.md
    glossary.md
    personas.md
    product-principles.md
    roadmap.md
    open-questions.md
    skoob-research.md
    business-rules.md
    business/
    features/
  ux/
  architecture/
  engineering/
  data/
  rag/
  adr/
  qa/
  operations/
```

## Areas

- `product/`: visao, conceitos, regras, features e decisoes de produto.
- `ux/`: arquitetura de informacao, navegacao, estados, conteudo e acessibilidade.
- `architecture/`: estrutura tecnica, dominio, estado, navegacao, persistencia, backend e seguranca.
- `engineering/`: padroes de codigo, testes, dependencias, performance e observabilidade.
- `data/`: entidades, contratos, eventos, analytics e seed data.
- `rag/`: regras para indexacao, recuperacao e avaliacao da base por agentes.
- `docs/rag/product-agent.md`: especificacao do agente de produto do Luminis.
- `adr/`: Architecture Decision Records.
- `qa/`: criterios de aceite, cenarios e checklist de regressao.
- `operations/`: ambientes, release e incidentes.

## Principios

- Documentacao pequena, objetiva e versionada junto com o codigo.
- Cada regra de negocio deve ter um identificador estavel, como `BR-BOOKSHELF-001`.
- Decisoes ainda incertas devem ficar marcadas como `Aberto`, nao escondidas no codigo.
- Agentes devem citar o arquivo consultado quando tomarem decisoes relevantes.

## Estado atual

O projeto Flutter ja existe em estado inicial, com `lib/main.dart` exibindo `Hello World!`. A documentacao inicial foi criada antes da primeira modelagem real da aplicacao.
