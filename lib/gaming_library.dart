import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/services/supabase_service.dart';
import 'src/core/services/providers.dart';
import 'src/screens/games_hub_screen.dart';

export 'src/core/theme/app_theme.dart';

/// Main entry point. Call this from your app's homepage button.
///
/// Example:
/// ```dart
/// ElevatedButton(
///   onPressed: () => GamingLibrary.launch(context, userId: user.id),
///   child: Text('Play Games'),
/// )
/// ```
class GamingLibrary {
  /// Initializes Supabase and opens the Games Hub.
  /// [userId] — the authenticated user's ID from your main app.
  static Future<void> launch(BuildContext context, {required String userId}) async {
    await SupabaseService.initialize();

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProviderScope(
          overrides: [],
          child: _GamingLibraryApp(userId: userId),
        ),
      ),
    );
  }
}

class _GamingLibraryApp extends ConsumerWidget {
  final String userId;

  const _GamingLibraryApp({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Load player profile on first render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerProvider.notifier).load(userId);
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: GamesHubScreen(userId: userId),
    );
  }
}
