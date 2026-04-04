import 'score_entry.dart';

class LeaderboardResult {
  /// Top N players sorted by average score per game (descending).
  final List<ScoreEntry> topByAverage;

  /// Top N players sorted by total cumulative score (descending).
  final List<ScoreEntry> topByTotal;

  /// Current user's entry ranked by average. Null if no scores yet.
  final ScoreEntry? userEntryByAverage;

  /// Current user's entry ranked by total. Null if no scores yet.
  final ScoreEntry? userEntryByTotal;

  const LeaderboardResult({
    required this.topByAverage,
    required this.topByTotal,
    this.userEntryByAverage,
    this.userEntryByTotal,
  });
}
