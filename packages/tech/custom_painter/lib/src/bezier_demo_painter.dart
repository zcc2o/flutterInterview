import 'package:flutter/material.dart';

class BezierDemoPainter extends CustomPainter {
  final double progress;

  BezierDemoPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final p0 = Offset(20, size.height - 20);
    final p1 = Offset(size.width * 0.35, size.height * 0.15);
    final p2 = Offset(size.width * 0.65, size.height * 0.85);
    final p3 = Offset(size.width - 20, 20);

    // 控制线
    final dashPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    _drawDashedLine(canvas, p0, p1, dashPaint);
    _drawDashedLine(canvas, p2, p3, dashPaint);

    // 控制点
    for (final p in [p0, p1, p2, p3]) {
      canvas.drawCircle(p, 6, Paint()..color = Colors.blue);
    }

    // 贝塞尔曲线
    final path = Path()..moveTo(p0.dx, p0.dy);
    path.cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);
    canvas.drawPath(path, Paint()..color = Colors.deepOrange..strokeWidth = 3..style = PaintingStyle.stroke);

    // 绘制曲线上 progress 位置的点
    final t = progress;
    final bx = _bezier(p0.dx, p1.dx, p2.dx, p3.dx, t);
    final by = _bezier(p0.dy, p1.dy, p2.dy, p3.dy, t);
    canvas.drawCircle(Offset(bx, by), 10, Paint()..color = Colors.red);
  }

  double _bezier(double a, double b, double c, double d, double t) {
    final mt = 1 - t;
    return mt * mt * mt * a + 3 * mt * mt * t * b + 3 * mt * t * t * c + t * t * t * d;
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final dist = (dx * dx + dy * dy);
    final len = dist > 0 ? (dist / 9).clamp(8.0, 20.0) : 8.0;
    for (double d = 0; d * len < (dx * dx + dy * dy); d += 2) {
      final fraction = d * len / (dx * dx + dy * dy);
      if (fraction > 1) break;
      final start = Offset(from.dx + dx * fraction, from.dy + dy * fraction);
      final endFraction = ((d + 1) * len / (dx * dx + dy * dy)).clamp(0.0, 1.0);
      final end = Offset(from.dx + dx * endFraction, from.dy + dy * endFraction);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(BezierDemoPainter old) => progress != old.progress;
}
