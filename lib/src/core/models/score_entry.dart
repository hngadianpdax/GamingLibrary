class ScoreEntry {
  final String userId;
  final String nickname;
  final String gameId;
  final int score;
  final int gamesPlayed;
  final int rank;

  const ScoreEntry({
    required this.userId,
    required this.nickname,
    required this.gameId,
    required this.score,
    this.gamesPlayed = 1,
    this.rank = 0,
  });
}
