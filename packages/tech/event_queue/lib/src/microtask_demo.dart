import 'dart:async';
import 'package:flutter/material.dart';

class MicrotaskDemo extends StatefulWidget {
  const MicrotaskDemo({super.key});

  @override
  State<MicrotaskDemo> createState() => _MicrotaskDemoState();
}

class _MicrotaskDemoState extends State<MicrotaskDemo> {
  final _log = <String>[];

  void _run() {
    setState(() => _log.clear());

    _addLog('1. 同步代码开始');

    scheduleMicrotask(() => _addLog('3. scheduleMicrotask 执行'));

    Future.microtask(() => _addLog('2. Future.microtask 执行'));

    _addLog('4. 同步代码结束');

    // 稍后显示事件队列的 Future
    Future(() => _addLog('5. Future (事件队列) 执行'));
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
        const Text('scheduleMicrotask 和 Future.microtask 都在微任务队列执行，比事件队列的 Future 优先。'),
        const SizedBox(height: 12),
        FilledButton.tonal(onPressed: _run, child: const Text('运行演示')),
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
              children: _log.map((l) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(l, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              )).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
