import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ai/minimax.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import '../widgets/game_board.dart';
import '../widgets/player_card.dart';

class SoloGameScreen extends StatefulWidget {
  final String mode;  // ai_easy | ai_medium | ai_hard
  const SoloGameScreen({super.key, required this.mode});

  @override
  State<SoloGameScreen> createState() => _SoloGameScreenState();
}

class _SoloGameScreenState extends State<SoloGameScreen> {
  static const _humanMark = 'X';
  static const _aiMark = 'O';
  static const _maxHints = 3;

  String _board = '.........';
  String _turn = _humanMark;
  String _result = '';
  bool _finished = false;
  bool _aiThinking = false;
  int? _lastMove;
  int? _hintPos;
  int _hintsLeft = _maxHints;

  // Snapshot of board state for one-step undo (before the most recent
  // human+AI pair of moves). Null = no undo available.
  String? _undoBoard;
  String? _undoTurn;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    setState(() {
      _board = '.........';
      _turn = _humanMark;
      _result = '';
      _finished = false;
      _aiThinking = false;
      _lastMove = null;
      _hintPos = null;
      _hintsLeft = _maxHints;
      _undoBoard = null;
      _undoTurn = null;
    });
  }

  Future<void> _onCellTap(int pos) async {
    if (_finished || _aiThinking || _turn != _humanMark) return;
    if (_board[pos] != '.') return;

    // Save undo snapshot before human move.
    _undoBoard = _board;
    _undoTurn = _turn;

    setState(() {
      _board = applyMove(_board, pos, _humanMark);
      _lastMove = pos;
      _turn = _aiMark;
      _hintPos = null;
    });

    if (_checkAndFinish()) return;

    setState(() => _aiThinking = true);
    await Future<void>.delayed(const Duration(milliseconds: 380));
    if (!mounted) return;

    final aiPos = pickAiMove(_board, _aiMark, widget.mode);
    setState(() {
      _board = applyMove(_board, aiPos, _aiMark);
      _lastMove = aiPos;
      _turn = _humanMark;
      _aiThinking = false;
    });

    _checkAndFinish();
  }

  bool _checkAndFinish() {
    final w = checkWinner(_board);
    if (w == null) return false;
    setState(() {
      _finished = true;
      _result = w == 'X' ? 'x_won' : (w == 'O' ? 'o_won' : 'draw');
    });
    return true;
  }

  void _undo() {
    if (_undoBoard == null || _finished || _aiThinking) return;
    setState(() {
      _board = _undoBoard!;
      _turn = _undoTurn!;
      _undoBoard = null;
      _undoTurn = null;
      _lastMove = null;
      _hintPos = null;
    });
  }

  void _hint() {
    if (_hintsLeft <= 0 || _finished || _aiThinking || _turn != _humanMark) return;
    final pos = aiHard(_board, _humanMark);
    setState(() {
      _hintPos = pos;
      _hintsLeft--;
    });
  }

  String _modeLabel() {
    switch (widget.mode) {
      case 'ai_easy': return 'AI — Easy';
      case 'ai_medium': return 'AI — Medium';
      case 'ai_hard': return 'AI — Hard';
      default: return widget.mode;
    }
  }

  ({IconData icon, String title, String subtitle, Color bg}) _bannerState() {
    if (!_finished) {
      return (
        icon: Icons.emoji_events,
        title: 'Game in progress...',
        subtitle: 'Win the game by getting 3 in a row.',
        bg: NeonColors.orange,
      );
    }
    if (_result == 'draw') {
      return (
        icon: Icons.handshake,
        title: "It's a draw",
        subtitle: 'Good game — try again?',
        bg: NeonColors.textMuted,
      );
    }
    if (_result == 'x_won') {
      return (
        icon: Icons.emoji_events,
        title: 'You win!',
        subtitle: 'Nice play. Hit restart for another round.',
        bg: NeonColors.success,
      );
    }
    return (
      icon: Icons.smart_toy,
      title: 'AI wins',
      subtitle: 'Tough one — give it another shot.',
      bg: NeonColors.danger,
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().user;
    final banner = _bannerState();

    return Scaffold(
      backgroundColor: NeonColors.bgDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              _TopBar(title: _modeLabel()),
              const SizedBox(height: 8),
              const GameTitle(fontSize: 30),
              const SizedBox(height: 22),
              Row(
                children: [
                  PlayerCard(
                    user: me,
                    mark: _humanMark,
                    isYou: true,
                    isTheirTurn: _turn == _humanMark && !_finished,
                  ),
                  const SizedBox(width: 10),
                  PlayerCard(
                    user: null,
                    mark: _aiMark,
                    fallbackLabel: _modeLabel(),
                    isTheirTurn: _turn == _aiMark && !_finished,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GameBoard(
                board: _board,
                interactive: !_finished &&
                    _turn == _humanMark &&
                    !_aiThinking,
                onTap: _onCellTap,
                lastMovePosition: _lastMove,
                hintPosition: _hintPos,
              ),
              const SizedBox(height: 16),
              if (_aiThinking)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: NeonColors.orange,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('AI thinking…',
                          style: TextStyle(
                              color: NeonColors.textMuted, fontSize: 13)),
                    ],
                  ),
                ),
              StatusBanner(
                icon: banner.icon,
                title: banner.title,
                subtitle: banner.subtitle,
                iconBg: banner.bg,
              ),
              const Spacer(),
              Row(
                children: [
                  GameActionButton(
                    icon: Icons.refresh,
                    label: 'RESTART',
                    onTap: _reset,
                  ),
                  const SizedBox(width: 10),
                  GameActionButton(
                    icon: Icons.lightbulb_outline,
                    label: 'HINT',
                    badge: _hintsLeft,
                    onTap: (_hintsLeft > 0 &&
                            !_finished &&
                            _turn == _humanMark &&
                            !_aiThinking)
                        ? _hint
                        : null,
                  ),
                  const SizedBox(width: 10),
                  GameActionButton(
                    icon: Icons.undo,
                    label: 'UNDO',
                    onTap: (_undoBoard != null &&
                            !_finished &&
                            !_aiThinking)
                        ? _undo
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconCircle(
          icon: Icons.arrow_back,
          onTap: () => Navigator.of(context).maybePop(),
        ),
        const Spacer(),
        Text(title,
            style: const TextStyle(
              color: NeonColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            )),
        const Spacer(),
        _IconCircle(
          icon: Icons.settings_outlined,
          onTap: () {},
        ),
      ],
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconCircle({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: NeonColors.bgCard,
            shape: BoxShape.circle,
            border: Border.all(color: NeonColors.bgElevated, width: 1),
          ),
          child: Icon(icon, color: NeonColors.textPrimary, size: 20),
        ),
      ),
    );
  }
}
