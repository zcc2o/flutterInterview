import 'dart:math';
import 'package:flutter/material.dart';

class WithBoundaryDemo extends StatelessWidget {
  final Animation<double> animation;

  const WithBoundaryDemo({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green.shade500, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
                child: const Text(
                  '有 RepaintBoundary',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    // RepaintBoundary 隔离，动画不会触发此子树重绘
                    const RepaintBoundary(child: _StaticGrid()),
                    // 旋转动画独立重绘
                    Positioned(
                      top: 8,
                      right: 8,
                      child: AnimatedBuilder(
                        animation: animation,
                        builder: (_, __) => Transform.rotate(
                          angle: animation.value * 2 * 3.14159,
                          child: const Icon(Icons.sync, size: 28, color: Colors.green),
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

class _StaticGridPainter extends CustomPainter {
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
      text: const TextSpan(
        text: 'paint() 调用: 仅初始 1 次',
        style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
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
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _StaticGrid extends StatefulWidget {
  const _StaticGrid();

  @override
  State<_StaticGrid> createState() => _StaticGridState();
}

class _StaticGridState extends State<_StaticGrid> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StaticGridPainter(), size: Size.infinite);
  }
}
