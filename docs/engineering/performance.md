# Performance

Status: proposta inicial.

## Areas criticas

- Listas longas de livros.
- Carregamento de capas.
- Feed.
- Busca.
- Estatisticas.

## Diretrizes

- Usar listas virtualizadas para colecoes grandes.
- Cachear imagens de capa quando houver rede.
- Evitar recomputar estatisticas pesadas na UI.
- Separar estados de carregamento por area.
- Medir antes de otimizar profundamente.
