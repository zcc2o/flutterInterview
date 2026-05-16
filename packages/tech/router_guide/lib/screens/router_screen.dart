import 'package:flutter/material.dart';
import 'package:interview_widgets/interview_widgets.dart';

class RouterScreen extends StatelessWidget {
  const RouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TechDetailShell(
      title: '路由方案',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Section(
            title: '1. go_router 核心概念',
            children: [
              ListTile(
                title: Text('GoRouter'),
                subtitle: Text('顶层路由配置，持有所有路由定义'),
              ),
              ListTile(
                title: Text('GoRoute'),
                subtitle: Text('单个路由定义：path + builder + 可选的子路由'),
              ),
              ListTile(
                title: Text('ShellRoute'),
                subtitle: Text('共享外壳（如 BottomNavigationBar）的路由组'),
              ),
              ListTile(
                title: Text('StatefulNavigationShell'),
                subtitle: Text('保留 Tab 状态的分支导航'),
              ),
            ],
          ),
          const _Section(
            title: '2. 路由参数',
            children: [
              ListTile(
                title: Text('路径参数'),
                subtitle: Text('/user/:id — state.pathParameters[\'id\']'),
              ),
              ListTile(
                title: Text('查询参数'),
                subtitle: Text(
                  '/search?q=flutter — state.uri.queryParameters[\'q\']',
                ),
              ),
              ListTile(
                title: Text('Extra 参数'),
                subtitle: Text('传递复杂对象 — state.extra as MyObject'),
              ),
            ],
          ),
          _Section(
            title: '3. 导航方法',
            children: [
              ListTile(
                title: const Text('context.push()'),
                subtitle: const Text('推入新页面'),
                onTap: () {},
              ),
              ListTile(
                title: const Text('context.pop()'),
                subtitle: const Text('返回上一页'),
                onTap: () {},
              ),
              ListTile(
                title: const Text('context.go()'),
                subtitle: const Text('替换整个导航栈'),
                onTap: () {},
              ),
              ListTile(
                title: const Text('context.replace()'),
                subtitle: const Text('替换当前路由'),
                onTap: () {},
              ),
            ],
          ),
          const _Section(
            title: '4. 重定向与守卫',
            children: [
              ListTile(
                title: Text('redirect'),
                subtitle: Text('根据状态条件重定向，常用于登录守卫、条件跳转'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}
