import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../dictionary/term_detail_screen.dart';
import '../../../data/mock/mock_dictionary_repository.dart';
import '../../../data/managers/progress_manager.dart';
import '../../../data/managers/user_manager.dart';
import '../../../data/managers/theme_manager.dart';
import '../../widgets/evaluation_dialog.dart';

import '../../../data/models/term_model.dart';

class HomeScreen extends StatelessWidget {
  final String userName;
  final void Function(TermModel)? onTermSelected;
  const HomeScreen({super.key, this.userName = 'Estudante', this.onTermSelected});

  @override
  Widget build(BuildContext context) {
    final daysSinceEpoch = DateTime.now().difference(DateTime(1970, 1, 1)).inDays;
    final termIndex = daysSinceEpoch % MockDictionaryRepository.terms.length;
    final termoDoDia = MockDictionaryRepository.terms[termIndex];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

    return Scaffold(
      appBar: isDesktop ? null : AppBar(
        toolbarHeight: 80,
        title: Image.asset('assets/images/logoContaLibras.png', height: 60),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/acenando-removebg-preview.png',
                  height: 140,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Termos Explorados',
                            style: AppTextStyles.heading3.copyWith(
                              color: ThemeManager().isDarkMode ? Colors.white : AppColors.primary
                            ),
                          ),
                          Icon(Icons.emoji_events_rounded, color: Colors.amber.shade600, size: 28),
                        ],
                      ),

                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: AppColors.divider,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${(progress * 100).toStringAsFixed(0)}% concluído',
                          style: AppTextStyles.label.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const EvaluationDialog(),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
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
                        color: Colors.amber.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        color: Colors.amber.shade600,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Avalie o app',
                            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sua opinião nos ajuda a melhorar!',
                            style: AppTextStyles.label,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey.shade400,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                if (onTermSelected != null) {
                  onTermSelected!(termoDoDia);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TermDetailScreen(term: termoDoDia),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
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
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            termoDoDia.title,
                            style: AppTextStyles.heading3.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            termoDoDia.concept,
                            style: AppTextStyles.label.copyWith(color: Colors.white.withOpacity(0.9)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.school_rounded,
                      color: AppColors.accent,
                      size: 36,
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
            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
    ),
    );
      }, // fim builder
    ); // fim LayoutBuilder
  }
}
