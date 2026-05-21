import 'dart:math';
import 'package:flutter/material.dart';

class PieChartPainter extends CustomPainter {
  final List<(String label, Color color, double percent)> slices;

  PieChartPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.8;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    double startAngle = -pi / 2;

    for (final (_, color, percent) in slices) {
      final sweepAngle = percent * 2 * pi;

      // 扇形
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, true, paint);

      // 标签
      final midAngle = startAngle + sweepAngle / 2;
      final labelRadius = radius * 0.65;
      final labelPos = Offset(
        center.dx + cos(midAngle) * labelRadius,
        center.dy + sin(midAngle) * labelRadius,
      );
      textPainter.text = TextSpan(
        text: '${(percent * 100).toInt()}%',
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, labelPos - Offset(textPainter.width / 2, textPainter.height / 2));

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(PieChartPainter old) => slices != old.slices;
}
