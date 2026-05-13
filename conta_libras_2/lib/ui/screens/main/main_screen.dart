import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../dictionary/dictionary_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';
import '../dictionary/term_detail_screen.dart';
import '../../widgets/first_access_dialog.dart';
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
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        builder: (context) => const FirstAccessDialog(),
      );
      if (result != null && result.isNotEmpty && mounted) {
        setState(() {
          _userName = result;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Scaffold(
            body: Column(
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Logo fixo à esquerda
                      Positioned(
                        left: 24,
                        child: Image.asset(
                          'assets/images/logoContaLibras.png',
                          height: 60,
                        ),
                      ),
                      // Itens de navegação centralizados
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_selectedTerm != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_rounded),
                                color: AppColors.primary,
                                tooltip: 'Voltar',
                                onPressed: _clearSelectedTerm,
                              ),
                            ),
                          _buildDesktopNavItem(0, 'Início', Icons.home_rounded),
                          const SizedBox(width: 16),
                          _buildDesktopNavItem(1, 'Dicionário', Icons.book_rounded),
                          const SizedBox(width: 16),
                          _buildDesktopNavItem(2, 'Favoritos', Icons.bookmark_rounded),
                          const SizedBox(width: 16),
                          _buildDesktopNavItem(3, 'Perfil', Icons.person_rounded),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _selectedTerm != null
                        ? TermDetailScreen(
                            key: ValueKey(_selectedTerm!.id),
                            term: _selectedTerm!,
                          )
                        : IndexedStack(
                            key: const ValueKey('main_stack'),
                            index: _currentIndex,
                            children: _screens,
                          ),
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile: navegação normal com Navigator.push
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
