import 'package:flutter/material.dart';
import 'package:interview_widgets/interview_widgets.dart';
import '../src/constructor_demo.dart';
import '../src/service_locator_demo.dart';
import '../src/provider_demo.dart';

class DiScreen extends StatelessWidget {
  const DiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TechDetailShell(
      title: '依赖注入方案',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Section(title: '构造函数注入', child: ConstructorDemo()),
          _Section(title: 'Service Locator', child: ServiceLocatorDemo()),
          _Section(title: 'ChangeNotifier 模式', child: ProviderDemo()),
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
      ('构造注入', '✅ 依赖显式', '⚠️ 层级深时传参冗长', '简单对象图'),
      ('Service Locator', '✅ 获取方便', '⚠️ 隐式依赖，运行时错误', '中小型项目'),
      ('Provider', '✅ Flutter 习惯', '⚠️ 需 BuildContext', 'Widget 树感知的场景'),
      ('get_it', '✅ 注解+代码生成', '⚠️ 依赖代码生成', '大型项目'),
      ('Riverpod', '✅ 编译安全，可覆写', '⚠️ 学习成本高', '需测试隔离的场景'),
    ];
    return Table(
      border: TableBorder.all(color: Theme.of(context).dividerColor),
      columnWidths: const {
        0: FixedColumnWidth(100),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
        3: FixedColumnWidth(100),
      },
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
          children: [
            _Th('方案'),
            _Th('优势'),
            _Th('劣势'),
            _Th('适用场景'),
          ],
        ),
        ...rows.map(
          (r) => TableRow(children: [_Td(r.$1), _Td(r.$2), _Td(r.$3), _Td(r.$4)]),
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
