# Estados De Erro

## Principios

- Mensagens devem ser humanas e acionaveis.
- Nao expor detalhes tecnicos ao usuario final.
- Registrar detalhes tecnicos em logs quando houver backend/observabilidade.

## Casos comuns

### Falha ao carregar livros

Mensagem:
Nao foi possivel carregar os livros agora.

Acao:
Tentar novamente.

### Falha ao salvar progresso

Mensagem:
Seu progresso nao foi salvo.

Acao:
Tentar novamente.

### Sem conexao

Mensagem:
Parece que voce esta sem conexao.

Acao:
Verificar conexao ou continuar com dados disponiveis, se houver suporte offline.
