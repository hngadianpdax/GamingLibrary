import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';
import 'supabase_service.dart';

// ── Theme mode ────────────────────────────────────────────────────────────────

const _themePrefKey = 'arcade_theme_mode';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themePrefKey);
    if (saved == 'light') state = ThemeMode.light;
  }

  Future<void> toggle() async {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePrefKey, state == ThemeMode.dark ? 'dark' : 'light');
  }
}

final supabaseServiceProvider = Provider<SupabaseService>((ref) => SupabaseService());

/// Holds the current user's player profile (nullable until loaded).
final playerProvider = StateNotifierProvider<PlayerNotifier, AsyncValue<Player?>>((ref) {
  return PlayerNotifier(ref.read(supabaseServiceProvider));
});

class PlayerNotifier extends StateNotifier<AsyncValue<Player?>> {
  final SupabaseService _service;

  PlayerNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> load(String userId) async {
    state = const AsyncValue.loading();
    try {
      final player = await _service.getPlayer(userId);
      state = AsyncValue.data(player);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> createOrUpdate({
    required String userId,
    required String nickname,
    bool isUpdate = false,
  }) async {
    try {
      final Player player;
      if (isUpdate) {
        player = await _service.updateNickname(userId, nickname);
      } else {
        player = await _service.createPlayer(userId, nickname);
      }
      state = AsyncValue.data(player);
      return true;
    } catch (_) {
      return false;
    }
  }
}
