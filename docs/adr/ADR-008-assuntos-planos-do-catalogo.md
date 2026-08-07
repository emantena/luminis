# ADR-008 - Preservar Assuntos Planos No Catalogo

Status: Aceita

## Contexto

O Catalog importa obras e edicoes sob demanda de provedores externos aprovados. Sem preservar assuntos ou categorias desses provedores, o catalogo cresceria sem informacao de genero e a busca `type=subject` dependeria sempre de fontes externas.

Uma taxonomia completa exigiria hierarquia, sinonimos, equivalencias entre fontes e curadoria propria, o que ultrapassa o MVP.

## Decisao

Persistir assuntos em um modelo plano, composto por `subjects` e `book_subjects`.

- `subjects` armazena o nome e a forma normalizada do assunto.
- `book_subjects` vincula a obra ao assunto e preserva internamente a fonte que informou o vinculo.
- Provedores externos aprovados sao a verdade operacional inicial para esses assuntos.
- `type=subject` consulta os vinculos internos e pode complementar resultados com provedores que suportem busca por assunto.

O detalhe da obra expõe uma lista normalizada de assuntos. A origem do vinculo nao e exposta ao Flutter.

## Consequencias

### Positivas

- O catalogo preserva generos e categorias importados.
- Busca por assunto passa a funcionar tambem sobre o catalogo proprio.
- A estrutura admite evolucao futura para taxonomia e mapeamentos sem perder os vinculos existentes.

### Custos e limites

- Categorias semanticamente parecidas podem coexistir no MVP.
- Nao ha hierarquia, sinonimos, equivalencias manuais ou navegacao por genero.
- A qualidade dos assuntos depende das fontes aprovadas ate a introducao de curadoria propria.

## Alternativas consideradas

### Consultar assuntos apenas em provedores externos

Rejeitada porque deixaria o catalogo interno sem informacao de genero e manteria esse tipo de busca dependente de provedores.

### Criar uma taxonomia completa no MVP

Adiada porque exige decisoes de produto e curadoria que nao sao necessarias para preservar os assuntos importados agora.

## Referencias

- `docs/product/business-rules.md` (`BR-BOOK-008`)
- `docs/data/database-schema-mvp.md`
- `docs/data/database-schema-mvp-er.md`
- `docs/architecture/backend-contracts.md`
- `docs/adr/ADR-002-book-catalog-provider-strategy.md`
