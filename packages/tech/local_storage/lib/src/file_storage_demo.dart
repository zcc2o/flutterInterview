import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileStorageDemo extends StatefulWidget {
  const FileStorageDemo({super.key});

  @override
  State<FileStorageDemo> createState() => _FileStorageDemoState();
}

class _FileStorageDemoState extends State<FileStorageDemo> {
  String _output = '点击按钮开始测试';
  bool _loading = false;

  Future<void> _test() async {
    setState(() => _loading = true);
    final sw = Stopwatch()..start();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/interview_demo.json');

    final data = {
      'timestamp': DateTime.now().toIso8601String(),
      'message': 'File I/O Demo',
      'items': ['apple', 'banana', 'cherry'],
    };

    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));

    final exists = await file.exists();
    final content = exists ? await file.readAsString() : '';
    final decoded = exists ? jsonDecode(content) : null;

    final buf = StringBuffer();
    buf.writeln('文件操作 (${sw.elapsedMilliseconds}ms)：');
    buf.writeln('  路径: ${file.path}');
    buf.writeln('  存在: $exists');
    buf.writeln('  大小: ${content.length} bytes');
    buf.writeln('  写入: ${data['message']}');
    buf.writeln('  读取 items: ${decoded?['items']}');

    setState(() {
      _loading = false;
      _output = buf.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('通过 path_provider 获取应用文档目录，进行 JSON 文件的读写操作。'),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton.tonal(onPressed: _loading ? null : _test, child: const Text('测试文件读写')),
            if (_loading) const Padding(
              padding: EdgeInsets.only(left: 12),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(_output, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
        ),
      ],
    );
  }
}
