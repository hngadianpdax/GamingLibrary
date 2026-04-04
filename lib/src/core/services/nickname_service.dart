import 'package:shared_preferences/shared_preferences.dart';

class NicknameService {
  static const _key = 'gaming_library_nickname';
  static final _validPattern = RegExp(r'^[a-zA-Z0-9_]+$');

  static Future<String?> getCachedNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> cacheNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, nickname);
  }

  static Future<void> clearCachedNickname() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Returns true if the nickname contains restricted words.
  static bool isRestricted(String nickname) {
    // TODO: expand this list — tracked in project todos
    const blocklist = <String>[
      'admin', 'moderator', 'system', 'null', 'undefined',
    ];
    final lower = nickname.toLowerCase();
    return blocklist.any((word) => lower.contains(word));
  }

  static String? validate(String nickname) {
    final trimmed = nickname.trim();
    if (trimmed.length < 3) return 'Nickname must be at least 3 characters.';
    if (trimmed.length > 20) return 'Nickname must be 20 characters or less.';
    if (!_validPattern.hasMatch(trimmed)) {
      return 'Only letters, numbers, and underscores allowed.';
    }
    if (isRestricted(trimmed)) return 'That nickname is not allowed.';
    return null;
  }
}
