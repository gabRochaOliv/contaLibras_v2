import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class EvaluationDialog extends StatefulWidget {
  const EvaluationDialog({super.key});

  @override
  State<EvaluationDialog> createState() => _EvaluationDialogState();
}

class _EvaluationDialogState extends State<EvaluationDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _hasAcceptedTerms = false;
  
  // Respostas salvas: índice da pergunta -> valor (1 a 5)
  final Map<int, int> _answers = {};

  final List<String> _questions = [
    '1. Avalie a facilidade de uso do aplicativo:',
    '2. O quão útil você achou o conteúdo em Libras?',
    '3. Como você avalia o design e visual do app?',
  ];

  void _nextPage() {
    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Finalizou
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Obrigado pela sua avaliação e contribuição à pesquisa!',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _selectAnswer(int questionIndex, int value) {
    setState(() {
      _answers[questionIndex] = value;
    });
    // Autonext
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _nextPage();
    });
  }

  Widget _buildLikertScale(int questionIndex) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            int value = index + 1;
            bool isSelected = _answers[questionIndex] == value;
            return GestureDetector(
              onTap: () => _selectAnswer(questionIndex, value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Discordo\nTotalmente', textAlign: TextAlign.left, style: AppTextStyles.label.copyWith(fontSize: 10)),
            Text('Concordo\nTotalmente', textAlign: TextAlign.right, style: AppTextStyles.label.copyWith(fontSize: 10)),
          ],
        )
      ],
    );
  }

  Widget _buildQuestionsView() {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _questions[index],
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _buildLikertScale(index),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: List.generate(
             _questions.length,
             (index) => Container(
               margin: const EdgeInsets.symmetric(horizontal: 4),
               width: 8,
               height: 8,
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 color: _currentPage == index ? AppColors.primary : AppColors.divider,
               ),
             ),
           ),
        ),
      ],
    );
  }

  Widget _buildTCLEView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TERMO DE CONSENTIMENTO LIVRE E ESCLARECIDO',
                  style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Pesquisa: Avaliação do Aplicativo ContaLibras'),
                _buildParagraph('Você está sendo convidado(a) a participar de uma pesquisa acadêmica relacionada ao desenvolvimento e avaliação do aplicativo ContaLibras, realizada no contexto de um TCC do curso de Ciência da Computação.'),
                _buildParagraph('O objetivo desta pesquisa é avaliar aspectos relacionados à usabilidade, experiência do usuário e utilidade educacional do aplicativo, voltado para termos contábeis em Libras.'),
                
                _buildSectionTitle('Sobre a participação'),
                _buildParagraph('Sua participação é voluntária e consiste em responder a um questionário sobre sua experiência (usabilidade, qualidade do conteúdo, etc.). Tempo estimado: 5 a 10 minutos.'),
                
                _buildSectionTitle('Confidencialidade e privacidade'),
                _buildParagraph('As informações serão usadas exclusivamente para fins acadêmicos. Nenhuma informação de identidade será divulgada. Os dados coletados serão analisados de forma anônima.'),
                
                _buildSectionTitle('Riscos e benefícios'),
                _buildParagraph('A participação não apresenta riscos significativos. Os resultados podem contribuir para melhorias no app e promoção de ferramentas educacionais e acessibilidade.'),
                
                _buildSectionTitle('Liberdade de participação'),
                _buildParagraph('Você poderá interromper sua participação a qualquer momento sem necessidade de justificativa.'),
                
                _buildSectionTitle('Declaração de consentimento'),
                _buildParagraph('Declaro que li e compreendi as informações apresentadas, tive a oportunidade de esclarecer dúvidas e concordo voluntariamente em participar da pesquisa.'),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        const Divider(),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade400,
                  side: BorderSide(color: Colors.red.shade200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Não Concordo'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasAcceptedTerms = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Concordo'),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium,
        textAlign: TextAlign.justify,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        // The dialog dynamically adjusts height up to a max of 600 or 80% of screen height
        height: _hasAcceptedTerms ? 380 : MediaQuery.of(context).size.height * 0.8,
        width: 500,
        constraints: const BoxConstraints(maxHeight: 650),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _hasAcceptedTerms ? 'Avaliação' : '',
                    style: AppTextStyles.heading2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _hasAcceptedTerms ? _buildQuestionsView() : _buildTCLEView(),
            ),
          ],
        ),
      ),
    );
  }
}
