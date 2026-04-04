import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../games/wordle/result/ad_banner_carousel.dart';
import '../invaders_game.dart';

class VictorySheet extends StatelessWidget {
  final InvadersGame game;
  final VoidCallback onPlayAgain;
  final VoidCallback onLeaderboard;

  const VictorySheet({
    super.key,
    required this.game,
    required this.onPlayAgain,
    required this.onLeaderboard,
  });

  bool get _perfectClear => game.lives == 3;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          if (_perfectClear) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.warning),
              ),
              child: Text(
                'PERFECT CLEAR',
                style: TextStyle(
                  color: colors.warning,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          Text(
            'VICTORY!',
            style: TextStyle(
              color: colors.success,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ALL STAGES CLEARED',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),

          _StatRow(label: 'FINAL SCORE', value: '${game.score} pts'),
          const SizedBox(height: 8),
          _StatRow(
            label: 'LIVES REMAINING',
            value: '${game.lives} / 3',
            valueColor: colors.error,
          ),
          if (_perfectClear) ...[
            const SizedBox(height: 8),
            _StatRow(
              label: 'PERFECT CLEAR BONUS',
              value: '+300 pts',
              valueColor: colors.warning,
            ),
          ],
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onPlayAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'PLAY AGAIN',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const AdBannerCarousel(),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                letterSpacing: 1)),
        Text(value,
            style: TextStyle(
                color: valueColor ?? colors.warning,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
