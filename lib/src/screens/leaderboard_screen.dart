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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text('$gameTitle — RANKINGS'),
          bottom: TabBar(
            indicatorColor: colors.primary,
            labelColor: colors.primary,
            unselectedLabelColor: colors.textSecondary,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              letterSpacing: 1,
            ),
            tabs: const [
              Tab(text: 'HIGHEST AVG'),
              Tab(text: 'HIGHEST TOTAL'),
            ],
          ),
        ),
        body: leaderboardAsync.when(
          loading: () =>
              Center(child: CircularProgressIndicator(color: colors.primary)),
          error: (e, _) => Center(
            child: Text(
              'Failed to load scores',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          data: (result) => TabBarView(
            children: [
              _LeaderboardTab(
                entries: result.topByAverage,
                userEntry: result.userEntryByAverage,
                userId: userId,
                mode: _TabMode.average,
              ),
              _LeaderboardTab(
                entries: result.topByTotal,
                userEntry: result.userEntryByTotal,
                userId: userId,
                mode: _TabMode.total,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tab mode ──────────────────────────────────────────────────────────────────

enum _TabMode { average, total }

// ── Tab body ──────────────────────────────────────────────────────────────────

class _LeaderboardTab extends StatelessWidget {
  final List<ScoreEntry> entries;
  final ScoreEntry? userEntry;
  final String userId;
  final _TabMode mode;

  const _LeaderboardTab({
    required this.entries,
    required this.userEntry,
    required this.userId,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final userInTop =
        userEntry != null && entries.any((e) => e.userId == userId);

    return Column(
      children: [
        // Ranking criterion hint
        Container(
          width: double.infinity,
          color: colors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            mode == _TabMode.average
                ? 'Ranked by highest score per game played'
                : 'Ranked by cumulative total score',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
        ),

        Expanded(
          child: entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events_outlined,
                          color: colors.textSecondary, size: 48),
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
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _LeaderboardRow(
                        entry: entry,
                        isCurrentUser: entry.userId == userId,
                        mode: mode,
                      );
                    },
                  ),
                ),
        ),

        // Pinned personal card
        _PinnedUserCard(
          userEntry: userEntry,
          userInTop: userInTop,
          userId: userId,
          mode: mode,
        ),
      ],
    );
  }
}

// ── Pinned user card ──────────────────────────────────────────────────────────

class _PinnedUserCard extends StatelessWidget {
  final ScoreEntry? userEntry;
  final bool userInTop;
  final String userId;
  final _TabMode mode;

  const _PinnedUserCard({
    required this.userEntry,
    required this.userInTop,
    required this.userId,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = mode == _TabMode.average ? 'YOUR AVG RANK' : 'YOUR TOTAL RANK';

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
                label,
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
                  mode: mode,
                  forcePrimaryHighlight: true,
                ),
        ],
      ),
    );
  }
}

// ── Row ───────────────────────────────────────────────────────────────────────

class _LeaderboardRow extends StatelessWidget {
  final ScoreEntry entry;
  final bool isCurrentUser;
  final _TabMode mode;
  final bool forcePrimaryHighlight;

  const _LeaderboardRow({
    required this.entry,
    required this.isCurrentUser,
    required this.mode,
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
    final avg = entry.avgScore.round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          // Rank
          SizedBox(
            width: 36,
            child: Text(
              _rankLabel,
              style: TextStyle(
                color: rankColor,
                fontWeight: FontWeight.bold,
                fontSize:
                    entry.rank <= 3 && !forcePrimaryHighlight ? 20 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),

          // Nickname + stats chips
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
                        color: highlight ? colors.textPrimary : null,
                      ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _StatChip(
                      label:
                          '${entry.gamesPlayed} ${entry.gamesPlayed == 1 ? 'game' : 'games'}',
                      color: colors.textSecondary,
                      bgColor: colors.surfaceElevated,
                    ),
                    const SizedBox(width: 6),
                    _StatChip(
                      label: '$avg avg/game',
                      color: entry.rank <= 3 && !forcePrimaryHighlight
                          ? colors.warning
                          : colors.textSecondary,
                      bgColor: entry.rank <= 3 && !forcePrimaryHighlight
                          ? colors.warning.withValues(alpha: 0.12)
                          : colors.surfaceElevated,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Primary stat — swaps based on tab
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (mode == _TabMode.average) ...[
                Text(
                  '$avg pts',
                  style: TextStyle(
                    color: highlight ? colors.primary : rankColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'avg/game',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ] else ...[
                Text(
                  '${entry.score}',
                  style: TextStyle(
                    color: highlight ? colors.primary : rankColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'total pts',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Stat chip ─────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const _StatChip({
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
