import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../models/game.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../services/ws_service.dart';
import '../widgets/chat_panel.dart';
import '../widgets/game_board.dart';
import '../widgets/player_card.dart';

class MultiplayerGameScreen extends StatefulWidget {
  final String gameId;
  final String myMark;  // 'X' or 'O'
  const MultiplayerGameScreen({
    super.key, required this.gameId, required this.myMark,
  });

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  WsConnection? _ws;
  StreamSubscription? _sub;
  GameState? _game;
  final List<ChatMessage> _chat = [];
  bool _chatOpen = false;
  String? _statusMsg;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
  }

  void _connect() {
    final token = context.read<ApiClient>().accessToken;
    if (token == null) return;
    _ws = WsConnection.connect('/ws/game/${widget.gameId}/', token);
    _sub = _ws!.messages.listen(_onMsg, onError: (e) {
      if (mounted) setState(() => _statusMsg = 'Connection error: $e');
    }, onDone: () {
      if (mounted) setState(() => _statusMsg = 'Disconnected');
    });
  }

  void _onMsg(Map<String, dynamic> msg) {
    if (!mounted) return;
    switch (msg['type']) {
      case 'state':
        final g = msg['game'];
        if (g != null) {
          setState(() => _game = GameState.fromJson(Map<String, dynamic>.from(g as Map)));
        }
        break;
      case 'chat':
        final m = msg['message'];
        if (m != null) {
          setState(() =>
              _chat.add(ChatMessage.fromJson(Map<String, dynamic>.from(m as Map))));
        }
        break;
      case 'error':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg['detail']?.toString() ?? 'error')),
        );
        break;
    }
  }

  void _tap(int pos) {
    final g = _game;
    if (g == null || g.isFinished) return;
    if (g.turn != widget.myMark) return;
    _ws?.send({'type': 'move', 'position': pos});
  }

  void _sendChat(String text) => _ws?.send({'type': 'chat', 'text': text});
  void _resign() => _ws?.send({'type': 'resign'});

  @override
  void dispose() {
    _sub?.cancel();
    _ws?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = _game;
    final me = context.watch<AuthProvider>().user;
    final myTurn = g != null && !g.isFinished && g.turn == widget.myMark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiplayer'),
        actions: [
          IconButton(
            icon: Icon(_chatOpen ? Icons.sports_esports : Icons.chat),
            onPressed: () => setState(() => _chatOpen = !_chatOpen),
          ),
        ],
      ),
      body: SafeArea(
        child: g == null
            ? Center(
                child: _statusMsg != null
                    ? Text(_statusMsg!)
                    : const CircularProgressIndicator())
            : _chatOpen
                ? ChatPanel(
                    messages: _chat,
                    myUserId: me?.id ?? -1,
                    onSend: _sendChat,
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            PlayerCard(
                              user: g.playerX,
                              mark: 'X',
                              isTheirTurn: g.turn == 'X' && !g.isFinished,
                            ),
                            PlayerCard(
                              user: g.playerO,
                              mark: 'O',
                              isTheirTurn: g.turn == 'O' && !g.isFinished,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          g.isFinished
                              ? _finalLabel(g, me?.id)
                              : (myTurn ? 'Your turn' : "Opponent's turn"),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        GameBoard(
                          board: g.board,
                          interactive: myTurn,
                          onTap: _tap,
                        ),
                        const Spacer(),
                        if (!g.isFinished)
                          OutlinedButton.icon(
                            onPressed: _resign,
                            icon: const Icon(Icons.flag),
                            label: const Text('Resign'),
                          )
                        else
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Back to menu'),
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }

  String _finalLabel(GameState g, int? myId) {
    if (g.status == 'abandoned') return 'Game abandoned';
    if (g.result == 'draw') return "It's a draw";
    return g.winner?.id == myId ? 'You win! 🎉' : 'You lost 😢';
  }
}
