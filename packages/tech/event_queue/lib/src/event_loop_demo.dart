import 'dart:async';
import 'package:flutter/material.dart';

class EventLoopDemo extends StatefulWidget {
  const EventLoopDemo({super.key});

  @override
  State<EventLoopDemo> createState() => _EventLoopDemoState();
}

class _EventLoopDemoState extends State<EventLoopDemo> {
  final _log = <String>[];
  bool _running = false;

  void _run() {
    setState(() {
      _log.clear();
      _running = true;
    });

    _addLog('同步 start');

    // 事件队列
    Future(() => _addLog('Future #1 (事件队列)'));
    Future(() => _addLog('Future #2 (事件队列)'));

    // 微任务
    Future.microtask(() => _addLog('Future.microtask #1'));
    scheduleMicrotask(() => _addLog('scheduleMicrotask #1'));
    Future.microtask(() => _addLog('Future.microtask #2'));
    scheduleMicrotask(() => _addLog('scheduleMicrotask #2'));

    // 嵌套微任务中的微任务
    scheduleMicrotask(() {
      _addLog('外层 microtask');
      scheduleMicrotask(() => _addLog('  内层 microtask (插队)'));
    });

    // Future 链式
    Future.value(1)
        .then((v) => _addLog('Future.then (微任务)'))
        .then((_) => _addLog('Future.then 链式'));

    // Timer
    Timer.run(() => _addLog('Timer.run (事件队列)'));

    _addLog('同步 end');

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _running = false);
    });
  }

  void _addLog(String msg) {
    if (!mounted) return;
    setState(() => _log.add(msg));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('演示同步代码→微任务队列→事件队列的完整执行顺序。Future.then 也是微任务。'),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton.tonal(
              onPressed: _running ? null : _run,
              child: const Text('运行演示'),
            ),
            if (_running) const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text('运行中...', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ),
          ],
        ),
        if (_log.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _log.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '${e.key + 1}. ${e.value}',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              )).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
