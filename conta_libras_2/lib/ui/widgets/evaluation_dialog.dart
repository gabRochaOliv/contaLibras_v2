import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/services/feedback_service.dart';
import '../../data/managers/user_manager.dart';

class EvaluationDialog extends StatefulWidget {
  const EvaluationDialog({
    super.key,
    this.initialPage = 0,
    this.initialAnswers = const {},
    this.initialOpenAnswers = const {},
    this.initialHasAcceptedTerms = false,
    this.submitHandler,
  });

  final int initialPage;
  final Map<int, int> initialAnswers;
  final Map<String, String> initialOpenAnswers;
  final bool initialHasAcceptedTerms;
  final Future<bool> Function(Map<int, int>, Map<String, String>)? submitHandler;

  @override
  State<EvaluationDialog> createState() => _EvaluationDialogState();
}

class _EvaluationDialogState extends State<EvaluationDialog> {
  late final PageController _pageController;
  late int _currentPage;
  late bool _hasAcceptedTerms;
  late Map<int, int> _answers;
  late Map<String, String> _openAnswers;
  late Map<String, TextEditingController> _openControllers;
  bool _showError = false;
  bool _isSubmitting = false;

  static const List<Map<String, dynamic>> _sections = [
    {
      'title': 'Usabilidade',
      'icon': Icons.tune,
      'questions': [
        {'id': 4, 'text': 'O aplicativo é fácil de usar.'},
        {'id': 5, 'text': 'Navegar pelo aplicativo é simples.'},
        {'id': 6, 'text': 'Eu aprendi a usar o aplicativo rapidamente.'},
        {'id': 7, 'text': 'Eu me senti confiante ao usar o aplicativo.'},
        {'id': 8, 'text': 'Foi difícil usar o aplicativo.'},
      ],
    },
    {
      'title': 'Experiência do Usuário (UX)',
      'icon': Icons.star_outline,
      'questions': [
        {'id': 9,  'text': 'O design do aplicativo é agradável.'},
        {'id': 10, 'text': 'As telas são bem organizadas.'},
        {'id': 11, 'text': 'O aplicativo é claro e fácil de entender.'},
        {'id': 12, 'text': 'O aplicativo responde rapidamente.'},
      ],
    },
    {
      'title': 'Qualidade do Conteúdo',
      'icon': Icons.library_books_outlined,
      'questions': [
        {'id': 13, 'text': 'Os vídeos ajudam na compreensão do conteúdo.'},
        {'id': 14, 'text': 'Os textos são fáceis de entender.'},
        {'id': 15, 'text': 'O conteúdo apresentado é relevante.'},
      ],
    },
    {
      'title': 'Utilidade',
      'icon': Icons.thumb_up_outlined,
      'questions': [
        {'id': 16, 'text': 'O aplicativo é útil para aprendizagem.'},
        {'id': 17, 'text': 'Eu utilizaria o aplicativo novamente.'},
        {'id': 18, 'text': 'Eu recomendaria o aplicativo para outras pessoas.'},
      ],
    },
    {
      'title': 'Satisfação Geral',
      'icon': Icons.assessment_outlined,
      'questions': [
        {'id': 19, 'text': 'Estou satisfeito com o aplicativo.'},
      ],
    },
  ];

  static const Map<String, List<Map<String, dynamic>>> _categoryQuestions = {
    'Professor': [
      {'id': 20, 'text': 'O aplicativo pode ser utilizado como recurso pedagógico.'},
      {'id': 21, 'text': 'O conteúdo é adequado para uso em sala de aula.'},
      {'id': 22, 'text': 'O aplicativo favorece a inclusão de estudantes surdos.'},
      {'id': 23, 'text': 'Eu utilizaria o aplicativo em atividades educacionais.'},
      {'id': 24, 'text': 'O aplicativo possui potencial educacional.'},
    ],
    'Intérprete de Libras': [
      {'id': 25, 'text': 'Os sinais apresentados são adequados.'},
      {'id': 26, 'text': 'A comunicação em Libras é clara.'},
      {'id': 27, 'text': 'Os vídeos apresentam boa qualidade linguística.'},
      {'id': 28, 'text': 'Os conceitos foram representados adequadamente em Libras.'},
    ],
    'Profissional da Contabilidade': [
      {'id': 29, 'text': 'Os conceitos contábeis apresentados estão corretos.'},
      {'id': 30, 'text': 'A terminologia utilizada é adequada.'},
      {'id': 31, 'text': 'O conteúdo possui relevância para a área contábil.'},
      {'id': 32, 'text': 'O aplicativo possui potencial para apoiar o ensino de contabilidade.'},
    ],
  };

  static const List<Map<String, String>> _openQuestions = [
    {'key': 'gostou', 'text': 'O que você mais gostou no aplicativo?'},
    {'key': 'melhorar', 'text': 'O que pode ser melhorado?'},
    {'key': 'sugestao', 'text': 'Gostaria de deixar alguma sugestão adicional?'},
  ];

  bool get _hasCategorySection =>
      _categoryQuestions.containsKey(UserManager().userCategory);

  int get _totalSections =>
      _sections.length + (_hasCategorySection ? 1 : 0) + 1;

  int get _openQuestionsIndex => _totalSections - 1;

  bool _isCategorySectionIndex(int sectionIndex) =>
      _hasCategorySection && sectionIndex == _sections.length;

  List<Map<String, dynamic>> _getQuestionsForSection(int sectionIndex) {
    if (sectionIndex < _sections.length) {
      return List<Map<String, dynamic>>.from(
          _sections[sectionIndex]['questions'] as List);
    }
    if (_isCategorySectionIndex(sectionIndex)) {
      return List<Map<String, dynamic>>.from(
          _categoryQuestions[UserManager().userCategory] ?? []);
    }
    return const [];
  }

  bool _isSectionComplete(int sectionIndex, List<Map<String, dynamic>> questions) {
    if (sectionIndex == _openQuestionsIndex) return true;
    return questions.every((q) => _answers.containsKey(q['id'] as int));
  }

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _hasAcceptedTerms = widget.initialHasAcceptedTerms;
    _answers = Map.from(widget.initialAnswers);
    _openAnswers = Map.from(widget.initialOpenAnswers);
    _openControllers = {
      for (final q in _openQuestions)
        q['key']!: TextEditingController(text: _openAnswers[q['key']] ?? ''),
    };
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _openControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _selectAnswer(int questionId, int value) {
    setState(() {
      _answers[questionId] = value;
    });
  }

  void _updateOpenAnswer(String key, String value) {
    _openAnswers[key] = value;
  }

  void _goBack() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goForward() {
    if (_currentPage < _totalSections - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _showError = false;
    });

    bool success;
    if (widget.submitHandler != null) {
      success = await widget.submitHandler!(_answers, _openAnswers);
    } else {
      await FeedbackService().submit(_answers, openAnswers: _openAnswers);
      success = !FeedbackService().hasError;
    }

    if (!mounted) return;

    if (!success) {
      setState(() {
        _isSubmitting = false;
        _showError = true;
      });
    } else {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
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

  Widget _buildErrorBanner() {
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Não foi possível enviar sua avaliação.',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Verifique sua conexão com a internet e tente novamente.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: Colors.red.shade700),
            ),
            const SizedBox(height: 8),
            Semantics(
              button: true,
              label: 'Tentar novamente enviar a avaliação',
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showError = false;
                  });
                  _submit();
                },
                child: const Text(
                  'Tentar novamente',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionProgress() {
    return Column(
      children: [
        LinearProgressIndicator(
          minHeight: 6,
          value: (_currentPage + 1) / _totalSections,
          backgroundColor: AppColors.divider,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Seção ${_currentPage + 1} de $_totalSections',
            style: AppTextStyles.label,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionPage(int sectionIndex) {
    final isOpenQuestionsPage = sectionIndex == _openQuestionsIndex;
    final questions = _getQuestionsForSection(sectionIndex);
    final isLastSection = sectionIndex == _totalSections - 1;
    final isSectionComplete = _isSectionComplete(sectionIndex, questions);

    String sectionTitle;
    IconData sectionIcon;
    if (sectionIndex < _sections.length) {
      sectionTitle = _sections[sectionIndex]['title'] as String;
      sectionIcon = _sections[sectionIndex]['icon'] as IconData;
    } else if (_isCategorySectionIndex(sectionIndex)) {
      sectionTitle =
          'Perguntas para ${_categoryLabel(UserManager().userCategory)}';
      sectionIcon = Icons.person_outline;
    } else {
      sectionTitle = 'Perguntas Abertas (opcional)';
      sectionIcon = Icons.chat_bubble_outline;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(sectionIcon, size: 20, color: AppColors.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(sectionTitle, style: AppTextStyles.heading3),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: isOpenQuestionsPage
                    ? _openQuestions.map((q) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                q['text']!,
                                style: AppTextStyles.bodyLarge
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _openControllers[q['key']],
                                maxLines: 3,
                                onChanged: (value) =>
                                    _updateOpenAnswer(q['key']!, value),
                                decoration: InputDecoration(
                                  hintText: 'Resposta opcional',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.all(12),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()
                    : questions.map((q) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                q['text'] as String,
                                style: AppTextStyles.bodyLarge
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              _buildLikertScale(q['id'] as int),
                            ],
                          ),
                        );
                      }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_showError && isLastSection) _buildErrorBanner(),
          Row(
            children: [
              if (sectionIndex > 0) ...[
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _goBack,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Voltar'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (isSectionComplete && !_isSubmitting)
                        ? _goForward
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.primary.withOpacity(0.4),
                      disabledForegroundColor:
                          Colors.white.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: (_isSubmitting && isLastSection)
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(isLastSection ? 'Enviar Avaliação' : 'Próximo'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _categoryLabel(String category) {
    const labels = {
      'Professor': 'Professores',
      'Intérprete de Libras': 'Intérpretes de Libras',
      'Profissional da Contabilidade': 'Profissionais da Contabilidade',
    };
    return labels[category] ?? category;
  }

  Widget _buildLikertScale(int questionIndex) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final value = index + 1;
            final isSelected = _answers[questionIndex] == value;
            return Semantics(
              label: 'Opção $value de 5',
              child: GestureDetector(
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
                            ),
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
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Discordo\nTotalmente',
                textAlign: TextAlign.left,
                style: AppTextStyles.label.copyWith(fontSize: 10)),
            Text('Concordo\nTotalmente',
                textAlign: TextAlign.right,
                style: AppTextStyles.label.copyWith(fontSize: 10)),
          ],
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
                  style: AppTextStyles.heading3
                      .copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Pesquisa: Avaliação do Aplicativo ContaLibras'),
                _buildParagraph(
                    'Você está sendo convidado(a) a participar de uma pesquisa acadêmica relacionada ao desenvolvimento e avaliação do aplicativo ContaLibras, realizada no contexto de um TCC do curso de Ciência da Computação.'),
                _buildParagraph(
                    'O objetivo desta pesquisa é avaliar aspectos relacionados à usabilidade, experiência do usuário e utilidade educacional do aplicativo, voltado para termos contábeis em Libras.'),
                _buildSectionTitle('Sobre a participação'),
                _buildParagraph(
                    'Sua participação é voluntária e consiste em responder a um questionário sobre sua experiência (usabilidade, qualidade do conteúdo, etc.). Tempo estimado: 5 a 10 minutos.'),
                _buildSectionTitle('Confidencialidade e privacidade'),
                _buildParagraph(
                    'As informações serão usadas exclusivamente para fins acadêmicos. Nenhuma informação de identidade será divulgada. Os dados coletados serão analisados de forma anônima.'),
                _buildSectionTitle('Riscos e benefícios'),
                _buildParagraph(
                    'A participação não apresenta riscos significativos. Os resultados podem contribuir para melhorias no app e promoção de ferramentas educacionais e acessibilidade.'),
                _buildSectionTitle('Liberdade de participação'),
                _buildParagraph(
                    'Você poderá interromper sua participação a qualquer momento sem necessidade de justificativa.'),
                _buildSectionTitle('Declaração de consentimento'),
                _buildParagraph(
                    'Declaro que li e compreendi as informações apresentadas, tive a oportunidade de esclarecer dúvidas e concordo voluntariamente em participar da pesquisa.'),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Concordo'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold, color: AppColors.primary),
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
        height: _hasAcceptedTerms
            ? MediaQuery.of(context).size.height * 0.85
            : MediaQuery.of(context).size.height * 0.8,
        width: 500,
        constraints:
            BoxConstraints(maxHeight: _hasAcceptedTerms ? 700 : 650),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
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
            if (_hasAcceptedTerms) ...[
              _buildSectionProgress(),
              const SizedBox(height: 8),
            ],
            Expanded(
              child: _hasAcceptedTerms
                  ? PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                          _showError = false;
                        });
                      },
                      itemCount: _totalSections,
                      itemBuilder: (_, i) => _buildSectionPage(i),
                    )
                  : _buildTCLEView(),
            ),
          ],
        ),
      ),
    );
  }
}
