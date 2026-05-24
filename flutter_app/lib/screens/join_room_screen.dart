import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../services/game_service.dart';
import '../theme.dart';
import 'multiplayer_game_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _ctrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  bool get _isReady => _ctrl.text.length == 4 && !_submitting;

  Future<void> _join() async {
    if (!_isReady) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final api = context.read<ApiClient>();
      final res = await GameService(api).joinRoom(_ctrl.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => MultiplayerGameScreen(
          gameId: res.gameId,
          myMark: res.yourMark,
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e is ApiException ? e.message : e.toString();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JOIN ROOM')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.vpn_key, size: 56, color: NeonColors.orange),
              const SizedBox(height: 18),
              const Text(
                'ENTER ROOM CODE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: NeonColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ctrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  color: NeonColors.orange,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 12,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '0000',
                  hintStyle: TextStyle(
                    color: NeonColors.textDim,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 12,
                  ),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _join(),
              ),
              const SizedBox(height: 8),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: NeonColors.danger,
                        fontSize: 13,
                      )),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isReady ? _join : null,
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text('JOIN'),
              ),
              const SizedBox(height: 10),
              TextButton(
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
