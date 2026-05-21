import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:interview_widgets/interview_widgets.dart';
import '../src/precise_timer.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  final _timer = PreciseTimer();
  Duration _tickerElapsed = Duration.zero;
  late final Ticker _ticker;

  bool _running = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (mounted) setState(() => _tickerElapsed = elapsed);
    });
    _ticker.start();

    macroTask();
  }

  @override
  void dispose() {
    _timer.dispose();
    _ticker.dispose();
    super.dispose();
  }

  String _fmt(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:'
      '${(d.inSeconds % 60).toString().padLeft(2, '0')}.'
      '${(d.inMilliseconds % 1000).toString().padLeft(3, '0')}';

  void _start() {
    _timer.start();
    _timer.timerCallback((_) {
      if (mounted) setState(() {});
    });
    setState(() => _running = true);
  }

  void _stop() {
    _timer.stop();

    debugPrint('_timer: ${_timer.elapsed}  _tickerElapsed: $_tickerElapsed');

    setState(() => _running = false);
  }

  void _reset() {
    _timer.reset();
    setState(() {});
  }

  void _blockUI() {
    final deadline = DateTime.now().add(const Duration(seconds: 2));
    while (DateTime.now().isBefore(deadline)) {}
    setState(() {});
  }

  void macroTask() {
    Future.delayed(
      Duration.zero,
      () => print('事件队列'),
    ).then((_) => print('微任务队列: then() 回调'));
    scheduleMicrotask(() => print('手动微任务'));
  }

  @override
  Widget build(BuildContext context) {
    return TechDetailShell(
      title: 'Timer vs Ticker 精度对比',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildRow(
              'Timer.periodic(16ms)',
              '每16ms读 Stopwatch.elapsed → setState',
              _fmt(_timer.elapsed),
              '挂钟触发，有事件循环抖晃',
            ),
            const Divider(height: 32),
            _buildRow(
              'Ticker',
              '每帧回调读 elapsed 参数 → setState',
              _fmt(_tickerElapsed),
              '帧同步触发，无抖晃',
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: _running ? null : _start,
                  child: const Text('开始'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(onPressed: _stop, child: const Text('停止')),
                const SizedBox(width: 12),
                OutlinedButton(onPressed: _reset, child: const Text('重置')),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _running ? _blockUI : null,
              icon: const Icon(Icons.warning),
              label: const Text('阻塞 UI 2 秒'),
              style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            ),
            const SizedBox(height: 16),
            const Text(
              '阻塞后两者显示的时间都准确，\n'
              '但 Timer 有事件循环抖晃，Ticker 帧同步更平滑',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String hint, String value, String note) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hint,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 36, fontFamily: 'monospace'),
        ),
        const SizedBox(height: 2),
        Text(
          note,
          style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
        ),
      ],
    );
  }
}
