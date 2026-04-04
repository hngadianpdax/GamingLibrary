import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/player.dart';
import '../models/score_entry.dart';
import '../models/leaderboard_result.dart';

class SupabaseService {
  final Map<String, int?> _personalBestCache = {};
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
    _personalBestCache.remove('$userId:$gameId');
  }

  /// Fetches scores for [gameId], aggregates per player, and returns two
  /// ranked lists — one by average score per game, one by total score.
  Future<LeaderboardResult> getLeaderboardWithUser(
    String gameId,
    String userId, {
    int topN = 20,
  }) async {
    final rows = await client
        .from('leaderboard')
        .select('user_id, score, game_id, player_profiles(nickname)')
        .eq('game_id', gameId)
        .order('score', ascending: false)
        .limit(500);

    // Aggregate per player
    final Map<String, _UserAgg> agg = {};
    for (final row in rows as List) {
      final uid = row['user_id'] as String;
      final pts = row['score'] as int;
      final nick =
          (row['player_profiles'] as Map?)?['nickname'] as String? ?? 'Unknown';
      if (agg.containsKey(uid)) {
        agg[uid]!.score += pts;
        agg[uid]!.gamesPlayed++;
      } else {
        agg[uid] = _UserAgg(userId: uid, nickname: nick, score: pts);
      }
    }

    final players = agg.values.toList();

    // ── By average (score / gamesPlayed) ─────────────────────────────────────
    final byAvg = List<_UserAgg>.from(players)
      ..sort((a, b) {
        final cmp = (b.score / b.gamesPlayed).compareTo(a.score / a.gamesPlayed);
        return cmp != 0 ? cmp : a.gamesPlayed.compareTo(b.gamesPlayed);
      });

    final allByAvg = byAvg.asMap().entries.map((e) => ScoreEntry(
          userId: e.value.userId,
          nickname: e.value.nickname,
          gameId: gameId,
          score: e.value.score,
          gamesPlayed: e.value.gamesPlayed,
          rank: e.key + 1,
        )).toList();

    // ── By total score ────────────────────────────────────────────────────────
    final byTotal = List<_UserAgg>.from(players)
      ..sort((a, b) => b.score.compareTo(a.score));

    final allByTotal = byTotal.asMap().entries.map((e) => ScoreEntry(
          userId: e.value.userId,
          nickname: e.value.nickname,
          gameId: gameId,
          score: e.value.score,
          gamesPlayed: e.value.gamesPlayed,
          rank: e.key + 1,
        )).toList();

    ScoreEntry? userByAvg;
    ScoreEntry? userByTotal;
    for (final entry in allByAvg) {
      if (entry.userId == userId) {
        userByAvg = entry;
        break;
      }
    }
    for (final entry in allByTotal) {
      if (entry.userId == userId) {
        userByTotal = entry;
        break;
      }
    }

    return LeaderboardResult(
      topByAverage: allByAvg.take(topN).toList(),
      topByTotal: allByTotal.take(topN).toList(),
      userEntryByAverage: userByAvg,
      userEntryByTotal: userByTotal,
    );
  }

  /// Returns the cumulative total score for a player across all their games.
  /// Result is cached for the session and invalidated after [submitScore].
  Future<int?> getPersonalBest(String userId, String gameId) async {
    final key = '$userId:$gameId';
    if (_personalBestCache.containsKey(key)) return _personalBestCache[key];

    final rows = await client
        .from('leaderboard')
        .select('score')
        .eq('user_id', userId)
        .eq('game_id', gameId);

    final result = (rows as List).isEmpty
        ? null
        : rows.fold<int>(0, (sum, row) => sum + (row['score'] as int));

    _personalBestCache[key] = result;
    return result;
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
