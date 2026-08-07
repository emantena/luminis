# Persistencia

Status: aberto.

## Fases

### Mock em memoria

Bom para validar UI e dominio inicial.

### Persistencia local

Necessaria para uso offline, cache e prototipos persistentes.

Opcoes candidatas:
- SQLite/Drift.
- Isar.
- Hive.

### Backend sincronizado

Necessario para rede social real, feed, seguidores, comentarios, autenticacao e catalogo compartilhado.

### Catalogo proprio

Conforme `docs/adr/ADR-002-book-catalog-provider-strategy.md`, o catalogo de livros deve ser proprio quando a arquitetura real for definida. Fontes externas devem enriquecer o catalogo, nao substituir a base interna do Luminis.

## Dados que exigem backend

- Usuarios.
- Catalogo interno de livros.
- Fontes externas normalizadas.
- Seguidores.
- Feed compartilhado.
- Comentarios.
- Resenhas publicas.
- Bloqueios.
- Moderacao.

## Banco principal

Status: aprovado.

O banco principal sera PostgreSQL.

## Acesso a dados no backend

Status: aprovado.

O backend usara Dapper e SQL explicito no MVP. Entity Framework nao sera usado inicialmente.

Racional:
- Queries ficam visiveis.
- Fica mais simples analisar planos de execucao.
- Indices podem ser pensados a partir de SQL real.
- Evita abstracao pesada antes de gargalos conhecidos.

## Migrations

Status: aprovado.

Migrations serao executadas com DbUp em um projeto dedicado `Luminis.Database`, usando scripts SQL versionados.

Referencia normativa:
- `docs/adr/ADR-006-database-migrations-dbup.md`

Regras:
- API nao aplica migrations automaticamente em producao.
- Arquivos devem seguir `ddMMyyyyHHMMSS_<nome_descritivo>.sql`.
- Scripts devem ser pequenos, ordenados e revisaveis.
- Execucao acontece por comando local, CI ou etapa controlada de deploy.

## Perguntas abertas

- Backend proprio ou BaaS?
- App deve funcionar offline?
- Qual fonte de catalogo sera priorizada em cada tipo de busca?
- Quando implementar a camada intermediaria de catalogo?
- Como lidar com rollback de migrations?
- Como organizar seeds iniciais?
