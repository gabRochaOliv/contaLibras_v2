import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Vídeo em loop, mudo e autoplay, usado como substituto de uma imagem estática.
class LoopingAssetVideo extends StatefulWidget {
  final String assetPath;
  final double size;
  final BorderRadius borderRadius;

  const LoopingAssetVideo({
    super.key,
    required this.assetPath,
    this.size = 140,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  State<LoopingAssetVideo> createState() => _LoopingAssetVideoState();
}

class _LoopingAssetVideoState extends State<LoopingAssetVideo> {
  late final VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..setVolume(0)
      ..setLooping(true)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _isInitialized = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: _isInitialized
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
