# Guia Para Agentes

Este guia define como agentes devem trabalhar no Luminis.

## Ordem de consulta

1. Leia `docs/README.md`.
2. Leia a documentacao especifica do dominio afetado.
3. Leia o codigo existente antes de propor ou aplicar mudancas.
4. Se houver conflito entre documentacao e codigo, trate como divergencia e registre no resultado.

## Respostas sobre produto

Ao responder perguntas de produto:

- Use `docs/rag/product-agent.md` como especificacao de comportamento do agente de produto.
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
