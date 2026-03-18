import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/term_model.dart';

class TermDetailScreen extends StatefulWidget {
  final TermModel term;

  const TermDetailScreen({super.key, required this.term});

  @override
  State<TermDetailScreen> createState() => _TermDetailScreenState();
}

class _TermDetailScreenState extends State<TermDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildVideoTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_circle_outline_rounded, size: 80, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Vídeo em Libras',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            '(Player de vídeo será inserido aqui)',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categoria',
            style: AppTextStyles.label.copyWith(color: AppColors.accent),
          ),
          const SizedBox(height: 4),
          Text(
            widget.term.category,
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 24),
          Text(
            'Definição',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            widget.term.definition,
            style: AppTextStyles.bodyLarge.copyWith(height: 1.5),
          ),
          if (widget.term.relatedTerms.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              'Termos Relacionados',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.term.relatedTerms.map((term) {
                return Chip(
                  label: Text(term, style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildAnimationTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.animation_rounded, size: 80, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Animação Passo a Passo',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            '(Animação Lottie virá aqui)',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.term.title),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.accent,
              indicatorWeight: 3,
              labelStyle: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(icon: Icon(Icons.play_circle_fill_rounded), text: 'Vídeo'),
                Tab(icon: Icon(Icons.description_rounded), text: 'Conteúdo'),
                Tab(icon: Icon(Icons.animation_rounded), text: 'Passos'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVideoTab(),
                _buildContentTab(),
                _buildAnimationTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
