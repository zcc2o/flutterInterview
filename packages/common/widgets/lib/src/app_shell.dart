import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_core/interview_core.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter 技术点面试'),
      ),
      body: child,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _techList = [
    (InterviewRoutes.timer, '精确定时器', Icons.timer),
    (InterviewRoutes.router, '路由方案', Icons.alt_route),
    (InterviewRoutes.state, '状态管理', Icons.manage_search),
    (InterviewRoutes.di, '依赖注入', Icons.settings_input_component),
    (InterviewRoutes.http, '网络请求', Icons.http),
    (InterviewRoutes.painter, '自定义绘制', Icons.brush),
    (InterviewRoutes.animation, '动画方案', Icons.animation),
    (InterviewRoutes.storage, '本地存储', Icons.sd_card),
  ];

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _techList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final (route, title, icon) = _techList[index];
          return Card(
            child: ListTile(
              leading: Icon(icon, color: AppTheme.primaryColor),
              title: Text(title),
              subtitle: Text(route.path),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(route.path),
            ),
          );
        },
      ),
    );
  }
}
