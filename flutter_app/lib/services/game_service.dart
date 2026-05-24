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

  /// Create a private room. Returns the gameId and 4-digit code to share.
  Future<({String gameId, String roomCode})> createRoom() async {
    final res = await api.post('/api/rooms/create/');
    final m = Map<String, dynamic>.from(res as Map);
    return (gameId: m['game_id'] as String, roomCode: m['room_code'] as String);
  }

  /// Join an existing private room by 4-digit code. Joiner always plays O.
  Future<({String gameId, String yourMark})> joinRoom(String code) async {
    final res = await api.post('/api/rooms/join/', {'room_code': code});
    final m = Map<String, dynamic>.from(res as Map);
    return (gameId: m['game_id'] as String, yourMark: m['your_mark'] as String);
  }
}
