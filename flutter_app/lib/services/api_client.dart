import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

/// Thin wrapper around `http` that:
///   - prepends AppConfig.apiBaseUrl
///   - attaches the JWT access token if present
///   - decodes JSON and surfaces server errors as ApiException
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  static const _kAccess = 'jwt_access';
  static const _kRefresh = 'jwt_refresh';

  String? _access;
  String? _refresh;

  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _access = prefs.getString(_kAccess);
    _refresh = prefs.getString(_kRefresh);
  }

  Future<void> setTokens(String access, String refresh) async {
    _access = access;
    _refresh = refresh;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccess, access);
    await prefs.setString(_kRefresh, refresh);
  }

  Future<void> clearTokens() async {
    _access = null;
    _refresh = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccess);
    await prefs.remove(_kRefresh);
  }

  String? get accessToken => _access;
  bool get isAuthenticated => _access != null && _access!.isNotEmpty;

  Uri _u(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  Map<String, String> _headers({bool json = true}) => {
        if (json) 'Content-Type': 'application/json',
        if (_access != null) 'Authorization': 'Bearer $_access',
      };

  Future<dynamic> get(String path) async {
    final r = await http.get(_u(path), headers: _headers(json: false));
    return _decode(r);
  }

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    final r = await http.post(_u(path),
        headers: _headers(), body: jsonEncode(body ?? {}));
    return _decode(r);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final r = await http.patch(_u(path),
        headers: _headers(), body: jsonEncode(body));
    return _decode(r);
  }

  dynamic _decode(http.Response r) {
    final body = r.body.isEmpty ? '{}' : r.body;
    dynamic parsed;
    try {
      parsed = jsonDecode(body);
    } catch (_) {
      parsed = body;
    }
    if (r.statusCode >= 200 && r.statusCode < 300) return parsed;
    final detail = parsed is Map && parsed['detail'] != null
        ? parsed['detail'].toString()
        : body;
    throw ApiException(r.statusCode, detail);
  }
}
