import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Celebratory confirmation shown after a feedback submission succeeds.
/// Draws its own checkmark (no external animation packages available).
class EvaluationSuccessDialog extends StatefulWidget {
  const EvaluationSuccessDialog({super.key});

  @override
  State<EvaluationSuccessDialog> createState() =>
      _EvaluationSuccessDialogState();
}

class _EvaluationSuccessDialogState extends State<EvaluationSuccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _circleScale;
  late final Animation<double> _checkProgress;
  late final Animation<double> _fade;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();

    _circleScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
    );
    _checkProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );

    // Auto-dismiss so the user isn't forced to interact, but the "Concluir"
    // button and the barrier tap still let them close it sooner.
    _autoCloseTimer = Timer(const Duration(milliseconds: 3200), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        width: 360,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Transform.scale(
                scale: _circleScale.value < 0 ? 0 : _circleScale.value,
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: _CheckmarkPainter(
                      progress: _checkProgress.value,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fade,
              child: Column(
                children: [
                  Text(
                    'Obrigado por Preencher!',
                    style: AppTextStyles.heading2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sua avaliação foi enviada com sucesso e vai nos ajudar a melhorar o ContaLibras.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fade,
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Concluir'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  _CheckmarkPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    if (progress <= 0) return;

    final checkPath = Path()
      ..moveTo(size.width * 0.27, size.height * 0.53)
      ..lineTo(size.width * 0.44, size.height * 0.68)
      ..lineTo(size.width * 0.76, size.height * 0.33);

    final metric = checkPath.computeMetrics().first;
    final extracted =
        metric.extractPath(0, metric.length * progress.clamp(0.0, 1.0));

    canvas.drawPath(
      extracted,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.09
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
