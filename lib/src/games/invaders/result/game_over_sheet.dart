import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../games/wordle/result/ad_banner_carousel.dart';
import '../invaders_game.dart';

class InvadersGameOverSheet extends StatelessWidget {
  final InvadersGame game;
  final String userId;
  final String nickname;
  final VoidCallback onPlayAgain;
  final VoidCallback onLeaderboard;

  const InvadersGameOverSheet({
    super.key,
    required this.game,
    required this.userId,
    required this.nickname,
    required this.onPlayAgain,
    required this.onLeaderboard,
  });

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

          Text(
            'GAME OVER',
            style: TextStyle(
              color: colors.error,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 20),

          _StatRow(label: 'FINAL SCORE', value: '${game.score} pts'),
          const SizedBox(height: 8),
          _StatRow(
            label: 'STAGE REACHED',
            value: '${game.stageIndex + 1} / ${game.totalStages}',
          ),
          const SizedBox(height: 8),
          _StatRow(
            label: 'WAVE REACHED',
            value: '${game.waveIndex + 1} / ${game.totalWaves}',
          ),
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

  const _StatRow({required this.label, required this.value});

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
                color: colors.warning,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
