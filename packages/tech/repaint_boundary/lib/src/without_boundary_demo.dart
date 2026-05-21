import 'dart:math';
import 'package:flutter/material.dart';

class WithoutBoundaryDemo extends StatelessWidget {
  final int paintCount;
  final Animation<double> animation;
  final ValueNotifier<int> repaintNotifier;

  const WithoutBoundaryDemo({
    super.key,
    required this.paintCount,
    required this.animation,
    required this.repaintNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.shade300, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
                child: const Text(
                  '无 RepaintBoundary',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    // 复杂静态绘制 — 动画触发父级重绘，此 CustomPaint 被连带 repaint
                    CustomPaint(
                      painter: _WithoutBoundaryPainter(paintCount),
                      size: Size.infinite,
                    ),
                    // 旋转动画
                    Positioned(
                      top: 8,
                      right: 8,
                      child: AnimatedBuilder(
                        animation: animation,
                        builder: (_, __) => Transform.rotate(
                          angle: animation.value * 2 * 3.14159,
                          child: const Icon(Icons.sync, size: 28, color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WithoutBoundaryPainter extends CustomPainter {
  final int paintCount;
  _WithoutBoundaryPainter(this.paintCount);

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
          final rect = Rect.fromCenter(center: Offset(cx, cy), width: cellW * 0.6, height: cellH * 0.6);
          canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), paint);
        }

        final borderPaint = Paint()
          ..color = colors[(r + c + 1) % colors.length].withAlpha(80)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        if ((r + c).isEven) {
          canvas.drawCircle(Offset(cx, cy), min(cellW, cellH) * 0.35, borderPaint);
        } else {
          final rect = Rect.fromCenter(center: Offset(cx, cy), width: cellW * 0.6, height: cellH * 0.6);
          canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), borderPaint);
        }
      }
    }

    final tp = TextPainter(
      text: TextSpan(
        text: 'paint() 调用: $paintCount 次',
        style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, size.height - tp.height - 12, tp.width + 16, tp.height + 8),
        const Radius.circular(6),
      ),
      Paint()..color = Colors.white.withAlpha(220),
    );
    tp.paint(canvas, Offset(16, size.height - tp.height - 8));
  }

  @override
  bool shouldRepaint(covariant _WithoutBoundaryPainter old) => true;
}
