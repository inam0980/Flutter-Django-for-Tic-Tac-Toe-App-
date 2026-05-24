import 'user.dart';

/// Represents the live state of a game as the server sees it.
/// `board` is a 9-char string ('.' = empty, 'X' / 'O' = marks).
class GameState {
  final String id;
  final String mode;     // ai_easy | ai_medium | ai_hard | multiplayer
  final String status;   // waiting | active | finished | abandoned
  final String result;   // '' | x_won | o_won | draw
  final String board;
  final String turn;     // 'X' or 'O'
  final User? playerX;
  final User? playerO;
  final User? winner;

  const GameState({
    required this.id,
    required this.mode,
    required this.status,
    required this.result,
    required this.board,
    required this.turn,
    required this.playerX,
    required this.playerO,
    required this.winner,
  });

  factory GameState.fromJson(Map<String, dynamic> j) => GameState(
        id: j['id'] as String,
        mode: j['mode'] as String,
        status: j['status'] as String,
        result: (j['result'] ?? '') as String,
        board: j['board'] as String,
        turn: j['turn'] as String,
        playerX: j['player_x'] == null ? null : User.fromJson(_pad(j['player_x'])),
        playerO: j['player_o'] == null ? null : User.fromJson(_pad(j['player_o'])),
        winner: j['winner'] == null ? null : User.fromJson(_pad(j['winner'])),
      );

  bool get isFinished => status == 'finished' || status == 'abandoned';

  /// The WS "brief" user shape lacks stats fields; pad them so User.fromJson
  /// doesn't crash when we use it for both shapes.
  static Map<String, dynamic> _pad(dynamic raw) {
    final m = Map<String, dynamic>.from(raw as Map);
    m.putIfAbsent('email', () => '');
    m.putIfAbsent('avatar_url', () => '');
    m.putIfAbsent('wins', () => 0);
    m.putIfAbsent('losses', () => 0);
    m.putIfAbsent('draws', () => 0);
    m.putIfAbsent('games_played', () => 0);
    m.putIfAbsent('win_rate', () => 0);
    return m;
  }
}
