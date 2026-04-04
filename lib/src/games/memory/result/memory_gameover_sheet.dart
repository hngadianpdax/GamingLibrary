import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/providers.dart';
import '../memory_game.dart';
import '../../wordle/result/ad_banner_carousel.dart';

class MemoryGameOverSheet extends ConsumerStatefulWidget {
  final MemoryGame game;
  final String userId;
  final VoidCallback onPlayAgain;
  final VoidCallback onLeaderboard;

  const MemoryGameOverSheet({
    super.key,
    required this.game,
    required this.userId,
    required this.onPlayAgain,
    required this.onLeaderboard,
  });

  @override
  ConsumerState<MemoryGameOverSheet> createState() =>
      _MemoryGameOverSheetState();
}

class _MemoryGameOverSheetState extends ConsumerState<MemoryGameOverSheet> {
  int? _cumulativeTotal;

  @override
  void initState() {
    super.initState();
    _loadTotal();
  }

  Future<void> _loadTotal() async {
    final score = await ref
        .read(supabaseServiceProvider)
        .getPersonalBest(widget.userId, 'memory');
    if (mounted) setState(() => _cumulativeTotal = score);
  }

  String get _headline {
    switch (widget.game.gameOverReason) {
      case GameOverReason.sessionComplete:
        return 'SESSION\nCOMPLETE!';
      case GameOverReason.timerExpired:
        return "TIME'S UP!";
      case GameOverReason.livesExhausted:
      default:
        return 'GAME OVER';
    }
  }

  Color _headlineColor(AppColors colors) {
    switch (widget.game.gameOverReason) {
      case GameOverReason.sessionComplete:
        return colors.success;
      case GameOverReason.timerExpired:
        return colors.warning;
      default:
        return colors.error;
    }
  }

  String get _subtitle {
    switch (widget.game.gameOverReason) {
      case GameOverReason.sessionComplete:
        return 'You conquered all 25 levels!';
      case GameOverReason.timerExpired:
        return 'The clock ran out on level ${widget.game.level}.';
      default:
        return 'You ran out of lives on level ${widget.game.level}.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final game = widget.game;
    final finalScore = game.totalScore + game.levelScore;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Headline
            Text(
              _headline,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _headlineColor(colors),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            // Stats card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                children: [
                  _StatRow(
                    label: 'LEVEL REACHED',
                    value: '${game.level} / ${MemoryGame.maxLevel}',
                    color: colors.primary,
                  ),
                  const SizedBox(height: 8),
                  _StatRow(
                    label: 'BEST STREAK',
                    value: '${game.bestStreak} tiles',
                    color: game.bestStreak >= 15
                        ? colors.warning
                        : colors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  _LivesRow(lives: game.lives),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: colors.border, height: 1),
                  ),
                  _StatRow(
                    label: 'FINAL SCORE',
                    value: '$finalScore pts',
                    color: colors.warning,
                    bold: true,
                    large: true,
                  ),
                  const SizedBox(height: 8),
                  _StatRow(
                    label: 'YOUR ALL-TIME TOTAL',
                    value: _cumulativeTotal != null
                        ? '$_cumulativeTotal pts'
                        : '— pts',
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onPlayAgain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                    ),
                    child: const Text('PLAY AGAIN'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onLeaderboard,
                    icon: const Icon(Icons.leaderboard, size: 16),
                    label: const Text('LEADERBOARD'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textSecondary,
                      side: BorderSide(color: colors.border),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Ad section
            Divider(color: colors.border, height: 1),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'SPONSORED',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 9,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const AdBannerCarousel(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool bold;
  final bool large;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: large ? 13 : 12,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: large ? 16 : 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LivesRow extends StatelessWidget {
  final int lives;

  const _LivesRow({required this.lives});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            'LIVES REMAINING',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Row(
          children: List.generate(MemoryGame.startingLives, (i) {
            return Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                i < lives ? Icons.favorite : Icons.favorite_border,
                color: i < lives ? colors.error : colors.border,
                size: 18,
              ),
            );
          }),
        ),
      ],
    );
  }
}
