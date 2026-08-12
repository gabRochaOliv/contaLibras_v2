import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../dictionary/dictionary_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';
import '../dictionary/term_detail_screen.dart';
import '../../../data/managers/user_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/term_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String _userName = 'Estudante';
  TermModel? _selectedTerm;

  void _onTermSelected(TermModel term) {
    setState(() {
      _selectedTerm = term;
    });
  }

  void _clearSelectedTerm() {
    setState(() {
      _selectedTerm = null;
    });
  }

  List<Widget> get _screens => [
    HomeScreen(userName: _userName, onTermSelected: _onTermSelected),
    DictionaryScreen(onTermSelected: _onTermSelected),
    FavoritesScreen(onTermSelected: _onTermSelected),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _userName = UserManager().userName;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Scaffold(
            body: Row(
              children: [
                // Barra Lateral (Sidebar) no Desktop
                Container(
                  width: 210,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      right: BorderSide(
                        color: AppColors.divider,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo no topo da barra lateral (maior)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 28.0),
                        child: Image.asset(
                          'assets/images/logoContaLibras.png',
                          height: 70,
                          fit: BoxFit.contain,
                        ),
                      ),
                      
                      // Botão de Voltar se houver termo selecionado
                      if (_selectedTerm != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
                          child: InkWell(
                            onTap: _clearSelectedTerm,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.primary.withOpacity(0.05),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_back_rounded, color: AppColors.primary, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Voltar',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 12),

                      // Itens de Navegação Empilhados
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildDesktopNavItem(0, 'Início', Icons.home_rounded),
                              const SizedBox(height: 8),
                              _buildDesktopNavItem(1, 'Dicionário', Icons.book_rounded),
                              const SizedBox(height: 8),
                              _buildDesktopNavItem(2, 'Favoritos', Icons.bookmark_rounded),
                              const SizedBox(height: 8),
                              _buildDesktopNavItem(3, 'Perfil', Icons.person_rounded),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Área de Conteúdo à Direita
                Expanded(
                  child: Container(
                    color: AppColors.background,
                    child: Stack(
                      children: [
                        // Sempre montado: preserva o estado (e a posição de
                        // rolagem) das telas internas ao alternar com o
                        // detalhe do termo.
                        IndexedStack(
                          key: const ValueKey('main_stack'),
                          index: _currentIndex,
                          children: _screens,
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _selectedTerm != null
                              ? TermDetailScreen(
                                  key: ValueKey(_selectedTerm!.id),
                                  term: _selectedTerm!,
                                )
                              : const SizedBox.shrink(key: ValueKey('empty')),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile: navegação mantendo o BottomNavigationBar visível
        return Scaffold(
          body: Stack(
            children: [
              // Sempre montado: preserva o estado (e a posição de rolagem)
              // das telas internas ao alternar com o detalhe do termo.
              IndexedStack(
                key: const ValueKey('main_stack'),
                index: _currentIndex,
                children: _screens,
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _selectedTerm != null
                    ? TermDetailScreen(
                        key: ValueKey(_selectedTerm!.id),
                        term: _selectedTerm!,
                        onBackPressed: _clearSelectedTerm,
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) => setState(() {
              _currentIndex = index;
              _selectedTerm = null;
            }),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Início',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book_rounded),
                label: 'Dicionário',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_rounded),
                label: 'Favoritos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopNavItem(int index, String title, IconData icon) {
    final isSelected = _currentIndex == index && _selectedTerm == null;
    return InkWell(
      onTap: () => setState(() {
        _currentIndex = index;
        _selectedTerm = null;
      }),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
