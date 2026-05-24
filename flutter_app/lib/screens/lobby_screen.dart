import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/game_service.dart';
import 'matchmaking_screen.dart';

/// Online players list. Beats every 30s to mark self as online and
/// refreshes the list every 10s. To challenge someone we just push the
/// shared matchmaking flow — direct-challenge over WS would require
/// invite tracking on the server which is out of scope for v1.
class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  late final GameService _service;
  Timer? _refreshTimer;
  Timer? _heartbeatTimer;
  List<User> _players = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _service = GameService(context.read<ApiClient>());
    _refresh();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30), (_) => _service.heartbeat().catchError((_) {}));
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10), (_) => _refresh());
  }

  Future<void> _refresh() async {
    try {
      await _service.heartbeat();
      final list = await _service.onlinePlayers();
      if (mounted) setState(() { _players = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Online players')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _players.isEmpty
              ? const Center(child: Text('No one online right now.\nPull to refresh.'))
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    itemCount: _players.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final p = _players[i];
                      return ListTile(
                        leading: CircleAvatar(child: Text(p.username[0].toUpperCase())),
                        title: Text(p.username),
                        subtitle: Text('W ${p.wins} • L ${p.losses} • D ${p.draws}'),
                        trailing: const Icon(Icons.sports_esports),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const MatchmakingScreen(),
                        )),
                      );
                    },
                  ),
                ),
    );
  }
}
