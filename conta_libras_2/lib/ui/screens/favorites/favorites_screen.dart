import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/managers/favorites_manager.dart';
import '../../widgets/term_card.dart';
import '../dictionary/term_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Image.asset('assets/images/logoContaLibras.png', height: 60),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: AnimatedBuilder(
            animation: FavoritesManager(),
            builder: (context, child) {
              final favorites = FavoritesManager().favorites;

              if (favorites.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border_rounded, size: 80, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum favorito ainda',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Os termos que você salvar aparecerão aqui.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 16, top: 8),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final term = favorites[index];
                  return TermCard(
                    term: term,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TermDetailScreen(term: term),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
