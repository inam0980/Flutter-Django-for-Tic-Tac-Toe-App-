import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../services/ws_service.dart';
import 'multiplayer_game_screen.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  WsConnection? _ws;
  StreamSubscription? _sub;
  String _status = 'Connecting...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
  }

  Future<void> _connect() async {
    final api = context.read<ApiClient>();
    final token = api.accessToken;
    if (token == null) {
      setState(() => _status = 'Not signed in');
      return;
    }
    _ws = WsConnection.connect('/ws/matchmaking/', token);
    setState(() => _status = 'Searching for opponent...');
    _sub = _ws!.messages.listen((msg) {
      if (!mounted) return;
      final type = msg['type'];
      if (type == 'waiting') {
        setState(() => _status = 'Waiting for an opponent...');
      } else if (type == 'matched') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => MultiplayerGameScreen(
            gameId: msg['game_id'] as String,
            myMark: msg['your_mark'] as String,
          ),
        ));
      }
    }, onError: (e) {
      if (mounted) setState(() => _status = 'Connection error: $e');
    }, onDone: () {
      if (mounted && _status.startsWith('Waiting')) {
        setState(() => _status = 'Disconnected');
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ws?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Match')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bolt, size: 64, color: Colors.amber),
            const SizedBox(height: 20),
            Text(_status, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
