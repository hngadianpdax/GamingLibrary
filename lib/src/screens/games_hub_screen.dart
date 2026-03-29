import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/services/providers.dart';
import '../games/wordle/wordle_screen.dart';
import 'leaderboard_screen.dart';
import 'nickname_screen.dart';

class GamesHubScreen extends ConsumerWidget {
  final String userId;

  const GamesHubScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('GAME ARCADE'),
        backgroundColor: AppColors.surface,
        actions: [
          playerAsync.whenOrNull(
            data: (player) => player != null
                ? TextButton.icon(
                    onPressed: () => _openNicknameEdit(context, ref),
                    icon: const Icon(Icons.person, color: AppColors.textSecondary, size: 16),
                    label: Text(
                      player.nickname,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  )
                : const SizedBox.shrink(),
          ) ?? const SizedBox.shrink(),
          const SizedBox(width: 8),
        ],
      ),
      body: playerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Text('Error loading profile', style: Theme.of(context).textTheme.bodyMedium),
        ),
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
    final games = [
      _GameCard(
        id: 'wordle',
        title: 'CRYPTODLE',
        description: 'Guess the 5-letter crypto term in 6 tries.',
        icon: Icons.grid_on,
        accentColor: AppColors.success,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => WordleScreen(userId: userId, nickname: nickname),
        )),
        onLeaderboard: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => LeaderboardScreen(gameId: 'wordle', gameTitle: 'CRYPTODLE'),
        )),
      ),
      _GameCard(
        id: 'memory',
        title: 'MEMORY GRID',
        description: 'Memorize the tiles. Recall them. Survive.',
        icon: Icons.grid_view,
        accentColor: AppColors.warning,
        comingSoon: true,
        onTap: () {},
        onLeaderboard: () {},
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
  final bool comingSoon;
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
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: comingSoon ? null : onTap,
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
                            if (comingSoon) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                                ),
                                child: const Text(
                                  'SOON',
                                  style: TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(description, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              if (!comingSoon) ...[
                const SizedBox(height: 16),
                const Divider(color: AppColors.border, height: 1),
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
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
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
