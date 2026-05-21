import 'package:flutter/material.dart';
import 'package:interview_widgets/interview_widgets.dart';
import '../src/shared_prefs_demo.dart';
import '../src/file_storage_demo.dart';

class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TechDetailShell(
      title: '本地存储方案',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Section(title: 'SharedPreferences (键值对)', child: SharedPrefsDemo()),
          _Section(title: '文件存储 (dart:io + JSON)', child: FileStorageDemo()),
          _Section(title: '存储方案对比', child: _ComparisonTable()),
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
      ('SharedPreferences', '键值对，设置项', 'API 简单，原生实现', '不适用于复杂数据'),
      ('文件存储', 'JSON、日志、缓存', '灵活，任意格式', '手动序列化/反序列化'),
      ('Hive', '结构化数据，缓存', '纯 Dart，快，加密', '需要 Adapter 生成'),
      ('sqflite', '关系型查询', 'SQL、事务、复杂查询', '表结构预先定义'),
      ('Drift', '类型安全 ORM', '编译检查，流查询', '代码生成较重'),
    ];
    return Table(
      border: TableBorder.all(color: Theme.of(context).dividerColor),
      columnWidths: const {
        0: FixedColumnWidth(110),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(),
      },
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
          children: [
            _Th('方案'),
            _Th('适用场景'),
            _Th('优势'),
            _Th('劣势'),
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
