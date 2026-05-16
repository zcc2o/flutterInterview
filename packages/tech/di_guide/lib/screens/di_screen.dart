import 'package:flutter/material.dart';
import 'package:interview_widgets/interview_widgets.dart';

// ---------- 1. 构造函数注入 ----------
abstract class AuthRepo {
  Future<bool> login(String user, String pwd);
}

class AuthRepoImpl implements AuthRepo {
  @override
  Future<bool> login(String user, String pwd) async => user == 'admin' && pwd == '123';
}

class AuthService {
  final AuthRepo repo;
  const AuthService(this.repo);

  Future<bool> authenticate(String user, String pwd) => repo.login(user, pwd);
}

// ---------- 2. Service Locator ----------
class ServiceLocator {
  static final _instances = <Type, Object>{};

  static void register<T>(T instance) => _instances[T] = instance as Object;
  static T get<T>() => _instances[T] as T;
}

void setupDi() {
  ServiceLocator.register<AuthRepo>(AuthRepoImpl());
  ServiceLocator.register<AuthService>(AuthService(ServiceLocator.get<AuthRepo>()));
}

class DiScreen extends StatefulWidget {
  const DiScreen({super.key});

  @override
  State<DiScreen> createState() => _DiScreenState();
}

class _DiScreenState extends State<DiScreen> {
  String _result = '';

  void _testConstructorInjection() async {
    final svc = AuthService(AuthRepoImpl());
    final ok = await svc.authenticate('admin', '123');
    setState(() => _result = '构造函数注入: ${ok ? "✅ 通过" : "❌ 失败"}');
  }

  void _testServiceLocator() async {
    setupDi();
    final svc = ServiceLocator.get<AuthService>();
    final ok = await svc.authenticate('admin', '123');
    setState(() => _result = 'Service Locator: ${ok ? "✅ 通过" : "❌ 失败"}');
  }

  @override
  Widget build(BuildContext context) {
    return TechDetailShell(
      title: '依赖注入方案',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('1. 构造函数注入', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('将依赖通过构造函数传入，依赖倒置原则（DIP）的基础实现。'
                      '接口 AuthRepo → 实现 AuthRepoImpl → 消费方 AuthService。'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _testConstructorInjection,
                    child: const Text('测试构造函数注入'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('2. Service Locator', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('全局 Map<Type, Object> 注册表。简单直接，但隐藏依赖关系。'
                      '适合简单项目，复杂项目中推荐使用 get_it / injectable。'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _testServiceLocator,
                    child: const Text('测试 Service Locator'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('3. 方案对比', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  const Text('构造注入：✅ 依赖显式、✅ 可测试、⚠️ 层级深时参数传递冗长\n\n'
                      'Service Locator：✅ 获取方便、⚠️ 隐藏依赖、⚠️ 运行时错误\n\n'
                      'Provider（包级变量覆盖）：✅ 符合 Flutter 习惯、✅ widget 树感知\n\n'
                      'get_it：✅ 注解+代码生成、✅ 支持单例/工厂/lazy\n\n'
                      'Riverpod：✅ 编译安全、✅ 可覆写、✅ 测试隔离'),
                ],
              ),
            ),
          ),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(child: Text(_result, style: const TextStyle(fontSize: 18))),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
