import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../services/game_service.dart';
import '../services/ws_service.dart';
import '../theme.dart';
import 'multiplayer_game_screen.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  WsConnection? _ws;
  StreamSubscription? _sub;

  String? _roomCode;
  String? _gameId;
  String _status = 'Creating room...';
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final api = context.read<ApiClient>();
    try {
      final res = await GameService(api).createRoom();
      if (!mounted) return;
      setState(() {
        _gameId = res.gameId;
        _roomCode = res.roomCode;
        _status = 'Waiting for opponent...';
      });
      _openWebSocket(api.accessToken!);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  void _openWebSocket(String token) {
    _ws = WsConnection.connect('/ws/game/$_gameId/', token);
    _sub = _ws!.messages.listen((msg) {
      if (!mounted) return;
      // GameConsumer sends {"type":"state","game":{...}} on every change.
      if (msg['type'] == 'state') {
        final game = Map<String, dynamic>.from(msg['game'] as Map);
        if (game['status'] == 'active' && game['player_o'] != null) {
          // Joiner arrived — go to the game screen.
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => MultiplayerGameScreen(
              gameId: _gameId!,
              myMark: 'X', // creator is always X
            ),
          ));
        }
      }
    }, onError: (e) {
      if (mounted) setState(() => _error = 'Connection error: $e');
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ws?.close();
    super.dispose();
  }

  void _copyCode() {
    if (_roomCode == null) return;
    Clipboard.setData(ClipboardData(text: _roomCode!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CREATE ROOM')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              if (_error != null)
                _ErrorCard(message: _error!, onRetry: _bootstrap)
              else if (_roomCode == null)
                const Center(child: CircularProgressIndicator())
              else
                _CodeDisplay(code: _roomCode!, onCopy: _copyCode),
              const SizedBox(height: 24),
              Text(_status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: NeonColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  )),
              const SizedBox(height: 12),
              if (_roomCode != null)
                const Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                ),
              const Spacer(),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CodeDisplay extends StatelessWidget {
  final String code;
  final VoidCallback onCopy;
  const _CodeDisplay({required this.code, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('SHARE THIS CODE',
            style: TextStyle(
              color: NeonColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            )),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: NeonColors.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: NeonColors.orange, width: 1.6),
            boxShadow: [
              BoxShadow(
                color: NeonColors.orange.withValues(alpha: 0.25),
                blurRadius: 24,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: code.split('').map((d) => _Digit(d)).toList(),
          ),
        ),
        const SizedBox(height: 14),
        TextButton.icon(
          onPressed: onCopy,
          icon: const Icon(Icons.copy, size: 16),
          label: const Text('Copy code'),
        ),
      ],
    );
  }
}

class _Digit extends StatelessWidget {
  final String digit;
  const _Digit(this.digit);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(digit,
          style: const TextStyle(
            color: NeonColors.orange,
            fontSize: 56,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          )),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.error_outline, color: NeonColors.danger, size: 48),
        const SizedBox(height: 12),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: NeonColors.danger)),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    );
  }
}
