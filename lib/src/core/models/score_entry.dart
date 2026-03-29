class ScoreEntry {
  final String id;
  final String userId;
  final String nickname;
  final String gameId;
  final int score;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const ScoreEntry({
    required this.id,
    required this.userId,
    required this.nickname,
    required this.gameId,
    required this.score,
    required this.metadata,
    required this.createdAt,
  });

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        nickname: json['player_profiles']?['nickname'] as String? ?? 'Unknown',
        gameId: json['game_id'] as String,
        score: json['score'] as int,
        metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
