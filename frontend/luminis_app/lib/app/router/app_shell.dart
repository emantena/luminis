import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Scaffold do shell autenticado: navigation bar fixa com as 5 abas do
/// MVP (Estante, Buscar, Leitura, Metas, Perfil) sobre o
/// `StatefulNavigationShell` do `go_router`.
///
/// Cada aba mantém sua própria pilha de navegação
/// (`StatefulShellRoute.indexedStack`, ver `app_router.dart`); trocar de
/// aba preserva o estado/pilha da aba anterior.
///
/// Estilo (cores, ícones ativos/inativos) vem do `navigationBarTheme`
/// de `LuminisTheme`; este widget só decide estrutura de navegação.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Tocar novamente na aba já ativa volta para a raiz dela.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'Estante',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Leitura',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Metas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
