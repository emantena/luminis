import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/session_controller.dart';
import '../../features/auth/presentation/controllers/session_state.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/books/presentation/screens/book_detail_screen.dart';
import '../../features/books/presentation/screens/book_draft_new_screen.dart';
import '../../features/bookshelf/presentation/screens/bookshelf_screen.dart';
import '../../features/goals/presentation/screens/goal_detail_screen.dart';
import '../../features/goals/presentation/screens/goal_edit_screen.dart';
import '../../features/goals/presentation/screens/goal_new_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/profile/presentation/screens/profile_edit_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/reading/presentation/screens/reading_plan_screen.dart';
import '../../features/reading/presentation/screens/reading_progress_new_screen.dart';
import '../../features/reading/presentation/screens/reading_screen.dart';
import '../../features/reading/presentation/screens/reading_state_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import 'app_route_error_screen.dart';
import 'app_route_names.dart';
import 'app_route_paths.dart';
import 'app_route_refresh_listenable.dart';
import 'app_shell.dart';

/// [GlobalKey] do Navigator raiz do app.
///
/// Usado por rotas que precisam abrir fora do Navigator de uma branch do
/// shell autenticado (ex.: `bookDraftNew`, fluxo global de cadastro
/// local), via `parentNavigatorKey`.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');

/// Provider `keepAlive` (padrão de `Provider`) do `GoRouter` do app.
///
/// Criado uma única vez: `refreshListenable` é a ponte
/// [GoRouterRefreshListenable], que notifica o `go_router` para reavaliar
/// `redirect` quando `sessionControllerProvider` muda entre autenticado e
/// não autenticado. O `redirect` em si só lê o estado já carregado via
/// `ref.read` — nunca chama repository/API (ver
/// `.claude/skills/luminis-go-router-agent/SKILL.md`).
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(goRouterRefreshListenableProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutePaths.authWelcome,
    refreshListenable: refreshListenable,
    redirect: (context, state) => _resolveAuthRedirect(ref, state),
    errorBuilder: (context, state) => AppRouteErrorScreen(error: state.error),
    routes: [
      GoRoute(
        path: AppRoutePaths.authWelcome,
        name: AppRouteNames.authWelcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.authLogin,
        name: AppRouteNames.authLogin,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.authRegister,
        name: AppRouteNames.authRegister,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.authForgotPassword,
        name: AppRouteNames.authForgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.authResetPassword,
        name: AppRouteNames.authResetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      GoRoute(
        path: AppRoutePaths.bookDraftNew,
        name: AppRouteNames.bookDraftNew,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const BookDraftNewScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // Estante
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.bookshelf,
                name: AppRouteNames.bookshelf,
                builder: (context, state) => const BookshelfScreen(),
              ),
            ],
          ),

          // Buscar (+ detalhe do livro empilhado)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.search,
                name: AppRouteNames.search,
                builder: (context, state) => const SearchScreen(),
              ),
              // Path absoluto `/books/:bookId`, não um sub-path de
              // `/search`: declarado como rota irmã dentro da mesma
              // branch para empilhar sobre o Navigator de Buscar
              // (decisão mínima deste agente — `docs/architecture/
              // navigation.md` só definia "branch de origem quando
              // fizer sentido"; Buscar é a única entrada do primeiro
              // ciclo, ver `docs/ux/flutter-prototype-handoff.md`).
              GoRoute(
                path: AppRoutePaths.bookDetail,
                name: AppRouteNames.bookDetail,
                builder: (context, state) =>
                    BookDetailScreen(bookId: state.pathParameters['bookId']!),
              ),
            ],
          ),

          // Leitura (+ estado, progresso e plano empilhados)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.reading,
                name: AppRouteNames.reading,
                builder: (context, state) => const ReadingScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutePaths.readingStateSegment,
                    name: AppRouteNames.readingState,
                    builder: (context, state) => ReadingStateScreen(
                      bookshelfItemId: state.pathParameters['bookshelfItemId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: AppRoutePaths.readingProgressNewSegment,
                        name: AppRouteNames.readingProgressNew,
                        builder: (context, state) => ReadingProgressNewScreen(
                          bookshelfItemId:
                              state.pathParameters['bookshelfItemId']!,
                        ),
                      ),
                      GoRoute(
                        path: AppRoutePaths.readingPlanSegment,
                        name: AppRouteNames.readingPlan,
                        builder: (context, state) => ReadingPlanScreen(
                          bookshelfItemId:
                              state.pathParameters['bookshelfItemId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Metas (+ criar, detalhe e editar empilhados)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.goals,
                name: AppRouteNames.goals,
                builder: (context, state) => const GoalsScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutePaths.goalNewSegment,
                    name: AppRouteNames.goalNew,
                    builder: (context, state) => const GoalNewScreen(),
                  ),
                  GoRoute(
                    path: AppRoutePaths.goalDetailSegment,
                    name: AppRouteNames.goalDetail,
                    builder: (context, state) => GoalDetailScreen(
                      readingGoalId: state.pathParameters['readingGoalId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: AppRoutePaths.goalEditSegment,
                        name: AppRouteNames.goalEdit,
                        builder: (context, state) => GoalEditScreen(
                          readingGoalId: state.pathParameters['readingGoalId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Perfil (+ editar empilhado)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.profile,
                name: AppRouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutePaths.profileEditSegment,
                    name: AppRouteNames.profileEdit,
                    builder: (context, state) => const ProfileEditScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Guard de autenticação top-level.
///
/// Regras (ver `docs/architecture/navigation.md` e
/// `.claude/skills/luminis-go-router-agent/references/go-router-17.md`):
/// - não autenticado tentando acessar rota protegida -> `authWelcome`;
/// - autenticado tentando acessar rota pública de auth -> `bookshelf`;
/// - caso contrário, `null` (navegação permitida sem redirect).
///
/// Só lê estado já carregado via `ref.read` — nunca chama repository/API
/// aqui. Apenas [SessionAuthenticated] conta como autenticado;
/// `SessionUnauthenticated`, `SessionAuthenticating` e `SessionError`
/// contam como não autenticado para efeito deste guard.
String? _resolveAuthRedirect(Ref ref, GoRouterState state) {
  final isAuthenticated =
      ref.read(sessionControllerProvider) is SessionAuthenticated;
  final isAuthRoute = state.uri.path.startsWith('/auth');

  if (!isAuthenticated && !isAuthRoute) {
    return state.namedLocation(AppRouteNames.authWelcome);
  }

  if (isAuthenticated && isAuthRoute) {
    return state.namedLocation(AppRouteNames.bookshelf);
  }

  return null;
}
