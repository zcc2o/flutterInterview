import 'package:flutter/material.dart';
import 'models/auth_repo.dart';

class ServiceLocator {
  static final _instances = <Type, Object>{};
  static final _factories = <Type, Object Function()>{};

  static void registerSingleton<T extends Object>(T instance) {
    _instances[T] = instance;
  }

  static void registerLazy<T extends Object>(T Function() factory) {
    _factories[T] = factory;
  }

  static T get<T extends Object>() {
    if (_instances.containsKey(T)) return _instances[T] as T;
    if (_factories.containsKey(T)) {
      final instance = _factories[T]!() as T;
      _instances[T] = instance;
      return instance;
    }
    throw StateError('$T not registered');
  }

  static void reset() {
    _instances.clear();
    _factories.clear();
  }
}

void setupLocator() {
  ServiceLocator.registerSingleton<AuthRepo>(AuthRepoImpl());
  ServiceLocator.registerLazy<AuthService>(() => AuthService(ServiceLocator.get<AuthRepo>()));
}

class ServiceLocatorDemo extends StatefulWidget {
  const ServiceLocatorDemo({super.key});

  @override
  State<ServiceLocatorDemo> createState() => _ServiceLocatorDemoState();
}

class _ServiceLocatorDemoState extends State<ServiceLocatorDemo> {
  String _result = '';
  bool _loading = false;

  Future<void> _test() async {
    setState(() => _loading = true);
    setupLocator();
    final service = ServiceLocator.get<AuthService>();
    final ok = await service.login('admin', '123');
    setState(() {
      _loading = false;
      _result = ok ? '登录成功 — 通过全局 ServiceLocator 获取' : '登录失败';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('全局注册表按类型存取实例，支持 singleton 和 lazy 两种模式。解耦但引入隐式依赖。'),
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
