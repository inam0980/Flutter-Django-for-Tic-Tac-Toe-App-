class User {
  final int id;
  final String username;
  final String email;
  final String avatarUrl;
  final int wins;
  final int losses;
  final int draws;
  final int gamesPlayed;
  final double winRate;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.gamesPlayed,
    required this.winRate,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'] as int,
        username: j['username'] as String,
        email: (j['email'] ?? '') as String,
        avatarUrl: (j['avatar_url'] ?? '') as String,
        wins: (j['wins'] ?? 0) as int,
        losses: (j['losses'] ?? 0) as int,
        draws: (j['draws'] ?? 0) as int,
        gamesPlayed: (j['games_played'] ?? 0) as int,
        winRate: ((j['win_rate'] ?? 0) as num).toDouble(),
      );
}
