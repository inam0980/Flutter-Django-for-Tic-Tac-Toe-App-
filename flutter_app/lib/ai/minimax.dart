/// Local Tic Tac Toe AI for offline solo play (mirrors the server logic
/// in tictactoe/game/logic.py — kept in sync for hot-seat scenarios).
/// In normal online play the server-side AI is authoritative.

import 'dart:math';

const winLines = [
  [0, 1, 2], [3, 4, 5], [6, 7, 8],
  [0, 3, 6], [1, 4, 7], [2, 5, 8],
  [0, 4, 8], [2, 4, 6],
];

/// Returns 'X', 'O', 'draw', or null.
String? checkWinner(String board) {
  for (final line in winLines) {
    final a = board[line[0]];
    if (a != '.' && a == board[line[1]] && a == board[line[2]]) return a;
  }
  if (!board.contains('.')) return 'draw';
  return null;
}

List<int> availablePositions(String board) {
  final out = <int>[];
  for (var i = 0; i < 9; i++) {
    if (board[i] == '.') out.add(i);
  }
  return out;
}

String applyMove(String board, int pos, String mark) {
  return board.substring(0, pos) + mark + board.substring(pos + 1);
}

final _rng = Random();

int aiEasy(String board, String aiMark) =>
    availablePositions(board)[_rng.nextInt(availablePositions(board).length)];

int aiMedium(String board, String aiMark) {
  final opp = aiMark == 'X' ? 'O' : 'X';
  for (final p in availablePositions(board)) {
    if (checkWinner(applyMove(board, p, aiMark)) == aiMark) return p;
  }
  for (final p in availablePositions(board)) {
    if (checkWinner(applyMove(board, p, opp)) == opp) return p;
  }
  for (final p in [4, 0, 2, 6, 8, 1, 3, 5, 7]) {
    if (board[p] == '.') return p;
  }
  throw StateError('no moves');
}

int aiHard(String board, String aiMark) {
  final opp = aiMark == 'X' ? 'O' : 'X';

  // Returns [score, bestPos].
  List<int> score(String b, int depth, bool maximizing) {
    final w = checkWinner(b);
    if (w == aiMark) return [10 - depth, -1];
    if (w == opp) return [depth - 10, -1];
    if (w == 'draw') return [0, -1];

    var bestPos = -1;
    if (maximizing) {
      var best = -999;
      for (final p in availablePositions(b)) {
        final v = score(applyMove(b, p, aiMark), depth + 1, false)[0];
        if (v > best) { best = v; bestPos = p; }
      }
      return [best, bestPos];
    } else {
      var best = 999;
      for (final p in availablePositions(b)) {
        final v = score(applyMove(b, p, opp), depth + 1, true)[0];
        if (v < best) { best = v; bestPos = p; }
      }
      return [best, bestPos];
    }
  }

  return score(board, 0, true)[1];
}

int pickAiMove(String board, String aiMark, String mode) {
  switch (mode) {
    case 'ai_easy':   return aiEasy(board, aiMark);
    case 'ai_medium': return aiMedium(board, aiMark);
    case 'ai_hard':   return aiHard(board, aiMark);
    default: throw ArgumentError('not an AI mode: $mode');
  }
}
