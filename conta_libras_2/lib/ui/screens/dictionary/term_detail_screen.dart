import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.term.videoUrl.isNotEmpty) {
      _videoController = VideoPlayerController.asset(widget.term.videoUrl)
        ..initialize().then((_) {
          _videoController!.setVolume(0); // Garante que o vídeo comece mudo
          setState(() {});
        }).catchError((error) {
          debugPrint("Erro ao carregar vídeo: $error");
        });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Widget _buildVideoTab() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off_rounded, size: 80, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Vídeo não disponível ou carregando...',
              style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _videoController!.value.isPlaying
                      ? _videoController!.pause()
                      : _videoController!.play();
                });
              },
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(_videoController!),
                  if (!_videoController!.value.isPlaying)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
                    ),
                  VideoProgressIndicator(
                    _videoController!,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: AppColors.primary,
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.white24,
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

  Widget _buildContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoCard(
            title: 'Categoria',
            content: widget.term.category,
            icon: Icons.category_rounded,
            color: AppColors.accent,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Conceito',
            content: widget.term.concept,
            icon: Icons.menu_book_rounded,
            color: AppColors.primary,
          ),
          if (widget.term.example.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Exemplo',
              content: widget.term.example,
              icon: Icons.lightbulb_outline_rounded,
              color: AppColors.secondary,
            ),
          ],
          if (widget.term.observation.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Observação',
              content: widget.term.observation,
              icon: Icons.info_outline_rounded,
              color: Colors.amber.shade800,
            ),
          ],
          if (widget.term.relatedTerms.isNotEmpty) ...[
            const SizedBox(height: 24),
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

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRichText(
            content,
            AppTextStyles.bodyLarge.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildRichText(String text, TextStyle baseStyle) {
    if (text.isEmpty) return const SizedBox.shrink();
    
    final List<TextSpan> spans = [];
    final pattern = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;
    
    for (final match in pattern.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }
    
    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: spans,
      ),
    );
  }

  Widget _buildAnimationTab() {
    if (widget.term.imageLbsUrl.isEmpty && widget.term.imageRvUrl.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_not_supported_rounded, size: 80, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Imagens não disponíveis',
              style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.term.imageLbsUrl.isNotEmpty) ...[
            Text(
              'Linguagem Brasileira de Sinais',
              style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  widget.term.imageLbsUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
          if (widget.term.imageRvUrl.isNotEmpty) ...[
            Text(
              'Representação Visual',
              style: AppTextStyles.heading2.copyWith(color: AppColors.secondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  widget.term.imageRvUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Image.asset('assets/images/logoContaLibras.png', height: 60),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.only(top: 8.0, bottom: 16.0, left: 16.0, right: 16.0),
            child: Text(
              widget.term.title,
              style: AppTextStyles.heading1,
              textAlign: TextAlign.center,
            ),
          ),
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
