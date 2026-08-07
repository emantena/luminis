# Feature: Metas

## Objetivo

Ajudar usuarios a acompanhar objetivos de leitura sem criar pressao desnecessaria.

## Fluxos principais

- Criar meta anual.
- Criar meta mensal.
- Editar meta.
- Ver progresso.
- Concluir meta.
- Ocultar meta do perfil.

## Regras relacionadas

- `BR-GOAL-001`
- `BR-STATS-001`

## Criterios iniciais

- Meta deve considerar leituras concluidas no periodo definido.
- Usuario pode alterar meta.
- Meta e privada por padrao.
- Visibilidade usa `is_public`.
- MVP deve suportar metas anuais e mensais na experiencia inicial.
- Schema deve suportar mensal, bimestral, trimestral, semestral, anual e customizada.
- Metricas iniciais: livros lidos e paginas lidas.
- Progresso da meta deve ser calculado, nao persistido no MVP.
