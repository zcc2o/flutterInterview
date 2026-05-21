import 'dart:math';
import 'package:flutter/material.dart';

class ClockPainter extends CustomPainter {
  final DateTime dateTime;

  ClockPainter({required this.dateTime});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;

    // 表盘
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFF5F5F5));
    canvas.drawCircle(center, radius, Paint()..color = Colors.grey.shade400..style = PaintingStyle.stroke..strokeWidth = 3);

    // 刻度
    for (int i = 0; i < 60; i++) {
      final angle = i * pi / 30 - pi / 2;
      final isHour = i % 5 == 0;
      final inner = radius * (isHour ? 0.82 : 0.9);
      final outer = radius * (isHour ? 0.95 : 0.92);
      canvas.drawLine(
        Offset(center.dx + cos(angle) * inner, center.dy + sin(angle) * inner),
        Offset(center.dx + cos(angle) * outer, center.dy + sin(angle) * outer),
        Paint()..color = isHour ? Colors.black : Colors.grey..strokeWidth = isHour ? 2.5 : 1,
      );
    }

    // 指针
    final hour = dateTime.hour % 12 + dateTime.minute / 60.0;
    final minute = dateTime.minute + dateTime.second / 60.0;
    final second = dateTime.second;

    _drawHand(canvas, center, hour * pi / 6 - pi / 2, radius * 0.5, 5, Colors.black);
    _drawHand(canvas, center, minute * pi / 30 - pi / 2, radius * 0.7, 3, Colors.black87);
    _drawHand(canvas, center, second * pi / 30 - pi / 2, radius * 0.85, 1.5, Colors.red);

    canvas.drawCircle(center, 6, Paint()..color = Colors.red);
  }

  void _drawHand(Canvas canvas, Offset center, double angle, double length, double width, Color color) {
    final end = Offset(center.dx + cos(angle) * length, center.dy + sin(angle) * length);
    canvas.drawLine(center, end, Paint()..color = color..strokeWidth = width..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(ClockPainter old) => dateTime != old.dateTime;
}
