# Dependencias Flutter

Status: decisao inicial para prototipo MVP.

Data: 2026-08-07.

## Versoes Aprovadas

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  go_router: ^17.3.0
  flutter_riverpod: ^3.4.1
  http: ^1.6.0

dev_dependencies:
  flutter_lints: ^6.0.0
```

## Dependencias Opcionais Para Codegen Riverpod

Usar apenas quando a repeticao ou complexidade dos providers justificar.

```yaml
dependencies:
  riverpod_annotation: ^4.0.5

dev_dependencies:
  build_runner: any
  riverpod_generator: ^4.0.7
```

## Racional

- `go_router` e a biblioteca aprovada para navegacao declarativa, deep links futuros e shell autenticado.
- `flutter_riverpod` e a biblioteca aprovada para estado e injecao de dependencia.
- `http` e o cliente HTTP aprovado para consumir `mock-api/` (ADR-009) e, depois, a API .NET real. Ver `docs/adr/ADR-010-flutter-http-client-package.md`.
- `flutter_localizations` e a dependencia SDK usada para localizar componentes Material/Cupertino do Flutter em `pt_BR`, incluindo date pickers.
- Codegen Riverpod fica opcional para nao aumentar complexidade antes da necessidade real.

## Regras

- Nao adicionar dependencia estrutural sem atualizar este arquivo.
- Validar compatibilidade com o SDK do `pubspec.yaml`.
- Quando uma major version mudar, criar ou atualizar skill/referencia versionada correspondente.

## Skills Relacionadas

- `luminis-go-router-agent`
- `luminis-riverpod-agent`
