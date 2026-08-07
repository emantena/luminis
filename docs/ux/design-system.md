# Design System

Status: proposta inicial.

## Tom visual

Luminis deve parecer acolhedor, literario e atual, sem copiar identidades existentes.

## Paleta inicial

Status: proposta aprovada para prototipacao.

```yaml
Primary: "#5f7fa5"
Accent:  "#f59f0a"
Ink:     "#303744"
Surface: "#ffffff"
Canvas:  "#f3f4f6"
Line:    "#d7dde6"
Coral:   "#d95f55"
Warm:    "#e9ca88"
```

Uso sugerido:
- `Primary`: navegacao, elementos estruturais e apoio visual.
- `Accent`: marca, progresso, conquistas, metas e acoes de destaque.
- `Ink`: texto principal e superficies escuras.
- `Surface`: cards e areas elevadas.
- `Canvas`: fundo principal do app.
- `Line`: bordas, divisores e trilhas de progresso.
- `Coral`: alertas, acoes destrutivas e estados que precisam de atencao.
- `Warm`: chips suaves, status de leitura e destaques secundarios.

Referencia visual:
- `docs/ux/design-assets/color-palette.png`
- `docs/ux/design-assets/component-preview.png`

## Componentes candidatos

- `BookCover`
- `BookCard`
- `BookshelfStatusChip`
- `ReadingProgressBar`
- `RatingInput`
- `SpoilerGate`
- `ActivityTile`
- `UserAvatar`
- `EmptyState`

## Fundamentos visuais

Status: proposta aprovada para prototipacao.

### Tipografia

Direcao inicial:
- Usar uma fonte sans-serif moderna e muito legivel.
- Preferencia para `Inter` no prototipo Flutter, com fallback para fonte nativa.
- Evitar serifas no corpo da interface; o toque literario deve vir de composicao, capas e linguagem visual.

Escala sugerida:
- Titulo de tela: 24/30, peso 700.
- Titulo de secao: 18/24, peso 700.
- Titulo de card: 16/22, peso 700.
- Corpo: 14/20, peso 400.
- Metadados: 13/18, peso 400.
- Label/chip: 12/16, peso 600.

### Formas e espacamento

- Raio de cards: 8px.
- Raio de capas: 6px.
- Raio de chips/botoes pequenos: pill.
- Margem lateral mobile: 16px.
- Espacamento entre secoes: 24px.
- Espacamento entre itens de lista: 12px.
- Altura minima de toque: 44px.

### Superficies

- Fundo do app usa `Canvas`.
- Cards usam `Surface` com borda `Line`.
- Evitar cards dentro de cards.
- Usar sombras muito discretas ou nenhuma sombra no MVP; borda e contraste devem sustentar a hierarquia.

## Componentes principais

Status: proposta aprovada para prototipacao.

### `BookCover`

Uso:
- Exibir capa de livro/edicao na estante, busca, detalhe e leitura.

Visual:
- Proporcao 2:3.
- Raio 6px.
- Fundo fallback em `Primary`.
- Quando nao houver capa, mostrar titulo abreviado e/ou icone simples, sem parecer erro.
- Capa deve ter presenca, mas nao dominar telas de lista.

Tamanhos sugeridos:
- Lista compacta: 56x84.
- Card principal: 72x108.
- Detalhe: largura 120 a 150, mantendo proporcao.

### `BookCard`

Uso:
- Item de estante, resultado de busca e atalhos de leitura.

Visual:
- Card em `Surface`, borda `Line`, raio 8px.
- Layout horizontal em listas: capa a esquerda, conteudo no centro, acao/status a direita quando necessario.
- Titulo em `Ink`, autor/editora/idioma em texto secundario.
- Progresso aparece apenas quando ajuda a decisao do usuario.

Conteudo minimo:
- Capa.
- Titulo.
- Autor ou metadado principal.
- Status ou contexto: lendo, pausado, lido, quero ler, resultado de busca.

### `BookshelfStatusChip`

Uso:
- Comunicar status principal da estante.

Visual:
- Pill pequeno, texto curto, peso 600.
- Nao depender apenas de cor; usar label textual sempre.

Mapeamento inicial:
- `all`: fundo `#7b61b5`, texto `Surface`, label `Todos`.
- `read`: fundo `#4fb38a`, texto `Surface`, label `Lido`.
- `reading`: fundo `Accent`, texto `Ink`, label `Lendo`.
- `paused`: fundo `#596574`, texto `Surface`, label `Pausado`.
- `want_to_read`: fundo `#2f80d1`, texto `Surface`, label `Quero ler`.
- `rereading`: fundo `Coral`, texto `Surface`, label `Relendo`.
- `abandoned`: fundo `Ink`, texto `Surface`, label `Abandonei`.

Observacao:
- `Favorito`, `Desejado` e `Avaliado` sao marcadores auxiliares, nao status principal de leitura. Eles nao entram neste mapeamento.
- Referencia visual: `docs/ux/design-assets/status-tag-colors.png`.

### `ReadingProgressBar`

Uso:
- Mostrar progresso de leitura e metas.

Visual:
- Trilho em `Line`.
- Preenchimento em `Accent`.
- Altura entre 8px e 10px.
- Raio total.
- Percentual textual ao lado quando houver espaco.

Regras:
- Para leitura sem total de paginas conhecido, permitir barra por percentual informado.
- Para ritmo indisponivel, mostrar estado neutro em texto secundario, sem erro visual.

### `PrimaryButton`

Uso:
- Acao principal da tela ou fluxo.

Visual:
- Fundo `Accent`.
- Texto `Ink`.
- Altura minima 48px.
- Raio 8px.
- Peso 700.

Exemplos:
- Registrar progresso.
- Adicionar a estante.
- Salvar meta.
- Entrar.

### `SecondaryButton`

Uso:
- Acao alternativa ou navegacao secundaria.

Visual:
- Fundo transparente ou `Surface`.
- Borda `Line`.
- Texto `Ink` ou `Primary`.
- Altura minima 44px.

### `DestructiveButton`

Uso:
- Remover item, abandonar leitura, cancelar meta ou sair.

Visual:
- Fundo `Coral` quando a acao for primaria dentro da confirmacao.
- Texto `Surface`.
- Em listas, preferir texto/icone em `Coral` e confirmacao antes de executar.

### `BottomNavigation`

Uso:
- Shell autenticado do MVP.

Abas:
- Estante.
- Buscar.
- Leitura.
- Metas.
- Perfil.

Visual:
- Fundo `Surface`.
- Borda superior `Line`.
- Item ativo em `Accent` ou `Primary`.
- Item inativo em texto secundario.
- Labels sempre visiveis no MVP para reduzir ambiguidade.

### `EmptyState`

Uso:
- Telas sem dados: estante vazia, sem leitura atual, sem metas, busca sem termo/resultado.

Visual:
- Sem ilustracao complexa obrigatoria.
- Icone simples ou composicao com capa vazia.
- Titulo curto.
- Texto de apoio objetivo.
- Uma acao primaria clara.

Exemplos:
- Estante vazia: acao `Buscar livros`.
- Sem leitura atual: acao `Abrir estante`.
- Sem metas: acao `Criar meta`.
- Busca sem resultado: acao `Criar cadastro local`.

## Diretrizes

- Capas de livros devem ter presenca visual.
- Cards devem ser compactos e legiveis.
- Texto deve ser confortavel para leitura prolongada.
- Acoes destrutivas devem exigir confirmacao.
- Estados vazios devem sugerir proxima acao.

## Acessibilidade

- Contraste adequado.
- Areas de toque confortaveis.
- Texto escalavel.
- Sem depender apenas de cor para comunicar estado.
