# Feature: Grupos De Leitura

## Objetivo

Permitir que usuarios leiam junto, discutam livros e acompanhem cronogramas coletivos.

## Decisoes aprovadas

- Usuario pode criar grupo de leitura.
- Ao criar grupo, define se ele e publico ou fechado.
- Grupos publicos podem ser descobertos.
- Grupos fechados exigem controle de entrada.
- Grupo publico pode ter entrada livre ou entrada por aprovacao.
- Grupos podem ter cronograma coletivo com checkpoints opcionais.

## Fluxos principais

- Criar grupo.
- Definir visibilidade: publico ou fechado.
- Associar grupo a um livro.
- Entrar em grupo publico.
- Solicitar entrada ou aceitar convite em grupo fechado.
- Publicar comentario/discussao no grupo.
- Acompanhar progresso coletivo.
- Criar checkpoints por pagina, capitulo ou data.
- Sair do grupo.
- Moderar membros e conteudo.

## Tipos de grupo

### Publico

Pode aparecer em busca, descoberta e pagina do livro. A entrada pode ser livre ou exigir aprovacao.

### Fechado

Tem visibilidade restrita. Entrada deve depender de convite, aprovacao ou mecanismo equivalente.

## Regras relacionadas

- `BR-GROUP-001`
- `BR-GROUP-002`
- `BR-GROUP-003`
- `BR-GROUP-004`
- `BR-GROUP-005`
- `BR-GROUP-006`
- `BR-FEED-002`

## Criterios iniciais

- Criador do grupo vira dono/moderador inicial.
- Grupo deve ter nome.
- Grupo deve ter visibilidade.
- Primeira versao deve priorizar grupo associado a um livro.
- Atividades de grupos fechados nao devem aparecer no feed publico.
- Checkpoint pode ter titulo, data alvo e pagina ou capitulo alvo.
- Discussao pode ser vinculada a checkpoint.

## Perguntas abertas

- Grupos podem ser tematicos sem livro associado no MVP?
- Havera topicos separados dentro do grupo?
- Comentarios em grupo terao marcacao de spoiler por capitulo/pagina?
