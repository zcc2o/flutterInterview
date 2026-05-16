import 'dart:math';
import 'package:flutter/material.dart';
import 'package:interview_widgets/interview_widgets.dart';

class AnimationScreen extends StatefulWidget {
  const AnimationScreen({super.key});

  @override
  State<AnimationScreen> createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen>
    with TickerProviderStateMixin {
  // 显式动画
  late final AnimationController _scaleCtrl;
  late final AnimationController _rotateCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _rotateAnim;

  // 隐式动画
  double _implicitSize = 100;
  double _implicitRadius = 0;
  Color _implicitColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    );

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _rotateAnim = Tween<double>(begin: 0, end: 2 * pi).animate(_rotateCtrl);
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TechDetailShell(
      title: '动画方案',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 隐式动画
          Text('1. 隐式动画 (AnimatedXxx)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: _implicitSize,
              height: _implicitSize,
              decoration: BoxDecoration(
                color: _implicitColor,
                borderRadius: BorderRadius.circular(_implicitRadius),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () => setState(() {
                  _implicitSize = _implicitSize == 100 ? 150 : 100;
                  _implicitRadius = _implicitRadius == 0 ? 24 : 0;
                  _implicitColor = _implicitColor == Colors.blue ? Colors.pink : Colors.blue;
                }),
                child: const Text('切换形态'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 显式动画
          Text('2. 显式动画 (AnimationController)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Center(
            child: ScaleTransition(
              scale: _scaleAnim,
              child: RotationTransition(
                turns: _rotateAnim,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(onPressed: _scaleCtrl.stop, child: const Text('暂停')),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => _scaleCtrl.isAnimating ? _scaleCtrl.stop() : _scaleCtrl.repeat(reverse: true),
                  child: const Text('播放'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Hero 动画说明
          Text('3. Hero 动画', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Hero(tag: 'demo1', child: Container(width: 50, height: 50, color: Colors.orange)),
              const SizedBox(width: 8),
              Hero(tag: 'demo2', child: Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(25)))),
              const SizedBox(width: 8),
              Hero(tag: 'demo3', child: const Icon(Icons.star, size: 50, color: Colors.amber)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('跨页面共享 element 的过渡动画。相同 tag 的 Widget 在路由切换时自动产生飞入效果。'),
          const SizedBox(height: 32),

          // TweenAnimationBuilder
          Text('4. TweenAnimationBuilder', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          const _TweenDemo(),
          const SizedBox(height: 32),

          // 总结
          Text('5. 动画方案对比', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          const Text('• 隐式动画 (AnimatedXxx)：自动管理 Controller，适合简单属性过渡\n'
              '• 显式动画 (AnimationController)：精确控制，适合复杂动画序列\n'
              '• Hero：跨页面共享元素过渡\n'
              '• TweenAnimationBuilder：轻量级 Tween 动画，无需手动管理\n'
              '• 交错动画：Interval + 多个 Tween，时序编排\n'
              '• AnimatedList：列表项的插入/删除动画'),
        ],
      ),
    );
  }
}

class _TweenDemo extends StatefulWidget {
  const _TweenDemo();

  @override
  State<_TweenDemo> createState() => _TweenDemoState();
}

class _TweenDemoState extends State<_TweenDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double _target = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: _target),
          duration: const Duration(seconds: 1),
          curve: Curves.easeOutBack,
          builder: (context, value, _) => LinearProgressIndicator(value: value),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [0.25, 0.5, 0.75, 1.0].map((v) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ActionChip(
              label: Text('${(v * 100).toInt()}%'),
              onPressed: () => setState(() => _target = v),
            ),
          )).toList(),
        ),
      ],
    );
  }
}
