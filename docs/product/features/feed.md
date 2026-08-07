# Feature: Feed

## Objetivo

Exibir atividade literaria relevante para o usuario.

## Decisao atual

O feed deve seguir um modelo hibrido: algumas atividades podem ser publicadas automaticamente, outras devem exigir confirmacao ou configuracao do usuario.

O MVP nao tera feed completo. Quando o social entrar, o feed inicial deve usar padroes fixos e respeitosos. Configuracoes finas por tipo de atividade ficam para etapa posterior.

## Tipos de atividade

- Livro adicionado a estante.
- Leitura iniciada.
- Progresso publicado.
- Livro concluido.
- Avaliacao publicada.
- Resenha publicada.
- Meta concluida.

## Regras relacionadas

- `BR-SOCIAL-001`
- `BR-SOCIAL-002`
- `BR-FEED-001`
- `BR-FEED-002`
- `BR-FEED-003`
- `BR-PRIVACY-001`
- `BR-PRIVACY-002`

## Criterios iniciais

- Feed deve respeitar privacidade e bloqueios.
- Atividades com spoiler devem ocultar conteudo sensivel.
- Usuario deve conseguir acessar livro, perfil e comentarios a partir do item do feed.

## Publicacao sugerida

### Publica automaticamente

- Resenha publicada.
- Livro concluido.

### Pergunta antes de publicar

- Progresso de leitura.
- Meta criada.
- Atualizacao de ritmo.
- Entrada em grupo publico.

### Privado por padrao

- Livro abandonado.
- Progresso detalhado.
- Notas pessoais.
- Grupos fechados.
- Ritmo individual.

## Perguntas abertas

- O usuario podera configurar publicacao automatica por tipo de atividade?
- Criar meta deve aparecer no feed?
- Entrar em grupo publico deve aparecer no feed?
