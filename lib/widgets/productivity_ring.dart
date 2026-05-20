import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Circular productivity ring indicator.
class ProductivityRing extends StatelessWidget {
  final double percentage;
  final double size;
  final String? label;

  const ProductivityRing({
    super.key,
    required this.percentage,
    this.size = 80,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = percentage >= 70
        ? ZyvoraColors.green
        : percentage >= 40
        ? ZyvoraColors.yellow
        : ZyvoraColors.red;

    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: (percentage / 100).clamp(0, 1).toDouble()),
        duration: ZyvoraMotion.regular,
        curve: ZyvoraMotion.curve,
        builder: (context, progress, _) {
          return SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _RingPainter(
                progress: progress,
                color: color,
                backgroundColor: color.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.15 : 0.1,
                ),
                strokeWidth: size * 0.1,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${percentage.round()}%',
                      style: TextStyle(
                        fontSize: size * 0.22,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    if (label != null)
                      Text(
                        label!,
                        style: TextStyle(
                          fontSize: size * 0.12,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress.clamp(0, 1),
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
