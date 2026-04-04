import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/player.dart';
import '../models/score_entry.dart';
import '../models/leaderboard_result.dart';

class SupabaseService {
  static const _url = 'https://detqfthnqyxibbliqmce.supabase.co';
  static const _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRldHFmdGhucXl4aWJibGlxbWNlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ2NjY4MDIsImV4cCI6MjA5MDI0MjgwMn0.rRgnvcdm5vLVQfZlnUx3ahGobmW9BtRkQNzwQSJvrb4';

  static Future<void> initialize() async {
    await Supabase.initialize(url: _url, anonKey: _anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;

  // ── Player Profiles ──────────────────────────────────────────────────────

  Future<Player?> getPlayer(String userId) async {
    final response = await client
        .from('player_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) return null;
    return Player.fromJson(response);
  }

  Future<bool> isNicknameTaken(String nickname) async {
    final response = await client
        .from('player_profiles')
        .select('user_id')
        .eq('nickname', nickname)
        .maybeSingle();
    return response != null;
  }

  Future<Player> createPlayer(String userId, String nickname) async {
    final response = await client
        .from('player_profiles')
        .insert({'user_id': userId, 'nickname': nickname})
        .select()
        .single();
    return Player.fromJson(response);
  }

  Future<Player> updateNickname(String userId, String newNickname) async {
    final response = await client
        .from('player_profiles')
        .update({'nickname': newNickname})
        .eq('user_id', userId)
        .select()
        .single();
    return Player.fromJson(response);
  }

  // ── Leaderboard ──────────────────────────────────────────────────────────

  Future<void> submitScore({
    required String userId,
    required String gameId,
    required int score,
    Map<String, dynamic> metadata = const {},
  }) async {
    await client.from('leaderboard').insert({
      'user_id': userId,
      'game_id': gameId,
      'score': score,
      'metadata': metadata,
    });
  }

  /// Fetches all scores for [gameId], aggregates per player, assigns ranks,
  /// and returns the top [topN] entries plus the current user's ranked entry.
  Future<LeaderboardResult> getLeaderboardWithUser(
    String gameId,
    String userId, {
    int topN = 20,
  }) async {
    final rows = await client
        .from('leaderboard')
        .select('user_id, score, game_id, player_profiles(nickname)')
        .eq('game_id', gameId);

    final Map<String, _UserAgg> agg = {};
    for (final row in rows as List) {
      final uid = row['user_id'] as String;
      final pts = row['score'] as int;
      final nick = (row['player_profiles'] as Map?)?['nickname'] as String? ?? 'Unknown';
      if (agg.containsKey(uid)) {
        agg[uid]!.score += pts;
        agg[uid]!.gamesPlayed++;
      } else {
        agg[uid] = _UserAgg(userId: uid, nickname: nick, score: pts);
      }
    }

    final sorted = agg.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    // Assign ranks and build full list
    final allEntries = sorted.asMap().entries.map((e) => ScoreEntry(
      userId: e.value.userId,
      nickname: e.value.nickname,
      gameId: gameId,
      score: e.value.score,
      gamesPlayed: e.value.gamesPlayed,
      rank: e.key + 1,
    )).toList();

    final topEntries = allEntries.take(topN).toList();

    ScoreEntry? userEntry;
    for (final entry in allEntries) {
      if (entry.userId == userId) {
        userEntry = entry;
        break;
      }
    }

    return LeaderboardResult(topEntries: topEntries, userEntry: userEntry);
  }

  /// Returns the cumulative total score for a player across all their games.
  Future<int?> getPersonalBest(String userId, String gameId) async {
    final rows = await client
        .from('leaderboard')
        .select('score')
        .eq('user_id', userId)
        .eq('game_id', gameId);

    if ((rows as List).isEmpty) return null;
    return rows.fold<int>(0, (sum, row) => sum + (row['score'] as int));
  }
}

class _UserAgg {
  final String userId;
  final String nickname;
  int score;
  int gamesPlayed = 1;

  _UserAgg({
    required this.userId,
    required this.nickname,
    required this.score,
  });
}
