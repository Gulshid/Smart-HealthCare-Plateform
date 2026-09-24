import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A hand-painted arc gauge showing a risk probability, animated on
/// entry. Replaces a generic LinearProgressIndicator with something
/// that reads like a diagnostic instrument.
class RiskArcGauge extends StatelessWidget {
  final double probability; // 0.0 - 1.0
  final String band;
  final double size;

  const RiskArcGauge({
    super.key,
    required this.probability,
    required this.band,
    this.size = 132,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.riskColor(band);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: probability.clamp(0, 1)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _ArcGaugePainter(progress: value, color: color),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(value * 100).toStringAsFixed(0)}%',
                    style: AppType.data(
                        size: 26, weight: FontWeight.w600, color: color),
                  ),
                  Text('risk', style: AppType.body(size: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ArcGaugePainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;

  _ArcGaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    const startAngle = math.pi * 0.75; // 135deg
    const sweepTotal = math.pi * 1.5; // 270deg gauge

    final track = Paint()
      ..color = AppColors.hairline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      track,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal * progress,
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcGaugePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
