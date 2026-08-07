# API Contracts

Status: placeholder estruturado.

Contratos concretos devem ser adicionados quando backend ou mock server forem definidos.

## Convencoes propostas

- Datas em ISO 8601.
- IDs opacos.
- Respostas paginadas para listas grandes.
- Erros com codigo estavel e mensagem segura.

## Recursos esperados

- Users.
- Books.
- Book search.
- Book ISBN lookup.
- Book sources.
- Bookshelf.
- Reading progress.
- Reviews.
- Feed.
- Comments.
- Follows.
- Blocks.
- Goals.

## Catalogo

O app Flutter deve consumir contratos proprios do Luminis para catalogo. Provedores externos devem ser normalizados por backend/API propria quando a feature sair do prototipo.

Fontes candidatas:
- Google Books para busca textual.
- BrasilAPI ISBN para ISBN.
- Open Library para fallback e enriquecimento.
- Catalogo interno/manual para curadoria.
