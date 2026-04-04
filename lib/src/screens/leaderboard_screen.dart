import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/models/score_entry.dart';
import '../core/models/leaderboard_result.dart';
import '../core/services/providers.dart';

class _LeaderboardParams {
  final String gameId;
  final String userId;
  const _LeaderboardParams(this.gameId, this.userId);

  @override
  bool operator ==(Object other) =>
      other is _LeaderboardParams &&
      other.gameId == gameId &&
      other.userId == userId;

  @override
  int get hashCode => Object.hash(gameId, userId);
}

final _leaderboardProvider =
    FutureProvider.family<LeaderboardResult, _LeaderboardParams>((ref, params) {
  return ref
      .read(supabaseServiceProvider)
      .getLeaderboardWithUser(params.gameId, params.userId);
});

class LeaderboardScreen extends ConsumerWidget {
  final String gameId;
  final String gameTitle;
  final String userId;

  const LeaderboardScreen({
    super.key,
    required this.gameId,
    required this.gameTitle,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final params = _LeaderboardParams(gameId, userId);
    final leaderboardAsync = ref.watch(_leaderboardProvider(params));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('$gameTitle — TOP SCORES'),
      ),
      body: leaderboardAsync.when(
        loading: () => Center(
            child: CircularProgressIndicator(color: colors.primary)),
        error: (e, _) => Center(
          child: Text('Failed to load scores',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        data: (result) => _LeaderboardBody(
          result: result,
          userId: userId,
        ),
      ),
    );
  }
}

class _LeaderboardBody extends StatelessWidget {
  final LeaderboardResult result;
  final String userId;

  const _LeaderboardBody({required this.result, required this.userId});

  @override
  Widget build(BuildContext context) {
    final entries = result.topEntries;
    final userEntry = result.userEntry;
    final userInTop = userEntry != null && userEntry.rank <= entries.length;

    return Column(
      children: [
        Expanded(
          child: entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events_outlined,
                          color: context.colors.textSecondary, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'No scores yet.\nBe the first to play!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(overscroll: false),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final isCurrentUser = entry.userId == userId;
                      return _LeaderboardRow(
                        entry: entry,
                        isCurrentUser: isCurrentUser,
                      );
                    },
                  ),
                ),
        ),

        // Pinned personal best section
        _PinnedUserCard(
          userEntry: userEntry,
          userInTop: userInTop,
        ),
      ],
    );
  }
}

class _PinnedUserCard extends StatelessWidget {
  final ScoreEntry? userEntry;
  final bool userInTop;

  const _PinnedUserCard({required this.userEntry, required this.userInTop});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: colors.textSecondary, size: 14),
              const SizedBox(width: 6),
              Text(
                userInTop ? 'YOUR RANK — IN TOP ${userEntry!.rank <= 20 ? 20 : userEntry!.rank}' : 'YOUR BEST',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          userEntry == null
              ? Text(
                  'Play to get on the board!',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              : _LeaderboardRow(
                  entry: userEntry!,
                  isCurrentUser: true,
                  forcePrimaryHighlight: true,
                ),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final ScoreEntry entry;
  final bool isCurrentUser;
  final bool forcePrimaryHighlight;

  const _LeaderboardRow({
    required this.entry,
    required this.isCurrentUser,
    this.forcePrimaryHighlight = false,
  });

  Color _rankColor(AppColors colors) {
    if (forcePrimaryHighlight || isCurrentUser) return colors.primary;
    switch (entry.rank) {
      case 1:
        return colors.warning;
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return colors.textSecondary;
    }
  }

  String get _rankLabel {
    if (entry.rank == 1 && !forcePrimaryHighlight) return '🥇';
    if (entry.rank == 2 && !forcePrimaryHighlight) return '🥈';
    if (entry.rank == 3 && !forcePrimaryHighlight) return '🥉';
    return '#${entry.rank}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rankColor = _rankColor(colors);
    final highlight = isCurrentUser || forcePrimaryHighlight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: highlight
            ? colors.primary.withValues(alpha: 0.08)
            : entry.rank <= 3
                ? rankColor.withValues(alpha: 0.08)
                : colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight
              ? colors.primary.withValues(alpha: 0.4)
              : entry.rank <= 3
                  ? rankColor.withValues(alpha: 0.3)
                  : colors.border,
          width: highlight ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              _rankLabel,
              style: TextStyle(
                color: rankColor,
                fontWeight: FontWeight.bold,
                fontSize: entry.rank <= 3 && !forcePrimaryHighlight ? 20 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.nickname,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: highlight || entry.rank == 1
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: highlight
                            ? colors.textPrimary
                            : null,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.gamesPlayed} ${entry.gamesPlayed == 1 ? 'game' : 'games'}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: highlight ? 0.2 : 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: colors.primary.withValues(
                    alpha: highlight ? 0.5 : 0.3),
              ),
            ),
            child: Text(
              '${entry.score} pts',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
