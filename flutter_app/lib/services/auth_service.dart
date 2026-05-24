import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient api;
  AuthService(this.api);

  Future<User> register(String username, String password,
      {String? email}) async {
    final res = await api.post('/api/auth/register/', {
      'username': username,
      'password': password,
      if (email != null && email.isNotEmpty) 'email': email,
    });
    final tokens = res['tokens'] as Map;
    await api.setTokens(tokens['access'] as String, tokens['refresh'] as String);
    return User.fromJson(Map<String, dynamic>.from(res['user'] as Map));
  }

  Future<User> login(String username, String password) async {
    final res = await api.post('/api/auth/login/', {
      'username': username,
      'password': password,
    });
    final tokens = res['tokens'] as Map;
    await api.setTokens(tokens['access'] as String, tokens['refresh'] as String);
    return User.fromJson(Map<String, dynamic>.from(res['user'] as Map));
  }

  Future<User> fetchMe() async {
    final res = await api.get('/api/auth/me/');
    return User.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<void> logout() => api.clearTokens();
}
