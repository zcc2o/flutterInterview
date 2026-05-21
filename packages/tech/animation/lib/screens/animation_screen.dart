import 'package:flutter/material.dart';
import 'package:interview_widgets/interview_widgets.dart';
import '../src/implicit_anim_demo.dart';
import '../src/explicit_anim_demo.dart';
import '../src/hero_anim_demo.dart';
import '../src/staggered_anim_demo.dart';
import '../src/animated_list_demo.dart';

class AnimationScreen extends StatelessWidget {
  const AnimationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TechDetailShell(
      title: '动画方案',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Section(title: '隐式动画 (AnimatedXxx)', child: ImplicitAnimDemo()),
          _Section(title: '显式动画 (AnimationController)', child: ExplicitAnimDemo()),
          _Section(title: '交错动画 (Interval + 多 Tween)', child: StaggeredAnimDemo()),
          _Section(title: 'AnimatedList (列表增删动画)', child: AnimatedListDemo()),
          _Section(title: 'Hero 动画 (跨页面共享元素)', child: HeroAnimDemo()),
          _Section(title: '方案对比', child: _ComparisonTable()),
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

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable();

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('隐式动画', 'Animated* 系列', '自动插值，setState 触发', '简单属性过渡'),
      ('显式动画', 'AnimationController', '手动控制播放/方向', '需精细控制的动画'),
      ('Hero 动画', 'Hero widget', '跨页面共享元素过渡', '页面跳转过渡'),
      ('交错动画', 'Interval 曲线', '多动画按时间窗口依次播放', '组合动画'),
      ('TweenAnimation', 'TweenAnimationBuilder', '无需 Controller 的补间', '单次轻量动画'),
      ('AnimatedList', 'AnimatedList + Key', '列表项增删动画', '列表操作反馈'),
    ];
    return Table(
      border: TableBorder.all(color: Theme.of(context).dividerColor),
      columnWidths: const {
        0: FixedColumnWidth(90),
        1: FixedColumnWidth(130),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(),
      },
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
          children: [
            _Th('方案'),
            _Th('核心 API'),
            _Th('特点'),
            _Th('适用场景'),
          ],
        ),
        ...rows.map(
          (r) => TableRow(
            children: [
              _Td(r.$1),
              _Td(r.$2),
              _Td(r.$3),
              _Td(r.$4),
            ],
          ),
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
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
