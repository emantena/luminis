/// Nomes estáveis das rotas do Luminis.
///
/// Usar sempre `context.goNamed`/`context.pushNamed` com estas constantes;
/// nunca espalhar paths literais dentro de widgets. Ver
/// [AppRoutePaths] para os paths correspondentes e
/// `docs/architecture/navigation.md` para o mapa de navegação aprovado.
abstract final class AppRouteNames {
  const AppRouteNames._();

  static const String authWelcome = 'authWelcome';
  static const String authLogin = 'authLogin';
  static const String authRegister = 'authRegister';
  static const String authForgotPassword = 'authForgotPassword';
  static const String authResetPassword = 'authResetPassword';

  static const String bookshelf = 'bookshelf';
  static const String search = 'search';
  static const String reading = 'reading';
  static const String goals = 'goals';
  static const String profile = 'profile';

  static const String bookDetail = 'bookDetail';
  static const String bookDraftNew = 'bookDraftNew';
  static const String readingState = 'readingState';
  static const String readingProgressNew = 'readingProgressNew';
  static const String readingPlan = 'readingPlan';
  static const String goalNew = 'goalNew';
  static const String goalDetail = 'goalDetail';
  static const String goalEdit = 'goalEdit';
  static const String profileEdit = 'profileEdit';
}
