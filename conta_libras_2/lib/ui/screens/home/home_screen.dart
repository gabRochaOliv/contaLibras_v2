import 'package:flutter/material.dart';
import '../../widgets/developer_footer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../dictionary/term_detail_screen.dart';
import '../../../data/mock/mock_dictionary_repository.dart';
import '../../../data/managers/progress_manager.dart';
import '../../../data/managers/user_manager.dart';
import '../../../data/managers/theme_manager.dart';
import '../../widgets/evaluation_dialog.dart';
import '../../widgets/looping_asset_video.dart';
import '../about/how_to_use_screen.dart';

import '../../../data/models/term_model.dart';

class HomeScreen extends StatelessWidget {
  final String userName;
  final void Function(TermModel)? onTermSelected;

  /// Abre o guia "Como usar" dentro da MainScreen (mantendo a navegação).
  /// Sem ele, o guia é empilhado no Navigator.
  final VoidCallback? onOpenHowToUse;

  /// Controla a rolagem da tela, permitindo que a MainScreen a leve de volta
  /// ao topo sempre que a Início reaparece.
  final ScrollController? scrollController;

  const HomeScreen({
    super.key,
    this.userName = 'Estudante',
    this.onTermSelected,
    this.onOpenHowToUse,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final daysSinceEpoch =
        DateTime.now().difference(DateTime(1970, 1, 1)).inDays;
    // O Termo do Dia só sorteia entre termos que têm vídeo em Libras.
    final termosComVideo = MockDictionaryRepository.terms
        .where((t) => t.videoUrl.isNotEmpty)
        .toList();
    final candidatos = termosComVideo.isNotEmpty
        ? termosComVideo
        : MockDictionaryRepository.terms;
    final termoDoDia = candidatos[daysSinceEpoch % candidatos.length];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        final isNarrow = constraints.maxWidth < 380;
        final greetingVideoSize = isNarrow ? 90.0 : 140.0;

        return Scaffold(
          appBar: isDesktop
              ? null
              : AppBar(
                  toolbarHeight: 80,
                  title: Image.asset('assets/images/logoContaLibras.png',
                      height: 60),
                  centerTitle: true,
                  elevation: 0,
                ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        LoopingAssetVideo(
                          assetPath: 'assets/images/acenandoVideo.mp4',
                          size: greetingVideoSize,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedBuilder(
                                animation: UserManager(),
                                builder: (context, child) {
                                  return Text(
                                    'Olá, ${UserManager().userName}!',
                                    style: AppTextStyles.heading1,
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Explore os termos contábeis em Libras.',
                                style: AppTextStyles.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildQuickActions(context,
                        isWide: constraints.maxWidth >= 600),
                    const SizedBox(height: 24),
                    AnimatedBuilder(
                      animation: ProgressManager(),
                      builder: (context, child) {
                        final manager = ProgressManager();
                        final progress = manager.progressRatio;

                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Termos Explorados',
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.heading3
                                          .copyWith(color: AppColors.primaryFg),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.emoji_events_rounded,
                                      color: AppColors.highlight, size: 28),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 10,
                                  backgroundColor: AppColors.divider,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.secondaryFg),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${(progress * 100).toStringAsFixed(0)}% concluído',
                                  style: AppTextStyles.label.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () {
                        if (onTermSelected != null) {
                          onTermSelected!(termoDoDia);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TermDetailScreen(term: termoDoDia),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          // No escuro o navy se confunde com o fundo; a borda
                          // delimita o card clicável (WCAG 1.4.11, >= 3:1).
                          border: ThemeManager().isDarkMode
                              ? Border.all(color: AppColors.action, width: 1.5)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Termo do Dia',
                                    style: AppTextStyles.label.copyWith(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    termoDoDia.title,
                                    style: AppTextStyles.heading3
                                        .copyWith(color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    termoDoDia.concept,
                                    style: AppTextStyles.label.copyWith(
                                        color: Colors.white.withOpacity(0.9)),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Mesmo ícone dos termos no Dicionário.
                            const Icon(
                              Icons.menu_book_rounded,
                              color: AppColors.accent,
                              size: 40,
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white.withOpacity(0.5),
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(child: DeveloperFooter()),
                  ],
                ),
              ),
            ),
          ),
        );
      }, // fim builder
    ); // fim LayoutBuilder
  }

  Widget _buildQuickActions(BuildContext context, {required bool isWide}) {
    final howToUse = _ActionCard(
      icon: Icons.help_outline_rounded,
      iconColor: AppColors.secondaryFg,
      title: 'Como usar',
      subtitle: 'Veja um guia rápido das funções.',
      onTap: () {
        if (onOpenHowToUse != null) {
          onOpenHowToUse!();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HowToUseScreen()),
          );
        }
      },
    );
    final evaluate = _ActionCard(
      icon: Icons.star_rounded,
      iconColor: AppColors.highlight,
      title: 'Avalie o app',
      subtitle: 'Sua opinião nos ajuda a melhorar!',
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const EvaluationDialog(),
        );
      },
    );

    if (isWide) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: howToUse),
            const SizedBox(width: 12),
            Expanded(child: evaluate),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [howToUse, const SizedBox(height: 12), evaluate],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.label),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textSecondary,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
