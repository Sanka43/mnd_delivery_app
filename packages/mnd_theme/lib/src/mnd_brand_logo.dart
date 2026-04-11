import 'package:flutter/material.dart';

/// Vector mark for **MND — Master N Delivery**: stylized “N” on a rounded tile.
class MndBrandLogo extends StatelessWidget {
  const MndBrandLogo({
    super.key,
    this.size = 72,
    this.semanticsLabel = 'MND Master N Delivery logo',
    this.backgroundColor,
    this.foregroundColor,
  });

  final double size;
  final String semanticsLabel;

  /// When set, overrides [ColorScheme.primary] / [ColorScheme.onPrimary].
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticsLabel,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _MndLogoPainter(
            backgroundColor: backgroundColor ?? scheme.primary,
            foregroundColor: foregroundColor ?? scheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

class _MndLogoPainter extends CustomPainter {
  _MndLogoPainter({
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = w * 0.22;
    final bgRrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(r),
    );
    canvas.drawRRect(
      bgRrect,
      Paint()..color = backgroundColor,
    );

    final stroke = w * 0.072;
    final paint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // “N” in normalized [0,1] with padding.
    const pad = 0.2;
    final x0 = pad * w;
    final x1 = (1 - pad) * w;
    final y0 = pad * h + stroke * 0.35;
    final y1 = (1 - pad) * h - stroke * 0.35;

    // Letter “N”: left stem, diagonal (bottom-left → top-right), right stem.
    final path = Path()
      ..moveTo(x0, y0)
      ..lineTo(x0, y1)
      ..moveTo(x0, y1)
      ..lineTo(x1, y0)
      ..moveTo(x1, y0)
      ..lineTo(x1, y1);

    canvas.drawPath(path, paint);

    // Subtle motion arc — suggests delivery route.
    final arcPaint = Paint()
      ..color = foregroundColor.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * 0.55
      ..strokeCap = StrokeCap.round;

    final arcRect = Rect.fromLTWH(
      w * 0.52,
      h * 0.58,
      w * 0.36,
      h * 0.28,
    );
    canvas.drawArc(arcRect, 0.15, 1.1, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _MndLogoPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.foregroundColor != foregroundColor;
  }
}
