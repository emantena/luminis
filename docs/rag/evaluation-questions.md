# Perguntas De Avaliacao RAG

Use estas perguntas para testar se a base de conhecimento esta recuperavel.

## Produto

- O que e o Luminis?
- O que entra no MVP do Luminis?
- Como o agente de produto deve diferenciar aprovado, proposta e aberto?
- O Luminis deve copiar o Skoob?
- Quais status de leitura existem?
- Qual a diferenca entre status de leitura e etiqueta?
- Resenha precisa ter tamanho minimo?
- Grupos de leitura podem ser publicos ou fechados?
- Grupo publico pode exigir aprovacao?
- Grupos de leitura terao checkpoints?
- A recomendacao inicial e social ou IA-first?
- Como o app calcula paginas por dia para terminar uma leitura?
- Qual a diferenca entre BookshelfItem, ReadingPlan, ReadingSession e ReadingProgressEntry?
- O progresso aponta para bookshelf item ou reading session?
- `daily_pages_target` e persistido?
- Onde fica `target_finish_date`?
- Qual e a diferenca entre Book e Edition?
- O usuario pode criar livro manualmente?

## Arquitetura

- Qual e a estrutura Flutter sugerida?
- O gerenciamento de estado ja foi decidido?
- Quais entidades principais existem no dominio?
- Quando devo criar uma ADR?
- O Flutter deve chamar Google Books diretamente na arquitetura final?
- Quais fontes candidatas existem para catalogo de livros?
- O backend sera microservicos ou monolito modular?
- Qual stack backend foi aprovada?
- Quais modulos entram no backend MVP?
- Quais modulos ficam pos-MVP?
- O MVP usara Entity Framework, CQRS ou Hangfire?
- Como migrations de banco serao executadas?
- A API pode aplicar migrations automaticamente em producao?
- Qual e o padrao de nome dos arquivos de migration?
- Qual caminho de login deve ser priorizado para usuarios Android?
- Login por email e senha entra no MVP?
- Onde a senha deve ser armazenada?
- Em quais tabelas email deve existir no Identity?
- Quais tabelas compõem o schema Identity do MVP?
- Firebase Auth entra no MVP?
- Como logout, refresh e reset de senha funcionam no MVP?
- Tokens reais devem ser armazenados em texto puro?
- Quais valores `users.status` aceita?
- Onde fica autorizacao de negocio?
- Como erros de API devem ser retornados?
- O backend usara Minimal APIs ou Controllers inicialmente?
- Onde ficam as rotas de cada modulo?
- O `Program.cs` pode registrar endpoints individuais?

## Social

- O feed deve exibir quais atividades?
- Como spoiler deve se comportar?
- O que acontece quando um usuario bloqueia outro?
- Quais atividades sao privadas por padrao?

## Dados

- Quais eventos podem alimentar feed e estatisticas?
- Qual e a diferenca entre Book e Edition no dominio?
- O catalogo proprio sera importado em massa ou criado sob demanda?
- Quais tabelas compoem o Catalog MVP?
- Editoras possuem logo?
- `publisher_id` pertence a `bookshelf_items` ou `editions`?
- Quais tabelas compoem Goals no schema MVP?
- Quais periodos e metricas de meta existem?
- Meta usa `visibility` textual ou `is_public` booleano?
- O progresso da meta e persistido ou calculado?
- Quais dados nao devem ser coletados em analytics?
