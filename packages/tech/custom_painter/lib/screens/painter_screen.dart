import 'dart:math';
import 'package:flutter/material.dart';
import 'package:interview_widgets/interview_widgets.dart';
import '../src/pie_chart_painter.dart';
import '../src/clock_painter.dart';
import '../src/bezier_demo_painter.dart';
import '../src/clip_path_demo.dart';

class PainterScreen extends StatefulWidget {
  const PainterScreen({super.key});

  @override
  State<PainterScreen> createState() => _PainterScreenState();
}

class _PainterScreenState extends State<PainterScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rippleCtrl;
  late final AnimationController _bezierCtrl;
  late final AnimationController _clockCtrl;
  DateTime _now = DateTime.now();

  final _pieSlices = [
    ('Flutter', Colors.blue, 0.30),
    ('Dart', Colors.red, 0.25),
    ('Java', Colors.orange, 0.20),
    ('Kotlin', Colors.green, 0.15),
    ('Swift', Colors.purple, 0.10),
  ];

  @override
  void initState() {
    super.initState();
    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _bezierCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _clockCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat()
          ..addListener(() => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _rippleCtrl.dispose();
    _bezierCtrl.dispose();
    _clockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TechDetailShell(
      title: '自定义绘制',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: '饼图 (PieChartPainter)',
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: CustomPaint(
                    painter: PieChartPainter(slices: _pieSlices),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: _pieSlices
                      .map(
                        (s) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 12, height: 12, color: s.$2),
                            const SizedBox(width: 4),
                            Text(
                              '${s.$1} ${(s.$3 * 100).toInt()}%',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          _Section(
            title: '贝塞尔曲线 (cubicTo)',
            child: Column(
              children: [
                SizedBox(
                  height: 160,
                  child: AnimatedBuilder(
                    animation: _bezierCtrl,
                    builder: (_, __) => CustomPaint(
                      painter: BezierDemoPainter(progress: _bezierCtrl.value),
                    ),
                  ),
                ),
                const Text(
                  '红色点沿三阶贝塞尔曲线运动',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          _Section(
            title: '波纹动画 (CustomPainter + Ticker)',
            child: SizedBox(
              height: 160,
              child: AnimatedBuilder(
                animation: _rippleCtrl,
                builder: (_, __) =>
                    CustomPaint(painter: _RipplePainter(_rippleCtrl.value)),
              ),
            ),
          ),
          _Section(
            title: '时钟 (Canvas API 综合)',
            child: SizedBox(
              height: 200,
              child: CustomPaint(painter: ClockPainter(dateTime: _now)),
            ),
          ),
          const _Section(
            title: '路径裁剪 (ClipPath + CustomClipper)',
            child: ClipPathDemo(),
          ),
          _Section(
            title: '核心 API 参考',
            child: Table(
              border: TableBorder.all(color: Theme.of(context).dividerColor),
              columnWidths: const {
                0: FixedColumnWidth(110),
                1: FlexColumnWidth(),
              },
              children: const [
                TableRow(
                  children: [
                    _Td('paint(Canvas, Size)'),
                    _Td('核心绘制方法，所有绘制逻辑入口'),
                  ],
                ),
                TableRow(
                  children: [_Td('shouldRepaint()'), _Td('判断是否需要重绘，性能优化关键')],
                ),
                TableRow(
                  children: [
                    _Td('Canvas.draw*'),
                    _Td('drawRect/Circle/Arc/Path/Line 等绘制方法'),
                  ],
                ),
                TableRow(
                  children: [
                    _Td('Paint'),
                    _Td('颜色、样式(fill/stroke)、渐变、阴影、strokeWidth'),
                  ],
                ),
                TableRow(
                  children: [
                    _Td('Path'),
                    _Td('moveTo, lineTo, quadraticBezierTo, cubicTo'),
                  ],
                ),
                TableRow(
                  children: [
                    _Td('ClipPath'),
                    _Td('CustomClipper + ClipPath 实现路径裁剪'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress;
  _RipplePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2;
    for (int i = 0; i < 4; i++) {
      final r = (progress + i * 0.25) % 1.0 * maxRadius;
      final opacity = (1 - r / maxRadius).clamp(0.0, 1.0);
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = Colors.indigo.withAlpha((opacity * 255).toInt())
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter old) => progress != old.progress;
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Td extends StatelessWidget {
  final String text;
  const _Td(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(text, style: const TextStyle(fontSize: 11)),
    );
  }
}
