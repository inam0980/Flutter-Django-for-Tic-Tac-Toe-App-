import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../services/game_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final GameService _service;
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _service = GameService(context.read<ApiClient>());
    _future = _service.history();
  }

  Color _resultColor(String? r) => switch (r) {
        'win' => Colors.green,
        'loss' => Colors.red,
        'draw' => Colors.grey,
        _ => Colors.blueGrey,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game history')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return Center(child: Text('${snap.error}'));
          final items = snap.data ?? const [];
          if (items.isEmpty) return const Center(child: Text('No games yet.'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final g = items[i];
              final opponent = g['opponent'];
              final oppName = opponent == null ? 'Unknown' : (opponent['username'] ?? '???');
              final myResult = g['my_result'] as String?;
              final mode = (g['mode'] ?? '') as String;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _resultColor(myResult),
                  child: Text(
                    (myResult ?? '-')[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text('vs $oppName'),
                subtitle: Text(mode),
                trailing: Text(
                  (myResult ?? g['status'] ?? '').toString(),
                  style: TextStyle(
                    color: _resultColor(myResult),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
