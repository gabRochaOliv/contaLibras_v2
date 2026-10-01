import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'info_page_scaffold.dart';

/// Um passo do guia de uso exibido na tela "Como usar".
class HowToUseStep {
  const HowToUseStep({
    required this.icon,
    required this.title,
    required this.text,
    this.items = const [],
  });

  final IconData icon;
  final String title;
  final String text;

  /// Partes destacadas do passo (ex.: as abas de um termo).
  final List<HowToUseItem> items;
}

class HowToUseItem {
  const HowToUseItem({
    required this.icon,
    required this.label,
    required this.text,
  });

  final IconData icon;
  final String label;
  final String text;
}

const List<HowToUseStep> howToUseSteps = [
  HowToUseStep(
    icon: Icons.home_rounded,
    title: 'Início',
    text: 'Veja o Termo do Dia e acompanhe, na barra "Termos Explorados", '
        'quantos termos você já abriu.',
  ),
  HowToUseStep(
    icon: Icons.book_rounded,
    title: 'Dicionário',
    text: 'Busque por nome do termo ou categoria e toque em um termo para '
        'abri-lo. Os termos que você já visitou ganham um selo amarelo.',
  ),
  HowToUseStep(
    icon: Icons.menu_book_rounded,
    title: 'Dentro de um termo',
    text: 'Cada termo é dividido em três abas:',
    // Mesmos ícones das abas da tela do termo, para o usuário reconhecê-las.
    items: [
      HowToUseItem(
        icon: Icons.play_circle_fill_rounded,
        label: 'Vídeo',
        text: 'o sinal em Libras. Toque no vídeo para pausar ou use a tela '
            'cheia.',
      ),
      HowToUseItem(
        icon: Icons.description_rounded,
        label: 'Conteúdo',
        text: 'categoria, conceito, exemplos, observações e termos '
            'relacionados.',
      ),
      HowToUseItem(
        icon: Icons.animation_rounded,
        label: 'Visual',
        text: 'o sinal ilustrado e uma representação visual do conceito.',
      ),
    ],
  ),
  HowToUseStep(
    icon: Icons.bookmark_rounded,
    title: 'Favoritos',
    text: 'Toque no marcador no topo de um termo para salvá-lo. Os termos '
        'salvos ficam na aba Favoritos.',
  ),
  HowToUseStep(
    icon: Icons.person_rounded,
    title: 'Perfil',
    text: 'Ative o modo escuro, consulte informações sobre o app ou troque '
        'de perfil.',
  ),
  HowToUseStep(
    icon: Icons.star_rounded,
    title: 'Avalie o app',
    text: 'Na tela Início, responda ao questionário de avaliação. Leva de 2 '
        'a 3 minutos e ajuda a melhorar o ContaLibras.',
  ),
];

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return InfoPageScaffold(
      title: 'Como usar',
      onBack: onBack,
      showFooter: false,
      children: [
        Text(
          'Um guia rápido das funções do ContaLibras.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < howToUseSteps.length; i++)
          _NumberedStep(number: i + 1, step: howToUseSteps[i]),
      ],
    );
  }
}

class _NumberedStep extends StatelessWidget {
  const _NumberedStep({required this.number, required this.step});

  final int number;
  final HowToUseStep step;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.action,
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(step.icon, size: 20, color: AppColors.secondaryFg),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        step.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primaryFg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  step.text,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                if (step.items.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _HowToUseItemList(items: step.items),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista das partes destacadas de um passo: cada item num bloco com ícone e
/// nome em destaque, para ficarem fáceis de identificar.
class _HowToUseItemList extends StatelessWidget {
  const _HowToUseItemList({required this.items});

  final List<HowToUseItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.secondaryFg.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border(
                left: BorderSide(color: AppColors.secondaryFg, width: 3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.icon, size: 20, color: AppColors.secondaryFg),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${item.label}: ',
                          style: TextStyle(
                            color: AppColors.primaryFg,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: item.text),
                      ],
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
