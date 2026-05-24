import '../models/game.dart';
import '../models/user.dart';
import 'api_client.dart';

class GameService {
  final ApiClient api;
  GameService(this.api);

  Future<GameState> startSolo({required String mode}) async {
    final res = await api.post('/api/games/solo/', {'mode': mode});
    return GameState.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<GameState> makeMove(String gameId, int position) async {
    final res = await api.post(
      '/api/games/$gameId/move/',
      {'position': position},
    );
    return GameState.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<List<Map<String, dynamic>>> history() async {
    final res = await api.get('/api/games/history/');
    return (res as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<User>> leaderboard() async {
    final res = await api.get('/api/leaderboard/');
    return (res as List)
        .map((e) => User.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<User>> onlinePlayers() async {
    final res = await api.get('/api/lobby/online/');
    return (res as List)
        .map((e) => User.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> heartbeat() => api.post('/api/lobby/heartbeat/');
}
