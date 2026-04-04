import 'score_entry.dart';

class LeaderboardResult {
  /// Top N players sorted by cumulative score.
  final List<ScoreEntry> topEntries;

  /// The current user's aggregated entry with their actual rank.
  /// Null if the user has no scores yet.
  final ScoreEntry? userEntry;

  const LeaderboardResult({
    required this.topEntries,
    this.userEntry,
  });
}
