import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/managers/user_manager.dart';
import '../../../data/managers/theme_manager.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/services/profile_storage_service.dart';
import '../../../core/app_messenger.dart';
import '../main/main_screen.dart';

class FirstAccessScreen extends StatefulWidget {
  const FirstAccessScreen({super.key});

  @override
  State<FirstAccessScreen> createState() => _FirstAccessScreenState();
}

class _FirstAccessScreenState extends State<FirstAccessScreen> {
  static const int _totalSteps = 2;

  final List<GlobalKey<FormState>> _formKeys =
      List.generate(_totalSteps, (_) => GlobalKey<FormState>());

  int _currentStep = 0;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedCategory;
  String? _selectedEscolaridade;
  bool? _usaLibras;
  String? _selectedConhecimentoLibras;

  final List<String> _categories = [
    'Professor',
    'Estudante',
    'Intérprete de Libras',
    'Profissional da Contabilidade',
    'Outro'
  ];

  final List<String> _escolaridades = [
    'Ensino Fundamental',
    'Ensino Médio',
    'Ensino Superior',
    'Pós-graduação',
  ];

  final List<String> _niveisConhecimentoLibras = [
    'Básico',
    'Intermediário',
    'Avançado',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  final _storage = ProfileStorageService();

  void _goToNextStep() {
    final isValid = _formKeys[_currentStep].currentState!.validate();
    if (!isValid) return;

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _goToPreviousStep() {
    if (_currentStep == 0) return;
    setState(() => _currentStep--);
  }

  Future<void> _submit() async {
    final profile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      category: _selectedCategory ?? '',
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      escolaridade: _selectedEscolaridade ?? '',
      usaLibras: _usaLibras ?? false,
      conhecimentoLibras: _selectedConhecimentoLibras ?? '',
    );

    UserManager().loadFromProfile(profile);

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );

    // Salvar localmente é um "melhor esforço": se o armazenamento do
    // navegador falhar ou travar, o usuário já está navegando e não
    // fica preso esperando o clique responder.
    try {
      await _storage.saveProfile(profile);
      await _storage.setActiveProfileId(profile.id);
    } catch (e) {
      debugPrint('[ProfileStorage] falha ao salvar perfil: $e');
      showAppMessage(
          'Não foi possível salvar seu perfil neste navegador (erro: $e)');
    }
  }

  InputDecoration _fieldDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.secondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  String get _stepTitle {
    switch (_currentStep) {
      case 0:
        return 'Vamos te conhecer';
      default:
        return 'Sua relação com a Libras';
    }
  }

  String get _stepSubtitle {
    switch (_currentStep) {
      case 0:
        return 'Conte um pouco sobre você.';
      default:
        return 'Isso nos ajuda a personalizar seu aprendizado.';
    }
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(_totalSteps, (index) {
        final isActive = index <= _currentStep;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == _totalSteps - 1 ? 0 : 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: _fieldDecoration(
                label: 'Apelido ou nome', icon: Icons.person_outline_rounded),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, insira seu nome';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: AppColors.textPrimary),
            decoration:
                _fieldDecoration(label: 'Idade', icon: Icons.cake_outlined),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, insira sua idade';
              }
              if (int.tryParse(value) == null) {
                return 'Por favor, insira uma idade válida';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            isExpanded: true,
            dropdownColor: AppColors.surface,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: _fieldDecoration(
                label: 'Categoria/perfil do usuário',
                icon: Icons.school_outlined),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category,
                    overflow: TextOverflow.ellipsis, maxLines: 1),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedCategory = value);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecione seu perfil';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLibrasStep() {
    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedEscolaridade,
            isExpanded: true,
            dropdownColor: AppColors.surface,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: _fieldDecoration(
                label: 'Escolaridade', icon: Icons.menu_book_outlined),
            items: _escolaridades.map((escolaridade) {
              return DropdownMenuItem(
                value: escolaridade,
                child: Text(escolaridade,
                    overflow: TextOverflow.ellipsis, maxLines: 1),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedEscolaridade = value);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecione sua escolaridade';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<bool>(
            value: _usaLibras,
            isExpanded: true,
            dropdownColor: AppColors.surface,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: _fieldDecoration(
                label: 'Você utiliza Libras?',
                icon: Icons.sign_language_outlined),
            items: const [
              DropdownMenuItem(value: true, child: Text('Sim')),
              DropdownMenuItem(value: false, child: Text('Não')),
            ],
            onChanged: (value) {
              setState(() => _usaLibras = value);
            },
            validator: (value) {
              if (value == null) {
                return 'Por favor, informe se você utiliza Libras';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedConhecimentoLibras,
            isExpanded: true,
            dropdownColor: AppColors.surface,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: _fieldDecoration(
                label: 'Conhecimento em Libras',
                icon: Icons.bar_chart_outlined),
            items: _niveisConhecimentoLibras.map((nivel) {
              return DropdownMenuItem(
                value: nivel,
                child:
                    Text(nivel, overflow: TextOverflow.ellipsis, maxLines: 1),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedConhecimentoLibras = value);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecione seu nível de conhecimento em Libras';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      default:
        return _buildLibrasStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ThemeManager().isDarkMode;
    final isLastStep = _currentStep == _totalSteps - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 380;
            final outerPadding = isNarrow ? 16.0 : 24.0;
            final cardPadding = isNarrow ? 20.0 : 32.0;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: outerPadding, vertical: 32.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo do App
                      Image.asset(
                        'assets/images/logoContaLibras.png',
                        height: isNarrow ? 80 : 100,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 32),

                      // Card de Cadastro
                      Container(
                        padding: EdgeInsets.all(cardPadding),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.divider,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildProgressIndicator(),
                            const SizedBox(height: 8),
                            Text(
                              'Etapa ${_currentStep + 1} de $_totalSteps',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _stepTitle,
                              style: AppTextStyles.heading2.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _stepSubtitle,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Container(
                                key: ValueKey(_currentStep),
                                child: _buildCurrentStep(),
                              ),
                            ),
                            const SizedBox(height: 36),
                            Row(
                              children: [
                                if (_currentStep > 0) ...[
                                  Expanded(
                                    flex: 2,
                                    child: OutlinedButton(
                                      onPressed: _goToPreviousStep,
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18),
                                        side: BorderSide(
                                            color: AppColors.divider),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'Voltar',
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  flex: 3,
                                  child: ElevatedButton(
                                    onPressed: _goToNextStep,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 18),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        isLastStep
                                            ? 'Começar a Aprender'
                                            : 'Continuar',
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
