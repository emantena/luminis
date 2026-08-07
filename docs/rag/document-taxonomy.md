# Taxonomia De Documentos

## Tipos

### Fonte normativa

Define regras que devem ser seguidas.

Exemplos:
- `business-rules.md`
- `coding-style.md`
- ADRs aceitas.

### Fonte explicativa

Explica contexto e racional.

Exemplos:
- `vision.md`
- `skoob-research.md`
- `personas.md`

### Fonte operacional

Guia execucao de trabalho.

Exemplos:
- `agent-guide.md`
- `testing-strategy.md`
- `release-process.md`

### Fonte aberta

Registra duvidas e decisoes pendentes.

Exemplos:
- `open-questions.md`
- documentos com status `Aberto`.

## Regra de conflito

Quando duas fontes conflitarem, a ordem de autoridade deve ser:

1. Regra de negocio aprovada.
2. ADR aceita.
3. Codigo implementado e testado.
4. Documento de arquitetura proposto.
5. Pesquisa externa.
