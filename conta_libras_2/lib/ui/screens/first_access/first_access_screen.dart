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
  final _formKey = GlobalKey<FormState>();
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

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
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
        showAppMessage('Não foi possível salvar seu perfil neste navegador (erro: $e)');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ThemeManager().isDarkMode;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo do App
                  Image.asset(
                    'assets/images/logoContaLibras.png',
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  
                  // Card de Cadastro
                  Container(
                    padding: const EdgeInsets.all(32.0),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Seja bem-vindo(a)!',
                            style: AppTextStyles.heading2.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Preencha seus dados para personalizar sua experiência no app.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          
                          // Campo Nome
                          TextFormField(
                            controller: _nameController,
                            style: TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Apelido ou nome',
                              prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.secondary),
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
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, insira seu nome';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // Campo Idade
                          TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Idade',
                              prefixIcon: const Icon(Icons.cake_outlined, color: AppColors.secondary),
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
                            ),
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
                          
                          // Campo Categoria
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            dropdownColor: AppColors.surface,
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Categoria/perfil do usuário',
                              prefixIcon: const Icon(Icons.school_outlined, color: AppColors.secondary),
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
                            ),
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, selecione seu perfil';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Campo Escolaridade
                          DropdownButtonFormField<String>(
                            value: _selectedEscolaridade,
                            isExpanded: true,
                            dropdownColor: AppColors.surface,
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Escolaridade',
                              prefixIcon: const Icon(Icons.menu_book_outlined, color: AppColors.secondary),
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
                            ),
                            items: _escolaridades.map((escolaridade) {
                              return DropdownMenuItem(
                                value: escolaridade,
                                child: Text(
                                  escolaridade,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedEscolaridade = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, selecione sua escolaridade';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Campo Uso de Libras
                          DropdownButtonFormField<bool>(
                            value: _usaLibras,
                            isExpanded: true,
                            dropdownColor: AppColors.surface,
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Você utiliza Libras?',
                              prefixIcon: const Icon(Icons.sign_language_outlined, color: AppColors.secondary),
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
                            ),
                            items: const [
                              DropdownMenuItem(value: true, child: Text('Sim')),
                              DropdownMenuItem(value: false, child: Text('Não')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _usaLibras = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Por favor, informe se você utiliza Libras';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Campo Conhecimento em Libras
                          DropdownButtonFormField<String>(
                            value: _selectedConhecimentoLibras,
                            isExpanded: true,
                            dropdownColor: AppColors.surface,
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Conhecimento em Libras',
                              prefixIcon: const Icon(Icons.bar_chart_outlined, color: AppColors.secondary),
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
                            ),
                            items: _niveisConhecimentoLibras.map((nivel) {
                              return DropdownMenuItem(
                                value: nivel,
                                child: Text(
                                  nivel,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedConhecimentoLibras = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, selecione seu nível de conhecimento em Libras';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 36),

                          // Botão Continuar
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Começar a Aprender',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
