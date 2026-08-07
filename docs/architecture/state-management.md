# Gerenciamento De Estado

Status: aberto.

## Situacao atual

O app ainda esta no estado inicial. Nenhuma solucao de estado foi adotada.

## Criterios para escolha

- Boa testabilidade.
- Baixo boilerplate para MVP.
- Facilidade para separar dominio e apresentacao.
- Suporte a estados assincronos.
- Comunidade ativa no ecossistema Flutter.

## Opcoes candidatas

### Riverpod

Vantagens:
- Forte composicao.
- Bom suporte a estado assincrono.
- Testavel.

Riscos:
- Requer disciplina para nao espalhar providers sem criterio.

### Bloc

Vantagens:
- Fluxos explicitos.
- Bom para estados complexos e times maiores.

Riscos:
- Pode ser verboso para prototipo inicial.

### ValueNotifier/setState

Vantagens:
- Simples para primeiras telas.

Riscos:
- Pode gerar refatoracao cedo quando estado atravessar features.

## Direcao sugerida

Comecar simples no prototipo. Ao criar fluxos reais de estante, leitura e feed, escolher uma solucao oficial antes de expandir estado compartilhado.
