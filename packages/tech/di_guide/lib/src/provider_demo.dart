import 'package:flutter/material.dart';
import 'models/auth_repo.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthService _service;
  bool _loggedIn = false;
  bool _loading = false;

  AuthNotifier(AuthRepo repo) : _service = AuthService(repo);

  bool get loggedIn => _loggedIn;
  bool get loading => _loading;

  Future<void> login(String user, String pwd) async {
    _loading = true;
    notifyListeners();
    _loggedIn = await _service.login(user, pwd);
    _loading = false;
    notifyListeners();
  }

  void logout() {
    _loggedIn = false;
    notifyListeners();
  }
}

class ProviderDemo extends StatefulWidget {
  const ProviderDemo({super.key});

  @override
  State<ProviderDemo> createState() => _ProviderDemoState();
}

class _ProviderDemoState extends State<ProviderDemo> {
  late final AuthNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = AuthNotifier(AuthRepoImpl());
    _notifier.addListener(_onChange);
  }

  @override
  void dispose() {
    _notifier.removeListener(_onChange);
    _notifier.dispose();
    super.dispose();
  }

  void _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ChangeNotifier + ListenableBuilder 模式，状态变化自动通知 UI 刷新。'),
        const SizedBox(height: 12),
        if (_notifier.loggedIn)
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 18),
              const SizedBox(width: 6),
              const Text('已登录', style: TextStyle(color: Colors.green)),
              const Spacer(),
              OutlinedButton(onPressed: _notifier.logout, child: const Text('退出')),
            ],
          )
        else
          Row(
            children: [
              FilledButton.tonal(
                onPressed: _notifier.loading ? null : () => _notifier.login('admin', '123'),
                child: const Text('登录'),
              ),
              if (_notifier.loading) const Padding(
                padding: EdgeInsets.only(left: 12),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ],
          ),
      ],
    );
  }
}
