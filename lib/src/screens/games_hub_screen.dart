import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/services/providers.dart';
import '../games/wordle/wordle_screen.dart';
import '../games/memory/memory_screen.dart';
import '../games/invaders/invaders_screen.dart';
import 'leaderboard_screen.dart';
import 'nickname_screen.dart';

class GamesHubScreen extends ConsumerWidget {
  final String userId;

  const GamesHubScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final playerAsync = ref.watch(playerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('PDAX ARCADE'),
        backgroundColor: colors.surface,
        actions: [
          playerAsync.whenOrNull(
            data: (player) => player != null
                ? TextButton.icon(
                    onPressed: () => _openNicknameEdit(context, ref),
                    icon: Icon(Icons.person, color: colors.textSecondary, size: 16),
                    label: Text(
                      player.nickname,
                      style: TextStyle(color: colors.textSecondary, fontSize: 13),
                    ),
                  )
                : const SizedBox.shrink(),
          ) ?? const SizedBox.shrink(),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: colors.textSecondary,
            ),
            tooltip: isDark ? 'Switch to Light' : 'Switch to Dark',
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: playerAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: colors.primary)),
        error: (e, st) {
          debugPrint('[HUB] Profile load error: $e\n$st');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: colors.error, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'Error loading profile\n$e',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.read(playerProvider.notifier).load(userId),
                    child: const Text('RETRY'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (player) {
          if (player == null) {
            return NicknameScreen(
              userId: userId,
              onDone: () => ref.read(playerProvider.notifier).load(userId),
            );
          }
          return _GameGrid(userId: userId, nickname: player.nickname);
        },
      ),
    );
  }

  void _openNicknameEdit(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NicknameScreen(
          userId: userId,
          isEditing: true,
          onDone: () {
            ref.read(playerProvider.notifier).load(userId);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

class _GameGrid extends StatelessWidget {
  final String userId;
  final String nickname;

  const _GameGrid({required this.userId, required this.nickname});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final games = [
      _GameCard(
        id: 'tradle',
        title: 'TRADLE',
        description: 'Guess the 5-letter finance & trading term in 6 tries.',
        icon: Icons.grid_on,
        accentColor: colors.success,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => WordleScreen(userId: userId, nickname: nickname),
        )),
        onLeaderboard: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => LeaderboardScreen(gameId: 'tradle', gameTitle: 'TRADLE', userId: userId),
        )),
      ),
      _GameCard(
        id: 'memory',
        title: 'MEMORY GRID',
        description: 'Memorize the tiles. Recall them. Survive.',
        icon: Icons.grid_view,
        accentColor: colors.warning,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => MemoryScreen(userId: userId, nickname: nickname),
        )),
        onLeaderboard: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => LeaderboardScreen(
            gameId: 'memory',
            gameTitle: 'MEMORY GRID',
            userId: userId,
          ),
        )),
      ),
      _GameCard(
        id: 'invaders',
        title: 'INVADERS',
        description: 'Defend against waves of enemies across 3 stages.',
        icon: Icons.rocket_launch,
        accentColor: colors.error,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => InvadersScreen(userId: userId, nickname: nickname),
        )),
        onLeaderboard: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => LeaderboardScreen(
            gameId: 'invaders',
            gameTitle: 'INVADERS',
            userId: userId,
          ),
        )),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'SELECT A GAME',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                letterSpacing: 2,
                fontSize: 12,
              ),
        ),
        const SizedBox(height: 16),
        ...games,
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback onLeaderboard;

  const _GameCard({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    required this.onLeaderboard,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: accentColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    letterSpacing: 1.5,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(description, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              ...[
                const SizedBox(height: 16),
                Divider(color: colors.border, height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                        child: const Text('PLAY'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: onLeaderboard,
                      icon: const Icon(Icons.leaderboard, size: 16),
                      label: const Text('Scores'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textSecondary,
                        side: BorderSide(color: colors.border),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
