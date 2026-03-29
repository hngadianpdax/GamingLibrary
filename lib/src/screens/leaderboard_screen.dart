import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/models/score_entry.dart';
import '../core/services/providers.dart';

final _leaderboardProvider =
    FutureProvider.family<List<ScoreEntry>, String>((ref, gameId) {
  return ref.read(supabaseServiceProvider).getLeaderboard(gameId);
});

class LeaderboardScreen extends ConsumerWidget {
  final String gameId;
  final String gameTitle;

  const LeaderboardScreen({
    super.key,
    required this.gameId,
    required this.gameTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(_leaderboardProvider(gameId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('$gameTitle — TOP SCORES'),
      ),
      body: leaderboardAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Text('Failed to load scores',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events_outlined,
                      color: AppColors.textSecondary, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'No scores yet.\nBe the first to play!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: entries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _LeaderboardRow(rank: index + 1, entry: entries[index]);
            },
          );
        },
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final ScoreEntry entry;

  const _LeaderboardRow({required this.rank, required this.entry});

  Color get _rankColor {
    switch (rank) {
      case 1:
        return AppColors.warning;
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: rank <= 3 ? _rankColor.withValues(alpha: 0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: rank <= 3 ? _rankColor.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              rank <= 3 ? _medalEmoji(rank) : '#$rank',
              style: TextStyle(
                color: _rankColor,
                fontWeight: FontWeight.bold,
                fontSize: rank <= 3 ? 20 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.nickname,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: rank == 1 ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${entry.score} pts',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _medalEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }
}
