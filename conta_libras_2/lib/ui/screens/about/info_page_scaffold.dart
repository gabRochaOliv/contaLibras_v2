import 'package:flutter/material.dart';
import '../../widgets/developer_footer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Estrutura comum das páginas informativas ("Sobre o App", "Como usar").
///
/// Quando [onBack] é informado a página está aberta dentro da MainScreen
/// (mantendo sidebar/barra inferior) e o botão voltar apenas a fecha; sem
/// ele, a página foi empilhada no Navigator e o voltar faz `pop`.
class InfoPageScaffold extends StatelessWidget {
  const InfoPageScaffold({
    super.key,
    required this.title,
    required this.children,
    this.onBack,
    this.showFooter = true,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback? onBack;

  /// Exibe o crédito "Desenvolvido por" no fim da página.
  final bool showFooter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: Text(title, style: AppTextStyles.heading3),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.primaryFg),
          tooltip: 'Voltar',
          onPressed: onBack ?? () => Navigator.of(context).pop(),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [...children, if (showFooter) const DeveloperFooter()],
          ),
        ),
      ),
    );
  }
}
