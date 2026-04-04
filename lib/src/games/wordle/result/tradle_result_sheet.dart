import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/providers.dart';
import '../wordle_game.dart';
import 'ad_banner_carousel.dart';

class TradleResultSheet extends ConsumerStatefulWidget {
  final WordleGame game;
  final String userId;
  final String nickname;
  final VoidCallback onPlayAgain;
  final VoidCallback onLeaderboard;

  const TradleResultSheet({
    super.key,
    required this.game,
    required this.userId,
    required this.nickname,
    required this.onPlayAgain,
    required this.onLeaderboard,
  });

  @override
  ConsumerState<TradleResultSheet> createState() => _TradleResultSheetState();
}

class _TradleResultSheetState extends ConsumerState<TradleResultSheet> {
  int? _cumulativeScore;

  @override
  void initState() {
    super.initState();
    _loadCumulativeScore();
  }

  Future<void> _loadCumulativeScore() async {
    final score = await ref
        .read(supabaseServiceProvider)
        .getPersonalBest(widget.userId, 'tradle');
    if (mounted) setState(() => _cumulativeScore = score);
  }

  bool get _won => widget.game.status == GameStatus.won;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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

            // Result headline
            Text(
              _won ? 'YOU GOT IT!' : 'BETTER LUCK\nNEXT TIME',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _won ? colors.success : colors.error,
                fontSize: _won ? 28 : 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            // Revealed word tiles
            _RevealedWord(word: widget.game.targetWord),
            const SizedBox(height: 20),

            // Score breakdown (win only)
            if (_won) ...[
              _ScoreBreakdown(
                game: widget.game,
                cumulativeScore: _cumulativeScore,
              ),
              const SizedBox(height: 20),
            ] else ...[
              Text(
                'The answer was',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onPlayAgain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _won ? colors.success : colors.primary,
                    ),
                    child: const Text('PLAY AGAIN'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onLeaderboard,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textSecondary,
                      side: BorderSide(color: colors.border),
                    ),
                    child: const Text('LEADERBOARD'),
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

class _RevealedWord extends StatelessWidget {
  final String word;

  const _RevealedWord({required this.word});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: word.toUpperCase().split('').map((letter) {
        return Container(
          width: 46,
          height: 46,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: colors.success,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ScoreBreakdown extends StatelessWidget {
  final WordleGame game;
  final int? cumulativeScore;

  const _ScoreBreakdown({required this.game, required this.cumulativeScore});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          _ScoreRow(
            label: 'ATTEMPTS',
            value: '${game.currentRow - 1}/6',
            color: colors.textSecondary,
          ),
          const SizedBox(height: 8),
          _ScoreRow(
            label: 'ATTEMPT SCORE',
            value: '+${game.attemptScore} pts',
            color: colors.success,
          ),
          const SizedBox(height: 8),
          _ScoreRow(
            label: 'TIME BONUS',
            value: '+${game.timeBonus} pts',
            color: colors.warning,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: colors.border, height: 1),
          ),
          _ScoreRow(
            label: 'THIS GAME',
            value: '${game.score} pts',
            color: colors.primary,
            bold: true,
            large: true,
          ),
          if (cumulativeScore != null) ...[
            const SizedBox(height: 8),
            _ScoreRow(
              label: 'YOUR TOTAL',
              value: '$cumulativeScore pts',
              color: colors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool bold;
  final bool large;

  const _ScoreRow({
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
