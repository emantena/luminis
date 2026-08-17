/// Status de submissão compartilhado por controllers de comando/formulário
/// (ex.: `auth`, `books`, `bookshelf`).
///
/// Cada controller mantém seu próprio state class com este status mais
/// campos específicos (ex.: `fieldErrors`), em vez de forçar tudo em
/// `AsyncValue`, conforme `references/riverpod-3.md`.
///
/// Promovido de `features/auth/presentation/state/` para `shared/` quando a
/// feature `bookshelf` passou a precisar do mesmo enum para seus controllers
/// de comando (adicionar/alterar status/alterar tags/remover), evitando
/// duplicar um enum idêntico entre features.
enum FormSubmissionStatus { idle, submitting, success, error }
