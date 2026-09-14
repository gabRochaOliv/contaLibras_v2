import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Vídeo em loop, mudo e autoplay, usado como substituto de uma imagem estática.
///
/// Em ambientes com suporte fraco a autoplay/controles nativos de vídeo no web
/// (ex.: navegador embutido do WhatsApp no Android), o playback pode nunca ser
/// confirmado ou o controller pode reportar erro. Nesses casos, o widget cai
/// permanentemente para [fallbackAssetImage] em vez de arriscar exibir um
/// `<video>` quebrado (controles nativos sobrepostos, tela travada).
class LoopingAssetVideo extends StatefulWidget {
  final String assetPath;
  final double size;
  final BorderRadius borderRadius;
  final String fallbackAssetImage;

  const LoopingAssetVideo({
    super.key,
    required this.assetPath,
    this.size = 140,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.fallbackAssetImage = 'assets/images/acenando-removebg-preview.png',
  });

  @override
  State<LoopingAssetVideo> createState() => _LoopingAssetVideoState();
}

class _LoopingAssetVideoState extends State<LoopingAssetVideo> {
  late final VideoPlayerController _controller;
  bool _isPlayingConfirmed = false;
  bool _useFallback = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      widget.assetPath,
      videoPlayerOptions: VideoPlayerOptions(
        webOptions: const VideoPlayerWebOptions(
          controls: VideoPlayerWebOptionsControls.disabled(),
          allowContextMenu: false,
          allowRemotePlayback: false,
        ),
      ),
    )
      ..setVolume(0)
      ..setLooping(true)
      ..addListener(_onControllerUpdate);

    _fallbackTimer = Timer(const Duration(seconds: 3), _activateFallback);

    _controller
        .initialize()
        .then((_) {
          if (!mounted || _useFallback) return;
          _controller.play().catchError((_) {
            _activateFallback();
          });
        })
        .catchError((_) {
          _activateFallback();
        });
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    if (_controller.value.hasError) {
      _activateFallback();
      return;
    }
    if (_controller.value.isPlaying && !_isPlayingConfirmed) {
      setState(() => _isPlayingConfirmed = true);
      _fallbackTimer?.cancel();
    }
  }

  void _activateFallback() {
    if (_useFallback || !mounted) return;
    _fallbackTimer?.cancel();
    setState(() => _useFallback = true);
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showVideo = _isPlayingConfirmed && !_useFallback;
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: showVideo
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
            : Image.asset(
                widget.fallbackAssetImage,
                width: widget.size,
                height: widget.size,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
