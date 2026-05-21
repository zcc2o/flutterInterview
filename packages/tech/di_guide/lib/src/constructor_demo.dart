import 'package:flutter/material.dart';
import 'models/auth_repo.dart';

class ConstructorDemo extends StatefulWidget {
  const ConstructorDemo({super.key});

  @override
  State<ConstructorDemo> createState() => _ConstructorDemoState();
}

class _ConstructorDemoState extends State<ConstructorDemo> {
  String _result = '';
  bool _loading = false;

  Future<void> _test() async {
    setState(() => _loading = true);
    final service = AuthService(AuthRepoImpl());
    final ok = await service.login('admin', '123');
    setState(() {
      _loading = false;
      _result = ok ? '登录成功 — 依赖通过构造函数传入' : '登录失败';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AuthService 依赖 AuthRepo 接口，具体实现通过构造函数传入，方便替换为 Mock 进行测试。'),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton.tonal(onPressed: _loading ? null : _test, child: const Text('测试')),
            if (_loading) const Padding(
              padding: EdgeInsets.only(left: 12),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ],
        ),
        if (_result.isNotEmpty) Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(_result, style: TextStyle(color: _result.contains('成功') ? Colors.green : Colors.red)),
        ),
      ],
    );
  }
}
