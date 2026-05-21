import 'dart:math';
import 'package:flutter/material.dart';

class RepaintCounterPainter extends CustomPainter {
  final int paintCount;
  final ValueNotifier<int> onPaint;

  RepaintCounterPainter({required this.paintCount, required this.onPaint}) : super(repaint: onPaint);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal];
    const rows = 6;
    const cols = 8;
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final color = colors[(r + c) % colors.length].withAlpha(150);
        final paint = Paint()..color = color;
        final cx = cellW * c + cellW / 2;
        final cy = cellH * r + cellH / 2;

        if ((r + c).isEven) {
          canvas.drawCircle(Offset(cx, cy), min(cellW, cellH) * 0.35, paint);
        } else {
          final rect = Rect.fromCenter(
            center: Offset(cx, cy),
            width: cellW * 0.6,
            height: cellH * 0.6,
          );
          canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), paint);
        }

        // 渐变边框
        final borderPaint = Paint()
          ..color = colors[(r + c + 1) % colors.length].withAlpha(80)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        if ((r + c).isEven) {
          canvas.drawCircle(Offset(cx, cy), min(cellW, cellH) * 0.35, borderPaint);
        } else {
          final rect = Rect.fromCenter(
            center: Offset(cx, cy),
            width: cellW * 0.6,
            height: cellH * 0.6,
          );
          canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), borderPaint);
        }
      }
    }

    // 重绘计数器
    final tp = TextPainter(
      text: TextSpan(
        text: 'paint() 调用: $paintCount 次',
        style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, size.height - tp.height - 12, tp.width + 16, tp.height + 8),
      const Radius.circular(6),
    );
    canvas.drawRRect(bgRect, Paint()..color = Colors.white.withAlpha(220));
    tp.paint(canvas, Offset(16, size.height - tp.height - 8));
  }

  @override
  bool shouldRepaint(RepaintCounterPainter old) {
    // Always repaint when paintCount changes — ensures we see real repaint count
    return true;
  }
}
