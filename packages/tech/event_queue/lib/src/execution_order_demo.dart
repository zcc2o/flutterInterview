import 'dart:async';
import 'package:flutter/material.dart';

class ExecutionOrderDemo extends StatefulWidget {
  const ExecutionOrderDemo({super.key});

  @override
  State<ExecutionOrderDemo> createState() => _ExecutionOrderDemoState();
}

class _ExecutionOrderDemoState extends State<ExecutionOrderDemo> {
  final _log = <String>[];

  void _run() {
    setState(() => _log.clear());

    _logMsg('=== 综合执行顺序测试 ===');

    _logMsg('A: 同步代码块');

    Future(() => _logMsg('C: Future (事件队列)'));
    scheduleMicrotask(() => _logMsg('B: scheduleMicrotask (微任务)'));
    Future.microtask(() => _logMsg('B2: Future.microtask (微任务)'));

    Future.delayed(Duration.zero, () => _logMsg('D: Future.delayed(零延迟, 事件队列)'));

    // 微任务中插入微任务
    scheduleMicrotask(() {
      _logMsg('B3: 微任务-1');
      scheduleMicrotask(() => _logMsg('B4: 微任务-1-1 (嵌套插队)'));
    });

    // Future 链式触发微任务
    Future.value(1).then((_) {
      _logMsg('B5: Future.then (微任务回调)');
      return Future.value(2);
    }).then((v) {
      _logMsg('B6: Future.then 链式 v=$v');
    });

    _logMsg('A: 同步代码结束');

    // 新的事件中再排微任务
    Future(() {
      _logMsg('E: 第二个事件循环');
      scheduleMicrotask(() => _logMsg('F: 事件内的微任务'));
    });
  }

  void _logMsg(String msg) {
    if (!mounted) return;
    setState(() => _log.add(msg));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('综合演示：同步代码执行完毕 → 清空微任务队列 → 取出一个事件 → 再清空微任务队列 → ...'),
        const SizedBox(height: 12),
        FilledButton.tonal(onPressed: _run, child: const Text('运行综合演示')),
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
                child: Text(
                  l,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: l.startsWith('A:') ? Colors.blue.shade700 : l.startsWith('B') ? Colors.teal.shade700 : l.startsWith('C:') || l.startsWith('D:') || l.startsWith('E:') || l.startsWith('F:') ? Colors.orange.shade700 : Colors.black87,
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
