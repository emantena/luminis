# Padroes De Codigo

Status: proposta inicial.

## Linguagem

- Codigo, nomes de classes, metodos e variaveis em ingles.
- Textos de interface em portugues do Brasil.
- Documentacao do projeto em portugues do Brasil.

## Flutter

- Preferir widgets pequenos e nomeados quando uma tela crescer.
- Evitar logica de negocio dentro de widgets.
- Usar `const` sempre que possivel.
- Manter arquivos focados em uma responsabilidade.
- Evitar componentes genericos antes de haver repeticao real.

## Nomes

- Entidades de dominio: substantivos claros, como `Book`, `Edition`, `BookshelfItem`, `ReadingSession`.
- Casos de uso/acoes: verbo + objeto, como `addBookToShelf`.
- Estados de UI: nome da feature + `State`, quando aplicavel.

## Erros e validacao

- Validacoes de regra de negocio devem ficar no dominio ou em servicos de aplicacao.
- Mensagens exibidas ao usuario devem ser amigaveis e em portugues.
- Nao retornar `null` para erro esperado quando um tipo explicito puder comunicar melhor o resultado.

## Documentacao junto ao codigo

Atualize `docs/product/business-rules.md` quando:

- Uma nova regra de negocio for criada.
- Uma regra existente mudar.
- Um caso de borda for decidido.

Atualize `docs/architecture/flutter-architecture.md` quando:

- Uma biblioteca estrutural for adicionada.
- A organizacao de pastas mudar.
- Uma decisao de estado, navegacao, storage ou backend for tomada.

## Commits

Quando o projeto virar um repositorio Git, preferir mensagens curtas no estilo:

```text
docs: add initial product knowledge base
feat: add bookshelf screen
fix: keep spoiler reviews hidden by default
```
