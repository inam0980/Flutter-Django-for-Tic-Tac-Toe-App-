import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import 'history_screen.dart';
import 'leaderboard_screen.dart';
import 'lobby_screen.dart';
import 'login_screen.dart';
import 'matchmaking_screen.dart';
import 'profile_screen.dart';
import 'solo_game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    return Scaffold(
      backgroundColor: NeonColors.bgDeep,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopBar(
                username: user?.username ?? '',
                onProfile: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen())),
                onLogout: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  }
                },
              ),
              const SizedBox(height: 18),
              const GameTitle(fontSize: 32),
              const SizedBox(height: 24),
              if (user != null) _StatsCard(user: user),
              const SizedBox(height: 24),
              _SectionLabel('PLAY'),
              const SizedBox(height: 10),
              _PrimaryAction(
                icon: Icons.smart_toy,
                title: 'Play vs AI',
                subtitle: 'Solo — pick a difficulty',
                onTap: () => _showDifficultyPicker(context),
              ),
              const SizedBox(height: 10),
              _PrimaryAction(
                icon: Icons.bolt,
                title: 'Quick Match',
                subtitle: 'Online — get paired instantly',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const MatchmakingScreen())),
              ),
              const SizedBox(height: 10),
              _PrimaryAction(
                icon: Icons.groups,
                title: 'Lobby',
                subtitle: 'Challenge a specific player',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const LobbyScreen())),
              ),
              const SizedBox(height: 24),
              _SectionLabel('EXPLORE'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _SquareTile(
                      icon: Icons.emoji_events,
                      label: 'Leaderboard',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const LeaderboardScreen())),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SquareTile(
                      icon: Icons.history,
                      label: 'History',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const HistoryScreen())),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDifficultyPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: NeonColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NeonColors.bgElevated,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Choose difficulty',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: NeonColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  )),
              const SizedBox(height: 14),
              for (final entry in const [
                ['Easy', 'ai_easy', 'Random moves', Icons.sentiment_satisfied],
                ['Medium', 'ai_medium', 'Win / block heuristic', Icons.psychology],
                ['Hard', 'ai_hard', 'Unbeatable minimax', Icons.local_fire_department],
              ]) ...[
                _DifficultyTile(
                  label: entry[0] as String,
                  subtitle: entry[2] as String,
                  icon: entry[3] as IconData,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => SoloGameScreen(mode: entry[1] as String),
                    ));
                  },
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String username;
  final VoidCallback onProfile;
  final VoidCallback onLogout;

  const _TopBar({
    required this.username,
    required this.onProfile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: NeonColors.bgCard,
            shape: BoxShape.circle,
            border: Border.all(color: NeonColors.orange, width: 1.5),
          ),
          child: const Icon(Icons.person, color: NeonColors.orange, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Welcome back',
                  style: TextStyle(
                      color: NeonColors.textMuted, fontSize: 11, letterSpacing: 0.8)),
              const SizedBox(height: 2),
              Text(username.isEmpty ? 'Player' : username,
                  style: const TextStyle(
                      color: NeonColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        IconButton(
          onPressed: onProfile,
          icon: const Icon(Icons.person_outline, color: NeonColors.textPrimary),
        ),
        IconButton(
          onPressed: onLogout,
          icon: const Icon(Icons.logout, color: NeonColors.textPrimary),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final User user;
  const _StatsCard({required this.user});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: NeonColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NeonColors.bgElevated, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('${user.wins}', 'WINS', NeonColors.success),
          _divider(),
          _stat('${user.losses}', 'LOSSES', NeonColors.danger),
          _divider(),
          _stat('${user.draws}', 'DRAWS', NeonColors.textMuted),
          _divider(),
          _stat('${user.gamesPlayed}', 'PLAYED', NeonColors.orange),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 32,
        color: NeonColors.bgElevated,
      );

  Widget _stat(String value, String label, Color accent) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: accent)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: NeonColors.textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8)),
        ],
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(text,
          style: const TextStyle(
            color: NeonColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          )),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PrimaryAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: NeonColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: NeonColors.bgElevated, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: NeonColors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: NeonColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: NeonColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: NeonColors.textMuted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _SquareTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SquareTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            color: NeonColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: NeonColors.bgElevated, width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: NeonColors.orange, size: 28),
              const SizedBox(height: 8),
              Text(label,
                  style: const TextStyle(
                      color: NeonColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _DifficultyTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: NeonColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: NeonColors.bgElevated, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: NeonColors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: NeonColors.orange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: NeonColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: NeonColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: NeonColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
