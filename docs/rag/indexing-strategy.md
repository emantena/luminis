# Estrategia De Indexacao RAG

Status: proposta inicial.

## Objetivo

Permitir que agentes encontrem rapidamente informacao confiavel sobre produto, negocio, arquitetura e codigo.

## Unidades de recuperacao

- Preferir documentos pequenos por assunto.
- Usar headings claros.
- Manter identificadores estaveis para regras e ADRs.
- Evitar arquivos enormes misturando dominios.

## Prioridade de fontes

1. `docs/product/business-rules.md` e `docs/product/features/`.
2. `docs/architecture/`.
3. `docs/engineering/`.
4. Codigo fonte.
5. Pesquisa externa, quando explicitamente necessario.

## Metadados manuais

Cada documento deve deixar claro:

- Status.
- Ultima verificacao quando houver pesquisa externa.
- Regras relacionadas quando aplicavel.
- Perguntas abertas.
