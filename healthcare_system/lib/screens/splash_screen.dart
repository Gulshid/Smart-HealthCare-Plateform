import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'risk_input_screen.dart';
import '../services/risk_api_service.dart';

/// Launch screen: a single orchestrated animation — a diagnostic pulse
/// line draws itself, then the wordmark resolves — rather than several
/// scattered entrance effects. Motion is skipped entirely if the OS
/// accessibility setting for reduced motion is on.
class SplashScreen extends StatefulWidget {
  final RiskApiService apiService;
  const SplashScreen({super.key, required this.apiService});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _lineProgress;
  late final Animation<double> _markOpacity;
  late final Animation<double> _markScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    // The pulse line draws across the first ~65% of the timeline.
    _lineProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeInOutCubic),
    );

    // The wordmark resolves in as the line finishes.
    _markOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
    );
    _markScale = Tween(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    final reduceMotion = WidgetsBinding
            .instance.platformDispatcher.accessibilityFeatures.disableAnimations;

    if (reduceMotion) {
      _controller.value = 1.0;
      _navigateNext(immediate: true);
    } else {
      _controller.forward();
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _navigateNext();
        }
      });
    }
  }

  void _navigateNext({bool immediate = false}) {
    Future.delayed(immediate ? Duration.zero : const Duration(milliseconds: 350), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) =>
              RiskInputScreen(apiService: widget.apiService),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 220,
                  height: 64,
                  child: CustomPaint(
                    painter: _PulseLinePainter(progress: _lineProgress.value),
                  ),
                ),
                const SizedBox(height: 28),
                Opacity(
                  opacity: _markOpacity.value,
                  child: Transform.scale(
                    scale: _markScale.value,
                    child: Column(
                      children: [
                        Text(
                          'Smart Healthcare Risk',
                          style: AppType.display(
                            size: 22,
                            weight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Clinical risk intelligence',
                          style: AppType.body(size: 12, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Draws a heartbeat/ECG-style waveform progressively, using
/// PathMetrics to reveal only the leading `progress` fraction of
/// the path — the "instrument drawing a reading" motif.
class _PulseLinePainter extends CustomPainter {
  final double progress; // 0..1

  _PulseLinePainter({required this.progress});

  Path _buildPath(Size size) {
    final w = size.width;
    final h = size.height;
    final midY = h / 2;
    final path = Path()..moveTo(0, midY);

    path.lineTo(w * 0.28, midY);
    path.lineTo(w * 0.36, midY - h * 0.18);
    path.lineTo(w * 0.42, midY + h * 0.42);
    path.lineTo(w * 0.48, midY - h * 0.85);
    path.lineTo(w * 0.54, midY + h * 0.30);
    path.lineTo(w * 0.60, midY);
    path.lineTo(w * 0.78, midY);
    path.quadraticBezierTo(w * 0.86, midY, w * 0.90, midY - h * 0.12);
    path.quadraticBezierTo(w * 0.94, midY - h * 0.22, w, midY - h * 0.22);

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final fullPath = _buildPath(size);

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (progress >= 1.0) {
      canvas.drawPath(fullPath, paint);
      return;
    }

    final metrics = fullPath.computeMetrics().toList();
    final totalLength =
        metrics.fold<double>(0, (sum, m) => sum + m.length);
    final targetLength = totalLength * progress;

    double consumed = 0;
    for (final metric in metrics) {
      if (consumed >= targetLength) break;
      final remaining = targetLength - consumed;
      final take = math.min(metric.length, remaining);
      final extracted = metric.extractPath(0, take);
      canvas.drawPath(extracted, paint);
      consumed += metric.length;
    }
  }

  @override
  bool shouldRepaint(covariant _PulseLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
