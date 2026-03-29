import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/player.dart';
import '../models/score_entry.dart';

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

  Future<List<ScoreEntry>> getLeaderboard(String gameId, {int limit = 10}) async {
    final response = await client
        .from('leaderboard')
        .select('*, player_profiles(nickname)')
        .eq('game_id', gameId)
        .order('score', ascending: false)
        .limit(limit);
    return (response as List).map((e) => ScoreEntry.fromJson(e)).toList();
  }

  Future<int?> getPersonalBest(String userId, String gameId) async {
    final response = await client
        .from('leaderboard')
        .select('score')
        .eq('user_id', userId)
        .eq('game_id', gameId)
        .order('score', ascending: false)
        .limit(1)
        .maybeSingle();
    return response?['score'] as int?;
  }
}
