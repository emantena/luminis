# Gerenciamento De Estado

Status: aprovado para MVP.

## Decisao

O app Flutter deve usar Riverpod como estrategia principal de estado e injecao de dependencia.

## Criterios para escolha

- Boa testabilidade.
- Baixo boilerplate para MVP.
- Facilidade para separar dominio e apresentacao.
- Suporte a estados assincronos.
- Comunidade ativa no ecossistema Flutter.

## Racional

- O app tera estado compartilhado entre autenticacao, estante, leitura, progresso e metas.
- Riverpod permite substituir mocks por repositories reais sem reescrever widgets.
- Providers sao testaveis com `ProviderContainer`.
- O projeto precisa de disciplina de camadas sem boilerplate excessivo no MVP.

## Versao Alvo

- `flutter_riverpod`: `^3.4.1`
- `riverpod_annotation`: `^4.0.5`, quando houver codegen.
- `riverpod_generator`: `^4.0.7`, quando houver codegen.

## Diretrizes

- Riverpod deve ser usado para DI e estado de tela.
- Widgets nao instanciam repositories concretos.
- Repositories sao injetados por providers.
- Controllers/notifiers coordenam caso de uso e estado da UI.
- Regras puras ficam no dominio ou application service.
- Mocks implementam os mesmos contratos de futuras APIs reais.
- Estado de tela deve representar carregamento, sucesso vazio, sucesso com dados e erro quando aplicavel.

## Codegen

Status: opcional no primeiro ciclo.

Comecar sem codegen quando a implementacao for pequena e direta. Adotar `riverpod_annotation` e `riverpod_generator` quando controllers/notifiers crescerem ou quando a repeticao justificar.

## Opcoes avaliadas

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

## Fonte Para Implementacao

Ao implementar ou revisar estado, providers, repositories, controllers ou testes, usar `luminis-riverpod-agent`.
