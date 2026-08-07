# ADR-002 - Estrategia De Fontes Para Catalogo De Livros

Status: Aceita

## Contexto

Luminis precisa de uma fonte confiavel para pesquisar livros, preencher metadados, obter capas e permitir busca por ISBN. Nenhuma fonte externa cobre todos os casos com qualidade perfeita, especialmente considerando livros brasileiros, edicoes diferentes, capas, sinopses, paginacao e duplicidades.

O uso direto de APIs externas pelo app Flutter acoplaria o cliente a provedores especificos, dificultaria cache, normalizacao, controle de quota, correcao manual e troca futura de fornecedor.

## Decisao

O Luminis deve ter um catalogo proprio, enriquecido por fontes externas. A consulta a provedores externos deve passar por uma camada propria de backend/API do Luminis, nao diretamente pelo cliente Flutter na arquitetura final.

Fontes externas previamente aprovadas podem alimentar o catalogo global sob demanda depois de normalizacao, validacao e deduplicacao no backend. A aprovacao da fonte e esses controles automaticos constituem a governanca exigida para essa importacao.

Cadastros, sugestoes e correcoes enviados por usuarios nao podem integrar o catalogo global sem curadoria futura.

Fontes candidatas:

- Google Books: fonte inicial para busca textual por titulo, autor, assunto e ISBN.
- BrasilAPI ISBN: fonte prioritaria para consulta por ISBN, especialmente no contexto brasileiro, pois agrega provedores como CBL, Mercado Editorial, Open Library e Google Books.
- Open Library: fallback e fonte complementar para obras, edicoes, autores e capas.
- Cadastro manual/curadoria: necessario para livros ausentes, duplicados ou com metadados incorretos.

## Consequencias

- O Flutter consome contratos proprios do Luminis, nao formatos crus de provedores externos.
- O backend pode cachear resultados e reduzir chamadas externas.
- O catalogo interno pode receber correcoes e curadoria.
- O app pode registrar a origem dos metadados.
- A equipe pode trocar ou reordenar provedores sem reescrever telas.
- Ha custo adicional de construir uma camada de catalogo/backend.

## Alternativas consideradas

### Usar apenas Google Books direto no Flutter

Mais simples para prototipo, mas cria acoplamento, limita normalizacao e dificulta curadoria.

### Usar apenas Open Library

Boa fonte aberta, mas pode ter lacunas de cobertura, especialmente em livros/editoras brasileiras e resultados comerciais recentes.

### Usar apenas BrasilAPI ISBN

Boa para ISBN e contexto brasileiro, mas nao resolve bem busca textual por titulo/autor nem descoberta ampla.

### Catalogo totalmente manual

Da controle maximo, mas torna o inicio lento e prejudica experiencia de busca.

## Direcao para o momento certo

Quando formos implementar catalogo real, avaliar:

- Volume esperado de buscas.
- Necessidade de backend ja existir no MVP.
- Limites e termos de uso dos provedores.
- Qualidade dos resultados em portugues do Brasil.
- Estrategia de cache e deduplicacao.
- Como armazenar obras versus edicoes.
- Como tratar capas e direitos de uso.

## Referencias

- `docs/architecture/backend-contracts.md`
- `docs/architecture/persistence.md`
- `docs/architecture/domain-model.md`
- `docs/data/entities.md`
- Google Books API: https://developers.google.com/books/docs/v1/using?hl=pt-BR
- BrasilAPI ISBN: https://brasilapi.com.br/docs#tag/ISBN
- Open Library APIs: https://openlibrary.org/developers/api
