import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../dictionary/dictionary_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';
import '../dictionary/term_detail_screen.dart';
import '../about/about_screen.dart';
import '../about/how_to_use_screen.dart';
import '../../../data/managers/user_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/term_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

/// Páginas informativas abertas dentro da MainScreen, mantendo a sidebar
/// (desktop) e a barra inferior (mobile) visíveis.
enum _InfoPage { about, howToUse }

class _MainScreenState extends State<MainScreen> {
  static const int _dictionaryTabIndex = 1;

  int _currentIndex = 0;
  String _userName = 'Estudante';
  TermModel? _selectedTerm;
  _InfoPage? _infoPage;
  final Set<String> _recentlyViewedTermIds = {};

  // A Início sempre reaparece no topo; as outras abas preservam a rolagem.
  final ScrollController _homeScrollController = ScrollController();

  void _resetHomeScroll() {
    if (_homeScrollController.hasClients) _homeScrollController.jumpTo(0);
  }

  void _onTermSelected(TermModel term) {
    setState(() {
      _selectedTerm = term;
      _infoPage = null;
      _recentlyViewedTermIds.add(term.id);
    });
  }

  void _clearSelectedTerm() {
    if (_currentIndex == 0) _resetHomeScroll();
    setState(() {
      _selectedTerm = null;
    });
  }

  void _openInfoPage(_InfoPage page) {
    setState(() {
      _infoPage = page;
      _selectedTerm = null;
    });
  }

  void _closeInfoPage() {
    if (_currentIndex == 0) _resetHomeScroll();
    setState(() {
      _infoPage = null;
    });
  }

  void _changeTab(int index) {
    if (index == 0) _resetHomeScroll();
    setState(() {
      _currentIndex = index;
      _selectedTerm = null;
      _infoPage = null;
      // Sair do Dicionário pra outra aba reseta o destaque de "recém-visto".
      if (index != _dictionaryTabIndex) {
        _recentlyViewedTermIds.clear();
      }
    });
  }

  List<Widget> get _screens => [
        HomeScreen(
          scrollController: _homeScrollController,
          userName: _userName,
          onTermSelected: _onTermSelected,
          onOpenHowToUse: () => _openInfoPage(_InfoPage.howToUse),
        ),
        DictionaryScreen(
          onTermSelected: _onTermSelected,
          recentlyViewedTermIds: _recentlyViewedTermIds,
        ),
        FavoritesScreen(onTermSelected: _onTermSelected),
        ProfileScreen(onOpenAbout: () => _openInfoPage(_InfoPage.about)),
      ];

  Widget _buildInfoPageLayer() {
    switch (_infoPage) {
      case _InfoPage.about:
        return AboutScreen(
          key: const ValueKey('about'),
          onBack: _closeInfoPage,
        );
      case _InfoPage.howToUse:
        return HowToUseScreen(
          key: const ValueKey('how_to_use'),
          onBack: _closeInfoPage,
        );
      case null:
        return const SizedBox.shrink(key: ValueKey('no_info_page'));
    }
  }

  @override
  void initState() {
    super.initState();
    _userName = UserManager().userName;
  }

  @override
  void dispose() {
    _homeScrollController.dispose();
    super.dispose();
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 28.0),
                        child: Image.asset(
                          'assets/images/logoContaLibras.png',
                          height: 70,
                          fit: BoxFit.contain,
                        ),
                      ),

                      // Botão de Voltar se houver termo selecionado
                      if (_selectedTerm != null)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 20.0),
                          child: InkWell(
                            onTap: _clearSelectedTerm,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                        AppColors.primaryFg.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.primaryFg.withOpacity(0.08),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_back_rounded,
                                      color: AppColors.primaryFg, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Voltar',
                                    style: TextStyle(
                                      color: AppColors.primaryFg,
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
                              _buildDesktopNavItem(
                                  0, 'Início', Icons.home_rounded),
                              const SizedBox(height: 8),
                              _buildDesktopNavItem(
                                  1, 'Dicionário', Icons.book_rounded),
                              const SizedBox(height: 8),
                              _buildDesktopNavItem(
                                  2, 'Favoritos', Icons.bookmark_rounded),
                              const SizedBox(height: 8),
                              _buildDesktopNavItem(
                                  3, 'Perfil', Icons.person_rounded),
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
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _buildInfoPageLayer(),
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildInfoPageLayer(),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: _changeTab,
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
      onTap: () => _changeTab(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.primaryFg.withOpacity(0.12)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryFg : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            // Expanded + ellipsis: não estoura a sidebar quando o usuário
            // aumenta o tamanho da fonte do sistema.
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primaryFg
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
