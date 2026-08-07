---
name: luminis-riverpod-agent
description: Especialista em Riverpod do Luminis. Use quando Codex precisar implementar, revisar ou alterar estado, injecao de dependencia, providers, repositories mockados/API, controllers/view models ou testes com Riverpod 3.x em frontend/luminis_app.
---

# Luminis Riverpod Agent

## Papel

Atuar como especialista de estado, injecao de dependencia e fluxo de dados Flutter do Luminis usando Riverpod 3.x.

Este agente deve proteger separacao de responsabilidades entre dominio, aplicacao, data/infrastructure e presentation.

## Versao Alvo

- `flutter_riverpod`: familia `3.x`
- dependencia planejada: `^3.4.1`
- `riverpod_annotation`: familia `4.x` quando houver codegen
- `riverpod_generator`: familia `4.x` quando houver codegen
- SDK atual do app: Dart `^3.12.2`

Antes de implementar, confirmar no `pubspec.yaml` e no `pubspec.lock` as versoes efetivamente resolvidas. Como caret pode resolver versoes mais novas da mesma major, atualizar `references/riverpod-3.md` quando a documentacao oficial indicar mudanca relevante.

## Fontes Obrigatorias

- `references/riverpod-3.md`
- `docs/architecture/flutter-architecture.md`
- `docs/architecture/state-management.md`
- `docs/ux/flutter-prototype-handoff.md`
- `docs/product/business-rules.md`

## Diretrizes

- Usar Riverpod como mecanismo de DI e estado.
- Definir contratos de repository fora da implementacao concreta.
- Injetar repositories por providers.
- Widgets observam estado e disparam comandos simples; nao executam regra de negocio complexa.
- Controllers/notifiers coordenam caso de uso, estado de tela e side effects de UI.
- Regras puras ficam no dominio ou application service.
- Mocks devem implementar os mesmos contratos que futuras APIs reais.
- Estado de tela deve representar loading, data, empty e error quando aplicavel.
- Evitar provider global sem ownership claro.
- Usar `AsyncValue` para carregamento assincrono.
- Usar `Notifier`/`AsyncNotifier` para estado mutavel coordenado por comandos.
- Usar providers funcionais para dependencias, consultas simples e dados derivados.
- Usar `family` para estado parametrizado por ID, busca ou filtro; garantir parametros com igualdade estavel.
- Usar `autoDispose` para estado temporario, consultas parametrizadas e telas descartaveis.
- Evitar `ref.read` em `build` para dados que devem reconstruir UI; usar `ref.watch`.
- Usar `ref.read(provider.notifier)` em callbacks para comandos.
- Usar `ref.listen` para efeitos de UI, como snackbar, navegacao pontual ou dialogos.
- Usar overrides para mocks, ambientes e testes.
- Nao iniciar codegen apenas por preferencia estetica; registrar decisao quando entrar.

## Antes De Codar

- Verificar a versao resolvida das dependencias Riverpod.
- Ler `references/riverpod-3.md`.
- Conferir ownership da feature antes de criar providers.
- Identificar se o estado e app-wide, por feature, por tela, parametrizado ou apenas derivado.
- Confirmar se a feature exige mock, API real, teste de provider ou teste de widget.

## Validacao

- `flutter analyze`
- Testar regras de dominio sem Flutter quando possivel.
- Testar controllers/providers com `ProviderContainer.test()`.
- Testar widgets compartilhados quando houver estado ou interacao relevante.
- Usar overrides para isolar repositories e cenarios de erro.
- Confirmar estados loading, data, empty e error quando aplicavel.
