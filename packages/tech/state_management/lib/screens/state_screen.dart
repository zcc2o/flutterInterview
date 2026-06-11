import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_widgets/interview_widgets.dart';

class StateScreen extends StatelessWidget {
  const StateScreen({super.key});

  static const _list = [
    (
      path: '/state/setstate',
      title: 'setState',
      desc: '所有状态在 Widget 内部，\n复杂场景下回调嵌套深、全树重建',
      color: Colors.red,
    ),
    (
      path: '/state/changenotifier',
      title: 'ChangeNotifier',
      desc: '官方推荐，Model 继承 ChangeNotifier，\n需手动 dispose，灵活但繁琐',
      color: Colors.orange,
    ),
    (
      path: '/state/provider',
      title: 'Provider',
      desc: 'InheritedWidget 封装，ChangeNotifierProvider\n注入，Consumer/Selector 精确重建',
      color: Colors.purple,
    ),
    (
      path: '/state/inherited',
      title: 'InheritedWidget',
      desc: 'Flutter 内置，跨组件共享，\n依赖注入式访问，但模板代码多',
      color: Colors.blue,
    ),
    (
      path: '/state/riverpod',
      title: 'Riverpod',
      desc: '编译安全、自动 dispose、\n支持异步、计算属性，测试友好',
      color: Colors.teal,
    ),
    (
      path: '/state/immutable-model',
      title: '数据模型不可变性 ⭐',
      desc: '面试重点：freeze / copyWith / 注解，\n可变 vs 不可变模型的对比讲解',
      color: Colors.deepPurple,
    ),
    (
      path: '/state/riverpod-improved',
      title: 'Riverpod + 不可变模型 ⭐',
      desc: '使用 copyWith 改写购物车，\n展示不可变模型在 Riverpod 中的最佳实践',
      color: Colors.indigo,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return TechDetailShell(
      title: '状态管理方案',
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _list[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: item.color,
                foregroundColor: Colors.white,
                child: Text('${index + 1}'),
              ),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item.desc, style: const TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(item.path),
            ),
          );
        },
      ),
    );
  }
}
