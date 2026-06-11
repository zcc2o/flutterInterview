import 'dart:math';
import 'package:flutter/material.dart';
import 'package:interview_widgets/interview_widgets.dart';
import '../src/microtask_demo.dart';
import '../src/event_loop_demo.dart';
import '../src/execution_order_demo.dart';

class EventQueueScreen extends StatelessWidget {
  const EventQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TechDetailShell(
      title: '微任务与事件队列',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Section(title: '事件循环模型', child: _EventLoopDiagram()),
          _Section(title: 'Microtask 微任务', child: MicrotaskDemo()),
          _Section(title: '事件循环 (Event + Microtask)', child: EventLoopDemo()),
          _Section(title: '综合执行顺序', child: ExecutionOrderDemo()),
          _Section(title: '核心概念总结', child: _ConceptTable()),
        ],
      ),
    );
  }
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

class _EventLoopDiagram extends StatelessWidget {
  const _EventLoopDiagram();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomPaint(
          painter: _LoopPainter(),
          size: const Size(double.infinity, 200),
        ),
        const SizedBox(height: 8),
        const Text(
          'Dart 单线程模型：同步代码 → 清空微任务 → 取出一个事件 → 清空微任务 → ...',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}

class _LoopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const center = Offset(120, 100);
    const r = 70.0;

    // 主循环圆
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = Colors.grey.shade200
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // 标签
    _drawLabel(
      canvas,
      '同步代码\nexecute',
      Offset(center.dx, center.dy - 55),
      Colors.blue,
    );
    _drawLabel(
      canvas,
      'Microtask\nQueue',
      Offset(center.dx, center.dy + 45),
      Colors.teal,
    );
    _drawLabel(
      canvas,
      'Event Queue\n(Future/Timer)',
      Offset(center.dx + 140, center.dy - 10),
      Colors.orange,
    );

    // 箭头
    final arrowPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.5;
    final p1 = Offset(
      center.dx + r * cos(-pi / 2),
      center.dy + r * sin(-pi / 2),
    );
    final p2 = Offset(center.dx + r * cos(pi / 2), center.dy + r * sin(pi / 2));
    canvas.drawLine(p1, p2, arrowPaint);

    // 右侧事件队列
    final eqX = center.dx + 120;
    for (int i = 0; i < 4; i++) {
      final y = 40.0 + i * 28;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(eqX, y, 100, 20),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = Colors.orange.shade50
          ..style = PaintingStyle.fill,
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = Colors.orange.shade200
          ..style = PaintingStyle.stroke,
      );
    }

    // 微任务队列
    for (int i = 0; i < 3; i++) {
      final y = center.dy + 60 + i * 20;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 60, y, 120, 16),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = Colors.teal.shade50
          ..style = PaintingStyle.fill,
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = Colors.teal.shade200
          ..style = PaintingStyle.stroke,
      );
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset pos, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _ConceptTable extends StatelessWidget {
  const _ConceptTable();

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('同步代码', 'main(), build(), initState()', '第一轮执行，阻塞线程'),
      (
        'Microtask',
        'scheduleMicrotask,\nFuture.microtask, .then',
        '同步代码后、事件前执行，可插队',
      ),
      ('Event Queue', 'Future(), Timer.run(),\nI/O, 手势', '微任务清空后才处理下一个事件'),
      ('事件循环', '-', '执行事件 → 清空微任务 → 执行下一个事件'),
      ('Isolate', 'Isolate.spawn()', '真正的多线程，独立内存，通过 Port 通信'),
    ];
    return Table(
      border: TableBorder.all(color: Theme.of(context).dividerColor),
      columnWidths: const {
        0: FixedColumnWidth(80),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
      },
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
          children: [_Th('概念'), _Th('API / 来源'), _Th('执行时机')],
        ),
        ...rows.map(
          (r) => TableRow(children: [_Td(r.$1), _Td(r.$2), _Td(r.$3)]),
        ),
      ],
    );
  }
}

class _Th extends StatelessWidget {
  final String text;
  const _Th(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
