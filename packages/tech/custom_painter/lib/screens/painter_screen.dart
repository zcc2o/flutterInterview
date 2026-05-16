import 'dart:math';
import 'package:flutter/material.dart';
import 'package:interview_widgets/interview_widgets.dart';

// ---------- 饼图 Painter ----------
class PieChartPainter extends CustomPainter {
  final List<(Color color, double percent)> slices;

  PieChartPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    double startAngle = -pi / 2; // 从顶部开始

    for (final (color, percent) in slices) {
      final sweepAngle = percent * 2 * pi;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant PieChartPainter old) =>
      old.slices != slices;
}

// ---------- 波纹 Painter ----------
class RipplePainter extends CustomPainter {
  final double progress;

  RipplePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2;

    for (int i = 0; i < 3; i++) {
      final r = (progress + i * 0.33) % 1.0 * maxRadius;
      final opacity = 1 - (r / maxRadius);
      final paint = Paint()
        ..color = Colors.blue.withValues(alpha: opacity.clamp(0, 1))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RipplePainter old) =>
      old.progress != progress;
}

class PainterScreen extends StatefulWidget {
  const PainterScreen({super.key});

  @override
  State<PainterScreen> createState() => _PainterScreenState();
}

class _PainterScreenState extends State<PainterScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final _pieSlices = [
    (Colors.blue, 0.3),
    (Colors.red, 0.2),
    (Colors.green, 0.25),
    (Colors.orange, 0.15),
    (Colors.purple, 0.1),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TechDetailShell(
      title: '自定义绘制',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('1. 饼图 (CustomPainter)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: PieChartPainter(_pieSlices),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _pieSlices.map((s) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 12, height: 12, color: s.$1),
                  const SizedBox(width: 4),
                  Text('${(s.$2 * 100).toInt()}%', style: const TextStyle(fontSize: 12)),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 32),
          Text('2. 波纹动画 (自定义绘制 + Ticker)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => CustomPaint(
                painter: RipplePainter(_controller.value),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text('3. CustomPainter 核心 API', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          const Text('• paint(Canvas, Size) — 核心绘制方法\n'
              '• shouldRepaint() — 是否需要重绘（性能优化关键）\n'
              '• Canvas.drawRect / drawCircle / drawArc / drawPath\n'
              '• Paint — 画笔：颜色、样式（fill/stroke）、渐变、阴影\n'
              '• Path — 路径：moveTo、lineTo、quadraticBezierTo、cubicTo\n'
              '• ClipPath / ClipRRect / ClipOval — 裁剪\n'
              '• CustomPaint + RepaintBoundary — 隔离重绘区域'),
        ],
      ),
    );
  }
}
