import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, anonymous, authenticated }

/// Single source of truth for auth state. UI reads `status` and `user`,
/// writes via login/register/logout. Provider rebuilds listeners on change.
class AuthProvider extends ChangeNotifier {
  final ApiClient api;
  final AuthService _auth;

  AuthProvider(this.api) : _auth = AuthService(api);

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  User? _user;
  User? get user => _user;

  String? _lastError;
  String? get lastError => _lastError;

  /// Called once on app start: load tokens from disk, validate by hitting /me.
  Future<void> bootstrap() async {
    await api.loadTokens();
    if (!api.isAuthenticated) {
      _status = AuthStatus.anonymous;
      notifyListeners();
      return;
    }
    try {
      _user = await _auth.fetchMe();
      _status = AuthStatus.authenticated;
    } catch (_) {
      await api.clearTokens();
      _status = AuthStatus.anonymous;
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _lastError = null;
    try {
      _user = await _auth.login(username, password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String password, {String? email}) async {
    _lastError = null;
    try {
      _user = await _auth.register(username, password, email: email);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    _user = null;
    _status = AuthStatus.anonymous;
    notifyListeners();
  }

  void updateUser(User u) {
    _user = u;
    notifyListeners();
  }

  /// Re-fetch the current user (used after a game ends to update stats).
  Future<User?> bootstrapRefresh() async {
    try {
      final u = await _auth.fetchMe();
      _user = u;
      notifyListeners();
      return u;
    } catch (_) {
      return null;
    }
  }
}
