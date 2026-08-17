import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Scaffold do shell autenticado: bottom navigation fixa com as 5 abas do
/// MVP (Estante, Buscar, Leitura, Metas, Perfil) sobre o
/// `StatefulNavigationShell` do `go_router`.
///
/// Cada aba mantém sua própria pilha de navegação
/// (`StatefulShellRoute.indexedStack`, ver `app_router.dart`); trocar de
/// aba preserva o estado/pilha da aba anterior.
///
/// Estilo (cores, ícones ativos/inativos) vem do `bottomNavigationBarTheme`
/// de `LuminisTheme`; este widget só decide estrutura de navegação.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          // Tocar novamente na aba já ativa volta para a raiz dela.
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: 'Estante',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Leitura',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            activeIcon: Icon(Icons.flag),
            label: 'Metas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
