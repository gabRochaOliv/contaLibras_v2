import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/services/feedback_service.dart';
import '../../data/managers/user_manager.dart';
import 'evaluation_success_dialog.dart';

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
  final Future<bool> Function(Map<int, int>, Map<String, String>)?
      submitHandler;

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

  // Chaves usadas para rolar até a próxima pergunta (ou até os botões de
  // navegação) depois que o usuário escolhe uma nota.
  final Map<int, GlobalKey> _questionKeys = {};
  final Map<int, GlobalKey> _navKeys = {};

  GlobalKey _questionKey(int id) =>
      _questionKeys.putIfAbsent(id, GlobalKey.new);
  GlobalKey _navKey(int section) =>
      _navKeys.putIfAbsent(section, GlobalKey.new);

  // Critérios avaliativos de IHC e Engenharia de Software definidos pelo
  // orientador. IDs 40-47 substituem as perguntas antigas (4-19) para que
  // respostas coletadas com o questionário anterior não se misturem.
  static const List<Map<String, dynamic>> _sections = [
    {
      'title': 'Usabilidade, IHC & Acessibilidade em Libras',
      'icon': Icons.accessibility_new,
      'questions': [
        // Clareza e Comunicação
        {
          'id': 40,
          'text':
              'Os conteúdos em Libras/Português, ícones e traduções são claros e compreensíveis?'
        },
        // Fluidez de Navegação
        {
          'id': 41,
          'text':
              'A transição entre os módulos e telas ocorre de forma simples e intuitiva?'
        },
        // Design Visual e Consistência
        {
          'id': 42,
          'text':
              'Cores, contraste, fontes e elementos visuais facilitam a leitura e a interação?'
        },
        // Prevenção de Erros
        {
          'id': 43,
          'text':
              'A interface minimiza ações acidentais e oferece instruções orientadoras?'
        },
      ],
    },
    {
      'title': 'Qualidade Técnica & Engenharia de Software',
      'icon': Icons.settings_outlined,
      'questions': [
        // Completude Funcional
        {
          'id': 44,
          'text':
              'As ferramentas necessárias para a rotina financeira/educacional estão totalmente operacionais?'
        },
        // Segurança e Privacidade
        {
          'id': 45,
          'text':
              'Sente segurança na apresentação dos dados na tela e na privacidade do seu acesso?'
        },
        // Desempenho e Resposta
        {
          'id': 46,
          'text':
              'O carregamento dos vídeos, avatares e telas ocorre sem lentidão ou travamentos?'
        },
        // Estabilidade e Confiabilidade
        {
          'id': 47,
          'text':
              'O sistema mantém-se firme e funcional durante toda a sua navegação?'
        },
      ],
    },
  ];

  static const Map<String, List<Map<String, dynamic>>> _categoryQuestions = {
    'Professor': [
      {
        'id': 20,
        'text': 'O aplicativo pode ser utilizado como recurso pedagógico.'
      },
      {'id': 21, 'text': 'O conteúdo é adequado para uso em sala de aula.'},
      {
        'id': 22,
        'text': 'O aplicativo favorece a inclusão de estudantes surdos.'
      },
      {
        'id': 23,
        'text': 'Eu utilizaria o aplicativo em atividades educacionais.'
      },
      {'id': 24, 'text': 'O aplicativo possui potencial educacional.'},
    ],
    'Intérprete de Libras': [
      {'id': 25, 'text': 'Os sinais apresentados são adequados.'},
      {'id': 26, 'text': 'A comunicação em Libras é clara.'},
      {'id': 27, 'text': 'Os vídeos apresentam boa qualidade linguística.'},
      {
        'id': 28,
        'text': 'Os conceitos foram representados adequadamente em Libras.'
      },
    ],
    'Profissional da Contabilidade': [
      {'id': 29, 'text': 'Os conceitos contábeis apresentados estão corretos.'},
      {'id': 30, 'text': 'A terminologia utilizada é adequada.'},
      {'id': 31, 'text': 'O conteúdo possui relevância para a área contábil.'},
      {
        'id': 32,
        'text':
            'O aplicativo possui potencial para apoiar o ensino de contabilidade.'
      },
    ],
  };

  static const List<Map<String, String>> _openQuestions = [
    {'key': 'gostou', 'text': 'O que você mais gostou no aplicativo?'},
    {'key': 'melhorar', 'text': 'O que pode ser melhorado?'},
    {
      'key': 'sugestao',
      'text': 'Gostaria de deixar alguma sugestão adicional?'
    },
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

  bool _isSectionComplete(
      int sectionIndex, List<Map<String, dynamic>> questions) {
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

  /// Primeira pergunta ainda sem resposta na seção — a "pergunta da vez".
  int? _activeQuestionId(List<Map<String, dynamic>> questions) {
    for (final q in questions) {
      final id = q['id'] as int;
      if (!_answers.containsKey(id)) return id;
    }
    return null;
  }

  void _selectAnswer(int questionId, int value) {
    final isFirstAnswer = !_answers.containsKey(questionId);
    setState(() {
      _answers[questionId] = value;
    });
    // Só avança na primeira resposta: quem volta para corrigir uma nota não
    // deve ser levado para outro lugar.
    if (isFirstAnswer) _scrollToNextStep(questionId);
  }

  /// Próxima pergunta sem resposta depois de [answeredId]; se as seguintes
  /// já foram respondidas, volta à primeira que ficou pulada.
  int? _nextQuestionId(List<Map<String, dynamic>> questions, int answeredId) {
    final ids = questions.map((q) => q['id'] as int).toList();
    final start = ids.indexOf(answeredId) + 1;
    for (final id in [...ids.skip(start), ...ids.take(start)]) {
      if (!_answers.containsKey(id)) return id;
    }
    return null;
  }

  /// Leva o usuário à próxima pergunta sem resposta da seção ou, se todas
  /// já foram respondidas, até os botões Próximo/Enviar.
  Future<void> _scrollToNextStep(int answeredId) async {
    // Pausa curta para o usuário ver a nota marcada antes de rolar.
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    final nextId =
        _nextQuestionId(_getQuestionsForSection(_currentPage), answeredId);
    final target = nextId != null
        ? _questionKeys[nextId]?.currentContext
        : _navKeys[_currentPage]?.currentContext;
    if (target == null || !target.mounted) return;

    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      // Pergunta perto do topo; botões encostados no fim da área visível.
      alignment: nextId != null ? 0.1 : 1.0,
    );
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
      final navigator = Navigator.of(context);
      navigator.pop();
      showDialog(
        context: navigator.context,
        barrierDismissible: true,
        builder: (_) => const EvaluationSuccessDialog(),
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
          color: AppColors.errorContainer,
          border: Border.all(color: AppColors.errorBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.errorFg, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Não foi possível enviar sua avaliação.',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.errorFg),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Verifique sua conexão com a internet e tente novamente.',
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.errorFg),
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

  // Cabeçalho fixo compacto: título, progresso e fechar numa única faixa,
  // para sobrar mais altura para as perguntas.
  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: _hasAcceptedTerms
                  ? Text(
                      'Avaliação',
                      style: AppTextStyles.heading3,
                      overflow: TextOverflow.ellipsis,
                    )
                  : const SizedBox.shrink(),
            ),
            if (_hasAcceptedTerms)
              Text(
                'Seção ${_currentPage + 1} de $_totalSections',
                style: AppTextStyles.label,
              ),
            IconButton(
              icon: Icon(Icons.close, color: AppColors.textSecondary),
              visualDensity: VisualDensity.compact,
              tooltip: 'Fechar',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        if (_hasAcceptedTerms) ...[
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              minHeight: 4,
              value: (_currentPage + 1) / _totalSections,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryFg),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionPage(int sectionIndex) {
    final isOpenQuestionsPage = sectionIndex == _openQuestionsIndex;
    final questions = _getQuestionsForSection(sectionIndex);
    final isLastSection = sectionIndex == _totalSections - 1;
    final isSectionComplete = _isSectionComplete(sectionIndex, questions);
    final activeId = _activeQuestionId(questions);

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

    final sectionHeader = <Widget>[
      Row(
        children: [
          Icon(sectionIcon, size: 18, color: AppColors.secondaryFg),
          const SizedBox(width: 8),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                sectionTitle,
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      if (sectionIndex < _sections.length)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Use os critérios como guia enquanto navega no ContaLibras.',
            style: AppTextStyles.label,
          ),
        ),
      if (!isOpenQuestionsPage)
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.secondaryFg.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.touch_app_rounded,
                  size: 18, color: AppColors.secondaryFg),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Toque em uma nota de 1 a 5. Ao responder, você vai direto '
                  'para a próxima pergunta.',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 10),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            // O título e a instrução da seção rolam junto com as perguntas,
            // em vez de ficarem fixos ocupando espaço.
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...sectionHeader,
                  ...(isOpenQuestionsPage
                      ? _openQuestions.map((q) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  q['text']!,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primaryFg,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _openControllers[q['key']],
                                  maxLines: 3,
                                  onChanged: (value) =>
                                      _updateOpenAnswer(q['key']!, value),
                                  decoration: InputDecoration(
                                    hintText: 'Resposta opcional',
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.all(10),
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                      : questions.map((q) {
                          final id = q['id'] as int;
                          final isActive = id == activeId;
                          return AnimatedContainer(
                            key: _questionKey(id),
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              // A pergunta da vez ganha borda de destaque.
                              border: Border.all(
                                color: isActive
                                    ? AppColors.action
                                    : AppColors.divider,
                                width: isActive ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  q['text'] as String,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primaryFg,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildLikertScale(q['id'] as int),
                              ],
                            ),
                          );
                        })),
                  // Navegação no fim da lista: só aparece após ver todas as
                  // perguntas e não ocupa espaço fixo na tela.
                  const SizedBox(height: 4),
                  if (_showError && isLastSection) _buildErrorBanner(),
                  Row(
                    key: _navKey(sectionIndex),
                    children: [
                      if (sectionIndex > 0) ...[
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton(
                              onPressed: _goBack,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryFg,
                                side: BorderSide(color: AppColors.primaryFg),
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
                          height: 44,
                          child: ElevatedButton(
                            onPressed: (isSectionComplete && !_isSubmitting)
                                ? _goForward
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.action,
                              foregroundColor: Colors.white,
                              // Desabilitado continua legível nos dois modos.
                              disabledBackgroundColor: AppColors.divider,
                              disabledForegroundColor: AppColors.textSecondary,
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
                                : Text(isLastSection
                                    ? 'Enviar Avaliação'
                                    : 'Próximo'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Shrink the circles on narrow screens so 5 of them always fit
        // instead of overflowing the row.
        final circleSize = (constraints.maxWidth / 5 - 12).clamp(32.0, 40.0);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final value = index + 1;
                final isSelected = _answers[questionIndex] == value;
                return Semantics(
                  label: 'Nota $value de 5',
                  button: true,
                  selected: isSelected,
                  child: GestureDetector(
                    onTap: () => _selectAnswer(questionIndex, value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.action : AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          // Contorno dos itens não selecionados com >= 3:1
                          // para serem percebidos como clicáveis.
                          color:
                              isSelected ? AppColors.action : AppColors.border,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.action.withOpacity(0.3),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: circleSize < 36 ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text('Discordo\nTotalmente',
                      textAlign: TextAlign.left,
                      style: AppTextStyles.label.copyWith(fontSize: 10)),
                ),
                Flexible(
                  child: Text('Concordo\nTotalmente',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.label.copyWith(fontSize: 10)),
                ),
              ],
            ),
          ],
        );
      },
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
                _buildSectionTitle(
                    'Pesquisa: Avaliação do Aplicativo ContaLibras'),
                _buildParagraph(
                    'Você está sendo convidado(a) a participar de uma pesquisa acadêmica relacionada ao desenvolvimento e avaliação do aplicativo ContaLibras, realizada no contexto de um TCC do curso de Ciência da Computação.'),
                _buildParagraph(
                    'O objetivo desta pesquisa é avaliar o aplicativo, voltado para termos contábeis em Libras, segundo critérios de Usabilidade, IHC e Acessibilidade em Libras e de Qualidade Técnica e Engenharia de Software.'),
                _buildSectionTitle('Sobre a participação'),
                _buildParagraph(
                    'Sua participação é voluntária e consiste em responder a um questionário sobre sua experiência (clareza, navegação, design, prevenção de erros, funcionalidades, segurança, desempenho e estabilidade). Tempo estimado: 5 a 10 minutos.'),
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
                  foregroundColor: AppColors.accentFg,
                  side: BorderSide(color: AppColors.accentFg),
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
                  backgroundColor: AppColors.action,
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
        style: AppTextStyles.bodyMedium
            .copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryFg),
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
    final screenSize = MediaQuery.of(context).size;
    final isCompact = screenSize.width < 680;
    final dialogWidth = isCompact ? screenSize.width * 0.94 : 640.0;
    final dialogHeight = screenSize.height * (isCompact ? 0.92 : 0.9);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 24,
        vertical: 24,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: dialogHeight,
        width: dialogWidth,
        constraints: const BoxConstraints(maxHeight: 860, maxWidth: 640),
        padding: EdgeInsets.fromLTRB(isCompact ? 14 : 20, isCompact ? 6 : 10,
            isCompact ? 14 : 20, isCompact ? 12 : 16),
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
            _buildHeader(),
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
