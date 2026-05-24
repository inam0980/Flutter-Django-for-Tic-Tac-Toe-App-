import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  user.username.isEmpty ? '?' : user.username[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 40),
                ),
              ),
              const SizedBox(height: 14),
              Text(user.username,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              if (user.email.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(user.email,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _stat('Wins', user.wins),
                      _stat('Losses', user.losses),
                      _stat('Draws', user.draws),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.percent),
                title: const Text('Win rate'),
                trailing: Text('${(user.winRate * 100).toStringAsFixed(0)}%'),
              ),
              ListTile(
                leading: const Icon(Icons.casino),
                title: const Text('Games played'),
                trailing: Text('${user.gamesPlayed}'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, int v) => Column(
        children: [
          Text('$v', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );
}
