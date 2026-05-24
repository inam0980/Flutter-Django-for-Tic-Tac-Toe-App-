import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/game_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late final GameService _service;
  late Future<List<User>> _future;

  @override
  void initState() {
    super.initState();
    _service = GameService(context.read<ApiClient>());
    _future = _service.leaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: FutureBuilder<List<User>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return Center(child: Text('${snap.error}'));
          final players = snap.data ?? const [];
          if (players.isEmpty) return const Center(child: Text('No players yet.'));
          return ListView.separated(
            itemCount: players.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final p = players[i];
              return ListTile(
                leading: SizedBox(
                  width: 32,
                  child: Text('#${i + 1}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                title: Text(p.username),
                subtitle: Text('W ${p.wins} • L ${p.losses} • D ${p.draws}'),
                trailing: Text(
                  '${(p.winRate * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
