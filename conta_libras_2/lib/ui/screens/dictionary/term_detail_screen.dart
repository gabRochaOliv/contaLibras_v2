import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/term_model.dart';
import '../../../data/managers/favorites_manager.dart';
import '../../../data/managers/progress_manager.dart';

class TermDetailScreen extends StatefulWidget {
  final TermModel term;
  final VoidCallback? onBackPressed;

  const TermDetailScreen({super.key, required this.term, this.onBackPressed});

  @override
  State<TermDetailScreen> createState() => _TermDetailScreenState();
}

class _TermDetailScreenState extends State<TermDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VideoPlayerController? _videoController;
  bool _isFullScreen = false;
  bool _videoLoading = false;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();
    // Adiado para após o build para evitar setState during layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProgressManager().markAsViewed(widget.term.id);
    });
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_videoController != null && _videoController!.value.isInitialized) {
        if (_tabController.index == 0 && !_isFullScreen) {
          _videoController!.play();
        } else {
          _videoController!.pause();
        }
      }
    });
    if (widget.term.videoUrl.isNotEmpty) {
      _videoLoading = true;
      _videoError = false;
      _videoController = VideoPlayerController.asset(widget.term.videoUrl)
        ..initialize().then((_) {
          if (mounted) {
            _videoController!.setVolume(0); // Garante que o vídeo comece mudo
            _videoController!
                .setLooping(true); // Faz o vídeo repetir automaticamente
            setState(() {
              _videoLoading = false;
            });
            if (_tabController.index == 0 && !_isFullScreen) {
              _videoController!.play();
            }
          }
        }).catchError((error) {
          debugPrint("Erro ao carregar vídeo: $error");
          if (mounted) {
            setState(() {
              _videoLoading = false;
              _videoError = true;
            });
          }
        });
    } else {
      _videoError = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _toggleFullScreen() async {
    if (_videoController!.value.isPlaying) {
      await _videoController!.pause();
    }

    setState(() {
      _isFullScreen = true;
    });

    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (_) => _FullScreenVideoPage(controller: _videoController!),
    ))
        .then((_) async {
      final bool endedPlaying = _videoController!.value.isPlaying;
      if (endedPlaying) {
        await _videoController!.pause();
      }

      if (mounted) {
        setState(() {
          _isFullScreen = false;
        });
      }

      await Future.delayed(const Duration(milliseconds: 100));

      if (endedPlaying && mounted) {
        _videoController!.play();
      } else if (mounted) {
        setState(() {}); // refresh generic UI
      }
    });
  }

  Widget _buildVideoTab() {
    if (_videoLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryFg),
            ),
            const SizedBox(height: 24),
            Text(
              'Carregando vídeo, aguarde...',
              style: AppTextStyles.heading3
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_videoError ||
        _videoController == null ||
        !_videoController!.value.isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off_rounded,
                size: 80, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Vídeo indisponível',
              style: AppTextStyles.heading3
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_isFullScreen) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fullscreen_rounded,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Reproduzindo em tela cheia...',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textSecondary),
            )
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: GestureDetector(
              // Opaque: o toque em qualquer ponto da área do vídeo pausa ou
              // retoma, mesmo onde o player nativo não repassa o evento.
              behavior: HitTestBehavior.opaque,
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
                  VideoProgressIndicator(
                    _videoController!,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: AppColors.secondary,
                      bufferedColor: Colors.black38,
                      backgroundColor: Colors.black12,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.fullscreen_rounded,
                          color: Colors.white, size: 30),
                      tooltip: 'Tela cheia',
                      onPressed: _toggleFullScreen,
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
            color: AppColors.accentFg,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Conceito',
            content: widget.term.concept,
            icon: Icons.menu_book_rounded,
            color: AppColors.primaryFg,
          ),
          if (widget.term.example.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Exemplo',
              content: widget.term.example,
              icon: Icons.lightbulb_outline_rounded,
              color: AppColors.secondaryFg,
            ),
          ],
          if (widget.term.observation.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Observação',
              content: widget.term.observation,
              icon: Icons.info_outline_rounded,
              color: AppColors.warningFg,
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
                  label: Text(term,
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.primaryFg)),
                  backgroundColor: AppColors.secondaryFg.withOpacity(0.12),
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
            Icon(Icons.image_not_supported_rounded,
                size: 80, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Imagens não disponíveis',
              style: AppTextStyles.heading3
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.term.imageLbsUrl.isNotEmpty) ...[
            Text(
              'Linguagem Brasileira de Sinais',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.primaryFg,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 350),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
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
            ),
            const SizedBox(height: 32),
          ],
          if (widget.term.imageRvUrl.isNotEmpty) ...[
            Text(
              'Representação Visual',
              style:
                  AppTextStyles.heading2.copyWith(color: AppColors.secondaryFg),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 350),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
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
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        return Scaffold(
          appBar: isDesktop
              ? null
              : AppBar(
                  toolbarHeight: 80,
                  title: Image.asset('assets/images/logoContaLibras.png',
                      height: 60),
                  centerTitle: true,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_rounded,
                        color: AppColors.primaryFg, size: 28),
                    tooltip: 'Voltar',
                    onPressed: () {
                      if (widget.onBackPressed != null) {
                        widget.onBackPressed!();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  actions: [
                    AnimatedBuilder(
                      animation: FavoritesManager(),
                      builder: (context, child) {
                        final isFav =
                            FavoritesManager().isFavorite(widget.term.id);
                        return IconButton(
                          icon: Icon(
                            isFav
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: isFav
                                ? AppColors.primaryFg
                                : AppColors.textSecondary,
                            size: 32,
                          ),
                          onPressed: () {
                            FavoritesManager().toggleFavorite(widget.term);
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.only(
                        top: 8.0, bottom: 16.0, left: 16.0, right: 16.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 48.0 : 16.0),
                          child: Text(
                            widget.term.title,
                            style: AppTextStyles.heading1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (isDesktop)
                          Positioned(
                            right: 8,
                            child: AnimatedBuilder(
                              animation: FavoritesManager(),
                              builder: (context, child) {
                                final isFav = FavoritesManager()
                                    .isFavorite(widget.term.id);
                                return IconButton(
                                  icon: Icon(
                                    isFav
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    color: isFav
                                        ? AppColors.primaryFg
                                        : AppColors.textSecondary,
                                    size: 28,
                                  ),
                                  tooltip: isFav
                                      ? 'Remover dos favoritos'
                                      : 'Favoritar termo',
                                  onPressed: () {
                                    FavoritesManager()
                                        .toggleFavorite(widget.term);
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    color: AppColors.surface,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primaryFg,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.accentFg,
                      dividerColor: AppColors.divider,
                      indicatorWeight: 3,
                      labelStyle: AppTextStyles.label
                          .copyWith(fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(
                            icon: Icon(Icons.play_circle_fill_rounded),
                            text: 'Vídeo'),
                        Tab(
                            icon: Icon(Icons.description_rounded),
                            text: 'Conteúdo'),
                        Tab(
                            icon: Icon(Icons.animation_rounded),
                            text: 'Visual'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _KeepAliveTab(child: _buildVideoTab()),
                        _KeepAliveTab(child: _buildContentTab()),
                        _KeepAliveTab(child: _buildAnimationTab()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _KeepAliveTab extends StatefulWidget {
  final Widget child;
  const _KeepAliveTab({required this.child});

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Vídeo em tela cheia. Sempre abre rodando em loop.
class _FullScreenVideoPage extends StatefulWidget {
  const _FullScreenVideoPage({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<_FullScreenVideoPage> {
  Animation<double>? _routeAnimation;

  /// Depois que o usuário toca no vídeo, a pausa dele é respeitada e o
  /// play automático não interfere mais.
  bool _userControlled = false;

  VideoPlayerController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.setLooping(true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animation = ModalRoute.of(context)?.animation;
    if (animation == _routeAnimation) return;
    _routeAnimation?.removeStatusListener(_onRouteAnimationStatus);
    _routeAnimation = animation;
    if (animation == null || animation.isCompleted) {
      _autoPlay();
    } else {
      animation.addStatusListener(_onRouteAnimationStatus);
    }
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteAnimationStatus);
    super.dispose();
  }

  void _onRouteAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _autoPlay();
  }

  // Na web o player é um único <video> que muda de lugar na página ao trocar
  // de rota, e o navegador pausa a mídia sempre que ela é retirada do DOM.
  // Por isso o play só acontece depois da transição da rota e é conferido
  // de novo logo em seguida.
  Future<void> _autoPlay() async {
    for (var attempt = 0; attempt < 3; attempt++) {
      if (!mounted || _userControlled) return;
      if (!_controller.value.isPlaying) await _controller.play();
      await Future.delayed(const Duration(milliseconds: 250));
    }
  }

  void _togglePlay() {
    _userControlled = true;
    _controller.value.isPlaying ? _controller.pause() : _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mesmo fundo do app (acompanha o tema). Antes era preto, o que
      // gerava faixas pretas grandes ao redor do vídeo vertical.
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _togglePlay,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(_controller),
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: AppColors.secondary,
                          bufferedColor: Colors.black38,
                          backgroundColor: Colors.black12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.fullscreen_exit_rounded,
                      color: Colors.white, size: 36),
                  tooltip: 'Sair da tela cheia',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
