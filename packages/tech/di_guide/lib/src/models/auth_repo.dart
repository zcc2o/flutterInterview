abstract class AuthRepo {
  Future<bool> login(String user, String pwd);
}

class AuthRepoImpl implements AuthRepo {
  @override
  Future<bool> login(String user, String pwd) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return user == 'admin' && pwd == '123';
  }
}

class AuthService {
  final AuthRepo repo;
  const AuthService(this.repo);

  Future<bool> login(String user, String pwd) => repo.login(user, pwd);
}
