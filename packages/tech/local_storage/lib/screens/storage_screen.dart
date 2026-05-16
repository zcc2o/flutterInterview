import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interview_widgets/interview_widgets.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  String _spResult = '';
  String _fileResult = '';
  String _fileContent = '';

  // ---------- SharedPreferences ----------
  Future<void> _testSharedPreferences() async {
    final sp = await SharedPreferences.getInstance();
    final key = 'interview_key';

    // 写入
    await sp.setString(key, 'Hello at ${DateTime.now().toIso8601String()}');
    await sp.setInt('counter', (sp.getInt('counter') ?? 0) + 1);

    // 读取
    final value = sp.getString(key);
    final counter = sp.getInt('counter');
    final keys = sp.getKeys();

    setState(() => _spResult = 'Keys: $keys\n'
        'counter: $counter\n'
        'value: $value');
  }

  // ---------- 文件读写 ----------
  Future<void> _testFileStorage() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/interview_demo.txt');

    // 写入
    final data = {
      'timestamp': DateTime.now().toIso8601String(),
      'message': '文件存储演示',
      'items': ['Flutter', 'Dart', 'GoRouter'],
    };
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));

    // 读取
    final exists = await file.exists();
    final size = exists ? await file.length() : 0;
    final content = exists ? await file.readAsString() : '';
    final path = file.path;

    setState(() {
      _fileResult = '路径: $path\n大小: $size bytes\n存在: $exists';
      _fileContent = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TechDetailShell(
      title: '本地存储方案',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SharedPreferences
          Text('1. SharedPreferences', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('适用于：键值对存储，如设置项、Token、简单标记\n'
              '⚠️ 不适合大量数据，iOS 上基于 plist'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _testSharedPreferences,
            icon: const Icon(Icons.settings),
            label: const Text('读写 SharedPreferences'),
          ),
          if (_spResult.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_spResult, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
              ),
            ),
          ],
          const SizedBox(height: 32),

          // 文件存储
          Text('2. 文件存储 (dart:io)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('适用于：较大数据、JSON 文件、用户生成内容、日志\n'
              '路径通过 path_provider 获取应用沙盒目录'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _testFileStorage,
            icon: const Icon(Icons.folder),
            label: const Text('读写文件'),
          ),
          if (_fileResult.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_fileResult, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
                    if (_fileContent.isNotEmpty) ...[
                      const Divider(),
                      Text(_fileContent, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),

          // 方案对比
          Text('3. 存储方案对比', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          const _CompareCard(
            name: 'SharedPreferences',
            scenario: '键值对、设置项',
            pros: 'API 简单，Android/iOS 原生实现',
            cons: '不适合复杂数据，多次读写性能差',
          ),
          const _CompareCard(
            name: '文件存储',
            scenario: 'JSON、日志、缓存文件',
            pros: '灵活，支持任意格式',
            cons: '需手动序列化/反序列化',
          ),
          const _CompareCard(
            name: 'Hive',
            scenario: '结构化数据、离线缓存',
            pros: '纯 Dart 实现，速度快，支持加密',
            cons: '需要生成 Adapter，schema 变更需迁移',
          ),
          const _CompareCard(
            name: 'sqflite',
            scenario: '关系型查询、复杂筛选',
            pros: 'SQL 支持，事务，复杂查询',
            cons: '表结构需提前定义，迁移管理',
          ),
          const _CompareCard(
            name: 'Drift',
            scenario: '类型安全的 ORM',
            pros: '编译时检查，流式查询',
            cons: '代码生成较重',
          ),
        ],
      ),
    );
  }
}

class _CompareCard extends StatelessWidget {
  final String name;
  final String scenario;
  final String pros;
  final String cons;

  const _CompareCard({
    required this.name,
    required this.scenario,
    required this.pros,
    required this.cons,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Chip(label: Text(scenario, style: const TextStyle(fontSize: 11))),
            ]),
            Text('✅ $pros\n⚠️ $cons', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
