# ADR-001 - Flutter First

Status: Aceita

## Contexto

O projeto Luminis foi iniciado como aplicativo Flutter. O produto desejado e mobile-first, com potencial futuro para outras plataformas.

## Decisao

Usar Flutter como tecnologia principal do cliente inicial.

## Consequencias

- O desenvolvimento inicial concentra-se em `lib/` e no ecossistema Dart/Flutter.
- A arquitetura deve manter dominio legivel para facilitar testes e possivel compartilhamento de regras.
- Decisoes de backend, estado e persistencia permanecem abertas.

## Alternativas consideradas

- App nativo Android/iOS separado.
- Web app responsivo primeiro.
- React Native.

## Referencias

- `docs/architecture/flutter-architecture.md`
