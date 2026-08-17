/// Paths e helpers de construção de URL para as rotas do Luminis.
///
/// Segmentos usados como filhos de um `GoRoute` pai ficam sufixados com
/// `Segment` (relativos ao path do pai, conforme declarado em
/// `app_router.dart`); as demais constantes são paths absolutos. Ver
/// `docs/architecture/navigation.md` para o mapa de navegação aprovado.
abstract final class AppRoutePaths {
  const AppRoutePaths._();

  static const String authWelcome = '/auth/welcome';
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';

  static const String bookshelf = '/bookshelf';
  static const String search = '/search';
  static const String reading = '/reading';
  static const String goals = '/goals';
  static const String profile = '/profile';

  /// Declarada como irmã de `/search` dentro da branch Buscar (não como
  /// filha), porque o path `/books/:bookId` não é um sub-path de
  /// `/search` — ver decisão registrada em `app_router.dart`.
  static const String bookDetail = '/books/:bookId';

  /// Fora do shell autenticado (usa `parentNavigatorKey` raiz), conforme
  /// `docs/architecture/navigation.md` ("root navigator se for fluxo
  /// global").
  static const String bookDraftNew = '/book-drafts/new';

  static const String readingStateSegment = ':bookshelfItemId';
  static const String readingProgressNewSegment = 'progress/new';
  static const String readingPlanSegment = 'plan';
  static const String goalNewSegment = 'new';
  static const String goalDetailSegment = ':readingGoalId';
  static const String goalEditSegment = 'edit';
  static const String profileEditSegment = 'edit';

  static String bookDetailPath(String bookId) => '/books/$bookId';

  static String readingStatePath(String bookshelfItemId) =>
      '/reading/$bookshelfItemId';

  static String readingProgressNewPath(String bookshelfItemId) =>
      '/reading/$bookshelfItemId/progress/new';

  static String readingPlanPath(String bookshelfItemId) =>
      '/reading/$bookshelfItemId/plan';

  static String goalDetailPath(String readingGoalId) => '/goals/$readingGoalId';

  static String goalEditPath(String readingGoalId) =>
      '/goals/$readingGoalId/edit';
}
