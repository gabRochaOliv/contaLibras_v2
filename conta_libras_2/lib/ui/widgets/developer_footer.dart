import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Crédito discreto exibido no fim das telas com rolagem.
///
/// Fica "apagado" pelo tamanho pequeno e pela cor secundária, em vez de
/// opacidade, para continuar legível (contraste >= 4.5:1 nos dois temas).
class DeveloperFooter extends StatelessWidget {
  const DeveloperFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        'Desenvolvido por Gabriel Rocha',
        textAlign: TextAlign.center,
        style: AppTextStyles.label.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
