import 'package:flutter/material.dart';
import 'package:interview_widgets/interview_widgets.dart';
import '../src/without_boundary_demo.dart';
import '../src/with_boundary_demo.dart';

class RepaintBoundaryScreen extends StatefulWidget {
  const RepaintBoundaryScreen({super.key});

  @override
  State<RepaintBoundaryScreen> createState() => _RepaintBoundaryScreenState();
}

class _RepaintBoundaryScreenState extends State<RepaintBoundaryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _paintNotifier = ValueNotifier<int>(0);
  int _paintCount = 0;
  bool _running = false;
  Duration _elapsed = Duration.zero;
  int _finalPaintCount = 0;
  final _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _ctrl.addListener(_onTick);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTick);
    _ctrl.dispose();
    _paintNotifier.dispose();
    super.dispose();
  }

  void _onTick() {
    _paintNotifier.value = ++_paintCount;
  }

  void _toggle() {
    setState(() {
      if (_running) {
        _ctrl.stop();
        _stopwatch.stop();
        _elapsed = _stopwatch.elapsed;
        _finalPaintCount = _paintCount;
      } else {
        _paintCount = 0;
        _paintNotifier.value = 0;
        _finalPaintCount = 0;
        _elapsed = Duration.zero;
        _stopwatch
          ..reset()
          ..start();
        _ctrl.repeat();
      }
      _running = !_running;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TechDetailShell(
      title: 'RepaintBoundary 优化',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 说明卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RepaintBoundary 原理',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Flutter 中父 Widget 重绘时，子 Widget 默认也会重绘。\n'
                    'RepaintBoundary 创建一个独立的绘制层，将子树与父级重绘隔离。\n'
                    '下方的复杂图案渲染需要 48 个图形 + 48 个边框，共 96 次 Canvas 调用。\n'
                    '有 RepaintBoundary 时，旋转动画不会触发复杂图案的重绘。',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _toggle,
                icon: Icon(_running ? Icons.stop : Icons.play_arrow),
                label: Text(_running ? '停止' : '开始动画'),
              ),
              if (!_running && _elapsed > Duration.zero) ...[
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => setState(() {
                    _paintCount = 0;
                    _paintNotifier.value = 0;
                    _finalPaintCount = 0;
                    _elapsed = Duration.zero;
                  }),
                  child: const Text('重置'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // 并排对比
          Row(
            children: [
              Expanded(
                child: WithoutBoundaryDemo(
                  paintCount: _paintCount,
                  animation: _ctrl,
                  repaintNotifier: _paintNotifier,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: WithBoundaryDemo(animation: _ctrl)),
            ],
          ),
          const SizedBox(height: 16),

          // 统计结果
          if (!_running && _elapsed > Duration.zero) ...[
            _StatsCard(
              elapsed: _elapsed,
              paintCount: _finalPaintCount,
              estimatedSavings: _finalPaintCount * 96,
            ),
          ],
          const SizedBox(height: 16),

          // 使用指南
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('使用指南', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const _GuideRow('1.', '点击「开始动画」观察两侧变化'),
                  const _GuideRow('2.', '左侧无 RepaintBoundary：paint() 每帧都在增长'),
                  const _GuideRow('3.', '右侧有 RepaintBoundary：paint() 始终为 1 次'),
                  const _GuideRow('4.', '点击停止，查看底部节省的 Canvas 调用次数'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withAlpha(50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '总结：将不随动画变化的重 Widget 用 RepaintBoundary 包裹，'
                      '可显著减少不必要的重绘，降低 GPU 负载。',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final Duration elapsed;
  final int paintCount;
  final int estimatedSavings;

  const _StatsCard({
    required this.elapsed,
    required this.paintCount,
    required this.estimatedSavings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(60),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('统计结果', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _StatRow('运行时长', '${elapsed.inMilliseconds} ms'),
            _StatRow('无 RepaintBoundary 侧 paint() 次数', '$paintCount 次'),
            const _StatRow('有 RepaintBoundary 侧 paint() 次数', '仅 1 次'),
            _StatRow('节省的 Canvas 操作', '≈ $estimatedSavings 次'),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideRow extends StatelessWidget {
  final String num;
  final String text;
  const _GuideRow(this.num, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            num,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
