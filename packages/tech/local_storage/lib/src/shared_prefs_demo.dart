import 'package:flutter/material.dart';
import 'storage_service.dart';

class SharedPrefsDemo extends StatefulWidget {
  const SharedPrefsDemo({super.key});

  @override
  State<SharedPrefsDemo> createState() => _SharedPrefsDemoState();
}

class _SharedPrefsDemoState extends State<SharedPrefsDemo> {
  final _service = StorageService();
  String _output = '点击按钮开始测试';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _service.init();
  }

  Future<void> _test() async {
    setState(() => _loading = true);
    final sw = Stopwatch()..start();

    await _service.setString('name', 'Flutter');
    await _service.setInt('count', 42);
    await _service.setBool('enabled', true);

    final name = _service.getString('name');
    final count = _service.getInt('count');
    final enabled = _service.getBool('enabled');
    final keys = _service.getKeys();

    final buf = StringBuffer();
    buf.writeln('读取所有键值 (${sw.elapsedMilliseconds}ms)：');
    buf.writeln('  Keys: $keys');
    buf.writeln('  name: $name');
    buf.writeln('  count: $count');
    buf.writeln('  enabled: $enabled');

    await _service.remove('name');
    buf.writeln('  删除 name 后: ${_service.getString('name') ?? "null"}');

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
        const Text('基于 StorageService 封装的读写操作，支持 String / int / bool 类型。'),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton.tonal(onPressed: _loading ? null : _test, child: const Text('测试读写')),
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
