# Observabilidade

Status: proposta inicial.

## Objetivo

Entender falhas, comportamento e saude do app sem violar privacidade.

## Eventos candidatos

- Livro adicionado a estante.
- Status alterado.
- Progresso registrado.
- Resenha publicada.
- Busca realizada.
- Erro ao salvar dado.

## Cuidados

- Nao registrar texto integral de resenhas em analytics.
- Nao registrar tokens.
- Evitar dados pessoais em logs.
- Eventos devem ter nomes estaveis.
