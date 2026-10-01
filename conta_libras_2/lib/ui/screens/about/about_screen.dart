import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/mock/mock_dictionary_repository.dart';
import 'info_page_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  static const String appVersion = '2.0.0';

  @override
  Widget build(BuildContext context) {
    final totalTerms = MockDictionaryRepository.terms.length;

    return InfoPageScaffold(
      title: 'Sobre o App',
      onBack: onBack,
      children: [
        Image.asset('assets/images/logoContaLibras.png', height: 72),
        const SizedBox(height: 8),
        Text(
          'Versão $appVersion',
          style: AppTextStyles.label,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _Section(
          icon: Icons.sign_language_rounded,
          title: 'O que é o ContaLibras',
          children: [
            _Paragraph(
              'O ContaLibras é um dicionário de termos contábeis em '
              'Libras (Língua Brasileira de Sinais). Ele reúne '
              '$totalTerms termos, cada um com o sinal em vídeo, o '
              'conceito em português, exemplos e uma representação '
              'visual.',
            ),
            const _Paragraph(
              'O objetivo é apoiar pessoas surdas, estudantes, '
              'professores, intérpretes e profissionais da contabilidade '
              'no acesso ao vocabulário contábil.',
            ),
          ],
        ),
        const _Section(
          icon: Icons.accessibility_new_rounded,
          title: 'Acessibilidade',
          children: [
            _Paragraph(
              'Os conteúdos são apresentados em Libras e em português. '
              'O app oferece modo escuro (em Perfil) e cores com '
              'contraste adequado para leitura, seguindo as diretrizes '
              'de acessibilidade WCAG 2.1 (nível AA).',
            ),
          ],
        ),
        const _Section(
          icon: Icons.lock_outline_rounded,
          title: 'Privacidade',
          children: [
            _Paragraph(
              'Seu perfil, seus favoritos e seu progresso ficam salvos '
              'neste dispositivo.',
            ),
            _Paragraph(
              'Os dados do cadastro e as respostas da avaliação são '
              'enviados ao servidor da pesquisa, usados exclusivamente '
              'para fins acadêmicos e analisados de forma anônima. '
              'Nenhuma informação que identifique você será divulgada.',
            ),
          ],
        ),
        const _Section(
          icon: Icons.school_outlined,
          title: 'Projeto acadêmico',
          children: [
            _Paragraph(
              'Desenvolvido por Gabriel Rocha Oliveira como Trabalho de '
              'Conclusão de Curso (TCC) em Ciência da Computação na '
              'Universidade Estadual do Norte do Paraná (UENP), Campus Luiz '
              'Meneghel. O projeto foi iniciado em 2024.',
            ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryFg, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: AppTextStyles.heading3
                        .copyWith(color: AppColors.primaryFg),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }
}
