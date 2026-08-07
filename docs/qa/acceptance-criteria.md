# Criterios De Aceite

Status: proposta inicial.

## Padrao

Cada feature deve ter criterios verificaveis.

Formato:

```md
### AC-FEATURE-000 - Titulo

Dado:
Quando:
Entao:
```

## Exemplos

### AC-BOOKSHELF-001 - Adicionar livro

Dado:
Usuario esta na pagina de um livro fora da estante.

Quando:
Usuario toca em adicionar a estante.

Entao:
Livro passa a aparecer na estante do usuario.

### AC-REVIEW-001 - Spoiler oculto

Dado:
Uma resenha foi marcada como spoiler.

Quando:
Outro usuario visualiza a resenha.

Entao:
Texto integral permanece oculto ate acao explicita.
